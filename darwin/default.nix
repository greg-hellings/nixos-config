{ inputs, overlays, ... }:
let
  mac =
    { system ? "aarch64-darwin"
    , name
    , channel ? inputs.nixunstable
    , hm ? inputs.hmunstable
    , extraMods ? [ ]
    }:
    let
      nixpkgs = import channel {
        inherit system overlays;
      };
    in
    inputs.darwin.lib.darwinSystem {
      inherit system;
      specialArgs = { inherit nixpkgs; };
      modules = [
        {
          nixpkgs.overlays = overlays;
          home-manager.extraSpecialArgs = {
            inherit inputs;
            host = name;
          };
        }
        hm.darwinModules.home-manager
        inputs.self.modules.darwinModule
        ./${name}
      ] ++ extraMods;
    };
in
rec {
  la23002 = mac { name = "ivr"; };
  LA23002 = la23002;
}
