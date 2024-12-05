{
  config,
  pkgs,
  lib,
  ...
}:

{
  # The Hack font is used in the Fugitive sidebars
  fonts.fontconfig.enable = true;
  home.packages = with pkgs.nerd-fonts; [ hack ];

  programs.nixvim = (import ./vim/config.nix { inherit config pkgs lib; }) // {
    enable = true;
  };
}
