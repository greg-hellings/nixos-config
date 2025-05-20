{ config, lib, ... }:
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
    age.secrets.kubernetesToken.file = ../../secrets/kubernetes/kubernetesToken.age;

    networking.firewall = {
      allowedTCPPorts =
        [
          6443
        ]
        ++ (
          if cfg.agentOnly then
            [
              2379
              2380
            ]
          else
            [ ]
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
