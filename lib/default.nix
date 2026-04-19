{ lib, ... }:
{
  hostsByNet =
    net: hosts:
    let
      netAttr =
        {
          lan = "ip";
          nebula = "nebulaIp";
          tailscale = "ts";
        }
        .${net};
    in
    lib.mapAttrsToList
      (name: value: {
        inherit name;
        address = builtins.getAttr netAttr value;
      })
      (
        lib.filterAttrs (
          _host: settings: (builtins.hasAttr netAttr settings) && (builtins.getAttr netAttr settings) != null
        ) hosts
      );
}
