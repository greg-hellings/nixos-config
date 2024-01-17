{ pkgs, ... }:
let
	bw = "${pkgs.bitwarden-cli}/bin/bw";

in pkgs.writeShellScriptBin "configure_aws_creds" ''
set -ex -o pipefail

session="$(${bw} unlock | grep -e '$ export' | awk -F\" '{print $2}')"
export BW_SESSION="''${session}"
export AWS_ACCESS_KEY_ID="$(${bw} get username "AWS Access Key")"
export AWS_SECRET_ACCESS_KEY="$(${bw} get password "AWS Access Key")"
''
