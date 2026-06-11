{
  pkgs,
  system ? pkgs.stdenv.hostPlatform.system,
  top,
  ...
}:

let
  c = pkgs.newScope packages;
  packages = if system == "x86_64-linux" then (allSys // x86Linux) else allSys;
  allSys = {
    #default = iso;
    #iso = top.self.nixosConfigurations.iso.config.system.build.isoImage;
    #iso-beta = self.nixosConfigurations.iso-beta.config.system.build.isoImage;
    aacs = c ./aacs.nix { };
    adblock_update = c ./adblock_update.nix { };
    brew = c ./homebrew.nix { };
    create_ssl = c ./create_ssl.nix { };
    dockerCompat = pkgs.runCommand "docker-compat" {
      nativeBuildInputs  = [];
    } ''
      mkdir -p $out/bin
      ln -s ${pkgs.podman}/bin/podman $out/bin/docker
    '';
    gcc-tune = c ./gcc-tune.nix { };
    #gen-build = c ./gen-build { };
    hms = c ./hms { };
    inject-darwin = c ./inject-darwin.nix { };
    inject = c ./inject.nix { };
    setup-ssh = c ./setup-ssh { };
    upgrade-pg-cluster = c ./upgrade-pg-cluster.nix { };
  };
  x86Linux = {
    qemu-hook = c ./qemu-hook.nix { };
    vfio_startup = c ./vfio_startup.nix { };
    vfio_shutdown = c ./vfio_shutdown.nix { };
  }
  // (import ./zim {
    inherit (top.nixpkgs-lib) lib;
    inherit pkgs;
  });
in
packages
