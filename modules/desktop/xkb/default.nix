{pkgs, ...}: {
  environment.systemPackages = [pkgs.libxkbcommon];

  my.outOfStoreSymlinks.config.xkb = "desktop/xkb";
}
