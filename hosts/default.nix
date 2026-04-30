{
  top,
  lib',
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
        inherit metadata top lib';
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
// {
  # nix build '.#nixosConfigurations.wsl.config.system.build.installer'
  #nixos = wsl { name = "wsl"; };
  # nix build '.#nixosConfigurations.wsl-aarch.config.system.build.installer'
  #nixos-arm = wsl {
  #  name = "wsl";
  #  system = "aarch64-linux";
  #};
}
