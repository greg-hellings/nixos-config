{
  buildGoModule,
}:
let
  src = ./.;
in
buildGoModule {
  inherit src;
  name = "gen-build";

  vendorHash = "sha256-g+yaVIx4jxpAQ/+WrGKxhVeliYx7nLQe/zsGpxV4Fn4=";

  meta.mainProgram = "main";
}
