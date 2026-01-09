[
  {
    name = "Toolbar";
    toolbar = true;
    bookmarks = [
      {
        name = "Allow Paste";
        url = ''
          javascript: (function () {
            allowCopyAndPaste = function (e) {
              e.stopImmediatePropagation();
              return true;
            };
            document.addEventListener("copy", allowCopyAndPaste, true);
            document.addEventListener("paste", allowCopyAndPaste, true);
            document.addEventListener("onpaste", allowCopyAndPaste, true);
          })();
        '';
      }
      {
        name = "Ansible";
        bookmarks = [
          {
            name = "Collection Index";
            url = "https://docs.ansible.com/ansible/latest/collections/index.html";
          }
        ];
      }
      {
        name = "Church";
        bookmarks = [
          {
            name = "DC4K";
            url = "https://www.dc4k.org/leaderzone/articles";
          }
        ];
      }
      {
        name = "IVR";
        bookmarks = [
          {
            name = "Dev";
            bookmarks = [
              {
                name = "Core Survey";
                url = "https://webdev5.ivrtechnology.com/coreservices/survey/admin/";
              }
              {
                name = "Audio";
                url = "https://apidev1.ivrtechnology.com/coreservices/audio/admin/";
              }
              {
                name = "Tower";
                url = "https://towerrd1.ivrtechnology.com";
              }
            ];
          }
          {
            name = "HC";
            bookmarks = [
              {
                name = "Audio";
                url = "https://hcweb3.ivrtechnology.com/coreservices/audio/admin/";
              }
              {
                name = "Survey";
                url = "https://hcweb2.ivrtechnology.com/coreservices/survey/admin/";
              }
            ];
          }
          {
            name = "PCI";
            bookmarks = [
              {
                name = "Audio";
                url = "https://pciweb3.ivrtechnology.com/coreservices/audio/admin/";
              }
            ];
          }
          {
            name = "IC";
            bookmarks = [
              {
                name = "Azure Portal/Console";
                url = "https://portal.azure.com";
              }
              {
                name = "Azure Code";
                url = "https://dev.azure.com";
              }
            ];
          }
          {
            name = "Processes";
            bookmarks = [
              {
                name = "Change Management";
                url = "https://ivrtg.atlassian.net/wiki/spaces/ITS/pages/13094842/Executing+Change+Management";
              }
              {
                name = "Okta";
                url = "https://engagesmart.okta.com/";
              }
              {
                name = "DB Request";
                url = "https://ivrtg.aha.io/develop/features/INFR-1073";
              }
              {
                name = "Deploy";
                url = "https://ivrtg.aha.io/develop/features/EN-1000";
              }
              {
                name = "Server list";
                url = "https://ivrtg.atlassian.net/wiki/spaces/ITS/pages/13009166/350+Main";
              }
            ];
          }
        ];
      }
      {
        name = "Katie";
        bookmarks = [
          {
            name = "Sports Forms";
            url = "https://midlothianisd.rankone.com/New/NewStudentList.aspx";
          }
          {
            name = "Skyward";
            url = "https://skyward.iscorp.com/MidlothianISDTXStuSTS/Session/Signin?area=Home&controller=Home&action=Index&logoutreason=TimedOut";
          }
        ];
      }
      {
        name = "Nix";
        bookmarks = [
          {
            name = "Package Versions";
            url = "https://lazamar.co.uk/nix-versions/?channel=nixpkgs-unstable&package=python3";
          }
          {
            name = "Channel status";
            url = "https://status.nixos.org/";
          }
          {
            name = "Home Manager options";
            url = "https://nix-community.github.io/home-manager/options.xhtml";
          }
          {
            name = "Flake Parts";
            url = "https://community.flake.parts/";
          }
          {
            name = "Language ref";
            url = "https://nix.dev/manual/nix/latest/language/index.html";
          }
          {
            name = "Builtin functions";
            url = "https://nix.dev/manual/nix/latest/language/builtins.html";
          }
          {
            name = "Nixpkgs functions";
            url = "https://ryantm.github.io/nixpkgs/functions/library/strings/#sec-functions-library-strings";
          }
          {
            name = "Noogle";
            url = "https://noogle.dev/";
          }
          {
            name = "NUR search";
            url = "https://nur.nix-community.org/";
          }
          {
            name = "runNixOSTest";
            url = "https://nixos.org/manual/nixos/stable/index.html#sec-calling-nixos-tests";
          }
        ];
      }
      {
        name = "Rust";
        bookmarks = [
          {
            name = "Learn Rust";
            url = "https://www.rust-lang.org/learn";
          }
          {
            name = "Rust by Example";
            url = "https://doc.rust-lang.org/rust-by-example/hello.html";
          }
          {
            name = "Iced";
            url = "https://docs.rs/iced/latest/iced/";
          }
        ];
      }
      {
        name = "Shopping";
        bookmarks = [
          {
            name = "Cables";
            url = "https://www.pchcables.com";
          }
        ];
      }
      {
        name = "Tools";
        bookmarks = [
          {
            name = "Proxmoxes";
            bookmarks = [
              {
                name = "PVE1";
                url = "https://10.42.1.1:8006/";
              }
              {
                name = "Jeremiah";
                url = "https://jeremiah.shire-zebra.ts.net:8006/";
              }
            ];
          }
          {
            name = "Kubernetes";
            bookmarks = [
              {
                name = "CloudNative PG";
                url = "https://cloudnative-pg.io/documentation/1.26/";
              }
              {
                name = "Kubernetes Dashboard";
                url = "https://dashboard.shire-zebra.ts.net/";
              }
              {
                name = "Longhorn";
                url = "http://longhorn.shire-zebra.ts.net";
              }
              {
                name = "PGAdmin4";
                url = "http://pgadmin.shire-zebra.ts.net/";
              }
            ];
          }
          {
            name = "Status";
            bookmarks = [
              {
                name = "Grafana";
                url = "http://hosea.shire-zebra.ts.net:3000/";
              }
              {
                name = "Prometheus";
                url = "http://prometheus.shire-zebra.ts.net/";
              }
              {
                name = "Smokeping";
                url = "https://ping.shire-zebra.ts.net/smokeping/smokeping.cgi";
              }
              {
                name = "Uptime Kuma";
                url = "https://kuma.shire-zebra.ts.net";
              }
            ];
          }
          {
            name = "Bitcoin";
            bookmarks = [
              {
                name = "Bitcoin dashboard";
                url = "http://hosea.shire-zebra.ts.net:60845/";
              }
              {
                name = "Ride the Lightning";
                url = "http://hosea.shire-zebra.ts.net:3000/";
              }
            ];
          }
          {
            name = "Infra";
            bookmarks = [
              {
                name = "NAS1 Minio Console";
                url = "http://nas1.shire-zebra.ts.net:30212/";
              }
              {
                name = "NAS1 Minio Direct";
                url = "http://nas1.shire-zebra.ts.net:9002/";
              }
              {
                name = "Chronicles Minio";
                url = "http://chronicles.shire-zebra.ts.net:9001";
              }
              {
                name = "Pinchflat";
                url = "https://pinchflat.shire-zebra.ts.net/";
              }
              {
                name = "Buildbot";
                url = "http://jeremiah.shire-zebra.ts.net:8010/";
              }
            ];
          }
          {
            name = "Password Hash";
            url = "https://unix4lyfe.org/crypt/";
          }
          {
            name = "Keymap editor";
            url = "https://nickcoutsos.github.io/keymap-editor/";
          }
          {
            name = "Syncthing - nas";
            url = "http://nas.home:8384/#";
          }
          {
            name = "Portainer";
            url = "https://nas1.shire-zebra.ts.net:31015";
          }
          {
            name = "Restic";
            url = "http://nas1.shire-zebra.ts.net:30248";
          }
        ];
      }
      {
        name = "REI";
        bookmarks = [
          {
            name = "SubTo";
            bookmarks = [
              {
                name = "Kajabi";
                url = "https://www.subtocourse.com/login";
              }
              {
                name = "SubTo Fund";
                url = "https://frontend.koreconx.com/auth/login";
              }
              {
                name = "Creive Title";
                url = "https://getcreativetitle.com/";
              }
              {
                name = "REI Scripts";
                url = "https://reiconveyorbelt.com/no-excuses/";
              }
              {
                name = "Ellis foreclosures";
                url = "https://co.ellis.tx.us/Archive.aspx?AMID=60";
              }
            ];
          }
          {
            name = "Door Loop";
            url = "https://btrgpm.app.doorloop.com/home";
          }
          {
            name = "HELOC payoff calculator";
            url = "https://acceleratedstrategies.com/free-calculator/";
          }
        ];
      }
    ];
  }
]
