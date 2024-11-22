{ top, ... }:
with top.self.nixosConfigurations;
{
  jellyfin = vm-jellyfin.config.formats.qcow;
  matrix = vm-matrix.config.formats.qcow;
}
