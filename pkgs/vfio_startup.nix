{
  writeShellApplication,
  kmod,
  systemd,
}:

writeShellApplication {
  name = "vfio_startup";
  runtimeInputs = [
    kmod
    systemd
  ];
  text = ''
    # Stop the service that uses the GPU
    echo "Stopping the display manager..."
    systemctl stop display-manager.service

    # Unload the GPU modules
    echo "Unloading the GPU modules..."
    modprobe -r nvidia_uvm
    modprobe -r nvidia_drm
    modprobe -r nvidia_modeset
    modprobe -r nvidia

    # Insert the vfio modules
    echo "Inserting the vfio modules..."
    modprobe vfio
    modprobe vfio_pci
    modprobe vfio_iommu_type1

    echo "Aaaand... off you go!"
  '';
}
