{ inputs
, overlays
, ...
}:

rec {
  greghellings =
    let
      system = "x86_64-linux";
      pkgs = (import inputs.nixunstable { inherit system overlays; config.allowUnfree = true; });
    in
    inputs.hmunstable.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./home.nix ];
      extraSpecialArgs = {
        inherit inputs;
        nixvim = inputs.nixvimunstable;
        gui = false;
        gnome = false;
        host = "ivr";
        username = "gregory.hellings";
      };
    };

  "gregory.hellings" = greghellings;
}
