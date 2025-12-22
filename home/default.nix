{
  metadata,
  nixpkgs,
  top,
}:
let
  user =
    host: username:
    let
      inherit (metadata.hosts.${host}) system;
      pkgs = nixpkgs.${system};
    in
    top.hmunstable.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ../modules/nix-conf.nix
        ./home.nix
      ];
      extraSpecialArgs = {
        inherit
          top
          host
          username
          metadata
          ;
        nixvim = top.nixvimunstable;
        gui = false;
        gnome = false;
      };
    };
  greg = host: (user host "greg");
in
{
  "MacBook-Pro.local" = user "ivr" "gregory.hellings";
  "MacBook-Prolocal.local" = user "ivr" "gregory.hellings";
  genesis = greg "genesis";
  exodus = greg "exodus";
  zeke = greg "zeke";
  isaiah = greg "isaiah";
  jeremiah = greg "jeremiah";
  linode = greg "linode";
  hosea = greg "hosea";
  vm-gitlab = greg "vm-gitlab";
}
