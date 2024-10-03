{ config, lib, ... }:

let
  cfg = config.greg.proxies;

  alias = name: with builtins; head (split "\\." name);

  makeHost = name: dest: {
    forceSSL = dest.ssl;
    enableACME = dest.ssl;
    locations."${dest.path}" = {
      proxyPass = dest.target;
      extraConfig = ''
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
      '' + dest.extraConfig;
    };
    serverAliases = lib.mkIf dest.genAliases [ "${alias name}" ];
  };

in
with lib; {
  options = {
    greg.proxies = mkOption {
      default = { };
      example = literalExpression ''
        				{ host-name = {
        					target = proxyLocation;
        					ssl = true;
        				};
        			'';
      description = ''
        				Quick and simple Nginx proxy configurations.
        				Use this to configure a very simple proxy that does not
        				need any extra customization options other than SSL
        				enablement.
        			'';

      type = with types; attrsOf (submodule (
        { ... }:
        {
          options = {
            genAliases = mkOption {
              type = types.bool;
              description = "Whether to auto-generate short alias name";
              default = true;
            };

            target = mkOption {
              type = types.str;
              description = ''The destination that is being proxied.'';
              example = "http://localhost:8080";
            };

            ssl = mkOption {
              type = types.bool;
              description = "Whether to enable SSL in front of the proxy";
              default = false;
            };

            path = mkOption {
              type = types.str;
              description = "The path prefix for this proxy";
              default = "/";
            };

            extraConfig = mkOption {
              type = types.str;
              description = "Extra nginx config options";
              default = "";
            };
          };
        }
      ));
    };
  };

  config.services.nginx = mkIf ((attrValues cfg) != [ ]) {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = mapAttrs makeHost cfg;
  };
}
