{ top, overlays, ... }:
let
  wsl = args: (unstable (args // { extraMods = [ top.wsl.nixosModules.wsl ]; }));
  unstable =
    args:
    (machine (
      args
      // {
        channel = top.nixunstable;
        hm = top.hmunstable;
        nixvim = top.nixvimunstable;
      }
    ));
  machine =
    {
      channel ? top.nixstable,
      extraMods ? [ ],
      name,
      system ? "x86_64-linux",
      hm ? top.hm,
      nixvim ? top.nixvimstable,
    }:
    let
      nixpkgs = import channel { inherit system; };
    in
    channel.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit nixpkgs top overlays;
        inherit (top) self;
      };
      modules = [
        {
          nixpkgs.overlays = overlays;
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.greg = import ../home/home.nix;
            extraSpecialArgs = {
              inherit top overlays nixvim;
              home = "/home/greg";
              host = name;
            };
            backupFileExtension = "bkp";
          };
        }
        top.agenix.nixosModules.default
        hm.nixosModules.home-manager
        top.self.modules.nixosModule
        top.nurpkgs.nixosModules.nur
        ./${name}
      ] ++ extraMods;
    };
in
{
  genesis = machine { name = "genesis"; };
  exodus = unstable { name = "exodus"; };
  jude = unstable { name = "jude"; };
  icdm-root = unstable { name = "icdm-root"; };
  linode = machine { name = "linode"; };
  hosea = unstable { name = "hosea"; };
  jeremiah = unstable { name = "jeremiah"; };
  myself = unstable { name = "myself"; };
  iso = machine { name = "iso"; };
  iso-beta = unstable { name = "iso"; };
  # nix build '.#nixosConfigurations.wsl.config.system.build.installer'
  nixos = wsl {
    name = "wsl";
    system = "aarch64-linux";
  };
  # nix build '.#nixosConfigurations.wsl-aarch.config.system.build.installer'
  nixos-arm = wsl {
    name = "wsl";
    system = "aarch64-linux";
  };
}
