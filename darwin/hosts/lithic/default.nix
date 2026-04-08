{ config, ... }:
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
      "github-mcp-server"
      {
        name = "libvirt";
        restart_service = true;
      }
      "mcp-atlassian"
      "notion-mcp-server"
      "nushell"
      "qemu"
      "slack-mcp-server"
      "zlib"
    ];
    casks = [
      "alt-tab"
      "audacity"
      "bitwarden"
      "bruno"
      "chromium"
      "claude-code"
      "dbeaver-community"
      "ghostty"
      "firefox"
      "notion"
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
