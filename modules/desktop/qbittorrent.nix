{
  my.jails.qbittorrent = {
    enable = true;
    bootstrapService.enable = true;
    permissions = combinators:
      with combinators; [
        network
        qt
        gpu
        notifications
        xdg-desktop-portal
        tray

        (mkdir-readwrite (noescape "~/.config/qBittorrent"))
        (mkdir-readwrite (noescape "~/.local/share/qBittorrent"))

        (mkdir-readwrite (noescape "~/Downloads"))
        (mkdir-readwrite (noescape "~/Data/Videos"))
        (mkdir-readwrite (noescape "~/Data/Games"))
        (mkdir-readwrite (noescape "~/Games"))
      ];
  };
}
