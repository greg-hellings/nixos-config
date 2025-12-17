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
    btc = {
      url = "github:fort-nix/nix-bitcoin/release";
    };
    buildbot = {
      url = "github:nix-community/buildbot-nix";
      inputs.nixpkgs.follows = "nixunstable";
    };
    charts = {
      url = "github:nix-community/nixhelm";
    };
    colmena.url = "github:zhaofengli/colmena";
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixunstable";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    hmunstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixunstable";
    };
    proxmox.url = "github:SaumonNet/proxmox-nixos";
    # To enable backups: https://github.com/SaumonNet/proxmox-nixos/pull/45
    #proxmox.url = "github:blecher-at/proxmox-nixos/fix-backup-pve-manager";
    nix-hardware.url = "github:nixos/nixos-hardware";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixunstable";
    };
    nixvimunstable = {
      url = "github:nix-community/nixvim/main";
      inputs.nixpkgs.follows = "nixunstable";
    };
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
      ];
      metadata = builtins.fromJSON (builtins.readFile ./network.json);
    in
    top.flake-parts.lib.mkFlake { inputs = top; } {
      systems = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
      ];

      flake = {
        colmenaHive = top.colmena.lib.makeHive (
          {
            meta = {
              nixpkgs = import top.nixunstable {
                inherit overlays;
                system = "x86_64-linux";
              };
              specialArgs = {
                inherit
                  metadata
                  self
                  top
                  overlays
                  ;
              };
            };
          }
          // (builtins.mapAttrs (
            k: v:
            {
              imports = v._module.args.modules;
            }
            // (
              if builtins.hasAttr "tags" metadata.hosts.${k} then
                {
                  deployment = {
                    inherit (metadata.hosts.${k}) tags;
                    targetUser = "greg";
                  };
                }
              else
                { }
            )
          ) self.nixosConfigurations)
        );

        darwinConfigurations = (import ./darwin { inherit top overlays; });

        nixosConfigurations = (import ./hosts { inherit top overlays metadata; });

        homeConfigurations = (import ./home { inherit top overlays; });

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
            pkgs = import top.nixunstable { inherit system overlays; };
          };

          packages = (import ./pkgs { inherit pkgs; });

          checks = import ./checks.nix {
            inherit system top self';
            inherit (pkgs) lib;
          };

          devShells = import ./shells.nix {
            inherit pkgs;
            inherit (top) colmena;
          };
        };
    };
}
