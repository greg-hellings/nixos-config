{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.greg.gitea-runner;
  host = config.networking.hostName;
  labels = cfg.labels ++ cfg.extraLabels;
in
{
  options.greg.gitea-runner = {
    enable = lib.mkEnableOption "Enable Gitea act_runner (shell mode)";

    instanceURL = lib.mkOption {
      type = lib.types.str;
      default = "https://src.thehellings.com";
      description = "URL of the Gitea instance to connect to";
    };

    name = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      description = "Name of the runner (defaults to hostname)";
    };

    capacity = lib.mkOption {
      type = lib.types.int;
      default = 5;
      description = "Number of concurrent jobs the runner can handle";
    };

    extraLabels = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    labels = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "self-hosted:host"
        "nixos-${host}:host"

        "debian-latest:docker://node:25-trixie"

        "ubuntu-latest:docker://docker.gitea.com/runner-images:ubuntu-latest"
        "ubuntu-24.04:docker://docker.gitea.com/runner-images:ubuntu-24.04"
        "ubuntu-22.04:docker://docker.gitea.com/runner-images:ubuntu-22.04"

        "ubuntu-full-latest:docker://ghcr.io/catthehacker/ubuntu:full-latest"
        "ubuntu-full-24.04:docker://ghcr.io/catthehacker/ubuntu:full-24.04"
        "ubuntu-full-22.04:docker://ghcr.io/catthehacker/ubuntu:full-22.04"

        "ubuntu-act-latest:docker://ghcr.io/catthehacker/ubuntu:act-latest"
        "ubuntu-act-24.04:docker://ghcr.io/catthehacker/ubuntu:act-24.04"
        "ubuntu-act-22.04:docker://ghcr.io/catthehacker/ubuntu:act-22.04"

        "ubuntu-runner-latest:docker://ghcr.io/catthehacker/ubuntu:runner-latest"
        "ubuntu-runner-24.04:docker://ghcr.io/catthehacker/ubuntu:runner-24.04"
        "ubuntu-runner-22.04:docker://ghcr.io/catthehacker/ubuntu:runner-22.04"

        "ubuntu-rust-latest:docker://ghcr.io/catthehacker/ubuntu:rust-latest"
        "ubuntu-rust-24.04:docker://ghcr.io/catthehacker/ubuntu:rust-24.04"
        "ubuntu-rust-22.04:docker://ghcr.io/catthehacker/ubuntu:rust-22.04"

        "nix-latest:docker://src.thehellings.com/greg/builder:latest"
      ];
      description = "Labels to assign to this runner";
    };

    tokenFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to a file containing the runner registration token (from agenix)";
      default = ../../secrets/gitea/runner-isaiah-podman.age;
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets."gitea-runner-${host}-podman".file = cfg.tokenFile;

    environment.systemPackages = with pkgs; [
      bash
      git
      nodejs
    ];

    greg.podman.enable = true;

    services.gitea-actions-runner = {
      package = pkgs.gitea-actions-runner;
      instances.${cfg.name} = {
        inherit labels;
        inherit (cfg) name;
        enable = true;
        url = cfg.instanceURL;
        tokenFile = config.age.secrets."gitea-runner-${host}-podman".path;
        settings = {
          container.force_pull = true;
          runner.capacity = cfg.capacity;
        };
      };
    };
  };
}
