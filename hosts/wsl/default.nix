{ ... }:

{
  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = "greg";
    startMenuLaunchers = true;
    nativeSystemd = true;
  };
}
