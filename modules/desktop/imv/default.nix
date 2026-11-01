{
  my.jails.imv = {
    enable = true;
    bootstrapService.enable = true;
    permissions = combinators:
      with combinators; [
        gui
        gpu

        (readonly (noescape "~/.config/imv"))

        (mkdir-readonly (noescape "~/Downloads"))
        (mkdir-readonly (noescape "~/Pictures"))
        (mkdir-readonly (noescape "~/Documents"))
      ];
  };

  my.outOfStoreSymlinks.config.imv = "desktop/imv";

  hj.xdg.mime-apps = {
    added-associations = {
      "image/*" = "imv.desktop";
    };
    default-applications = {
      "image/*" = "imv.desktop";
    };
  };
}
