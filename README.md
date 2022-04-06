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
6. Symlink the folder for the appropriate host to the location 'host' as such:
   `ln -s hosts/myhost host`.
7. Run the nixos installation command

# Adding new hosts

To add a new host, create a folder in the directory `hosts/` that matches the name of
the target system. Each host must contain, minimally, a `default.nix` file that serves
as the basis of configuring that host.

## Profiles

Certain shared characteristics can be created in the `profiles/` folder and included in
a particular host's configuration. For instance, any hosts that are running on a
Raspsberry Pi 4 should include the `profiles/rpi4.nix` file to properly configure things
like the kernel and boot parameters. Since I live in the "America/Chicago" timezone, hosts
that run in my home will also include `profiles/home.nix`. That file will also set the
domain that I use for my hosts at home. This allows shared content to be reused across
multiple machines without the need to repeat it.
