{pkgs, ...}: {
  environment.systemPackages = [pkgs.bat];

  my.outOfStoreSymlinks.config.bat = "cli/bat";
}
