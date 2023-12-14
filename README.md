[![built with garnix](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Fgarnix.io%2Fapi%2Fbadges%2Fgreg-hellings%2Fnixos-config%3Fbranch%3Dmain)](https://garnix.io)    [![built with garnix](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Fgarnix.io%2Fapi%2Fbadges%2Fgreg-hellings%2Fnixos-config%3Fbranch%3Dmain)](https://garnix.io)

This is a unified repo to contain my personal configurations for NixOS machines.

# How To Use This

Go through the normal process to setup a NixOS system during installation.

1. Boot from an appropriate medium
2. Parition the drives
3. Mount them
4. Before you generate out the configuration, clone this repoistory to your
   /etc/nixos folder
5. Run the configuration generator. It should only genreate the hardware-configuration.nix
   file, which this repo gitignores
6. Create a folder and file with the machine name in `hosts/<machine>/default.nix`
7. Add `hosts/default.nix` an appropriate entry for the machine you are building
8. Create a file `home/hosts/<machine>/default.nix` with the new machine name as well

# Adding new hosts

To add a new host, create a folder in the directory `hosts/` that matches the name of
the target system. Each host must contain, minimally, a `default.nix` file that serves
as the basis of configuring that host.
