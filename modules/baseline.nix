{ pkgs, ... }:
{
  # Enable flakes
  nix = {
    gc = {
      automatic = true;
      # Scheduling of them is different in nixos vs nix-darwin, so check for
      # the extra details there
      options = "--delete-older-than 30d";
    };

    settings = {
      experimental-features = "nix-command flakes";
      keep-outputs = true;
      keep-derivations = true;
      min-free = (toString (1024 * 1024 * 1024));
      max-free = (toString (5 * 1024 * 1024 * 1024));
      substituters = [
        "https://cache.garnix.io"
        "https://ai.cachix.org"
      ];
      trusted-public-keys = [
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
      ];
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "jitsi-meet-1.0.8043"
    ];
  };

  # Base packages that need to be in all my hosts
  environment.systemPackages = with pkgs; [
    agenix
    bitwarden-cli
    bmon
    diffutils
    git
    gnupatch
    gregpy
    findutils
    file
    hms # My own home manager switcher
    htop
    iperf
    killall
    nano
    pciutils
    pwgen
    unzip
    wget
  ];
}
