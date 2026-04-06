{
  metadata,
  nixpkgs,
  top,
}:
let
  inherit (top.nixunstable) lib;
  mac =
    {
      system ? "aarch64-darwin",
      name,
      hm ? top.hmunstable,
    }:
    let
      pkgs = nixpkgs.${system};
    in
    top.darwin.lib.darwinSystem {
      inherit pkgs system;
      specialArgs = {
        inherit metadata top;
        inherit (top) self;
      };
      modules = [
        {
          home-manager = {
            extraSpecialArgs = {
              inherit top;
              host = name;
            };
          };
        }
        hm.darwinModules.home-manager
        # Local changes
        ../modules/nix-conf.nix
        ./baseline.nix
      ]
      ++ lib.optionals (builtins.pathExists ./hosts/${name}) [ ./hosts/${name} ];
    };
in
(
  lib.genAttrs
    (builtins.attrNames (builtins.readDir ./hosts))
    (
      name:
      mac { inherit name; }
    )
)
