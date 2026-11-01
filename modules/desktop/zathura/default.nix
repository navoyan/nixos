{pkgs, ...}: {
  my.jails.zathura = {
    enable = true;
    bootstrapService.enable = true;
    package = pkgs.zathura.override {
      useMupdf = true;
    };
    permissions = combinators:
      with combinators; [
        gui
        gpu
        xdg-open

        (readwrite (noescape "~/.config/zathura"))
        (mkdir-readwrite (noescape "~/.local/share/zathura"))

        (mkdir-readonly (noescape "~/Downloads"))
        (mkdir-readonly (noescape "~/Documents"))
      ];
  };

  my.outOfStoreSymlinks.config.zathura = "desktop/zathura";

  hj.xdg.mime-apps.default-applications = {
    "application/pdf" = "org.pwmt.zathura.desktop";
  };
}
