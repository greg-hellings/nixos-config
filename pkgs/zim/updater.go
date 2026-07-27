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
	"reflect"
	"regexp"
	"sort"
	"strings"
)

const BASE = "https://download.kiwix.org/zim"

// ///////////////////////////////////////////////////////////////////////////
// ////////////////  THE BLOB ITSELF /////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////
type Blobs struct {
	En    Language `json:"en"`
	Fr    Language `json:"fr"`
	Ht    Language `json:"ht"`
	dirty bool
}

func (b *Blobs) Populate() {
	done := make(chan bool)
	waitFor := 0
	// Launch self-populating efforts
	blobType := reflect.Indirect(reflect.ValueOf(b)).Type()
	for f := range blobType.Fields() {
		if f.IsExported() {
			//fmt.Printf("%s:\tBeginning population efforts\n", f.Name)
			waitFor += 1
			go reflect.Indirect(reflect.ValueOf(b)).
				FieldByName(f.Name).
				Addr().
				Interface().
				(*Language).
				Populate(strings.ToLower(f.Name), done)
		}
	}
	// Wait until all languages are completed
	for d := range done {
		waitFor -= 1
		if waitFor == 0 {
			fmt.Println("Completed waiting for all languages")
			close(done)
			break
		}
		b.dirty = b.dirty || d
	}
}

/////////////////////////////////////////////////////////////////////////////
//////////////////////// The Language ///////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

type Language struct {
	Gutenberg   *Zim `json:"gutenberg,omitempty"`
	Phet        *Zim `json:"phet,omitempty"`
	Ted         *Zim `json:"ted,omitempty"`
	Wikibooks   *Zim `json:"wikibooks,omitempty"`
	Wikipedia   *Zim `json:"wikipedia,omitempty"`
	Wikisource  *Zim `json:"wikisource,omitempty"`
	Wikiversity *Zim `json:"wikiversity,omitempty"`
	Wiktionary  *Zim `json:"wiktionary,omitempty"`
	dirty       bool
}

func (l *Language) Populate(code string, done chan bool) {
	childDone := make(chan bool)
	waitFor := 0
	languageType := reflect.Indirect(reflect.ValueOf(l)).Type()
	l.dirty = false
	for f := range languageType.Fields() {
		if f.IsExported() {
			ptrPtrZim := reflect.Indirect(reflect.ValueOf(l)).
			    FieldByName(f.Name)
			if ptrPtrZim.IsValid() && !ptrPtrZim.IsNil() {
				waitFor += 1
				go reflect.Indirect(ptrPtrZim).
				    Addr().
				    Interface().
				    (*Zim).
				    Populate(strings.ToLower(f.Name), code, childDone)
			} else {
				// TODO: Figure out how to set a value over the nil pointer
				// of the field, so we can auto-detect when these are available
				// in the future
				// waitFor += 1
				//z := &Zim{Name: f.Name, Version: "1999-01-01", Hash: ""}
				//ptrPtrZim.Set(reflect.ValueOf(z))
				//go z.Populate(strings.ToLower(f.Name), code, childDone)
			}
		}
	}
	// Wait until children are all done
	for d := range childDone {
		waitFor -= 1
		if waitFor == 0 {
			close(childDone)
			break
		}
		l.dirty = l.dirty || d
	}

	//fmt.Printf("%s\tFinished populate\n", code)
	done <- l.dirty
}

// ///////////////////////////////////////////////////////////////////////////
// ////////////////////// A Single Zim ///////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////
type Zim struct {
	Name    string `json:"name"`
	Version string `json:"version"`
	Hash    string `json:"hash"`
	dirty   bool
}

