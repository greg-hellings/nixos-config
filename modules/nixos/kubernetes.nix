{
  config,
  lib,
  pkgs,
  top,
  ...
}:
let
  cfg = config.greg.kubernetes;
  cert-manager = pkgs.fetchurl {
    url = "https://github.com/cert-manager/cert-manager/releases/download/v1.18.2/cert-manager.yaml";
    sha256 = "0vx1nfyhl0rzb6psfxplq8pfp18mrrdk83n8rj2ph8q6r15vcih5";
  };
  flux = pkgs.fetchurl {
    url = "https://github.com/fluxcd/flux2/releases/download/v2.7.2/install.yaml";
    sha256 = "sha256-Qs1qJmgZm8q9xZsORjT/N/wzpbWVVODXtzDpjnAYMuQ=";
  };
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
      priority = lib.mkOption {
        type = lib.types.int;
        default = 1;
        description = "VIP priority";
      };
      vip = lib.mkOption {
        type = lib.types.str;
        default = null;
        description = "The IP address of this host";
      };
      vipInterface = lib.mkOption {
        type = lib.types.str;
        default = null;
        description = "Interface to attach VIP for clustering onto";
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
      pkgs.etcd
      pkgs.fluxcd
      pkgs.kubectl-cnpg
      pkgs.kubernetes-helm
      pkgs.kustomize
      pkgs.k9s
      pkgs.openiscsi
      pkgs.nfs-utils # Needed for Longhorn
    ];

    networking.firewall = {
      allowedTCPPorts = [
        80
        443
        5432
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

    services = {
      k3s = {
        enable = true;
        autoDeployCharts = {
          external-secrets = {
            inherit (top.charts.chartsMetadata.external-secrets.external-secrets) repo version;
            enable = true;
            name = top.charts.chartsMetadata.external-secrets.external-secrets.chart;
            hash = "sha256-aRlMiaKAOWlectqM0czjaVAaUWceGHm5t3Q2J1pXl28=";
            createNamespace = true;
            targetNamespace = "external-secrets";
            values = {
              crds.create = true;
              includeCRDs = true;
            };
          };
          kyverno = {
            inherit (top.charts.chartsMetadata.kyverno.kyverno) repo version;
            enable = true;
            name = top.charts.chartsMetadata.kyverno.kyverno.chart;
            hash = "sha256-acETukO1PUR+bAjXR+jBUjymBaB4uSPzDA1uvPqdY3U=";
            createNamespace = true;
            targetNamespace = "kyverno-system";
            values = {
              admissionController.replicas = 3;
              backgroundController.replicas = 3;
              cleanupController.replicas = 2;
              reportsController.replicas = 2;
              crds.install = true;
            };
          };
          tailscale = {
            inherit (top.charts.chartsMetadata.tailscale.tailscale-operator) repo version;
            enable = true;
            name = top.charts.chartsMetadata.tailscale.tailscale-operator.chart;
            hash = "sha256-8pZyWgBTDtnUXnYzDCtbXtTzvUe35BnqHckI/bBuk7o=";
            createNamespace = true;
            targetNamespace = "tailscale";
          };
        };
        extraFlags = [
          "--cluster-cidr=10.211.0.0/16"
          "--service-cidr=10.221.0.0/16"
          "--write-kubeconfig-mode 0640"
          "--write-kubeconfig-group kubeconfig"
          "--resolv-conf=/etc/resolv.conf"
          "--node-label node.longhorn.io/create-default-disk=config"
          "--supervisor-metrics=true"
          "--tls-san ${config.networking.hostName}.home"
          "--tls-san ${config.networking.hostName}.thehellings.lan"
          "--tls-san ${config.networking.hostName}.shire-zebra.ts.net"
        ];
        manifests = {
          cert-manager.source = cert-manager;
          flux.source = flux;
          node-annotations.source = ../../manifests/auto/nodes.yaml;
          operator-oauth.source = ../../manifests/auto/operator-oauth.yaml;
        };
        role = if cfg.agentOnly then "agent" else "server";
        serverAddr = lib.mkIf (config.networking.hostName != "isaiah") "https://isaiah.home:6443";
        tokenFile = config.age.secrets.kubernetesToken.path;
      };
      keepalived = {
        enable = true;
        openFirewall = true;
        vrrpInstances.kubernetes = {
          interface = cfg.vipInterface;
          priority = cfg.priority;
          state = if (config.networking.hostName == "isaiah") then "MASTER" else "BACKUP";
          virtualIps = [
            {
              addr = "10.42.5.1/16";
              dev = cfg.vipInterface;
            }
          ];
          virtualRouterId = 77;
          extraConfig = ''
            advert_int 1
          '';
        };
      };
      openiscsi = {
        enable = true;
        name = "${config.networking.hostName}-initiatorhost";
      };
    };

    users = {
      groups.kubeconfig = { };
      users.greg.extraGroups = [ "kubeconfig" ];
    };
  };
}
