{
  overlays,
  top,
  ...
}:
let
  pkgs =
    system:
    (import top.nixunstable {
      inherit system overlays;
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    });
  ivr =
    let
      system = "aarch64-darwin";
    in
    top.hmunstable.lib.homeManagerConfiguration {
      pkgs = pkgs system;
      modules = [
        ../modules/nix-conf.nix
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
in
{
  "MacBook-Pro.local" = ivr;
}
