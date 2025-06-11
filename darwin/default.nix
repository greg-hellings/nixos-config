{ top, overlays, ... }:
let
  inherit (top.nixunstable) lib;
  mac =
    {
      system ? "aarch64-darwin",
      name,
      channel ? top.nixunstable,
      hm ? top.hmunstable,
    }:
    let
      nixpkgs = import channel { inherit system overlays; };
    in
    top.darwin.lib.darwinSystem {
      inherit system;
      specialArgs = {
        inherit nixpkgs overlays top;
        inherit (top) self;
      };
      modules = [
        {
          nixpkgs.overlays = overlays;
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
      ] ++ lib.optionals (builtins.pathExists ./hosts/${name}) [ ./hosts/${name} ];
    };
in
rec {
  "MacBook-Pro" = mac { name = "ivr"; };
}
