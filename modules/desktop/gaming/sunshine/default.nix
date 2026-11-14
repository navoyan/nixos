{my, ...}: {
  services.sunshine = {
    enable = true;
    openFirewall = true;
    autoStart = false;
  };

  hardware.display.outputs = {
    "HDMI-A-1".mode = "2560x1440@60e";
  };

  my.outOfStoreSymlinks.config.sunshine = my.lib.symlinks.mkSources "desktop/gaming/sunshine" [
    "./sunshine.conf"
  ];
}
