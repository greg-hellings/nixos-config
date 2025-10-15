{ config, pkgs, ... }:

let
  ip = "100.68.203.1";
in
{
  nix-bitcoin = {
    generateSecrets = true;
    operator = {
      enable = true;
      name = "greg";
    };
    useVersionLockedPkgs = true; # Use the exact versions of packages from upstream
  };

  networking.firewall.allowedTCPPorts = with config.services; [
    bitcoind.port
    bitcoind.rpc.port
    lnd.restPort
    lnd.port
    mempool.frontend.port
  ];

  greg.backup.jobs = {
    clightning = {
      src = config.services.clightning.replication.local.directory;
      dest = "hosea-clightning";
    };
  };

  services = {
    backups = {
      enable = true;
      frequency = "hourly";
    };
    bitcoind = {
      enable = true;
      address = "0.0.0.0";
      dataDir = "/chain/bitcoind";
      listen = true;
      rpc = {
        address = ip;
        allowip = [ "100.1.1.1/8" ];
      };
    };
    clightning = {
      enable = true;
      address = ip;
      port = 9736;
      replication = {
        enable = true;
        local.directory = "/var/backup/clightning";
        encrypt = false;
      };
    };
    electrs = {
      enable = true;
      address = ip;
    };
    lnd = {
      enable = true;
      address = ip;
      lndconnect.enable = true;
    };
    mempool = {
      enable = true;
      frontend = {
        enable = true;
        address = ip;
      };
    };
  };

  environment.systemPackages = with pkgs; [ ];
}
