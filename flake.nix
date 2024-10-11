# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  description = "Greg's machines!";

  nixConfig = {
    extra-substituters = [ "https://cache.garnix.io" ];
    extra-trusted-public-keys = [ "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g" ];
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
    hm = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixstable";
    };
    hmunstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixstable";
    };
    nixvimstable.url = "github:nix-community/nixvim/nixos-24.05";
    nixvimunstable.url = "github:nix-community/nixvim/main";
    nix23_05.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixstable.url = "github:nixos/nixpkgs/nixos-24.05";
    nixunstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nurpkgs.url = "github:nix-community/NUR";
    vsext.url = "github:nix-community/nix-vscode-extensions";
    wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixunstable";
    };
    zed.url = "github:zed-industries/zed/v0.156.x";
  };

  outputs =
    { self, ... }@top:
    let
      local_overlay = import ./overlays;
      packages_overlay = (
        _: prev:
        (import ./pkgs {
          inherit self;
          pkgs = prev;
        }).packages
      );
      overlays = [
        top.agenix.overlays.default
        local_overlay
        packages_overlay
        top.nurpkgs.overlay
        top.vsext.overlays.default
        (_: _: { zed-editor = top.zed.packages.x86_64-linux.default; })
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
            pkgs = import top.nixstable { inherit system overlays; };
          };

          imports = [ ./pkgs ];

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
