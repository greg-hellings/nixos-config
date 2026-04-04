{
  pkgs,
  lib,
  config,
  ...
}:

{
  imports = [
    ./git.nix
    ./hardware-configuration.nix
    ./podman.nix
    ./matrix.nix
    ./nextcloud.nix
    ./nginx.nix
    ./postgres.nix
  ];

  environment.systemPackages = with pkgs; [
    bind
    graphviz
    nix-du
    pgloader
  ];

  age.secrets = {
    # TODO: Greg add agenix secret at secrets/gitea-runner-linode.age
    # gitea-runner-linode.file = ../../../secrets/gitea-runner-linode.age;
  };

  greg = {
    home = false;
    linode.enable = true;
    nebula = {
      enable = true;
      isLighthouse = true;
    };
    proxies."immich.thehellings.com" = {
      genAliases = false;
      target = "http://localhost:${builtins.toString config.services.immich-public-proxy.port}";
      ssl = true;
    };
    tailscale.enable = true;
    gitea-runner = {
      enable = true;
      labels = [ "self-hosted" "host:linode" ];
      # TODO: Greg add agenix secret at secrets/gitea-runner-linode.age
      # tokenFile = config.age.secrets.gitea-runner-linode.path;
    };
  };

  networking = {
    networkmanager.enable = lib.mkForce false;
    hostName = "linode";
    domain = "thehellings.com";
    nameservers = [ "100.88.91.27" ];
  };

  programs.ssh.extraConfig = lib.strings.concatStringsSep "\n" [
    "Host chronicles.shire-zebra.ts.net"
    "    User backup"
    "    IdentityFile /etc/ssh/backup_ed25519"
    "    StrictHostKeyChecking no"
    "    UserKnownHostsFile /dev/null"
  ];

  services = {
    immich-public-proxy = {
      enable = true;
      immichUrl = "https://immich.shire-zebra.ts.net";
    };
  };

  security.sudo.extraRules = [
    {
      users = [ "gitlab-runner" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/podman";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
