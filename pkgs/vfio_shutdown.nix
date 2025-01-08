{
  writeShellApplication,
  coreutils,
  kmod,
  systemd,
}:

writeShellApplication {
  name = "vfio_shutdown";
  runtimeInputs = [
    coreutils
    kmod
    systemd
  ];
  text = ''
    echo "Removing vfio modules..."
    modprobe -r vfio_pci
    modprobe -r vfio_iommu_type1
    modprobe -r vfio

    echo "Reload the GPU modules..."
    modprobe nvidia
    modprobe nvidia_modeset
    modprobe nvidia_drm
    modprobe nvidia_uvm

    echo "Starting the display manager..."
    systemctl start display-manager.service

    echo "All done!"
  '';
}
