package main

import (
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
)

const BASE = "https://download.kiwix.org/zim"

func getTypes() []string {
	return []string{
		"phet",
		// "wikipedia",
		// "wiktionary",
		// "wikiversity",
		// "wikisource",
		// "wikibooks",
		"gutenberg",
		"ted",
	}
}

func getLanguages() []string {
	return []string{
		"ht",
		"en",
		"fr",
	}
}

func getPage(t string) string {
	page, err := http.Get(fmt.Sprintf("%s/%s/", BASE, t))
	if err != nil {
		panic(err)
	}
	defer page.Body.Close()
	pageBytes, _ := io.ReadAll(page.Body)
	return string(pageBytes)
}

func getLinks(page string) []string {
	ret := []string{}

	link_href := regexp.MustCompile(`href="(.*?)"`)
	// Is a list of lists
	links := link_href.FindAllStringSubmatch(page, -1)
	for _, link := range links {
		ret = append(ret, link[len(link)-1])
	}
	return ret
}

func getName(links []string, t, lang string) (string, error) {
	candidates := []string{}
	prefix := fmt.Sprintf("%s_%s_all", t, lang)
	for _, link := range links {
		if strings.HasPrefix(link, prefix) {
			if !strings.HasPrefix(link, "wiki") || strings.Contains(link, "maxi") {
				candidates = append(candidates, link)
			}
		}
	}
	sort.Strings(candidates)
	if len(candidates) > 0 {
		ret := candidates[len(candidates)-1]
		return ret, nil
	} else {
		return "", errors.New("Language item not found")
	}
}

func getHash(ch chan result, file, category, language string) {
	// TODO: Only call this if the file doesn't already have a hash
	// in the existing file
	fmt.Printf("Fetching hash for %s\n", file)
	cmd := exec.Command("nix-prefetch",
		"--option",
		"extra-experimental-features",
		"flakes",
		"--check-store",
		fmt.Sprintf(`fetchtorrent {
            url="%s/%s/%s.torrent";
            hash="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
            backend="transmission";
            postUnpack="mkdir -p $downloadedDirectory/tmp; mv $downloadedDirectory/*.zim $downloadedDirectory/tmp";
        }`, BASE, category, file),
	)
	out, err := cmd.Output()
	if err != nil {
		fmt.Printf("Error fetching hash for %s (category: %s, language: %s): %v\n", file, category, language, err)
		if exitErr, ok := err.(*exec.ExitError); ok {
			fmt.Printf("Command stderr: %s\n", string(exitErr.Stderr))
		}
		ch <- result{category, language, ""}
		return
	}
	hash := strings.TrimSpace(string(out))
	fmt.Printf("Successfully fetched hash for %s (category: %s, language: %s)\n", file, category, language)
	ch <- result{category, language, hash}
}

func outputIsValid(o map[string]map[string]Zim) bool {
	for a := range o {
		for b := range o[a] {
			if o[a][b].Hash == "" {
				return false
			}
		}
	}
	return true
}

type result struct {
	category, language, hash string
}

type Zim struct {
	Name string `json:"name"`
	Hash string `json:"hash"`
}

func main() {
	outputFile := flag.String("output", "", "Output file path (default: blobs.json in same directory as updater.go)")
	flag.Parse()

	// Determine the output file path
	var outputPath string
	if *outputFile != "" {
		outputPath = *outputFile
	} else {
		// Get the directory where updater.go is located
		execPath, err := os.Executable()
		if err != nil {
			// Fallback to current directory if we can't determine executable path
			outputPath = "blobs.json"
		} else {
			dir := filepath.Dir(execPath)
			outputPath = filepath.Join(dir, "blobs.json")
		}
	}

	fmt.Println("Writing file to ", outputPath)

	// Read existing cache if it exists
	cached := make(map[string]map[string]Zim)
	if data, err := os.ReadFile(outputPath); err == nil {
		if err := json.Unmarshal(data, &cached); err != nil {
			fmt.Printf("Warning: could not parse existing cache file: %v\n", err)
		} else {
			fmt.Printf("Loaded existing cache from %s\n", outputPath)
		}
	}

	output := make(map[string]map[string]Zim)
	comms := make(chan result)
	pendingHashes := 0

	for _, t := range getTypes() {
		page := getPage(t)
		links := getLinks(page)
		for _, lang := range getLanguages() {
			if file, err := getName(links, t, lang); err == nil {
				if _, ok := output[lang]; !ok {
					output[lang] = make(map[string]Zim)
				}

				// Check if this file already exists in cache with same name
				if cachedLang, ok := cached[lang]; ok {
					if cachedEntry, ok := cachedLang[t]; ok && cachedEntry.Name == file {
						// Reuse cached hash
						fmt.Printf("Using cached hash for %s (category: %s, language: %s)\n", file, t, lang)
						output[lang][t] = cachedEntry
						continue
					}
				}

				// File is new or name has changed, fetch hash
				output[lang][t] = Zim{file, ""}
				pendingHashes++
				go getHash(comms, file, t, lang)
			}
		}
	}

	// Only wait for results if we actually spawned goroutines
	if pendingHashes > 0 {
		hashesReceived := 0
		for r := range comms {
			if entry, ok := output[r.language][r.category]; ok {
				entry.Hash = r.hash
				output[r.language][r.category] = entry
			}
			hashesReceived++
			if hashesReceived >= pendingHashes {
				close(comms)
				break
			}
		}
	}

	// Verify all hashes are present
	if !outputIsValid(output) {
		fmt.Println("Warning: Some hashes are missing from the output")
	}
	ret, err := json.MarshalIndent(output, "", "  ")
	if err != nil {
		fmt.Printf("Error marshaling JSON: %v\n", err)
		os.Exit(1)
	}

	err = os.WriteFile(outputPath, ret, 0644)
	if err != nil {
		fmt.Printf("Error writing to file %s: %v\n", outputPath, err)
		os.Exit(1)
	}

	fmt.Printf("Successfully wrote output to %s\n", outputPath)
	fmt.Println(string(ret))
}
