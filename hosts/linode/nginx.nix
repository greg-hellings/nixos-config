{ ... }:
let
	homepage = "127.0.0.1:30080";
in
{
	security.acme = {
		acceptTerms = true;
		email = "greg.hellings@gmail.com";
	};

	services.nginx = {
		enable = true;

		# If there are recommended settings, let's use them!
		recommendedGzipSettings = true;
		recommendedOptimisation = true;
		recommendedProxySettings = true;
		recommendedTlsSettings = true;
	};

	# Actually serve the content from here
	virtualisation.podman.enable = true;
	virtualisation.oci-containers = {
		backend = "podman";
		containers."homepage" = {
			image = "ghcr.io/greg-hellings/homepage:latest";
			ports = [ "${homepage}:80" ];
		};
	};
	services.nginx.virtualHosts = {
		"thehellings.com" = {
			locations."/".proxyPass = "http://${homepage}/";
		};
	};
}
