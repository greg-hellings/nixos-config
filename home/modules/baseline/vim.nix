{ pkgs, ... }:

{
  # The Hack font is used in the Fugitive sidebars
  fonts.fontconfig.enable = true;
  home.packages = [ (pkgs.nerdfonts.override { fonts = [ "Hack" ]; }) ];

  programs.nixvim = (import ./vim/config.nix { inherit pkgs; }) // { enable = true; };
}
