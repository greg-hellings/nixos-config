{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.greg.sway;
  file_browser = {
    pkg = pkgs.krusader;
    path = "${pkgs.krusader}/bin/krusader";
  };
  term = "${pkgs.alacritty}/bin/alacritty";
  msg = "${pkgs.sway}/bin/swaymsg";
  sleep = "${pkgs.coreutils}/bin/sleep";
  workstation1 = pkgs.writeScriptBin "workstation1" (
    builtins.concatStringsSep "\n" [
      "${msg} \"workspace 1 ; exec ${pkgs.firefox}/bin/firefox ; split horizontal ; exec ${pkgs.element-desktop}/bin/element-desktop \""
      "${sleep} 1"
      "${msg} '[app_id=\"firefox\"]' move left"
      "${msg} '[instance=\"element\"]' \"layout tabbed ; exec ${term} \""
      "${msg} '[app_id=\"firefox\"]' move left"
      "${sleep} 0.3"
      "${msg} '[app_id=\"Alacritty\" workspace=\"1\"]' move right"
      "${msg} '[app_id=\"firefox\"]' resize grow width 300 px"
    ]
  );
  workstation2 = pkgs.writeScriptBin "workstation2" (
    builtins.concatStringsSep "\n" [
      "${sleep} 5"
      "${msg} \"workspace 2 ; exec ${term} ; layout tabbed\""
    ]
  );
in
{
  options.greg.sway = lib.mkEnableOption "Enable Sway support and settings";

  config = (
    lib.mkIf cfg {
      programs.swaylock.enable = true;

      wayland.windowManager.sway =
        let
          mod = config.wayland.windowManager.sway.config.modifier;
        in
        {
          enable = true;
          config = rec {
            #fonts.size = 10.0;
            keybindings = lib.mkOptionDefault {
              "Mod4+l" = "exec ${pkgs.swaylock}/bin/swaylock -c 000000";
              "Mod4+h" = "exec ${pkgs.qpwgraph}/bin/qpwgraph -x /home/greg/sound/headphones.qpwgraph -m";
              "Mod4+m" = "exec ${pkgs.qpwgraph}/bin/qpwgraph -x /home/greg/sound/monitor.qpwgraph -m";
              "Mod4+b" = "exec ${pkgs.qpwgraph}/bin/qpwgraph -x /home/greg/sound/both.qpwgraph -m";

              "${mod}+Shift+Return" = file_browser.path;
            };
            modifier = "Mod1";
            output = {
              "Samsung Electric Company S24E650 H4ZN600985" = {
                mode = "1920x1200";
                transform = "90";
                pos = "0 0";
              };
              "ViewSonic Corporation VA2252 Series VMT201800925" = {
                mode = "1920x1080";
                pos = "200 1920";
              };
            };
            terminal = term;
            startup = [
              { command = "${workstation1}/bin/workstation1"; }
              { command = "${workstation2}/bin/workstation2"; }
            ];
          };
          extraOptions = [ "--unsupported-gpu" ];
          extraSessionCommands = ''
            export WLR_NO_HARDWARE_CURSORS=1
          '';
          systemd.enable = true;
          wrapperFeatures = {
            base = true;
            gtk = true;
          };
        };

      home.pointerCursor = {
        name = "Adwaita";
        package = pkgs.gnome.adwaita-icon-theme;
        size = 12;
        x11 = {
          enable = true;
          defaultCursor = "Adwaita";
        };
      };

      home.packages = with pkgs; [
        arj
        dpkg
        kate
        kget
        krename
        file_browser.pkg
        p7zip
        plocate
        rpm
        qpwgraph
        xorg.xev
        xorg.xmodmap
        xxdiff
      ];
    }
  );
}
