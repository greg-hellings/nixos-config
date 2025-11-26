{
  immich-go,
  cacert,
  dockerTools,
  lib,
  ...
}:
dockerTools.buildLayeredImage {
  name = "img-immich";
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
