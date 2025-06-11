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
  user =
    system: host: username:
    top.hmunstable.lib.homeManagerConfiguration {
      pkgs = pkgs system;
      modules = [
        ../modules/nix-conf.nix
        ./home.nix
      ];
      extraSpecialArgs = {
        inherit top host username;
        nixvim = top.nixvimunstable;
        gui = false;
        gnome = false;
      };
    };
  greg = host: (user "x86_64-linux" host "greg");
in
{
  "MacBook-Pro.local" = user "aarch64-darwin" "ivr" "gregory.hellings";
  exodus = greg "exodus";
  jude = greg "jude";
  isaiah = greg "isaiah";
  jeremiah = greg "jeremiah";
}
