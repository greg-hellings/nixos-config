{
  metadata,
  nixpkgs,
  top,
}:
let
  inherit (top.nixunstable) lib;
  user =
    host:
    let
      inherit (metadata.hosts.${host}) system;
      pkgs = nixpkgs.${system};
      username = if builtins.hasAttr "user" metadata.hosts.${host} then metadata.hosts.${host}.user else "greg";
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
in
(
  lib.genAttrs
    (builtins.attrNames (builtins.readDir ./hosts))
    user
)
