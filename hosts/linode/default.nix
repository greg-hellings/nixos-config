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

  age.secrets.runner-deployer = {
    file = ../../secrets/gitlab/linode-deployer-runner-reg.age;
    owner = "gitlab-runner";
  };

  environment.systemPackages = with pkgs; [
    bind
    graphviz
    nix-du
    pgloader
  ];

  greg = {
    home = false;
    linode.enable = true;
    proxies."immich.thehellings.com" = {
      genAliases = false;
      target = "http://localhost:${builtins.toString config.services.immich-public-proxy.port}";
      ssl = true;
    };
    tailscale.enable = true;
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
    gitlab-runner = {
      enable = true;
      services.deployer = {
        executor = "shell";
        authenticationTokenConfigFile = config.age.secrets.runner-deployer.path;
      };
    };

    immich-public-proxy = {
      enable = true;
      immichUrl = "https://immich.shire-zebra.ts.net";
    };
  };

  systemd.services."gitlab-runner".serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "gitlab-runner";
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

  users = {
    groups.gitlab-runner = { };
    users.gitlab-runner = {
      isSystemUser = true;
      group = "gitlab-runner";
    };
  };
}
