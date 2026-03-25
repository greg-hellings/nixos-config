# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  metadata,
  pkgs,
  ...
}:
let
  wanInterface = "enp2s0";
  lanInterface = "enp1s0";
  lanIpAddress = metadata.hosts.${config.networking.hostName}.ip;
in

{
  imports = [
    # Include the results of the hardware scan.
    ./arr.nix
    ./hardware-configuration.nix
  ];

  age.secrets.grafana-secret-key = {
    file = ../../../secrets/grafana-secret-key.age;
    owner = "grafana";
  };

  # Bootloader
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/";
      };
    };
    extraModprobeConfig = "vboxdrv";
  };

  environment.systemPackages = with pkgs; [
    clinfo
    jellyfin-ffmpeg
    libva-utils
    mesa-demos
    radeontop
    vulkan-tools
  ];

  greg = {
    home = true;
    proxies = {
      "jellyfin.home".target = "http://localhost:8096/";
      "jellyfin.thehellings.lan".target = "http://localhost:8096/";
      "grafana.home".target = "http://localhost:3001/";
      "grafana.thehellings.lan".target = "http://localhost:3001/";
    };
    tailscale = {
      enable = true;
      tags = [ "home" ];
    };
  };

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libva-vdpau-driver
        #intel-media-sdk
        intel-compute-runtime
      ];
    };
  };

  networking = {
    defaultGateway = metadata.infra.gw;
    firewall.allowedTCPPorts = [ 3000 ];
    hostName = "hosea";
    interfaces = {
      "${wanInterface}".useDHCP = true;
      "${lanInterface}" = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = lanIpAddress;
            prefixLength = 16;
          }
        ];
      };
    };
    nameservers = [ metadata.infra.dns ];
  };

  services = {
    albyhub = {
      enable = true;
      openFirewall = true;
      settings = {
        workDir = "/chain/alby";
      };
    };
    jellyfin = {
      enable = true;
      openFirewall = true;
    };
    grafana = {
      enable = true;
      provision = {
        enable = true;
        dashboards.settings.providers = [
          {
            name = "Dashboards";
            disableDeletion = true;
            options = {
              path = "/etc/grafana-dashboards";
              foldersFromFilesStructure = true;
            };
          }
        ];
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            uid = "prometheus";
            url = "https://prometheus.shire-zebra.ts.net";
            isDefault = true;
            editable = false;
          }
        ];
      };
      settings = {
        security.secret_key = "$__file{${config.age.secrets.grafana-secret-key.path}}";
        server = {
          domain = "${config.networking.hostName}.shire-zebra.ts.net";
          enforce_domain = true;
          http_addr = "0.0.0.0";
          enable_gzip = true;
          http_port = 3001;
        };
        analytics.reporting_enabled = false;
      };
    };
    prometheus.exporters.graphite.enable = true;
    # Configure keymap
    xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };

  # After first deploy: create a Grafana service account + API token for Klaatu
  # via the Grafana UI, then encrypt it: agenix -e secrets/grafana-api-token.age
  age.secrets.grafana-api-token = {
    file = ../../../secrets/grafana-api-token.age;
    owner = "grafana";
  };

  environment.etc = {
    "grafana-dashboards/system-health.json".text = ''
      {
        "uid": "system-health",
        "title": "System Health Overview",
        "schemaVersion": 38,
        "version": 1,
        "refresh": "30s",
        "time": {"from": "now-3h", "to": "now"},
        "panels": [
          {
            "id": 1,
            "type": "stat",
            "title": "Hosts Up",
            "gridPos": {"x": 0, "y": 0, "w": 6, "h": 4},
            "targets": [{"datasource": {"type": "prometheus", "uid": "prometheus"}, "expr": "count(up{job=\"node\"} == 1)", "refId": "A"}]
          },
          {
            "id": 2,
            "type": "stat",
            "title": "Hosts Down",
            "gridPos": {"x": 6, "y": 0, "w": 6, "h": 4},
            "targets": [{"datasource": {"type": "prometheus", "uid": "prometheus"}, "expr": "count(up{job=\"node\"} == 0) or vector(0)", "refId": "A"}],
            "fieldConfig": {
              "defaults": {
                "thresholds": {
                  "mode": "absolute",
                  "steps": [{"color": "green", "value": null}, {"color": "red", "value": 1}]
                }
              }
            }
          },
          {
            "id": 3,
            "type": "timeseries",
            "title": "CPU Usage %",
            "gridPos": {"x": 0, "y": 4, "w": 12, "h": 8},
            "targets": [{"datasource": {"type": "prometheus", "uid": "prometheus"}, "expr": "100 - (avg by(instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)", "legendFormat": "{{instance}}", "refId": "A"}]
          },
          {
            "id": 4,
            "type": "timeseries",
            "title": "Memory Usage %",
            "gridPos": {"x": 12, "y": 4, "w": 12, "h": 8},
            "targets": [{"datasource": {"type": "prometheus", "uid": "prometheus"}, "expr": "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100", "legendFormat": "{{instance}}", "refId": "A"}]
          },
          {
            "id": 5,
            "type": "timeseries",
            "title": "Disk Usage % (/)",
            "gridPos": {"x": 0, "y": 12, "w": 12, "h": 8},
            "targets": [{"datasource": {"type": "prometheus", "uid": "prometheus"}, "expr": "100 - ((node_filesystem_avail_bytes{mountpoint=\"/\",fstype!~\"tmpfs|overlay\"} / node_filesystem_size_bytes{mountpoint=\"/\",fstype!~\"tmpfs|overlay\"}) * 100)", "legendFormat": "{{instance}}", "refId": "A"}]
          },
          {
            "id": 6,
            "type": "timeseries",
            "title": "Network RX bytes/s",
            "gridPos": {"x": 0, "y": 20, "w": 12, "h": 8},
            "targets": [{"datasource": {"type": "prometheus", "uid": "prometheus"}, "expr": "rate(node_network_receive_bytes_total{device!~\"lo|tailscale.*\"}[5m])", "legendFormat": "{{instance}} {{device}}", "refId": "A"}]
          },
          {
            "id": 7,
            "type": "timeseries",
            "title": "Network TX bytes/s",
            "gridPos": {"x": 12, "y": 20, "w": 12, "h": 8},
            "targets": [{"datasource": {"type": "prometheus", "uid": "prometheus"}, "expr": "rate(node_network_transmit_bytes_total{device!~\"lo|tailscale.*\"}[5m])", "legendFormat": "{{instance}} {{device}}", "refId": "A"}]
          }
        ]
      }
    '';

    "grafana-dashboards/backup-health.json".text = ''
      {
        "uid": "backup-health",
        "title": "Backup Health",
        "schemaVersion": 38,
        "version": 1,
        "refresh": "30s",
        "time": {"from": "now-3h", "to": "now"},
        "panels": [
          {
            "id": 1,
            "type": "stat",
            "title": "Backup Jobs Reporting",
            "gridPos": {"x": 0, "y": 0, "w": 8, "h": 4},
            "targets": [{"datasource": {"type": "prometheus", "uid": "prometheus"}, "expr": "count(restic_last_success_timestamp_seconds) or vector(0)", "refId": "A"}]
          },
          {
            "id": 2,
            "type": "stat",
            "title": "Stale Backups (>26h)",
            "gridPos": {"x": 8, "y": 0, "w": 8, "h": 4},
            "targets": [{"datasource": {"type": "prometheus", "uid": "prometheus"}, "expr": "count(time() - restic_last_success_timestamp_seconds > 93600) or vector(0)", "refId": "A"}],
            "fieldConfig": {
              "defaults": {
                "thresholds": {
                  "mode": "absolute",
                  "steps": [{"color": "green", "value": null}, {"color": "red", "value": 1}]
                }
              }
            }
          },
          {
            "id": 3,
            "type": "table",
            "title": "Last Backup Times",
            "gridPos": {"x": 0, "y": 4, "w": 24, "h": 10},
            "options": {"instant": true},
            "targets": [{"datasource": {"type": "prometheus", "uid": "prometheus"}, "expr": "restic_last_success_timestamp_seconds", "instant": true, "refId": "A"}],
            "fieldConfig": {"defaults": {"unit": "dateTimeAsLocal"}}
          },
          {
            "id": 4,
            "type": "timeseries",
            "title": "Backup Duration (seconds)",
            "gridPos": {"x": 0, "y": 14, "w": 24, "h": 8},
            "targets": [{"datasource": {"type": "prometheus", "uid": "prometheus"}, "expr": "restic_last_run_duration_seconds", "refId": "A"}]
          }
        ]
      }
    '';

    "grafana-dashboards/kubernetes.json".text = ''
      {
        "uid": "kubernetes-overview",
        "title": "Kubernetes Overview",
        "schemaVersion": 38,
        "version": 1,
        "refresh": "30s",
        "time": {"from": "now-3h", "to": "now"},
        "panels": [
          {
            "id": 1,
            "type": "stat",
            "title": "Running Pods",
            "gridPos": {"x": 0, "y": 0, "w": 6, "h": 4},
            "targets": [{"datasource": {"type": "prometheus", "uid": "prometheus"}, "expr": "count(kube_pod_status_phase{phase=\"Running\"}) or vector(0)", "refId": "A"}]
          },
          {
            "id": 2,
            "type": "stat",
            "title": "Failed Pods",
            "gridPos": {"x": 6, "y": 0, "w": 6, "h": 4},
            "targets": [{"datasource": {"type": "prometheus", "uid": "prometheus"}, "expr": "count(kube_pod_status_phase{phase=\"Failed\"}) or vector(0)", "refId": "A"}],
            "fieldConfig": {
              "defaults": {
                "thresholds": {
                  "mode": "absolute",
                  "steps": [{"color": "green", "value": null}, {"color": "red", "value": 1}]
                }
              }
            }
          },
          {
            "id": 3,
            "type": "stat",
            "title": "Pending Pods",
            "gridPos": {"x": 12, "y": 0, "w": 6, "h": 4},
            "targets": [{"datasource": {"type": "prometheus", "uid": "prometheus"}, "expr": "count(kube_pod_status_phase{phase=\"Pending\"}) or vector(0)", "refId": "A"}],
            "fieldConfig": {
              "defaults": {
                "thresholds": {
                  "mode": "absolute",
                  "steps": [{"color": "green", "value": null}, {"color": "yellow", "value": 1}]
                }
              }
            }
          },
          {
            "id": 4,
            "type": "timeseries",
            "title": "Pod Restart Rate",
            "gridPos": {"x": 0, "y": 4, "w": 24, "h": 8},
            "targets": [{"datasource": {"type": "prometheus", "uid": "prometheus"}, "expr": "topk(10, rate(kube_pod_container_status_restarts_total[15m]) * 900)", "legendFormat": "{{namespace}}/{{pod}}", "refId": "A"}]
          },
          {
            "id": 5,
            "type": "table",
            "title": "All Pods",
            "gridPos": {"x": 0, "y": 12, "w": 24, "h": 10},
            "targets": [{"datasource": {"type": "prometheus", "uid": "prometheus"}, "expr": "kube_pod_status_phase", "instant": true, "refId": "A"}]
          },
          {
            "id": 6,
            "type": "timeseries",
            "title": "Node CPU Usage",
            "gridPos": {"x": 0, "y": 22, "w": 12, "h": 8},
            "targets": [{"datasource": {"type": "prometheus", "uid": "prometheus"}, "expr": "100 - (avg by(node) (rate(node_cpu_seconds_total{mode=\"idle\",job=\"node\"}[5m])) * 100)", "refId": "A"}]
          },
          {
            "id": 7,
            "type": "timeseries",
            "title": "Node Memory Usage %",
            "gridPos": {"x": 12, "y": 22, "w": 12, "h": 8},
            "targets": [{"datasource": {"type": "prometheus", "uid": "prometheus"}, "expr": "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100", "refId": "A"}]
          }
        ]
      }
    '';

    "grafana-dashboards/network.json".text = ''
      {
        "uid": "network-overview",
        "title": "Network & UniFi",
        "schemaVersion": 38,
        "version": 1,
        "refresh": "30s",
        "time": {"from": "now-3h", "to": "now"},
        "panels": [
          {
            "id": 1,
            "type": "stat",
            "title": "DNS Queries/s",
            "gridPos": {"x": 0, "y": 0, "w": 8, "h": 4},
            "targets": [{"datasource": {"type": "prometheus", "uid": "prometheus"}, "expr": "rate(dnsmasq_queries_total[5m]) or vector(0)", "refId": "A"}]
          },
          {
            "id": 2,
            "type": "stat",
            "title": "DHCP Leases",
            "gridPos": {"x": 8, "y": 0, "w": 8, "h": 4},
            "targets": [{"datasource": {"type": "prometheus", "uid": "prometheus"}, "expr": "kea_dhcp4_addresses_assigned_total or vector(0)", "refId": "A"}]
          },
          {
            "id": 3,
            "type": "stat",
            "title": "UniFi Devices",
            "gridPos": {"x": 16, "y": 0, "w": 8, "h": 4},
            "targets": [{"datasource": {"type": "prometheus", "uid": "prometheus"}, "expr": "count(unifipoller_device_uptime_seconds) or vector(0)", "refId": "A"}]
          },
          {
            "id": 4,
            "type": "timeseries",
            "title": "UniFi Port RX (bytes/s)",
            "gridPos": {"x": 0, "y": 4, "w": 12, "h": 8},
            "targets": [{"datasource": {"type": "prometheus", "uid": "prometheus"}, "expr": "rate(unifipoller_port_receive_bytes_total[5m])", "legendFormat": "{{port_id}} {{name}}", "refId": "A"}]
          },
          {
            "id": 5,
            "type": "timeseries",
            "title": "UniFi Port TX (bytes/s)",
            "gridPos": {"x": 12, "y": 4, "w": 12, "h": 8},
            "targets": [{"datasource": {"type": "prometheus", "uid": "prometheus"}, "expr": "rate(unifipoller_port_transmit_bytes_total[5m])", "legendFormat": "{{port_id}} {{name}}", "refId": "A"}]
          },
          {
            "id": 6,
            "type": "timeseries",
            "title": "Ping Latency (ms)",
            "gridPos": {"x": 0, "y": 12, "w": 24, "h": 8},
            "targets": [{"datasource": {"type": "prometheus", "uid": "prometheus"}, "expr": "probe_duration_seconds{job=\"ping\"} * 1000", "legendFormat": "{{instance}}", "refId": "A"}]
          }
        ]
      }
    '';
  };

  users.users = {
    greg.extraGroups = [ "vboxusers" ];

    jellyfin.extraGroups = [
      "video"
      "render"
    ];
  };
}
