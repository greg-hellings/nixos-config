{ ... }:
let
  username = "gregory.hellings";
in
{
  homebrew = {
    enable = true;
    brews = [
      "bitwarden-cli"
      "direnv"
      {
        name = "libvirt";
        restart_service = true;
      }
      "nushell"
      "qemu"
    ];
    casks = [
      "alt-tab"
      "bitwarden"
      "bruno"
      "chromium"
      "firefox"
      "onlyoffice"
      "pgadmin4"
      "tabby"
      "vagrant"
      "visual-studio-code"
      "zed"
    ];
    user = username;
  };

  system.primaryUser = username;

  users.users."${username}" = {
    name = username;
    home = "/Users/${username}";
  };
}
