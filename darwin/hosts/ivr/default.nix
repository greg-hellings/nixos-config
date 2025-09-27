{ ... }:
let
  username = "gregory.hellings";
in
{
  greg = {
    nix.cache = false;
  };

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
      "poetry"
      {
        name = "postgresql@17";
        restart_service = true;
      }
      "pytest"
      "qemu"
    ];
    casks = [
      "alt-tab"
      "audacity"
      "bitwarden"
      "bruno"
      "chromium"
      "dbeaver-community"
      "ghostty"
      "firefox"
      "microsoft-teams"
      "notunes"
      "onlyoffice"
      "pgadmin4"
      "podman-desktop"
      "tabby"
      "vagrant"
      "virtualbox"
      "visual-studio-code"
      "zed"
      "zoho-workdrive"
    ];
    user = username;
  };

  system.primaryUser = username;

  users.users."${username}" = {
    name = username;
    home = "/Users/${username}";
  };
}
