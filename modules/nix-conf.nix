{
  pkgs,
  lib,
  cache,
  ...
}:

{
  nix = {
    gc = {
      automatic = true;
      # Scheduling of them is different in nixos vs nix-darwin, so check for
      # the extra details there
      options = "--delete-older-than 30d";
    };

    package = pkgs.nixStable;

    settings = {
      experimental-features = "nix-command flakes";
      keep-outputs = true;
      keep-derivations = true;
      min-free = (toString (1024 * 1024 * 1024));
      max-free = (toString (5 * 1024 * 1024 * 1024));
      cores = 0; # Use all cores for builds
      trusted-users = [
        "greg"
        "gregory.hellings"
      ]; # For home and for work machines
      substituters =
        (lib.optionals cache [
          "http://nas.thehellings.lan:9000/binary-cache/"
          "http://nas.home:9000/binary-cache/"
        ])
        ++ [
          "https://cache.garnix.io"
          "https://ai.cachix.org"
          "https://nixpkgs-python.cachix.org"
          "https://greg-hellings.cachix.org"
          "https://nix-community.cachix.org"
          "https://cache.nixos.org"
        ];
      trusted-public-keys = [
        "nix.thehellings.lan:0qWYHn3gGllXChhAaaxKlNZtRy6yG/XJs1RFSqV3nW8="
        "nix.home:0qWYHn3gGllXChhAaaxKlNZtRy6yG/XJs1RFSqV3nW8="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
        "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU="
        "greg-hellings.cachix.org-1:y01Jl/L5evlhxdnUW6n56AiI1k8g1wxWhTxJCe7XSco="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
    permittedInsecurePackages = [ "jitsi-meet-1.0.8043" ];
  };
}
