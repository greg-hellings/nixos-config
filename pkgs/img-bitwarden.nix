{
  bitwarden-cli,
  cacert,
  dockerTools,
  lib,
  wget,
  writeShellApplication,
  ...
}:
dockerTools.buildLayeredImage {
  name = "img-bitwarden";
  tag = "latest";
  contents = [
    dockerTools.binSh
    dockerTools.caCertificates
    wget
  ];
  config = {
    Cmd = [
      (lib.getExe (writeShellApplication {
        name = "bitwarden-cli-entrypoint.sh";
        runtimeInputs = [ bitwarden-cli ];
        text = ''
          set -ex

          # Uncomment if you need to hit a custom host
          #bw config server ''${BW_HOST}

          echo "Using apikey to log in"
          bw login --apikey --raw
          BW_SESSION="$(bw unlock --passwordenv BW_PASSWORD --raw)"
          export BW_SESSION

          echo 'Running "bw serve" on port 8087'
          bw serve --hostname all --port 8087
        '';
      }))
    ];
    Env = [
      "CURL_CA_BUNDLE=${cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
    ExposedPorts = {
      "8087/tcp" = { };
    };
  };
}
