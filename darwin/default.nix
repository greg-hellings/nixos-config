{ top, overlays, ... }:
let
  mac =
    {
      system ? "aarch64-darwin",
      name,
      channel ? top.nixunstable,
      hm ? top.hmunstable,
      extraMods ? [ ],
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
        ./${name}
      ] ++ extraMods;
    };
in
rec {
  la23002 = mac { name = "ivr"; };
  LA23002 = la23002;
}
