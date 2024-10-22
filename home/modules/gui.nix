{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.greg.gui;

  excludes = systems: opts: (if (builtins.all (x: pkgs.system != x) systems) then opts else [ ]);

  vars = {
    XDG_CURRENT_DESKTOP = "GNOME";
  };
in
{
  options.greg.gui = lib.mkEnableOption "Enable GUI programs";

  config = (
    lib.mkIf cfg {
      # These packages are Linux only
      home.packages =
        with pkgs;
        (excludes
          [
            "x86_64-darwin"
            "aarch64-darwin"
          ]
          [
            cdrtools
            element-desktop
            freetube
            qpwgraph
            vlc
            x265
          ]
        )
        ++

          # x86_64-linux only
          (excludes
            [
              "x86_64-darwin"
              "aarch64-darwin"
              "aarch64-linux"
            ]
            [
              bitwarden
              discord
              endeavour
              gnucash
              jellyfin-media-player
              #logseq
              nextcloud-client
              slack
            ]
          )
        ++

          # Items that are not supported on ARM/Linux
          (excludes [ "aarch64-linux" ] [
            onlyoffice-bin
            synology-drive-client
            zoom-us
          ]);

      programs.firefox = {
        enable = (!pkgs.stdenv.hostPlatform.isDarwin);
        package = pkgs.firefox-bin;
        policies = {
          DisableAppUpdate = true;
        };
        profiles = {
          default = {
            bookmarks = import ./gui/bookmarks.nix;
            id = 0;
            isDefault = true;
            search = {
              default = "DuckDuckGo";
              force = true;
              engines = {
                Google.metaData.alias = "@g";
                "Nix Packages" = {
                  urls = [
                    {
                      template = "https://search.nixos.org/packages";
                      params = [
                        {
                          name = "type";
                          value = "packages";
                        }
                        {
                          name = "query";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];
                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@np" ];
                };
                "Nix Options" = {
                  urls = [
                    {
                      template = "https://search.nixos.org/options";
                      params = [
                        {
                          name = "type";
                          value = "packages";
                        }
                        {
                          name = "query";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];
                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@no" ];
                };
                "Noogle" = {
                  urls = [
                    {
                      template = "https://noogle.dev/q";
                      params = [
                        {
                          name = "term";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];
                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@nl" ];
                };
              };
            };
            settings = {
              "app.update.auto" = false;
              "browser.ctrlTab.sortByRecentlyUsed" = true;
              "browser.startup.page" = 3;
              "browser.startup.homepage" = "https://thehellings.com";
              "doh-rollout.doorhanger-decision" = "UIDisabled";
              "doh-rollout.doneFirstRun" = true;
              "signon.rememberSignons" = false;
            };
            extensions = with pkgs.nur.repos.rycee.firefox-addons; [
              bitwarden
              gsconnect
              foxyproxy-standard
              multi-account-containers
              octotree
              okta-browser-plugin
              refined-github
              tree-style-tab
              ublock-origin
            ];
          };
        };
      };

      # This is supposed to be in support of Firefox, but I dunno...
      programs.bash.sessionVariables = vars;
      programs.xonsh.sessionVariables = vars;
    }
  );
}
