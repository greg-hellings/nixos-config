{
  writeShellApplication,
  vfio_shutdown,
  vfio_startup,
}:

writeShellApplication {
  name = "qemu_hook";
  runtimeInputs = [
    vfio_shutdown
    vfio_startup
  ];

  text = ''
    OBJECT="''${1}"
    OPERATION="''${2}"

    if [[ "''${OBJECT}" == "win10" ]]; then
      case "''${OPERATION}" in
        "prepare")
          systemctl start libvirt-nosleep@"''${OBJECT}".service
          systemctl start bluetooth.service
          vfio_startup 2>&1 | tee -a /var/log/qemu_hook.log
          ;;
        "release")
          systemctl stop libvirt-nosleep@"''${OBJECT}".service
          vfio_shutdown 2>&1 | tee -a /var/log/qemu_hook.log
      esac
    fi
  '';
}
