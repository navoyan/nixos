{pkgs, ...}: {
  environment.systemPackages = [pkgs.bat];

  my.outOfStoreSymlinks.config.bat = "programs/bat";
}
