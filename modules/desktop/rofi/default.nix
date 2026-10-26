{pkgs, ...}: {
  environment.systemPackages = [
    (pkgs.rofi.override {
      plugins = [pkgs.rofi-calc];
    })
  ];

  my.outOfStoreSymlinks.config.rofi = "desktop/rofi";
}
