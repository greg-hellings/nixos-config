{ pkgs, ... }:

let
  c = pkgs.callPackage;
in
{
  packages = {
    #default = iso;
    #iso = top.self.nixosConfigurations.iso.config.system.build.isoImage;
    #iso-beta = self.nixosConfigurations.iso-beta.config.system.build.isoImage;
    hms = c ./hms { };
  };
}
