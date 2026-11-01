{pkgs, ...}: {
  programs.niri.enable = true;

  environment.systemPackages = [pkgs.xwayland-satellite];

  hj.environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  my.outOfStoreSymlinks.config.niri = "desktop/niri";
}
