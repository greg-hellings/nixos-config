{
  buildGoModule,
}:
buildGoModule {
  name = "updater";
  src = ./.;
  vendorHash = null;
}
