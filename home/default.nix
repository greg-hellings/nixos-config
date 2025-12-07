{
  overlays,
  top,
  ...
}:
let
  pkgs =
    system:
    (import top.nixunstable {
      inherit system;
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
      overlays = overlays ++ [
        top.nurpkgs.overlays.default
        top.vsext.overlays.default
      ];
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
  "MacBook-Prolocal.local" = user "aarch64-darwin" "ivr" "gregory.hellings";
  genesis = greg "genesis";
  exodus = greg "exodus";
  zeke = greg "zeke";
  isaiah = greg "isaiah";
  jeremiah = greg "jeremiah";
  linode = greg "linode";
  hosea = greg "hosea";
  vm-gitlab = greg "vm-gitlab";
}
