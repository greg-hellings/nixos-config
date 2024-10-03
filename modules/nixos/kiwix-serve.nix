{ config, pkgs, lib, ... }:

let
  cfg = config.services.kiwix-serve;
in
with lib; {
  options.services.kiwix-serve = {
    enable = mkEnableOption "Enable the Kiwix web server";

    port = mkOption {
      type = types.int;
      default = 8888;
      description = "Port to serve the Kiwix HTTP service on";
    };

    path = mkOption {
      type = types.str;
      default = "/var/lib/kiwix-serve/";
      description = "Path to Zim file(s) to serve";
    };

    proxy = mkOption {
      type = types.str;
      default = "";
      description = ''Upstream proxy, if any, to configure with kiwix. Specify
				host and port. E.g. "localhost:8080"
			'';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.kiwix-tools
    ];

    systemd.services.kiwix-serve = {
      enable = true;
      after = [ "network.service" ];
      description = "Runs the kiwix-serve binary as a sysmted service";
      restartTriggers = [ pkgs.kiwix-tools ];
      wantedBy = [ "multi-user.target" ];
      script = "${pkgs.kiwix-tools}/bin/kiwix-serve --port ${toString cfg.port} ${cfg.path}";
      environment = {
        UPSTREAM_HOST = mkIf (cfg.proxy != "") cfg.proxy;
        UPSTREAM_WIKI = mkIf (cfg.proxy != "") cfg.proxy;
      };
    };
  };
}
