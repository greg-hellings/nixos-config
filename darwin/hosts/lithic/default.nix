{ ... }:
let
  username = "greg";
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
      "notunes"
      "onlyoffice"
      "podman-desktop"
      "tabby"
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
