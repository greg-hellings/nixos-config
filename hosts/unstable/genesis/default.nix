# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ top, pkgs, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./networking.nix
    top.minecraft.nixosModules.minecraft-servers
  ];

  greg = {
    home = true;
    gnome.enable = false;
    proxies = {
    };
  };

  # Bootloader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
      edk2-uefi-shell.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    create_ssl
    step-ca
  ];

  networking.hostName = "genesis"; # Define your hostname.

  services = {
    minecraft-servers = {
      enable = true;
      eula = true;
      openFirewall = true;

      servers = {
        maya = {
          enable = true;
          operators = {
            Almec = {
              bypassesPlayerLimit = true;
              uuid = "7884dc5a-ae21-43d5-9506-a934d59be19a";
            };
          };
          package = pkgs.fabricServers.fabric.override { jre_headless = pkgs.openjdk25_headless; };

          serverProperties = {
            allow-flight = true;
            motd = "Maya's Minecraft World";
          };
          whitelist = { };

          jvmOpts = "-Xms4092M -Xmx4092M";

          symlinks = {
            mods = pkgs.linkFarmFromDrvs "mods" (
              builtins.attrValues {
                # Health info
                appleskin = pkgs.fetchurl {
                  url = "https://cdn.modrinth.com/data/EsAfCjCV/versions/HwaLJe3v/appleskin-fabric-mc26.1-3.0.9.jar";
                  hash = "sha256-iNCycR/oxqFpbPGfIcfgfWOm7PzPiIu5AmBWb8asTb4=";
                };
                # Needed by survivalfly
                balm = pkgs.fetchurl {
                  url = "https://mediafilez.forgecdn.net/files/7959/843/balm-fabric-26.1.2-26.1.2.4.jar";
                  hash = "sha256-zDtDxkxOftpW0wUIap7l6abGCjXNczwrF2wLZDztyA0=";
                };
                # Adds more diverse biomes
                # https://www.curseforge.com/minecraft/mc-mods/biomes-o-plenty
                biomes = pkgs.fetchurl {
                  url = "https://mediafilez.forgecdn.net/files/7977/180/BiomesOPlenty-fabric-26.1.2-26.1.2.0.3.jar";
                  hash = "sha256-0aPtsRep0ftbkKqbp69PgUnNJyOBLY9vcPsB1mhOy/M=";
                };
                # Automation engines
                # https://www.curseforge.com/minecraft/mc-mods/create
                #create = pkgs.fetchurl {
                #  url = "https://mediafilez.forgecdn.net/files/7963/363/create-1.21.1-6.0.10.jar";
                #  hash = "sha256-74f+Vwnxuh9bi7IKKSW1r7RmnheP1ti/EMFndZ7v43o=";
                #};
                fabric_api = pkgs.fetchurl {
                  url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/tnmuHGZA/fabric-api-0.146.1%2B26.1.2.jar";
                  hash = "sha256-8Jy/xmxRtw4z4GJ+38wwbXHVn4NGYp4w/mFvW9cmvKg=";
                };
                # Required by biomes-o-plenty
                # https://www.curseforge.com/minecraft/mc-mods/glitchcore
                glitchcore = pkgs.fetchurl {
                  url = "https://mediafilez.forgecdn.net/files/7975/608/GlitchCore-fabric-26.1.2-26.1.2.0.0.jar";
                  hash = "sha256-IDz+TblWvgt4UxFg3L3DhFMEESoX7y5cTOvXhyccQm8=";
                };
                # Tooltips
                # https://www.curseforge.com/minecraft/mc-mods/jade/
                jade = pkgs.fetchurl {
                  url = "https://mediafilez.forgecdn.net/files/7886/518/Jade-mc26.1-Fabric-26.0.8.jar";
                  hash = "sha256-Pc3R5eO4Jf+94mNMPtY/vvpbomp+S+qnAUAVbQk1r2Y=";
                };
                # Gives info on crafting recipes
                # https://www.curseforge.com/minecraft/mc-mods/jei
                jei = pkgs.fetchurl {
                  url = "https://mediafilez.forgecdn.net/files/7920/925/jei-26.1.2-fabric-29.5.0.26.jar";
                  hash = "sha256-7nF7fXYPIg9the/mxi6pUYEmKtosZO6yL2b0Dgf8+fI=";
                };
                # Machines
                # https://www.curseforge.com/minecraft/mc-mods/mekanism
                #mekanism = pkgs.fetchurl {
                #  url = "https://mediafilez.forgecdn.net/files/7904/58/Mekanism-1.21.1-10.7.19.85.jar";
                #  hash = "sha256-AE28nzEG9NGSrqoe4RkN0W7JyoBZ7T0JO4ADT0xXT0M=";
                #};
                # Shows installed mods
                modmenu = pkgs.fetchurl {
                  url = "https://cdn.modrinth.com/data/mOgUt4GM/versions/jvjwXH6l/modmenu-18.0.0-alpha.8.jar";
                  hash = "sha256-u0gtCOVAnNxyHcslo+y9l/jCGsFb+U/Y8soiUilhZDA=";
                };
                # Better storage engines
                # https://www.curseforge.com/minecraft/mc-mods/refined-storage
                refined-storage = pkgs.fetchurl {
                  url = "https://mediafilez.forgecdn.net/files/7961/605/refinedstorage-fabric-3.0.0-beta.5.jar";
                  hash = "sha256-UiXNrGw/giCZAnCjFzFc9k4mrq6deTtL6Z00arSUFOU=";
                };
                survivalfly = pkgs.fetchurl {
                  url = "https://mediafilez.forgecdn.net/files/7870/312/survivalfly-1.3_fabric-mc26.1.1.jar";
                  hash = "sha256-Kai4wSxckpXbs1yLp8wJ4BmmjNkdDbeqerqWGIz3+Zk=";
                };
                # Also needed by biomes
                # https://www.curseforge.com/minecraft/mc-mods/terrablender-fabric
                terrablender = pkgs.fetchurl {
                  url = "https://mediafilez.forgecdn.net/files/7933/873/TerraBlender-fabric-26.1.2-26.1.2.0.1.jar";
                  hash = "sha256-lUrkmMIod54Qj78H0rzT4EYoEeiBG7w6sVOJlRvsnQ4=";
                };
              }
            );
          };
        };
      };
    };
  };
}
