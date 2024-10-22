{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (mumble.override { pulseSupport = true; })
    #logseq
  ];
  greg = {
    development = true;
    gui = true;
    sway = false;
    gnome = false;
    vscodium = true;
  };

  programs.xonsh.sessionVariables.EFI_DIR = "${pkgs.OVMF.fd}/FV/";
}
