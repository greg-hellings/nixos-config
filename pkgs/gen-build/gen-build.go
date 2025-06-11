package main

import (
	"encoding/json"
	"fmt"
	"os/exec"

	"gopkg.in/yaml.v3"
)

type NixFlakeOutput struct {
	Apps                 map[string]interface{} `json:"apps"`
	Checks               map[string]interface{} `json:"checks"`
	DarwinConfigurations ArchTypes              `json:"darwinConfigurations"`
	DevShells            map[string]interface{} `json:"devShells"`
	HomeConfigurations   map[string]interface{} `json:"homeConfigurations"`
	NixosConfigurations  map[string]interface{} `json:"nixosConfigurations"`
	Packages             ArchTypes              `json:"packages"`
}

type ArchTypes struct {
	X86_64    map[string]map[string]string `json:"x86_64-linux"`
	Aarch64   map[string]map[string]string `json:"aarch64-linux"`
	DarwinX86 map[string]map[string]string `json:"x86_64-darwin"`
	DarwinArm map[string]map[string]string `json:"aarch64-darwin"`
}

func GetNixFlakeOutput() (*NixFlakeOutput, error) {
	cmd := exec.Command("nix", "flake", "show", "--json")
	output, err := cmd.Output()
	if err != nil {
		return nil, err
	}

	var flakeOutput NixFlakeOutput
	err = json.Unmarshal(output, &flakeOutput)
	if err != nil {
		return nil, err
	}

	return &flakeOutput, nil
}

type GitlabCIJob struct {
	Stage  string   `json:"stage"`
	Tags   []string `json:"tags"`
	Script []string `json:"script"`
}

func NewGitlabCIJob(target string) GitlabCIJob {
	return GitlabCIJob{
		Stage: "build",
		Tags:  []string{"nix"},
		Script: []string{
			"nix build -L '.#" + target + "'",
		},
	}
}

func main() {
	flakeOutput, err := GetNixFlakeOutput()
	if err != nil {
		panic(err)
	}

	// Some boilerplate that Go requires us to have
	pipeline := make(map[string]interface{})
	pipeline["stages"] = []string{"build"}
	pipeline["Run flake check"] = GitlabCIJob{
		Stage: "build",
		Tags:  []string{"nix"},
		Script: []string{
			"nix flake check --no-build",
		},
	}
	// Since this is kinda a one-off thing, I can use this directly
	// homeConfigurations are treated like they are not known as a
	// flake output type. Therefore, it just informs you that it is
	// part of the output, but does not evaluate deeper to tell you
	// what the name of it is. I will just do this manually for now.
	pipeline["Build Home config "] = NewGitlabCIJob("homeConfigurations.\"greg\".activationPackage")

	if flakeOutput.Apps != nil {
		for appName := range flakeOutput.Apps {
			pipeline[appName] = NewGitlabCIJob("apps." + appName)
		}
	}

	if flakeOutput.Packages.X86_64 != nil {
		for pkgName := range flakeOutput.Packages.X86_64 {
			if flakeOutput.Packages.X86_64[pkgName]["type"] == "derivation" {
				pipeline["Build package "+pkgName] = NewGitlabCIJob("packages.x86_64-linux." + pkgName)
			}
		}
	}

	if flakeOutput.NixosConfigurations != nil {
		for configName := range flakeOutput.NixosConfigurations {
			pipeline["Build NixOS config "+configName] = NewGitlabCIJob("nixosConfigurations." + configName + ".config.system.build.toplevel")
		}
	}

	yamlData, err := yaml.Marshal(pipeline)
	if err != nil {
		panic(err)
	}

	fmt.Printf("%s\n", yamlData)
}
