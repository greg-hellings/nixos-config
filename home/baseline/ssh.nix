{ lib, ... }:

{
  # Workaround to set the config value to user read-only
  # This allows things like SSH in distrobox to read the config file just fine
  home.file.".ssh/config" = {
    target = ".ssh/config_source";
    onChange = "cat ~/.ssh/config_source > ~/.ssh/config && chmod 600 ~/.ssh/config";
  };
  programs.ssh = {
    enable = true;

    includes = [ "config.local" ];
    enableDefaultConfig = false;

    settings =
      let
        nas = {
          User = "admin";
        };
        owned = {
          User = "greg";
        };
      in
      {
        inherit nas;

        "*" = {
          DynamicForward = [ "10240" ];
          ServerAliveInterval = 60;
          LogLevel = "error";
          SetEnv = { TERM = "xterm-256color"; };
        };

        "10.42.1.4" = lib.hm.dag.entryBefore [ "10.42.*" ] nas;
        "nas.thehellings.lan" = nas;
        "nas.greg-hellings.gmail.com.beta.tailscale.net" = nas;
        chronicles = nas;
        "chronicles.thehellings.lan" = lib.hm.dag.entryBefore [ "*.thehellings.lan" ] nas;

        gh = {
          User = "git";
          Hostname = "github.com";
        };
        "src" = {
          User = "git";
          Hostname = "jeremiah.shire-zebra.ts.net";
          Port = 32222;
        };
        srcpub = {
          User = "git";
          Hostname = "src.thehellings.com";
          Port = 2222;
        };
        ivr = {
          User = "git";
          Hostname = "gitlab.com";
        };

        "ivr.thehellings.lan" = lib.hm.dag.entryBefore [ "ivr" ] {
          User = "gregory.hellings";
        };

        "*.thehellings.lan" = owned;
        "10.42.*" = owned;

        "host.crosswire.org crosswire" = {
          Hostname = "host.crosswire.org";
          User = "ghellings";
        };

        fedpeople = {
          Hostname = "fedorapeople.org";
          User = "greghellings";
        };

        "src.fedoraproject.org pkgs.fedoraproject.org" = {
          User = "greghellings";
        };

        "127.*" = {
          PubkeyAcceptedAlgorithms = "+ssh-rsa";
          HostkeyAlgorithms = "+ssh-rsa";
        };
      };
  };
}
