{ pkgs, ... }:

let
  c = pkgs.callPackage;
in
{
  #default = iso;
  #iso = top.self.nixosConfigurations.iso.config.system.build.isoImage;
  #iso-beta = self.nixosConfigurations.iso-beta.config.system.build.isoImage;
  aacs = c ./aacs.nix { };
  brew = c ./homebrew.nix { };
  create_ssl = c ./create_ssl.nix { };
  inject-darwin = c ./inject-darwin.nix { };
  inject = c ./inject.nix { };
  hms = c ./hms { };
  qemu-hook = c ./qemu-hook.nix { };
  setup-ssh = c ./setup-ssh { };
  upgrade-pg-cluster = c ./upgrade-pg-cluster.nix { };
  vfio_startup = c ./vfio_startup.nix { };
  vfio_shutdown = c ./vfio_shutdown.nix { };
  zim = c ./zim.nix { };
}
