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

  greg = {
    home = false;
    linode.enable = true;
    tailscale.enable = true;
  };

  programs.ssh.extraConfig = lib.strings.concatStringsSep "\n" [
    "Host chronicles.shire-zebra.ts.net"
    "    User backup"
    "    IdentityFile /etc/ssh/backup_ed25519"
    "    StrictHostKeyChecking no"
    "    UserKnownHostsFile /dev/null"
  ];

  networking = {
    networkmanager.enable = lib.mkForce false;
    hostName = "linode";
    domain = "thehellings.com";
    nameservers = [ "100.88.91.27" ];
  };

  age.secrets.runner-deployer = {
    file = ../../secrets/gitlab/linode-deployer-runner-reg.age;
    owner = "gitlab-runner";
  };

  services.gitlab-runner = {
    enable = true;
    services.deployer = {
      executor = "shell";
      authenticationTokenConfigFile = config.age.secrets.runner-deployer.path;
    };
  };

  users.users.gitlab-runner = {
    isSystemUser = true;
    group = "gitlab-runner";
  };
  users.groups.gitlab-runner = { };

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

  environment.systemPackages = with pkgs; [
    bind
    graphviz
    nix-du
    pgloader
  ];
}
