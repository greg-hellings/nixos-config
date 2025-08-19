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
      {
        name = "colima";
        restart_service = true;
      }
      "direnv"
      "docker-compose"
      {
        name = "libvirt";
        restart_service = true;
      }
      "mysql"
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
      "docker"
      "ghostty"
      "firefox"
      "microsoft-teams"
      "mysqlworkbench"
      "notunes"
      "onlyoffice"
      "pgadmin4"
      "podman-desktop"
      "tabby"
      "twine"
      "vagrant"
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
