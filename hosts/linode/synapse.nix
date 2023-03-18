# Registration of new users is disabled for the public, but I can create
# them by the following commands:
# nix run nixpkgs.matrix-synapse
# register_new_matrix_user -k "B9EoPr2WV9hzwc7uL2Sx1JmvCeKDEOGCpB0uginQcQtEH4wzRtkSIdo7lltrjSQa" http://localhost:8448
{ config, pkgs, ... }:
let
	domain = "${config.networking.domain}";
	fqdn = "matrix.${domain}";
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
					proxyPass = "http://127.0.0.1:8448"; # Lacking the trailing / is correct
				};
			};

			# Run Element web
			"chat.${fqdn}" = {
				enableACME = true;
				forceSSL = true;
				serverAliases = [
					"chat.${domain}"
				];
				root = pkgs.element-web.override {
					conf.default_server_config."m.homeserver" = {
						"base_url" = "https://${fqdn}";
						"server_name" = "${fqdn}";
					};
				};
			};
		};
	};

	# Environment secrets
	age.secrets.dendrite = {
		file = ../../secrets/dendrite.age;
		owner = "dendrite";
	};

	users.users.dendrite = {
		isSystemUser = true;
		group = "dendrite";
	};
	users.groups.dendrite = {};

	systemd.services.dendrite.serviceConfig = {
		User = "dendrite";
	};

	services.dendrite = {
		enable = true;
		environmentFile = "/run/agenix/dendrite";
		httpPort = 8448;
		# Identify ourselves as the root of our own domain
		settings = {
			global = {
				database.args = {
					connection_string = "postgresql://dendrite@localhost/dendrite?sslmode=disable";
					max_open_conns = 90;
					max_idle_conns = 5;
					conn_max_lifetime = -1;
				};
				server_name = "thehellings.com";
				trusted_third_party_id_servers = [
					"matrix.org"
					"vector.im"
					"jupiterbroadcasting.com"
				];
				# Generate this with {path-to-dendrite}/bin/generate-keys --private-key /etc/dendrite.pem
				private_key = "/etc/dendrite.pem";
			};
			client_api = {
				egistration_enabled = false;
				registration_shared_secret = "\${REGISTRATION_SHARED_SECRET}";
			};
		};
	};

	# Open networking ports for the server
	networking.firewall = {
		enable = true;
		allowedTCPPorts = [ 80 443 ];
	};
}
