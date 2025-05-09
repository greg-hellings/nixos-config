{ ... }:
{
  imports = [ ../baseline.nix ];

  home-manager = {
    useGlobalPkgs = true;
    users."gregory.hellings" = import ../../home/home.nix;
    extraSpecialArgs = {
      gnome = false;
      gui = false;
      home = "/Users/gregory.hellings";
    };
  };

  nix = {
    gc.interval.Hour = 24;
    settings.auto-optimise-store = false; # Darwin bugs?
  };

  programs = {
    zsh.enable = true;
    bash.enable = true;
  };

  services.nix-daemon.enable = true;

  system.stateVersion = 4;

  users.users."gregory.hellings".home = "/Users/gregory.hellings";
}
