package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os/exec"
	"regexp"
	"sort"
	"strings"
)

const BASE = "https://download.kiwix.org/zim"

func getTypes() []string {
	return []string{
		"wikipedia",
		"wiktionary",
		"wikiversity",
		"wikisource",
		"wikibooks",
		"gutenberg",
		"phet",
		"ted",
	}
}

func getLanguages() []string {
	return []string{
		"en",
		"fr",
		"ht",
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
		fmt.Sprintf(`fetchtorrent {
            url="%s/%s/%s.torrent";
            hash="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
            backend="rqbit";
        }`, BASE, category, file),
	)
	out, err := cmd.Output()
	if err != nil {
		panic(err)
	}
	ch <- result{category, language, strings.TrimSpace(string(out))}
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
	output := make(map[string]map[string]Zim)
	comms := make(chan result)

	for _, t := range getTypes() {
		page := getPage(t)
		links := getLinks(page)
		for _, lang := range getLanguages() {
			if file, err := getName(links, t, lang); err == nil {
				if _, ok := output[lang]; !ok {
					output[lang] = make(map[string]Zim)
				}
				output[lang][t] = Zim{file, ""}
				go getHash(comms, file, t, lang)
			}
		}
	}

	for r := range comms {
		if entry, ok := output[r.language][r.category]; ok {
			entry.Hash = r.hash
			output[r.language][r.category] = entry
		}
		if outputIsValid(output) {
			close(comms)
			break
		}
	}
	ret, _ := json.MarshalIndent(output, "  ", "")
	fmt.Println(string(ret))
}
