{localLib, ...}: {
  my.jails.vesktop = {
    enable = true;
    bootstrapService.enable = true;
    permissions = combinators:
      with combinators; [
        network
        gui
        gpu
        xdg-open
        xdg-desktop-portal
        camera
        notifications

        tray
        (dbus {
          # to own `org.freedesktop.StatusNotifierItem-<pid>-<n>`:
          own = ["org.freedesktop.*"];
        })

        (readwrite (noescape "~/.config/vesktop"))

        (readonly (noescape "~/Downloads"))
        (readonly (noescape "~/Pictures"))
      ];
  };

  my.outOfStoreSymlinks.config.vesktop = localLib.symlinks.mkSources "desktop/discord" [
    "./themes"
    "./settings.json"
  ];
}
