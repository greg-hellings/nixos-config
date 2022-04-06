{ config, pkgs, ... }:

{
  # Sets up a basic Gnome installation
  services.xserver = {
    enable = true;
    displayManager = {
      gdm.enable = true;
      gnome.enable = true;
    };
    layout = "us";
    # Trackpad support
    libinput.enable = true;
  };

  programs.dconf.enable = true;

  # Enable some Gnome plugins that I like
  environment.systemPackages = with pkgs; [
    gnome3.adwaita-icon-theme
    gnomeExtensions.appindicator
  ];

  services.udev.packages = with pkgs; [
    gnome3.gnome-settings-daemon
  ];
}
