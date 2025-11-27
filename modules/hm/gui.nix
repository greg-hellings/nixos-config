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
            onlyoffice-desktopeditors
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
              bitwarden-desktop
              endeavour
              # Is removed because it depends on qt5-qtwebengine
              # jellyfin-media-player
              nextcloud-client
              slack
              (pkgs.zoom-us.overrideAttrs {
                version = "6.2.11.5069";
                src = pkgs.fetchurl {
                  url = "https://zoom.us/client/6.2.11.5069/zoom_x86_64.pkg.tar.xz";
                  hash = "sha256-k8T/lmfgAFxW1nwEyh61lagrlHP5geT2tA7e5j61+qw=";
                };
              })
            ]
          )
        ++

          # Items that are not supported on ARM/Linux
          (excludes
            [ "aarch64-linux" ]
            [
              synology-drive-client
            ]
          );

      programs.firefox = {
        enable = true; # (!pkgs.stdenv.hostPlatform.isDarwin);
        package = pkgs.firefox-bin;
        policies = {
          DisableAppUpdate = true;
        };
        profiles = {
          default = {
            bookmarks = {
              force = true;
              settings = import ./gui/bookmarks.nix;
            };
            id = 0;
            isDefault = true;
            search = {
              default = "ddg";
              force = true;
              engines = {
                google.metaData.alias = "@g";
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
              "browser.startup.homepage" =
                if pkgs.stdenv.hostPlatform.isDarwin then
                  "https://thehellings.com"
                else
                  "https://kuma.shire-zebra.ts.net/";
              "doh-rollout.doorhanger-decision" = "UIDisabled";
              "doh-rollout.doneFirstRun" = true;
              "signon.rememberSignons" = false;
            };
            extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
              bitwarden
              gsconnect
              foxyproxy-standard
              multi-account-containers
              octotree
              okta-browser-plugin
              refined-github
              sponsorblock
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
