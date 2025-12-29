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
    proxmox.url = "github:greg-hellings/proxmox-nixos/fix/212-AcceptEnv-redefinition";
    #proxmox.url = "github:SaumonNet/proxmox-nixos";
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
      overlays = system: [
        top.agenix.overlays.default
        local_overlay
        top.nixvimunstable.overlays.default
        top.proxmox.overlays.${system}
        top.nurpkgs.overlays.default
        top.vsext.overlays.default
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
          inherit system;
          config = {
            allowUnfree = true;
            allowUnfreePredicate = _: true;
            permittedInsecurePackages = [ "ventoy-1.1.05" ];
          };
          overlays = overlays system;
        }
      );
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
                  metadata
                  self
                  top
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
                    targetHost = metadata.hosts.${k}.ts;
                    targetUser = "greg";
                  };
                }
              else
                { }
            )
          ) self.nixosConfigurations)
        );

        darwinConfigurations = (
          import ./darwin {
            inherit top;
            nixpkgs = imported_packages;
          }
        );

        nixosConfigurations = (
          import ./hosts {
            inherit top metadata;
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
