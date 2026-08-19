{
  config,
  metadata,
  modulesPath,
  ...
}:
{
  imports = [
    "${modulesPath}/virtualisation/proxmox-image.nix"
  ];

  # Wealthfolio (https://wealthfolio.app/) secrets.
  #   1. Add money's real `pubkey` (its /etc/ssh host ed25519 key) to
  #      network.json, same as every other host.
  #   2. Re-key existing secrets so money can decrypt them:
  #        agenix rekey
  age.secrets = {
    wealthfolio-secret-key.file = ../../../secrets/wealthfolio-secret-key.age;
    wealthfolio-auth-hash.file = ../../../secrets/wealthfolio-auth-hash.age;
  };

  greg = {
    home = true;
    nebula.enable = true;
    proxies =
      let
        tgt = {
          target = "http://localhost:${toString config.services.wealthfolio.port}";
          genAliases = false;
        };
      in
      {
        "money.nebula.thehellings.com" = tgt;
        "money.thehellings.lan" = tgt;
        "money.shire-zebra.ts.net" = tgt;
      };
    backup.jobs.wealthfolio = {
      src = "/var/lib/wealthfolio";
      dest = "wealthfolio";
      # Wealthfolio's data is a single SQLite file (no WAL-safe hot-copy
      # guarantee going through restic's plain file backup), so stop the
      # service for the duration of the snapshot - same pattern as
      # nextcloud/albyhub elsewhere in this repo.
      pre = "systemctl stop wealthfolio || true";
      post = "systemctl start wealthfolio";
    };
  };

  networking = {
    defaultGateway = metadata.infra.gw;
    nameservers = [ metadata.infra.dns ];
    interfaces.ens18 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = metadata.hosts."${config.networking.hostName}".ip;
          prefixLength = 16;
        }
      ];
    };
  };

  proxmox.cloudInit.enable = false;

  services = {
    fstrim.enable = true;

    openssh = {
      enable = true;
      openFirewall = true;
    };

    wealthfolio = {
      enable = true;
      address = "127.0.0.1";
      port = 8088;
      # Not exposed directly; reached only through the nginx proxy
      # configured via greg.proxies above.
      openFirewall = false;
      secretKeyFile = config.age.secrets.wealthfolio-secret-key.path;
      authPasswordHashFile = config.age.secrets.wealthfolio-auth-hash.path;
      authRequired = true;
      # Module asserts this can't be "*" while authRequired is true; list
      # every hostname alias configured above.
      corsAllowOrigins = "http://money.thehellings.lan,http://money.nebula.thehellings.com,http://money.shire-zebra.ts.net";
    };
  };
}
