{
  config,
  lib,
  pkgs,
  top,
  ...
}:

{
  imports = [
    ./boot.nix
    ./hardware-configuration.nix
    ./virt.nix
    ./work.nix
    top.nix-hardware.nixosModules.system76
  ];

  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

  greg = {
    tailscale.enable = true;
    gnome.enable = true;
    kde.enable = false;
    kubernetes.enable = true;
    podman.enable = true;
    print.enable = true;
    remote-builder.enable = true;
  };

  environment.systemPackages =
    with pkgs;
    lib.mkMerge [
      [
        # for Immersed
        cudatoolkit
        immersed
        libva
      ]
      [
        bind # For things like nslookup
        create_ssl
        distrobox
        expect
        fswatch
        gimp
        go
        gparted
        graphviz
        flock
        ffmpeg
        handbrake
        imagemagick
        libtheora
        libxml2
        linode-cli
        makemkv
        oathToolkit
        usbutils
        ventoy
      ]

      [
        # Video/Audio data composition framework tools like "gst-inspect", "gst-launch" ...
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
        gst_all_1.gst-libav
        gst_all_1.gst-vaapi
      ]
    ];

  hardware = {
    nvidia =
      let
        gpl_symbols_linux_615_patch = pkgs.fetchpatch {
          url = "https://github.com/CachyOS/kernel-patches/raw/914aea4298e3744beddad09f3d2773d71839b182/6.15/misc/nvidia/0003-Workaround-nv_vm_flags_-calling-GPL-only-code.patch";
          hash = "sha256-YOTAvONchPPSVDP9eJ9236pAPtxYK5nAePNtm2dlvb4=";
          stripLen = 1;
          extraPrefix = "kernel/";
        };
      in
      {
        #package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
        package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
          version = "575.57.08";
          openSha256 = "sha256-DOJw73sjhQoy+5R0GHGnUddE6xaXb/z/Ihq3BKBf+lg=";
          sha256_64bit = "sha256-KqcB2sGAp7IKbleMzNkB3tjUTlfWBYDwj50o3R//xvI=";
          settingsSha256 = "sha256-AIeeDXFEo9VEKCgXnY3QvrW5iWZeIVg4LBCeRtMs5Io=";
          persistencedSha256 = "sha256-Len7Va4HYp5r3wMpAhL4VsPu5S0JOshPFywbO7vYnGo=";
          usePersistenced = true;
          patches = [ gpl_symbols_linux_615_patch ];
        };
        modesetting.enable = true;
        powerManagement = {
          enable = false;
          finegrained = false;
        };
        nvidiaSettings = true;
        open = true;
      };
    system76 = {
      firmware-daemon.enable = true;
      #kernel-modules.enable = true;
    };
  };

  networking = {
    hostName = "jude";
    networkmanager.enable = lib.mkForce true;
    enableIPv6 = false;
    useDHCP = false;
    interfaces = {
      # This seems to be direct mother board interface
      enp12s0.useDHCP = true;
      #enp12s0.ipv4.addresses = [
      #{
      #address = "10.42.1.11";
      #prefixLength = 16;
      #}
      #];
      # This seems to be the one that comes through the monitor hookup
      enp14s0u1u2.ipv4.addresses = [
        {
          address = "10.42.1.10";
          prefixLength = 16;
        }
      ];
    };
    defaultGateway = {
      address = "10.42.1.1";
      interface = "enp14s0u1u2";
    };
    nameservers = [
      "10.42.1.5"
      "10.42.1.1"
    ];
    firewall = {
      enable = false;
      allowedTCPPorts = [ 21000 ];
      allowedUDPPorts = [
        21000
        21010
      ];
    };
  };

  programs = {
    adb.enable = true;
    steam.enable = true;
    nix-index = {
      enable = true;
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableZshIntegration = false;
    };
    nix-ld.enable = false;
  };

  # Let's do a sound thing
  services = {
    k3s.extraFlags =
      let
        ip = (builtins.head config.networking.interfaces.enp14s0u1u2.ipv4.addresses).address;
      in
      [
        "--tls-san ${ip}"
        #"--bind-address ${ip}"
      ];
    pipewire = {
      enable = true;
      alsa.enable = true;
      audio.enable = true;
      jack.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    pulseaudio.enable = false; # This conflicts with pipewire
    locate.enable = true;
    xserver.videoDrivers = [ "nvidia" ];
  };

  users.users.greg.extraGroups = [
    "adbusers"
    "kvm"
    "podman"
  ];
}
