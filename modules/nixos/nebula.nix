{
  config,
  lib,
  metadata,
  ...
}:

# Nebula overlay mesh network module (greg namespace)
#
# This module configures a Nebula node for the nebula.thehellings.com overlay.
# CIDR: 10.157.0.0/16
# Lighthouse: linode (public internet, acts as relay too)
#
# Each host requires:
#   secrets/nebula/<hostname>.key.age  - encrypted private key
#   secrets/nebula/<hostname>.crt      - certificate (public, unencrypted in repo)
#   secrets/nebula/ca.crt              - CA certificate (public, unencrypted in repo)
#
# The nebula IP for each host must be set in network.json under
#   hosts.<name>.nebulaIp  (e.g. "10.157.0.1")
#
# Lighthouse address is the public IP/DNS of linode.  Update the
# `lighthouseAddrs` option below or override per-host if it changes.

let
  cfg = config.greg.nebula;
  nebulaDomain = "nebula.thehellings.com";
  # Linode's public address — used by all non-lighthouse hosts to reach it.
  # Override with greg.nebula.lighthouseAddr if the public IP ever changes.
  defaultLighthouseAddr = "linode.${nebulaDomain}";
in
{
  options.greg.nebula = {
    enable = lib.mkEnableOption "Nebula overlay mesh network";

    isLighthouse = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this host is a Nebula lighthouse/relay node";
    };

    isRelay = lib.mkOption {
      type = lib.types.bool;
      default = cfg.isLighthouse;
      description = "Whether this host acts as a relay (am_relay). Defaults to true when isLighthouse is true.";
    };

    nebulaIp = lib.mkOption {
      type = lib.types.str;
      description = "This host's Nebula overlay IP (e.g. 10.157.0.1)";
      default =
        let
          hostData = metadata.hosts.${config.networking.hostName} or { };
        in
        hostData.nebulaIp or (throw "greg.nebula.nebulaIp must be set for host ${config.networking.hostName}");
    };

    lighthouseAddr = lib.mkOption {
      type = lib.types.str;
      default = defaultLighthouseAddr;
      description = "Public address (host:port) used to reach the lighthouse from non-lighthouse hosts";
    };

    lighthouseNebulaIp = lib.mkOption {
      type = lib.types.str;
      default =
        let
          linodeData = metadata.hosts.linode or { };
        in
        linodeData.nebulaIp or "10.157.0.1";
      description = "Nebula overlay IP of the lighthouse host";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 4242;
      description = "UDP port Nebula listens on";
    };

    # unsafe_routes: allow non-Nebula subnets to be routed through this host.
    # Used on genesis to expose 10.42.0.0/16 (the home LAN) to the overlay.
    unsafeRoutes = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            route = lib.mkOption {
              type = lib.types.str;
              description = "CIDR to route through this host (e.g. 10.42.0.0/16)";
            };
            via = lib.mkOption {
              type = lib.types.str;
              description = "Nebula overlay IP of the host that provides the route";
            };
          };
        }
      );
      # Default: route the home LAN through genesis (the home router node).
      # Hosts that ARE genesis (or any other routing node) should override this to [].
      default = [
        {
          route = "10.42.0.0/16";
          via = "10.157.0.2"; # genesis's Nebula IP
        }
      ];
      description = ''
        List of unsafe_routes to configure on this host (for reaching non-Nebula subnets).
        Defaults to routing the home LAN (10.42.0.0/16) through genesis (10.157.0.2).
        Override to [] on hosts that are themselves a routing node (e.g. genesis).
      '';
    };

    # Whether this host IS the router for an unsafe subnet
    # (enables IP forwarding + nftables masquerade for the home LAN)
    routesSubnet = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        When set, this host will route traffic from the Nebula overlay
        to this subnet.  Enables IP forwarding and nftables masquerade.
        Example: "10.42.0.0/16"
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # agenix: decrypt this host's Nebula private key at boot
    age.secrets."nebula-${config.networking.hostName}-key" = {
      file = ../../secrets/nebula/${config.networking.hostName}.key.age;
      # nebula service runs as root, key owned by root is fine
      mode = "0400";
    };

    services.nebula.networks.${nebulaDomain} = {
      enable = true;

      # CA certificate (public — lives unencrypted in the repo)
      ca = ../../secrets/nebula/ca.crt;

      # Host certificate (public — lives unencrypted in the repo)
      cert = ../../secrets/nebula/${config.networking.hostName}.crt;

      # Private key (agenix-decrypted at runtime)
      key = config.age.secrets."nebula-${config.networking.hostName}-key".path;

      # Static host map: tell every node where the lighthouse lives
      staticHostMap = {
        "${cfg.lighthouseNebulaIp}" = [ "${cfg.lighthouseAddr}:${toString cfg.port}" ];
      };

      isLighthouse = cfg.isLighthouse;
      isRelay = cfg.isRelay;

      listen = {
        host = "0.0.0.0";
        # Lighthouses and relays need a fixed port; regular nodes use 0 (OS-assigned)
        port = if (cfg.isLighthouse || cfg.isRelay) then cfg.port else null;
      };

      lighthouses = lib.optionals (!cfg.isLighthouse) [ cfg.lighthouseNebulaIp ];

      relays = lib.optionals (!cfg.isLighthouse && !cfg.isRelay) [ cfg.lighthouseNebulaIp ];

      tun = {
        # Interface name
        device = "nebula0";
      };

      settings.tun.unsafe_routes = map (r: { route = r.route; via = r.via; }) cfg.unsafeRoutes;

      # Firewall: permissive defaults — tighten per-host as desired
      firewall = {
        outbound = [
          {
            port = "any";
            proto = "any";
            host = "any";
          }
        ];
        inbound =
          [
            # Allow ICMP (ping) from any Nebula peer
            {
              port = "any";
              proto = "icmp";
              host = "any";
            }
            # Allow all traffic from within the Nebula overlay
            {
              port = "any";
              proto = "any";
              host = "any";
            }
          ]
          # When routing an unsafe subnet, allow inbound traffic destined
          # for that subnet from any Nebula peer (local_cidr scopes it)
          ++ lib.optionals (cfg.routesSubnet != null) [
            {
              port = "any";
              proto = "any";
              host = "any";
              local_cidr = cfg.routesSubnet;
            }
          ];
      };
    };

    # Open the Nebula UDP port in the firewall
    networking.firewall.allowedUDPPorts = [ cfg.port ];

    # When this host routes traffic to a non-Nebula subnet, enable IP
    # forwarding and add nftables masquerade rules (see unsafe_routes guide).
    boot.kernel.sysctl = lib.mkIf (cfg.routesSubnet != null) {
      "net.ipv4.ip_forward" = lib.mkDefault "1";
    };

    networking.nftables.tables = lib.mkIf (cfg.routesSubnet != null) {
      nebula_routing = {
        family = "ip";
        content = ''
          chain postrouting {
            type nat hook postrouting priority srcnat; policy accept;
            ip saddr 10.157.0.0/16 ip daddr ${cfg.routesSubnet} counter masquerade
          }

          chain forward {
            type filter hook forward priority filter; policy accept;
            ct state related,established counter accept
            iifname "nebula0" ip saddr 10.157.0.0/16 ip daddr ${cfg.routesSubnet} counter accept
          }
        '';
      };
    };
  };
}
