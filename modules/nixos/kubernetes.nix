{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.greg.kubernetes;
in
{
  options.greg = {
    kubernetes = {
      enable = lib.mkEnableOption "kubernetes";
      agentOnly = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to run the Kubernetes agent only";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      bw_secret.file = ../../secrets/kubernetes/bw_secret.age;
      dendrite_key.file = ../../secrets/dendrite_key.age;
      kubernetesToken.file = ../../secrets/kubernetes/kubernetesToken.age;
    };

    environment.systemPackages = [
      pkgs.fluxcd
      pkgs.kubectl-cnpg
      pkgs.kubernetes-helm
      pkgs.kustomize
      pkgs.k9s
    ];

    networking.firewall = {
      allowedTCPPorts =
        [
          6443
        ]
        ++ (
          if cfg.agentOnly then
            [ ]
          else
            [
              2379
              2380
            ]
        );
      allowedUDPPorts = [ 8472 ];
    };

    services.k3s = {
      enable = true;
      role = if cfg.agentOnly then "agent" else "server";
      tokenFile = config.age.secrets.kubernetesToken.path;
      extraFlags = [
        "--cluster-cidr=10.211.0.0/16"
        "--service-cidr=10.221.0.0/16"
        "--write-kubeconfig-mode 0640"
        "--write-kubeconfig-group kubeconfig"
        "--resolv-conf=/etc/resolv.conf"
        "--tls-san ${config.networking.hostName}.home"
        "--tls-san ${config.networking.hostName}.thehellings.lan"
        "--tls-san ${config.networking.hostName}.shire-zebra.ts.net"
      ];
      serverAddr = lib.mkIf (config.networking.hostName != "isaiah") "https://isaiah.home:6443";
    };

    users = {
      groups.kubeconfig = { };
      users.greg.extraGroups = [ "kubeconfig" ];
    };
  };
}
