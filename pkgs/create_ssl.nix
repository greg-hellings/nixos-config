{ writeShellApplication, openssl, ... }:

writeShellApplication {
  name = "create_ssl";
  runtimeInputs = [ openssl ];
  text = ''
      set -e -o pipefail
      name="''${1}"
      root_key="''${2}"

      function usage {
    	  echo "USAGE: create_ssl <cert name> <root path>"
      }

      if [ -z "''${name}" ]; then
    	  usage
    	  exit 1
      fi

      if [ -z "''${root_key}" ]; then
    	  usage
    	  exit 1
      fi

      # Create the certificate key
      openssl ecparam -out "''${name}.key" -name prime256v1 -genkey
      # Create the CSR
      openssl req -name -sha256 -key "''${name}.key" -out "''${name}.csr"
      # Sign it
      openssl x509 -req -in "''${name}.csr" -CA "''${root_key}.crt" -CAkey "''${root_key}.key" -CAcreateserial -out "''${name}.crt" -days 3650 -sha256
  '';
}
