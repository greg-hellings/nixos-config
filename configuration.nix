# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/0.10.1.tar.gz"}/modules/age.nix"
      ./hardware-configuration.nix
      ./base.nix
      ./host
    ];
}
