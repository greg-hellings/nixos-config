{ ... }:

let
in {
	fileSystems."serve" = {
		#device = "10.42.1.4:/volume1/icdm-mysql/";
		#fsType = "nfs";
		device = "/dev/sdb1";
		fsType = "auto";
		mountPoint = "/srv";
	};
}
