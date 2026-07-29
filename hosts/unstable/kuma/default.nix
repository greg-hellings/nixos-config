{
  config,
  metadata,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [ "${modulesPath}/virtualisation/proxmox-image.nix" ];
  greg = {
    home = true;
    nebula.enable = true;
    proxies =
      let
        tgt = {
          target = "http://localhost:${config.services.uptime-kuma.settings.PORT}";
          genAliases = false;
        };
      in
      {
        "kuma.nebula.thehellings.com" = tgt;
        "kuma.thehellings.lan" = tgt;
        "kuma.shire-zebra.ts.net" = tgt;
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
    mysql = {
      enable = true;
      ensureDatabases = [
        config.services.uptime-kuma.settings.UPTIME_KUMA_DB_NAME
      ];
      ensureUsers = [
        {
          name = config.services.uptime-kuma.settings.UPTIME_KUMA_DB_USERNAME;
          ensurePermissions = {
            "uptimekuma.*" = "ALL PRIVILEGES";
          };
        }
      ];
      package = pkgs.mariadb;
    };
    openssh = {
      enable = true;
      openFirewall = true;
    };
    uptime-kuma = {
      enable = true;
      settings = {
        PORT = "3001"; # Default, but this allows us to explicitly use it elsewhere
        UPTIME_KUMA_DB_TYPE = "mariadb";
        UPTIME_KUMA_DB_SOCKET = "/run/mysqld/mysqld.sock";
        UPTIME_KUMA_DB_NAME = "uptimekuma";
        UPTIME_KUMA_DB_USERNAME = "uptimekuma";
        UPTIME_KUMA_DB_PASSWORD = "uptimekuma";
      };
    };
  };
}
