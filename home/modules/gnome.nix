{ config, pkgs, lib, ... }:

let
  gv = lib.hm.gvariant;
  cfg = config.greg.gnome;

in
{
  options.greg.gnome = lib.mkEnableOption "Enable Gnome support and settings";

  config = (lib.mkIf cfg {
    programs.gnome-terminal = lib.mkIf (pkgs.system != "x86_64-darwin") {
      enable = true;
      showMenubar = true;
      themeVariant = "dark";
      profile."95f3c68e-82f3-4f44-ac85-6e075fed80b0" = {
        default = true;
        customCommand = "xonsh -st best";
        loginShell = true;
        scrollbackLines = 65535;
        transparencyPercent = 50;
        visibleName = "greg";
      };
    };

    dconf.settings = {
      "org/gnome/Disks" = {
        image-dir-uri = "file:///home/greg/Downloads";
      };
      "org/gnome/desktop/interface" = {
        clock-show-weekday = true;
        color-scheme = "default";
        cursor-size = 24;
        toolbar-style = "text";
      };
      "org/gnome/desktop/screensaver" = {
        lock-delay = "uint32 0";
        lock-enabled = false;
      };
      "org/gnome/desktop/wm/keybindings" = {
        switch-applications = [ ];
        switch-applications-backward = [ ];
        switch-windows = [ "<Alt>Tab" ];
        switch-windows-backward = [ "<Shift><Alt>Tab" ];
      };
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "icon:minimize,maximize,close";
      };
      "org/gnome/file-roller/listing" = {
        list-mode = "as-folder";
        name-coloumn-width = 302;
        show-path = true;
        sort-method = "name";
        sort-type = "ascending";
      };
      "org/gnome/nautilus/preferences" = {
        default-folder-viewer = "icon-view";
        search-filter-time-type = "last_modified";
        search-view = "list-view";
      };
      "org/gnome/shell" = {
        enabled-extensions = [
          "appindicatorsupport@rgcjonas.gmail.com"
          "Vitals@CoreCoding.com"
          "window-list@gnome-shell-extensions.gcampax.github.com"
          "gsconnect@andyholmes.github.io"
        ];
        favorite-apps = [
          "org.gnome.Calendar.desktop"
          "org.gnome.Nautilus.desktop"
          "org.gnome.Terminal.desktop"
          "firefox.desktop"
          "vlc.desktop"
        ];
        remember-mount-password = true;
      };
      "org/gnome/shell/extensions/vitals" = {
        hot-sensors = [
          "_memory_usage_"
          "_system_load_1m_"
          "__network-rx_max__"
          "_temperature_k10temp_tccd1_"
          "_temperature_k10temp_tctl_"
        ];
      };
      "org/gnome/shell/overrides" = {
        attach-modal-dialogs = true;
        dynamic-workspaces = true;
        edge-tiling = true;
        focus-change-on-pointer-rest = true;
        workspaces-only-on-primary = true;
      };
      "org/gnome/shell/weather" = {
        automation-location = true;
        locations = "[<(uint32 2, <('Midlothian / Waxahachie, Mid-Way Regional Airport', 'KJWY', false, [(0.5664611473274288, -1.691437359323684)], @a(dd) [])>)>]";
      };
      "org/gnome/shell/window-switcher" = {
        app-icon-mode = "both";
        current-workspace-only = true;
      };
      "org/gtk/settings/file-chooser" = {
        location-mode = "path-bar";
        show-hidden = false;
        show-size-column = true;
        sort-column = "modified";
        sort-directories-first = false;
        sort-order = "descending";
      };
      "org/virt-manager/virt-manager/confirm" = {
        delete-storage = true;
        forcepoweroff = false;
      };
      "org/virt-manager/virt-manager/details" = {
        show-toolbar = true;
      };
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///session" "qemu:///system" ];
        uris = [ "qemu:///session" "qemu:///system" ];
      };
    };
  });
}
