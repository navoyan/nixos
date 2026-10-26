{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.rbw
    pkgs.rofi-rbw-wayland
  ];

  my.outOfStoreSymlinks.config."rofi-rbw.rc" = "desktop/rofi-rbw/rofi-rbw.rc";
}
