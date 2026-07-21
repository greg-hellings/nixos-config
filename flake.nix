# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  description = "Greg's machines!";

  inputs = {
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixunstable";
    };
    buildbot = {
      url = "github:nix-community/buildbot-nix";
      inputs.nixpkgs.follows = "nixunstable";
    };
    colmena.url = "github:zhaofengli/colmena";
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixunstable";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    hermes = {
      url = "github:nousresearch/hermes-agent";
      inputs.nixpkgs.follows = "nixunstable";
    };
    hmunstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixunstable";
    };
    minecraft.url = "github:Infinidoge/nix-minecraft";
    niks3.url = "github:Mic92/niks3";
    nix-hardware.url = "github:nixos/nixos-hardware";
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    nixvimunstable.url = "github:nix-community/nixvim/main";
    nixunstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nurpkgs.url = "github:nix-community/NUR";
    vsext.url = "github:nix-community/nix-vscode-extensions";
    wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixunstable";
    };
  };

  outputs =
    { self, ... }@top:
    let
      local_overlay = import ./overlays;
      overlays = [
        top.agenix.overlays.default
        local_overlay
        top.nixvimunstable.overlays.default
        top.nurpkgs.overlays.default
        top.vsext.overlays.default
        top.minecraft.overlay
      ];
      metadata = builtins.fromJSON (builtins.readFile ./network.json);
      systems = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
      ];
      imported_packages = top.nixunstable.lib.genAttrs systems (
        system:
        import top.nixunstable {
          inherit system overlays;
          config = {
            allowUnfree = true;
            allowUnfreePredicate = _: true;
            permittedInsecurePackages = [
              "ventoy-1.1.05"
              "electron-39.8.10"
            ];
          };
        }
      );
      lib' = import ./lib { inherit (top.nixunstable) lib; };
    in
    top.flake-parts.lib.mkFlake { inputs = top; } {
      inherit systems;

      flake = {
        colmenaHive = top.colmena.lib.makeHive (
          {
            meta = {
              nixpkgs = imported_packages.x86_64-linux;
              specialArgs = {
                inherit
                  lib'
                  metadata
                  self
                  top
                  ;
                pkgs' = top.self.packages.x86_64-linux;
              };
            };
          }
          // (builtins.mapAttrs (
            k: v:
            {
              imports = self.nixosConfigurations.${k}._module.args.modules;
            }
            // (
              if builtins.hasAttr "tags" v then
                {
                  deployment = {
                    inherit (v) tags;
                    targetHost = v.ts;
                    targetUser = "greg";
                  };
                }
              else
                { }
            )
          ) (top.nixunstable.lib.filterAttrs (_: v: !(v ? "external") || !v.external) metadata.hosts))
        );

        darwinConfigurations = (
          import ./darwin {
            inherit top metadata;
            nixpkgs = imported_packages;
          }
        );

        nixosConfigurations = (
          import ./hosts {
            inherit top metadata lib';
            nixpkgs = imported_packages;
          }
        );

        homeConfigurations = (
          import ./home {
            inherit top metadata;
            nixpkgs = imported_packages;
          }
        );

        modules = import ./modules;

        overlays.default = local_overlay;
      };

      perSystem =
        {
          pkgs,
          self',
          system,
          ...
        }:
        {
          _module.args = {
            pkgs = imported_packages.${system};
          };

          packages = (import ./pkgs { inherit pkgs top; });

          checks = import ./checks.nix {
            inherit system top self';
            inherit (top.nixpkgs-lib) lib;
          };

          devShells = import ./shells.nix {
            inherit pkgs;
            inherit (top) colmena;
            inherit (self') packages;
          };
        };
    };
}
