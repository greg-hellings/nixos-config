{
  config,
  metadata,
  modulesPath,
  ...
}:
{
  imports = [ "${modulesPath}/virtualisation/proxmox-image.nix" ];

  # Wealthfolio (https://wealthfolio.app/) secrets.
  #
  # NOTE for first deploy: `money` doesn't have a real SSH host key yet (this
  # is scaffolding ahead of the box existing), so it isn't in the `systems`
  # list in secrets/secrets.nix and can't decrypt anything encrypted today.
  # After the host is actually installed and up:
  #   1. Add money's real `pubkey` (its /etc/ssh host ed25519 key) to
  #      network.json, same as every other host.
  #   2. Re-key existing secrets so money can decrypt them:
  #        agenix rekey
  #   3. Create the two secrets below with real values:
  #        openssl rand -base64 32 | agenix -e secrets/wealthfolio-secret-key.age
  #        printf '<password>' | argon2 <16+ char salt> -id -e | agenix -e secrets/wealthfolio-auth-hash.age
  #      (argon2-utils package provides the `argon2` CLI.)
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

  nix.settings = {
    sandbox = false;
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

    # Wealthfolio: open-source personal investment/net-worth tracker.
    # https://wealthfolio.app/ - self-hosted web mode ships as a single
    # Axum server binary (`wealthfolio-server`) backed by an embedded
    # SQLite database, so there's no separate database service to stand
    # up here (unlike services.postgresql-backed apps elsewhere in this
    # repo) - just the app itself plus the restic backup job above
    # covering its SQLite file.
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
