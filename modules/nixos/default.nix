{ config, pkgs, lib, ... }:

let
  x =
    if builtins.hasAttr "xonsh-unwrapped" pkgs then
      pkgs.xonsh else
      pkgs.xonsh.passthru.wrapper;
in
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
    ./router.nix
    ./rpi4.nix
    ./sway.nix
    ./syncthing.nix
    ./tailscale.nix
    ./vmdev.nix
  ];

  environment.sessionVariables.MOZ_ENABLE_WAYLAND = "0";
  environment.systemPackages = with pkgs; [
    btrfs-progs
    coreutils-full
    efibootmgr
    psmisc
    lshw
    usbutils
    xfsprogs
  ];

  system.stateVersion = "24.05";

  nix = {
    gc.dates = "weekly";
    settings.auto-optimise-store = true;
  };

  # I am a fan of network manager, myself
  networking = {
    search = [
      "thehellings.lan"
      "home"
    ];
    networkmanager.enable = true;
  };

  programs.xonsh = {
    enable = true;
    package = (x.override {
      extraPackages = (ps: with ps; [
        (ps.toPythonModule pkgs.pipenv)
        pyyaml
        requests
        ruamel-yaml
        xonsh-apipenv
        pkgs.nur.repos.xonsh-xontribs.xonsh-direnv
        pkgs.nur.repos.xonsh-xontribs.xontrib-vox
      ]);
    });
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
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    shell = config.programs.xonsh.package;
    openssh.authorizedKeys.keys = lib.strings.splitString "\n" (builtins.readFile ../../home/ssh/authorized_keys);
  };

  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
}
