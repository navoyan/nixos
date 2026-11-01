{
  pkgs,
  localLib,
  ...
}: {
  my.jails.chromium = {
    enable = true;
    bootstrapService.enable = true;
    package = pkgs.ungoogled-chromium;
    permissions = combinators:
      with combinators; [
        network
        gui
        gpu
        xdg-open
        xdg-desktop-portal
        notifications
        camera

        # for webhid/webusb, should be relatively safe with
        # chromium's permission system and my usecases for chromium:
        (unsafe-dev "/dev")
        (readonly "/sys/bus/usb")
        (readonly "/sys/class/hidraw")
        (readonly "/sys/class/input")
        (readonly "/sys/devices")

        (mkdir-readwrite (noescape "~/.config/chromium"))
        (mkdir-readwrite (noescape "~/.cache/chromium"))

        (mkdir-readwrite (noescape "~/Downloads"))
        (mkdir-readwrite (noescape "~/Documents"))
        (mkdir-readwrite (noescape "~/Pictures"))
      ];
  };

  my.outOfStoreSymlinks.data.applications = localLib.symlinks.mkSources "desktop/chromium" [
    "./google-meet.desktop"
  ];
}
