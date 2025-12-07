{ top, ... }@all:
let
  vm = args: (unstable (args // { extraMods = [ top.nixos-generators.nixosModules.all-formats ]; }));
  wsl = args: (unstable (args // { extraMods = [ top.wsl.nixosModules.wsl ]; }));
  unstable =
    args:
    (machine (
      args
      // {
        channel = top.nixunstable;
        hm = top.hmunstable;
      }
    ));
  machine =
    {
      channel ? top.nixstable,
      extraMods ? [ ],
      name,
      system ? "x86_64-linux",
      hm ? top.hm,
    }:
    let
      nixpkgs = import channel { inherit system; };
      overlays = all.overlays ++ [ top.proxmox.overlays.${system} ];
    in
    channel.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit nixpkgs top overlays;
        inherit (top) self;
      };
      modules = [
        # Imported ones
        top.agenix.nixosModules.default
        hm.nixosModules.home-manager
        # Local ones
        ./baseline.nix
        top.self.modules.nixosModule
        ./${name}
      ]
      ++ extraMods;
    };
in
{
  genesis = unstable { name = "genesis"; };
  exodus = unstable { name = "exodus"; };
  zeke = unstable { name = "zeke"; };
  icdm-root = unstable { name = "icdm-root"; };
  linode = unstable { name = "linode"; };
  hosea = unstable { name = "hosea"; };
  jeremiah = unstable { name = "jeremiah"; };
  isaiah = unstable { name = "isaiah"; };

  vm-gitlab = vm { name = "vm-gitlab"; };
  proxmoxtemplate = unstable { name = "proxmoxtemplate"; };

  iso = unstable { name = "iso"; };
  # nix build '.#nixosConfigurations.wsl.config.system.build.installer'
  nixos = wsl {
    name = "wsl";
    system = "aarch64-linux";
  };
  # nix build '.#nixosConfigurations.wsl-aarch.config.system.build.installer'
  #nixos-arm = wsl {
  #name = "wsl";
  #system = "aarch64-linux";
  #};
}
