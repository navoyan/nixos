{pkgs, ...}: {
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
      xdg-desktop-portal-termfilechooser
    ];
  };

  my.outOfStoreSymlinks.config.xdg-desktop-portal = "desktop/xdg-desktop-portal";
}
