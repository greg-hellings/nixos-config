# Registration of new users is disabled for the public, but I can create
# them by the following commands:
# nix run nixpkgs.matrix-synapse
# register_new_matrix_user -k "B9EoPr2WV9hzwc7uL2Sx1JmvCeKDEOGCpB0uginQcQtEH4wzRtkSIdo7lltrjSQa" http://localhost:8448
{ config, pkgs, ... }:
let
	domain = "${config.networking.domain}";
	fqdn = "matrix.${domain}";
	conn = "postgresql:///dendrite?sslmode=disable&host=/run/postgresql";
in
{
	services.nginx = {
		virtualHosts = {
			# Server the '.well-known' files to find the Matrix API server
			"${domain}" = {
				enableACME = true;
				forceSSL = true;

				# This is needed so that servers contacting hellings.com can find
				# the actual application server at matrix.thehellings.com
				locations."= /.well-known/matrix/server".extraConfig =
					let
						server = { "m.server" = "${fqdn}:443"; };
					in ''
add_header Content-Type application/json;
return 200 '${builtins.toJSON server}';
'';

				locations."= /.well-known/matrix/client".extraConfig =
					let
						client = {
							"m.homeserver" = { "base_url" = "https://${fqdn}"; };
							"m.identity_server" = { "base_url" = "https://vector.im"; };
						};
					in ''
add_header Content-Type application/json;
add_header Access-Control-Allow-Origin *;
return 200 '${builtins.toJSON client}';
'';
			};

			# Reverse proxy in front of the actual Matrix server
			"${fqdn}" = {
				enableACME = true;
				forceSSL = true;

				# Not the appropriate place for the chat client
				locations."/".extraConfig = "return 404;";

				locations."/_matrix" = {
					proxyPass = "http://matrix.shire-zebra.ts.net:8448"; # Lacking the trailing / is correct
				};
			};
		};
	};

	# Open networking ports for the server
	networking.firewall = {
		enable = true;
		allowedTCPPorts = [ 80 443 ];
	};
}
