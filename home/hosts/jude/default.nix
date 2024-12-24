{ pkgs, ... }:

{
  greg = {
    development = true;
    gui = true;
    sway = false;
    gnome = false;
    vscodium = true;
    zed = true;
  };

  home = {
    file.".config/libvirt/qemu.conf".text = ''
      nvram = [ "/run/libvirt/nix-ovmf/OVMF_CODE.fd:/run/libvirt/nix-ovmf/OVMF_VARS.fd" ]
    '';

    packages = with pkgs; [
      audacity
      (mumble.override { pulseSupport = true; })
      #logseq
      webcamoid
    ];
  };

  programs.xonsh.sessionVariables.EFI_DIR = "${pkgs.OVMF.fd}/FV/";
}
