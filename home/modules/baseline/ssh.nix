{ lib, ... }:

{
  # Workaround to set the config value to user read-only
  # This allows things like SSH in distrobox to read the config file just fine
  home.file.".ssh/config" = {
    target = ".ssh/config_source";
    onChange = ''cat ~/.ssh/config_source > ~/.ssh/config && chmod 600 ~/.ssh/config'';
  };
  programs.ssh = {
    enable = true;
    serverAliveInterval = 60;

    includes = [ "config.local" ];

    matchBlocks =
      let
        nas = {
          user = "admin";
        };
        owned = {
          user = "greg";
        };
      in
      {
        inherit nas;

        "*" = {
          dynamicForwards = [ { port = 10240; } ];
        };

        "10.42.1.4" = lib.hm.dag.entryBefore [ "10.42.*" ] nas;
        "nas.thehellings.lan" = nas;
        "nas.greg-hellings.gmail.com.beta.tailscale.net" = nas;
        chronicles = nas;
        "chronicles.thehellings.lan" = lib.hm.dag.entryBefore [ "*.thehellings.lan" ] nas;

        gh = {
          user = "git";
          hostname = "github.com";
        };
        "src" = {
          user = "gitlab";
          hostname = "git.thehellings.lan";
        };
        srcpub = {
          user = "gitlab";
          hostname = "src.thehellings.com";
          port = 2222;
        };
        ivr = {
          user = "git";
          hostname = "gitlab.com";
        };

        "ivr.thehellings.lan" = lib.hm.dag.entryBefore [ "ivr" ] {
          user = "gregory.hellings";
        };

        "*.thehellings.lan" = owned;
        "10.42.*" = owned;

        "host.crosswire.org crosswire" = {
          hostname = "host.crosswire.org";
          user = "ghellings";
        };

        fedpeople = {
          hostname = "fedorapeople.org";
          user = "greghellings";
        };

        "src.fedoraproject.org pkgs.fedoraproject.org" = {
          user = "greghellings";
        };

        "127.*".extraOptions = {
          PubkeyAcceptedAlgorithms = "+ssh-rsa";
          HostkeyAlgorithms = "+ssh-rsa";
        };
      };
  };
}
