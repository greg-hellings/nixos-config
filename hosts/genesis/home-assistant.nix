{ pkgs, ... }:

{
  virtualisation.podman.enable = true;

  services.home-assistant = {
    enable = true;
    configDir = "/var/lib/hass";
    extraComponents = [
      "accuweather"
      "calendar"
      "cast"
      "daikin"
      "eufy"
      "lovelace"
      "nest"
      "nextcloud"
      "ping"
      "piper"
      "radio_browser"
      "rainbird"
      "roborock"
      "smart_meter_texas"
      "speedtestdotnet"
      "solaredge"
      "whisper"
      "wiz"
      "wyoming"
      "zwave_js"
    ];
    customComponents = with pkgs.home-assistant-custom-components; [ smartthinq-sensors ];

    config = {
      default_config = { };
      tts = [ { platform = "google_translate"; } ];
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [
          "127.0.0.1"
          "::1"
        ];
        server_host = "127.0.0.1";
      };
      #"automation manual" = *nix config here* and so on
      "automation ui" = "!include automations.yaml";
      "script ui" = "!include scripts.yaml";
      "scene ui" = "!include scenes.yaml";
    };
  };

  # Helps with Voice stuff for Home Assistant
  services.wyoming = {
    faster-whisper.servers = {
      greg = {
        enable = true;
        beamSize = 1; # wut?
        device = "auto"; # Could be CPU or CUDA
        language = "en";
        model = "base-int8";
        uri = "tcp://0.0.0.0:13415";
      };
    };
    piper.servers.greg = {
      enable = true;
      uri = "tcp://0.0.0.0:13416";
      voice = "en_US-amy-medium";
    };
  };

  # Although NixOS has a package for Home Assistant, it is not kept as up to date as the container and the upstream
  # is very vocal about only supporting their own container or the HAOS deployments. So we deploy the container here
  # and avoid any potential messes from that
  virtualisation.oci-containers = {
    backend = "podman";

    # I have ZWave devices. The easiest way to connect to them is the zwavejs2mqtt service running, so we spin up
    # its container and map the ZWave device into it
    containers.zwave = {
      autoStart = false; # We will try to start it with udev.extraRules listed below, as this option starts it too quickly
      image = "zwavejs/zwave-js-ui:latest";
      ports = [
        "8091:8091"
        "3000:3000"
      ];
      volumes = [ "/var/lib/zwave:/usr/src/app/store" ];
      extraOptions = [
        "--device"
        "/dev/serial/by-id/usb-0658_0200-if00:/dev/zwave"
        "--pull=newer"
      ];
      environment = {
        TZ = "America/Chicago";
        CONSOLE_OUTPUT = "true";
      };
    };
  };

  # Both of the above container need storage for their configuration and devices, but it is not created correctly by
  # the container. So we add the creation of /var/lib/{zwave,hass} to the systemd Unit files
  systemd.services = {
    "podman-zwave" = {
      after = [
        "sys-devices-pci0000:00-0000:00:1e.0-0000:02:1b.0-usb2-2\\x2d1-2\\x2d1:1.0-tty-ttyACM0.device"
      ];
      wantedBy = [
        "sys-devices-pci0000:00-0000:00:1e.0-0000:02:1b.0-usb2-2\\x2d1-2\\x2d1:1.0-tty-ttyACM0.device"
      ];
      serviceConfig = {
        StateDirectory = "zwave";
        StateDirectoryMode = pkgs.lib.mkForce "0777";
      };
    };
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="tty", KERNEL=="ttyACM0", TAG+="systemd"
  '';

  greg.proxies = {
    "smart.home".target = "http://127.0.0.1:8123/";
    "smart.thehellings.lan".target = "http://127.0.0.1:8123/";
    "zwave.home".target = "http://127.0.0.1:8091/";
  };

  # Ensure that both ports are up and running. We keep 8123 directly open because we are on the LAN and sometimes want to connect
  # directly for troubleshooting Nginx configuration
  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
  };

  greg.backup.jobs.zwave = {
    src = "/var/lib/zwave";
    dest = "zwave";
    id = "zwave-rsnap";
  };

  greg.backup.jobs.hass-backup = {
    src = "/var/lib/hass";
    dest = "hass";
    id = "hass-rsnap";
  };
}
