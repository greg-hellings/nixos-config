# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  description = "Greg's machines!";

  nixConfig = {
    extra-substituters = [
      "https://greg-hellings.cachix.org"
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "greg-hellings.cachix.org-1:y01Jl/L5evlhxdnUW6n56AiI1k8g1wxWhTxJCe7XSco="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g"
    ];
  };

  inputs = {
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixunstable";
    };
    btc = {
      url = "github:fort-nix/nix-bitcoin/release";
    };
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixunstable";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    hooks.url = "github:cachix/git-hooks.nix";
    hmunstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixunstable";
    };
    #proxmox.url = "github:SaumonNet/proxmox-nixos";
    # To enable backups: https://github.com/SaumonNet/proxmox-nixos/pull/45
    proxmox.url = "github:blecher-at/proxmox-nixos/fix-backup-pve-manager";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixunstable";
    };
    nixvimunstable.url = "github:nix-community/nixvim/main";
    nix23_05.url = "github:NixOS/nixpkgs/nixos-23.05";
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
      packages_overlay = (
        _: prev:
        (import ./pkgs {
          inherit self top;
          pkgs = prev;
        })
      );
      overlays = [
        top.agenix.overlays.default
        local_overlay
        packages_overlay
        top.nurpkgs.overlay
        top.vsext.overlays.default
      ];

    in
    top.flake-parts.lib.mkFlake { inputs = top; } {
      systems = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
      ];

      flake = {
        nixosConfigurations = (import ./hosts { inherit top overlays; });

        darwinConfigurations = (import ./darwin { inherit top overlays; });

        homeConfigurations = (import ./home { inherit top overlays; });

        overlays = {
          default = packages_overlay;
          local = local_overlay;
        };

        modules = import ./modules;
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

          packages = (import ./pkgs { inherit pkgs top; }) // (import ./vms { inherit top; });

          checks = import ./checks.nix {
            inherit system;
            inherit (top) hooks;
          };

          devShells = import ./shells.nix {
            inherit self' pkgs;
            inherit (top) nixvimunstable;
          };
        };
    };
}
