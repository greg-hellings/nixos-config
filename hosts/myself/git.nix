{
  config,
  pkgs,
  lib,
  ...
}:

let
  gitlabStateDir = "/var/lib/gitlab";
in
{
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 ];
    };
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "enp38s0";
    };
  };

  greg.proxies."git.thehellings.lan" = {
    target = "http://192.168.200.2";
    extraConfig = ''
      proxy_set_header X-Forwarded-Proto https;
      proxy_set_header X-Forwarded-Ssl on;
    '';
  };

  system.activationScripts.makeGitlabDir = lib.stringAfter [
    "var"
  ] "mkdir -p ${gitlabStateDir} && touch ${gitlabStateDir}/touch";

  greg.containers.gitlab = {
    tailscale = true;
    subnet = "200";
    builder = (import ./container-git.nix);
  };

  #####################################################################################
  #################### Local Podman/Docker Runner #####################################
  #####################################################################################
  age.secrets.runner-reg.file = ../../secrets/gitlab/myself-podman-runner-reg.age;
  age.secrets.docker-auth.file = ../../secrets/gitlab/docker-auth.age;
  age.secrets.runner-qemu.file = ../../secrets/gitlab/myself-qemu-runner-reg.age;
  systemd.services.gitlab-runner = {
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
  };
  services.gitlab-runner = {
    enable = true;
    settings = {
      concurrent = 5;
    };
    services = {
      default = {
        executor = "docker";
        authenticationTokenConfigFile = config.age.secrets.runner-reg.path;
        dockerImage = "gitlab.shire-zebra.ts.net:5000/greg/ci-images/fedora:latest";
        dockerAllowedImages = [
          "alpine:*"
          "debian:*"
          "docker:*"
          "fedora:*"
          "python:*"
          "ubuntu:*"
          "registry.gitlab.com/gitlab-org/*"
          "registry.thehellings.com/*/*/*:*"
          "gitlab.shire-zebra.ts.net:5000/*/*/*:*"
        ];
        dockerAllowedServices = [
          "docker:*"
          "registry.thehellings.com/*/*/*:*"
          "gitlab.shire-zebra.ts.net:5000/*/*/*:*"
        ];
        dockerPrivileged = true;
        dockerVolumes = [
          "/certs/client"
          "/cache"
        ];
      };
      qemu = {
        executor = "shell";
        limit = 5;
        authenticationTokenConfigFile = config.age.secrets.runner-qemu.path;
        environmentVariables = {
          EFI_DIR = "${pkgs.OVMF.fd}/FV/";
          STORAGE_URL = "http://s3.thehellings.lan:9000";
        };
      };
    };
  };
  virtualisation = {
    podman.enable = true;
    oci-containers.backend = "podman";
  };
  environment.systemPackages = with pkgs; [
    curl
    gawk
    git
    unzip
    wget
  ];
}
