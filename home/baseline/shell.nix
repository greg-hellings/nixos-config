{ pkgs, ... }:
{
  programs = {
    ghostty = {
      enable = true;
      package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
      settings = {
        font-family = "Hacker";
        theme = "Dracula";
        scrollback-limit = "1000000";
        window-save-state = "always";

        keybind = [
          "ctrl+n=new_window"

          "ctrl+h=goto_split:left"
          "ctrl+j=goto_split:down"
          "ctrl+k=goto_split:up"
          "ctrl+l=goto_split:right"

          "ctrl+b>h=new_split:left"
          "ctrl+b>j=new_split:down"
          "ctrl+b>k=new_split:up"
          "ctrl+b>l=new_split:right"

          "ctrl+b>t=new_tab"
          "ctrl+b>n=next_tab"
          "ctrl+b>p=previous_tab"
        ];
      };
    };
  };
}
