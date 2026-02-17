{ ... }:

{
  imports = [ top.wsl.nixosModules.default ];
  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = "greg";
    startMenuLaunchers = true;
  };
}
