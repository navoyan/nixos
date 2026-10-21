{pkgs, ...}: {
  programs.niri.enable = true;

  environment.systemPackages = [pkgs.xwayland-satellite];

  my.outOfStoreSymlinks.config.niri = "programs/niri";
}
