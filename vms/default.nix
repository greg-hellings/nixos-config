{ top, ... }:
with top.self.nixosConfigurations;
{
  #jellyfin = vm-jellyfin.config.formats.proxmox;
  matrix = vm-matrix.config.formats.proxmox;
}
