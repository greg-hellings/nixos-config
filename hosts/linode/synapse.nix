# Registration of new users is disabled for the public, but I can create
# them by the following commands:
# nix run nixpkgs.matrix-synapse
# register_new_matrix_user -k "B9EoPr2WV9hzwc7uL2Sx1JmvCeKDEOGCpB0uginQcQtEH4wzRtkSIdo7lltrjSQa" http://localhost:8448
{ config, pkgs, ... }:
let
	domain = "${config.networking.domain}";
	fqdn = "matrix.${domain}";
	fbRegistration = import ./synapse.nix.crypt {};
	fbRegistrationFile = "matrix/mautrix-facebook.json";
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

	environment.etc."${fbRegistrationFile}".text = builtins.toJSON fbRegistration;

	services.matrix-synapse = {
		enable = true;
		# Identify ourselves as the root of our own domain
		settings = {
			database.args = {
				user = "matrix-synapse";
				name = "synapse";
			};
			server_name = "thehellings.com";
			#registration_shared_secret = "B9EoPr2WV9hzwc7uL2Sx1JmvCeKDEOGCpB0uginQcQtEH4wzRtkSIdo7lltrjSQa";
			# Bind a single listener to localhost only, disable SSL/TLS, and put
			# it behind an nginx proxy
			listeners = [ {
				port = 8448;
				bind_addresses = ["127.0.0.1"];
				type = "http";  # Offload SSL/TLS to Nginx
				tls = false;
				resources = [ {
					names = [ "client" "federation" ];
					compress = false;  # Offload compressiong to Nginx
				} ];
			} ];
			app_service_config_files = [
				"/etc/${fbRegistrationFile}"
			];
		};
	};

	# Open networking ports for the server
	networking.firewall = {
		enable = true;
		allowedTCPPorts = [ 80 443 ];
	};

	# Enable Facebook bridge
	services.mautrix-facebook = {
		enable = true;
		settings = {
			homeserver = {
				address = "http://localhost:8448";
				domain = "thehellings.com";
			};
			bridge.permissions = {
				"@admin:thehellings.com" = "admin";
				"thehellings.com" = "user";
			};
			appservice = {
				as_token = fbRegistration.as_token;
				hs_token = fbRegistration.hs_token;
			};
		};
		registrationData = fbRegistration;
	};
}
