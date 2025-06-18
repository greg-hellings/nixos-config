{ pkgs, ... }:

{
  greg = {
    development = true;
    gui = true;
    gnome = false;
    vscodium = true;
    zed = true;
  };

  home = {
    file.".config/libvirt/qemu.conf".text = ''
      nvram = [
        "/run/libvirt/nix-ovmf/OVMF_CODE.fd:/run/libvirt/nix-ovmf/OVMF_VARS.fd",
        "/run/libvirt/nix-ovmf/AAVMF_CODE.fd:/run/libvirt/nix-ovmf/AAVMF_VARS.fd",
        "${pkgs.OVMFFull.fd}/FV/OVMF_CODE.ms.fd:${pkgs.OVMFFull.fd}/FV/OVMF_VARS.ms.fd"
      ]
    '';

    packages = with pkgs; [
      audacity
      bitwarden-cli
      element
      (mumble.override { pulseSupport = true; })
      super-productivity
      webcamoid
    ];
  };

  programs.xonsh.sessionVariables.EFI_DIR = "${pkgs.OVMF.fd}/FV/";
}
