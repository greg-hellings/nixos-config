{ ... }:
{
  #environment.loginShell = lib.getExe pkgs.xonsh;
  homebrews = {
    enable = true;
    brews = [
      "direnv"
      {
        name = "libvirt";
        restart_service = true;
      }
      "qemu"
    ];
    casks = [
      "alt-tab"
      "bruno"
      "chromium"
      "firefox"
      "onlyoffice"
      "pgadmin4"
      "vagrant"
      "visual-studio-code"
      "zed"
    ];
  };
}
