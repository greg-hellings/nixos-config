{
  immich-go,
  cacert,
  dockerTools,
  lib,
  ...
}:
dockerTools.buildLayeredImage {
  name = "registry.thehellings.com/greg/nixos-config/img-immich";
  tag = "latest";
  contents = [
    dockerTools.binSh
    dockerTools.caCertificates
    immich-go
  ];
  config = {
    Cmd = [
      (lib.getExe immich-go)
    ];
    Env = [
      "CURL_CA_BUNDLE=${cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
  };
}
