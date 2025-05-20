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
      allowedTCPPorts = [ 6443 ];
      allowedUDPPorts = [ 8472 ];
    };

    services.k3s = {
      enable = true;
      role = if cfg.agentOnly then "agent" else "server";
      tokenFile = config.age.secrets.kubernetesToken.path;
      serverAddr = lib.mkIf (config.networking.hostName != "isaiah") "https://isaiah.home:6443";
    };
  };
}
