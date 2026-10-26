{
  programs.waybar.enable = true;
  systemd.user.services.waybar.path = ["/run/current-system/sw"];

  my.outOfStoreSymlinks.config.waybar = "desktop/waybar";
}