func (z *Zim) Populate(category string, language string, done chan bool) {
	//fmt.Printf("%s:%s\tBeginning populate for\n", language, category)
	// Look for a possible Zim file
	links := getLinks(getPage(category))
	link, err := getName(links, category, language)
	if err != nil {
		fmt.Printf("%s:%s\tNo zim found\n", language, category)
		done <- false
		return
	}
	//fmt.Printf("%s:%s\tFound link: %s\n", category, language, link)
	// Extract name and version
	re := regexp.MustCompilePOSIX("^([a-zA-Z_]+)_([0-9-]+)\\.zim$")
	match := re.FindStringSubmatch(link)
	if len(match) != 3 {
		fmt.Printf("%s:%s Matches: %s", language, category, match)
		os.Exit(1)
	}
	// Check if the name and version mismatch
	if match[1] == z.Name && match[2] == z.Version {
		fmt.Printf("Skipping existing hash: %s\n", link)
		done <- false
	} else {
		z.Name = match[1]
		z.Version = match[2]
		// Fetch the Zim file, if it differs from what we currently have
		z.UpdateHash(category)
		done <- true
	}
}

// Helper function to fetch the HTML of a given type page
func getPage(t string) string {
	page, err := http.Get(fmt.Sprintf("%s/%s/", BASE, t))
	if err != nil {
		panic(err)
	}
	defer page.Body.Close()
	pageBytes, _ := io.ReadAll(page.Body)
	return string(pageBytes)
}

// Helper function to parse out all the links from the page
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

// Helper function to get the most likely link for this particular entry
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

// Helper function to get the hash value from the resulting link
func (z *Zim) UpdateHash(category string) error {
	file := fmt.Sprintf("%s_%s.zim", z.Name, z.Version)

	// First fetch the file into our local Nix store
	fmt.Printf("Fetching hash: %s\n", file)
	cmd := exec.Command("nix-prefetch-url", fmt.Sprintf("%s/%s/%s", BASE, category, file))
	out, err := cmd.Output()
	if err != nil {
		fmt.Printf("%s: ERROR fetching hash: %v\n", file, err)
		if exitErr, ok := err.(*exec.ExitError); ok {
			fmt.Printf("Command stderr: %s\n", string(exitErr.Stderr))
		}
		return errors.New("Error fetching file")
	}
	hash := strings.TrimSpace(string(out))
	fmt.Printf("%s: Successfully fetched raw hash\n", file)
	fmt.Printf("%s: Hash is: %s\n", file, hash)

	// Then, convert the hash to SRI
	cmd2 := exec.Command("nix", "hash", "convert", "--to", "sri", hash, "--hash-algo", "sha256")
	out2, err2 := cmd2.Output()
	if err2 != nil {
		fmt.Printf("%s: Error converting hash to SRI: %v\n", file, err)
		if exitErr, ok := err.(*exec.ExitError); ok {
			fmt.Printf("%s: Command stderr: %s\n", file, string(exitErr.Stderr))
		}
		return errors.New("Error fetching file")
	}
	z.Hash = strings.TrimSpace(string(out2))
	z.dirty = true
	fmt.Printf("%s: Successfully convert hash to SRI: %s", file, out2)
	return nil
}

func main() {
	outputFile := flag.String("output", "", "Output file path (default: blobs.json in same directory as updater.go)")
	flag.Parse()

	// Determine the output file path
	var outputPath string
	outputPath = *outputFile

	fmt.Println("Writing file to ", outputPath)

	// Read existing cache if it exists
	var blobs Blobs
	if data, err := os.ReadFile(outputPath); err == nil {
		if err := json.Unmarshal(data, &blobs); err != nil {
			fmt.Printf("Warning: could not parse existing cache file: %v\n", err)
		} else {
			fmt.Printf("Loaded existing cache from %s\n", outputPath)
		}
	} else {
		fmt.Printf("Error reading file: %s", err)
		os.Exit(1)
	}
	blobs.Populate()

	ret, err := json.MarshalIndent(&blobs, "", "  ")
	if err != nil {
		fmt.Printf("Error marshaling JSON: %v\n", err)
		os.Exit(1)
	}

	err = os.WriteFile(outputPath, []byte(fmt.Sprintf("%s\n", ret)), 0644)
	if err != nil {
		fmt.Printf("Error writing to file %s: %v\n", outputPath, err)
		os.Exit(1)
	}

	fmt.Printf("Successfully wrote output to %s\n", outputPath)
	fmt.Println(string(ret))
}
