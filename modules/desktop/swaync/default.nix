{pkgs, ...}: {
  environment.systemPackages = [pkgs.swaynotificationcenter];

  my.outOfStoreSymlinks.config.swaync = "desktop/swaync";
}
