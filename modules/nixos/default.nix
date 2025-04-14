{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../baseline.nix
    ./backup.nix
    ./ceph.nix
    ./container.nix
    ./db.nix
    ./gnome.nix
    ./home.nix
    ./kde.nix
    ./kiwix-serve.nix
    ./linode.nix
    ./print.nix
    ./proxy.nix
    ./remote-builder.nix
    ./router.nix
    ./rpi4.nix
    ./sway.nix
    ./syncthing.nix
    ./tailscale.nix
    ./vmdev.nix
  ];

  environment.systemPackages = with pkgs; [
    btrfs-progs
    coreutils-full
    efibootmgr
    psmisc
    lshw
    usbutils
    xfsprogs
  ];

  system.stateVersion = "24.11";

  nix = {
    gc.dates = "weekly";
    settings.auto-optimise-store = true;
  };

  # Network Manager pulls in too many deps
  networking = {
    search = [
      "thehellings.lan"
      "home"
    ];
    networkmanager.enable = false;
  };

  programs.xonsh = {
    enable = true;
    extraPackages = (
      ps: with ps; [
        xonsh-apipenv
        pkgs.nur.repos.xonsh-xontribs.xonsh-direnv
        pkgs.nur.repos.xonsh-xontribs.xontrib-vox
      ]
    );
  };

  # Enable the OpenSSH daemon for remote control
  services = {
    openssh = {
      enable = true;
      settings.X11Forwarding = true;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.greg = {
    isNormalUser = true;
    createHome = true;
    extraGroups = [
      "wheel"
    ]; # Enable ‘sudo’ for the user.
    shell = config.programs.xonsh.package;
    initialPassword = "password";
    openssh.authorizedKeys.keys = lib.strings.splitString "\n" (
      builtins.readFile ../../home/ssh/authorized_keys
    );
  };

  security.sudo.extraRules = [
    {
      users = [ "greg" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
}
