{ ... }:
{
  imports = [
    ../baseline.nix
  ];
  system.stateVersion = 4;
  home-manager = {
    useGlobalPkgs = true;
    users."gregory.hellings" = import ../../home/home.nix;
    extraSpecialArgs = {
      gnome = false;
      gui = false;
      home = "/Users/gregory.hellings";
    };
  };
  users.users."gregory.hellings".home = "/Users/gregory.hellings";
  programs = {
    zsh.enable = true;
    bash.enable = true;
  };
  services.nix-daemon.enable = true;
  nix = {
    gc.interval.Hour = 24;
    settings.auto-optimise-store = false; # Darwin bugs?
  };
}
