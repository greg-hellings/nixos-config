{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.greg.print;

in
with lib;
{
  options.greg.print.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Configures the system to print with my home printer";
  };

  config = mkIf cfg.enable {
    # ipp://printer.thehellings.lan:631/ - generic postscript printer
    services.printing = {
      enable = true;
      drivers = with pkgs; [ gutenprint ] ++ (lib.optional pkgs.stdenv.isx86_64 gutenprintBin);
    };

    hardware.printers.ensurePrinters = [
      {
        name = "HomeLexmarkColorPrinter";
        location = "Home office";
        deviceUri = "ipp://printer.thehellings.lan:631/";
        model = "drv:///sample.drv/generic.ppd";
        ppdOptions = {
          PageSize = "Letter";
        };
      }
    ];
  };
}
