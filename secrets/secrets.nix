let
  linode = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMv9Zud3kZOl86gtmkn+uj3D4kiXWDPtyUL02VVLNR4Q";
  jude = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOos0zQePsa+T6Z2dsKbPOvEdrBQ8a6mx3s7pN6ysCI0 root@jude";
  myself = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHleYKtfV4W1Z63Ysu9w5Rbglqlz4F92YcZoMkucoTNf";
  genesis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEI9jbTPmEWQ0F2bLYmnIOLmBnag1fkKxHRjz3X8lB/k root@genesis";
  hosea = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKLIwkTTXA56sUlUjEulXXZRvZy5H4a5ZwgKWLlpkQDz";
  jeremiah = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOjQjXq9WYU2Ki27BR9WwJ4ZruS/lJXbjC1b0Q42Adi0";
  systems = [ genesis linode jude myself hosea jeremiah ];

  user_genesis_virt = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFWPSFQT0AH77wrwRhiskcBS0w4ZakBRdJywYYBsnm3S greg@genesis";
  user_ivr = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMYzms+KIe5/bYF3uCyFjA5e1AgMPLIA3c4k417coqBe gregory.hellings@ls23003";
  user_jude = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINnRc/kBhxcjpUtiRQY+BXnSObdp0jFL1395wAQxJip7 greg@jude";
  user_linode = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINAX6pNx5mbwIa8X+GzktyNijfYmJUpgROFpRxSW9js0 greg@linode";
  user_myself = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAl6DJVrPSujvJSAEA5Q8tRrzfJs/c6DMwqwQEUFffIR greg@myself";
  user_hosea = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGrqJQvDspLi1vXQRJ/Z5kN/F8jCBHvaXjo+5zLuIYjR greg@hosea";
  user_jeremiah = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIYIiecdyM9c7tXgR96983K3wqiJeQRMbrzGIF8Wy6uO greg@jeremiah";

  users = [
    user_genesis_virt
    user_ivr
    user_jude
    user_linode
    user_myself
    user_hosea
    user_jeremiah
  ];

  everyone = systems ++ users;
in
{
  # Demo of how to create it
  "matrix.age".publicKeys = everyone;
  # At the point where you want to use it, put
  # age.secrets.matrix.file = ../../secrets/matrix.age;
  # Then you can reference the file at /run/agenix/matrix
  "nextcloudadmin.age".publicKeys = everyone;

  "3proxy.age".publicKeys = everyone;

  "linode-forgejo-runner.age".publicKeys = everyone;
  "jude-forgejo-runner.age".publicKeys = everyone;
  "minio.age".publicKeys = everyone;

  "restic-env.age".publicKeys = everyone;
  "restic-pw.age".publicKeys = everyone;


  "dendrite.age".publicKeys = everyone;
  "dendrite_key.age".publicKeys = everyone;
  "gitlab/secret.age".publicKeys = everyone;
  "gitlab/otp.age".publicKeys = everyone;
  "gitlab/db.age".publicKeys = everyone;
  "gitlab/jws.age".publicKeys = everyone;
  # openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.crt -days 365 -nodes -subj '/CN=issuer'
  # Then pipe the resulting files to agenix -e <foo>
  "gitlab/key.age".publicKeys = everyone;
  "gitlab/cert.age".publicKeys = everyone;
  "gitlab/jeremiah-runner-reg.age".publicKeys = everyone;
  "gitlab/myself-qemu-runner-reg.age".publicKeys = everyone;
  "gitlab/myself-vbox-runner-reg.age".publicKeys = everyone;
  "gitlab/myself-podman-runner-reg.age".publicKeys = everyone;
  "gitlab/myself-shell-runner-reg.age".publicKeys = everyone;
  "gitlab/linode-deployer-runner-reg.age".publicKeys = everyone;
  "gitlab/docker-auth.age".publicKeys = everyone;

  "acme_password.age".publicKeys = everyone;
  "ca/intermediate_key.age".publicKeys = everyone;
  "ca/root_key.age".publicKeys = everyone;

  "minio_secret_access_key.age".publicKeys = everyone;
  "minio_access_key_id.age".publicKeys = everyone;
}
