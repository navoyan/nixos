{pkgs, ...}: {
  environment.systemPackages = [pkgs.swaynotificationcenter];

  my.outOfStoreSymlinks.config.swaync = "programs/swaync";
}
