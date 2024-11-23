{ pkgs, config, ... }:
let
  conn = "postgresql:///dendrite?sslmode=disable&host=/run/postgresql";
in
{
  imports = [ ./hardware-configuration.nix ];

  environment.systemPackages = with pkgs; [ upgrade-pg-cluster ];

  boot.loader.grub.devices = [ "/dev/vda" ];

  greg = {
    tailscale.enable = true;
  };
  networking = {
    hostName = "vm-matrix";
    domain = "thehellings.lan";
    firewall.allowedTCPPorts = [ config.services.dendrite.httpPort ];
  };

  # Environment secrets
  age = {
    secrets.dendrite = {
      file = ../../secrets/dendrite.age;
      owner = "dendrite";
    };
    secrets.dendrite_key = {
      file = ../../secrets/dendrite_key.age;
      owner = "dendrite";
    };
  };
  users.users = {
    dendrite = {
      isSystemUser = true;
      group = "dendrite";
    };
    greg.initialPassword = "password";
  };
  users.groups.dendrite = { };

  systemd.services.dendrite.serviceConfig = {
    User = "dendrite";
  };

  greg.databases.dendrite = { };

  services.dendrite = {
    enable = true;
    environmentFile = config.age.secrets.dendrite.path;
    httpPort = 8448;
    # Identify ourselves as the root of our own domain
    settings = (
      (builtins.listToAttrs (
        map
          (x: {
            name = x;
            value = {
              database.connection_string = conn;
            };
          })
          [
            "app_service_api"
            "federation_api"
            "key_server"
            "media_api"
            "mscs"
            "relay_api"
            "room_server"
            "sync_api"
          ]
      ))
      // {
        user_api.account_database.connection_string = conn;
        user_api.device_database.connection_string = conn;
        global = {
          database = {
            connection_string = conn;
            max_open_conns = 25;
            max_idle_conns = 5;
            conn_max_lifetime = -1;
          };
          server_name = "thehellings.com";
          trusted_third_party_id_servers = [
            "matrix.org"
            "vector.im"
            "jupiterbroadcasting.com"
          ];
          # Generate this with {path-to-dendrite}/bin/generate-keys --private-key /etc/dendrite.pem
          private_key = config.age.secrets.dendrite_key.path;
        };
        client_api = {
          registration_disabled = true;
          registration_shared_secret = "\${REGISTRATION_SHARED_SECRET}";
        };
      }
    );
  };

  systemd.services.dendrite = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
  };
}
