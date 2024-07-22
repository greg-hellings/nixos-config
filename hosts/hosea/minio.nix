{ config, pkgs, ... }:

let
	minioPort = 9000;
	minioConsolePort = 9001;
in {
	fileSystems."/proxy" = {
		device = "/dev/sda1";
		fsType = "btrfs";
	};

	networking.firewall.allowedTCPPorts = [
		80
		minioPort
		minioConsolePort
	];

	age.secrets.minio.file = ../../secrets/minio.age;

	services.minio = {
		enable = true;
		dataDir = [ "/proxy/minio" ];
		rootCredentialsFile = config.age.secrets.minio.path;
		browser = true;
	};

	greg.proxies."s3.thehellings.lan".target = "http://127.0.0.1:${toString minioPort}";

	environment.systemPackages = with pkgs; [
		minio-client
	];
}
