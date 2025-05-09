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
        inherit nixpkgs;
      };
      modules = [
        {
          nixpkgs.overlays = overlays;
          home-manager.extraSpecialArgs = {
            inherit top;
            host = name;
          };
        }
        hm.darwinModules.home-manager
        top.self.modules.darwinModule
      ] ++ lib.optionals (builtins.pathExists ./hosts/${name}) [ ./hosts/${name} ];
    };
in
rec {
  la23002 = mac { name = "ivr"; };
  LA23002 = la23002;
}
