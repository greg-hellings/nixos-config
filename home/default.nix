{ top, overlays, ... }:

rec {
  greghellings =
    let
      system = "x86_64-linux";
      pkgs = (
        import top.nixunstable {
          inherit system overlays;
          config = {
            allowUnfree = true;
            allowUnfreePredicate = _: true;
          };
        }
      );
    in
    top.hmunstable.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        (import ../modules/nix-conf.nix {
          inherit pkgs;
          inherit (pkgs) lib;
          cache = false;
        })
        ./home.nix
      ];
      extraSpecialArgs = {
        inherit top;
        nixvim = top.nixvimunstable;
        gui = false;
        gnome = false;
        host = "ivr";
        username = "gregory.hellings";
      };
    };

  "gregory.hellings" = greghellings;
}
