{
  pkgs,
  config,
  lib,
  ...
}:
let
  builderHosts = [ "jude" "myself" ];
in
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
      trusted-users = [
        "greg"
        "gregory.hellings"
      ]; # For home and for work machines
      substituters = [
        "https://cache.garnix.io"
        "https://ai.cachix.org"
        "https://nixpkgs-python.cachix.org"
        "https://greg-hellings.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
        "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU="
        "greg-hellings.cachix.org-1:y01Jl/L5evlhxdnUW6n56AiI1k8g1wxWhTxJCe7XSco="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    buildMachines = (
      lib.map (host: {
        hostName = "${host}-builder";
        system = "x86_64-linux";
        protocol = "ssh-ng";
        maxJobs = 12;
        speedFactor = 2;
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
      }) (lib.filter (x: x != config.networking.hostName) builderHosts)
    );
    distributedBuilds = true;
    extraOptions = ''
      builders-use-substitutes = true
    '';
  };

  programs.ssh.extraConfig = (
    builtins.concatStringsSep "\n" (
      lib.map (x: ''
        Host ${x}-builder
          Hostname ${x}.home
          User remote-builder-user
      '') builderHosts
    )
  );

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [ "jitsi-meet-1.0.8043" ];
  };

  # Base packages that need to be in all my hosts
  environment.systemPackages = with pkgs; [
    agenix
    bitwarden-cli
    bmon
    cachix
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
    nix-output-monitor
    pciutils
    pwgen
    unzip
    wget
  ];
}
