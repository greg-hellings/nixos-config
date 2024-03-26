{ pkgs, config, lib, ... }:

let
	address = (builtins.elemAt config.networking.interfaces.ens18.ipv4.addresses 0).address;
	root_ca = pkgs.writeText "root_ca.crt" (builtins.readFile ../../ca/root_ca.crt);
	intermediate_ca = pkgs.writeText "intermediate_ca.crt" (builtins.readFile ../../ca/intermediate_ca.crt);
in {
	age.secrets.acme_password = {
		file = ../../secrets/acme_password.age;
	};
	age.secrets.intermediate_ca_key = {
		file = ../../secrets/ca/intermediate_key.age;
	};
	age.secrets.root_ca_key.file = ../../secrets/ca/root_key.age;
	systemd.services.step-ca.serviceConfig.Environment = lib.mkForce ["STEPDEBUG=1" "HOME=%S/step-ca"];
	services.step-ca = {
		inherit address;
		enable = false;
		intermediatePasswordFile = config.age.secrets.acme_password.path;
		openFirewall = true;
		port = 8443;
		settings = {
			root = root_ca;
			federatedRoots = null;
			cert = intermediate_ca;
			key = config.age.secrets.intermediate_ca_key.path;
			dnsNames = [
				"10.42.1.5"
				"acme.thehellings.lan"
			];
			logger.format = "text";
			db = {
				type = "badgerv2";
				dataSource = "/var/lib/step-ca/db";
				badgerFileLoadingMode = "";
			};
			authority.provisioners = [ {
				type = "JWK";
				name = "greg@thehellings.com";
				key = {
					use = "sig";
					kty = "EC";
					kid = "1GOpOttYLZtx7XiG79ZycbGcG4ptL0czfohK35SZOEI";
					crv = "P-256";
					alg = "ES256";
					x = "YEWVj5CCoqWQXWqmL0UuORlFY9IEOLcg1jpG1o-wGx4";
					y = "MEpqnJp60VV-SpFtb6m8U-VAYut7R_PKFm07xl7MjBk";
				};
				encryptedKey = "eyJhbGciOiJQQkVTMi1IUzI1NitBMTI4S1ciLCJjdHkiOiJqd2sranNvbiIsImVuYyI6IkEyNTZHQ00iLCJwMmMiOjYwMDAwMCwicDJzIjoieWdfb0lfbWgwbHhPRXdjUTBsd0FnUSJ9.ivdQUFEhs2U8PUBYr8AhQl3hHdb4spF4jvXgqY_hiVgpjB-z3Nn9Uw.u7vrNht_3WD1G97q.mbydlpAQxjtKLkOmmDOUczqscRDPqrUyoPJ1uqXcJDH3vs4KiYlrKRcFLjPy9sWzEL1iIrqjwf3U-3AAx1KNAg7frs2D__MGfOO-U5SdQDVJVAND7KpWOJGJVSb0xioCA6-8ldlP_REqu4ENmkkdw0_6Is2b0p7ZFKqke_fqOOs7osqFAfbMb_WzEWrACLn5A5-Teh2rpEgR-z9zipN6MSEqE6VIQ2BXuv70aHWhslNe1MK1OgTYm9CqA47EMYvQ7HQLPDZAbP56WK84yJLktoXMmnkaKeTtvER0dh4ufyjJHBhecnEranbR5rHc_jV8_qvyWhlqbCrOU_8bWrk.a9SH_q3GKIUsOUSRWkDxQg";
			} ];
			tls = {
				cipherSuites = [
					"TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256"
					"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
				];
				minVersion = 1.2;
				maxVersion = 1.3;
				renegotiation = false;
			};
		};
	};
}
