{
  top,
  metadata,
  nixpkgs,
}:
let
  inherit (top.nixunstable) lib;
  unstable =
    {
      channel ? top.nixunstable,
      extraMods ? [ ],
      name,
      hm ? top.hmunstable,
    }:
    let
      inherit (metadata.hosts.${name}) system;
    in
    channel.lib.nixosSystem {
      pkgs = nixpkgs.${system};
      specialArgs = {
        inherit metadata top;
      };
      modules = [
        {
          nixpkgs.hostPlatform = system;
        }
        # Imported ones
        top.agenix.nixosModules.default
        hm.nixosModules.home-manager
        # Local ones
        ./baseline.nix
        top.self.modules.nixosModule
      ]
      ++ extraMods;
    };
in
(lib.genAttrs
  (builtins.attrNames (lib.filterAttrs (_: v: v == "directory") (builtins.readDir ./unstable)))
  (
    name:
    (unstable {
      inherit name;
      extraMods = [ ./unstable/${name} ];
    })
  )
)
// (lib.genAttrs
  (builtins.attrNames (lib.filterAttrs (_: v: v == "directory") (builtins.readDir ./vm)))
  (
    name:
    (unstable {
      inherit name;
      extraMods = [ ./vm/${name} ];
    })
  )
)
// {
  # nix build '.#nixosConfigurations.wsl.config.system.build.installer'
  #nixos = wsl { name = "wsl"; };
  # nix build '.#nixosConfigurations.wsl-aarch.config.system.build.installer'
  #nixos-arm = wsl {
  #  name = "wsl";
  #  system = "aarch64-linux";
  #};

  builder-aarch = lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      "${top.nixunstable}/nixos/modules/profiles/nix-builder-vm.nix"
      {
        virtualisation.host.pkgs = import top.nixunstable { system = "aarch64-darwin"; };
        boot.loader.grub.devices = [ "/dev/vda" ];
      }
    ];
  };

  builder-x86 = lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      "${top.nixunstable}/nixos/modules/profiles/nix-builder-vm.nix"
      {
        virtualisation.host.pkgs = import top.nixunstable { system = "aarch64-darwin"; };
        boot.loader.grub.devices = [ "/dev/vda" ];
      }
    ];
  };
}
