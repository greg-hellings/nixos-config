{ pkgs, ... }:

{
  greg = {
    development = true;
    gui = true;
    sway = false;
    gnome = false;
    vscodium = true;
  };

  home = {
    file.".config/libvirt/qemu.conf".text = ''
      nvram = [ "/run/libvirt/nix-ovmf/OVMF_CODE.fd:/run/libvirt/nix-ovmf/OVMF_VARS.fd" ]
    '';

    packages = with pkgs; [
      (mumble.override { pulseSupport = true; })
      #logseq
    ];
  };

  programs.xonsh.sessionVariables.EFI_DIR = "${pkgs.OVMF.fd}/FV/";
}
