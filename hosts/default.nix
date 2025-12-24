{
  top,
  metadata,
  nixpkgs,
}:
let
  vm = args: (unstable (args // { extraMods = [ top.nixos-generators.nixosModules.all-formats ]; }));
  wsl = args: (unstable (args // { extraMods = [ top.wsl.nixosModules.wsl ]; }));
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
  nixos = wsl { name = "wsl"; };
  # nix build '.#nixosConfigurations.wsl-aarch.config.system.build.installer'
  #nixos-arm = wsl {
  #name = "wsl";
  #system = "aarch64-linux";
  #};
}
