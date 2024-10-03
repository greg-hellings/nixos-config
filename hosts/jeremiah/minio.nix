{ config, pkgs, ... }:

let
  minioPort = 9000;
  minioConsolePort = 9001;
in
{
  environment.systemPackages = with pkgs; [
    minio-client
    xfsprogs
  ];

  greg.proxies."minio-02.thehellings.lan".target = "http://localhost:9000";

  fileSystems."/data/1" = {
    device = "/dev/disk/by-id/ata-ST12000NM0558_ZHZ5YSXW-part1";
    fsType = "xfs";
  };

  networking.firewall.allowedTCPPorts = [
    minioPort
    minioConsolePort
  ];

  age.secrets.minio.file = ../../secrets/minio.age;

  services.minio = {
    enable = true;
    dataDir = [ "/data/1/minio" ];
    rootCredentialsFile = config.age.secrets.minio.path;
    browser = true;
  };
}
