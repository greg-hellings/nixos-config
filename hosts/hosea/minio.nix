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

	environment.systemPackages = with pkgs; [
		minio-client
	];
}
