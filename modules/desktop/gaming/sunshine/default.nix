{localLib, ...}: {
  services.sunshine = {
    enable = true;
    openFirewall = true;
    autoStart = false;
  };

  hardware.display.outputs = {
    "HDMI-A-1".mode = "2560x1440@60e";
  };

  my.outOfStoreSymlinks.config.sunshine = localLib.symlinks.mkSources "desktop/gaming/sunshine" [
    "./sunshine.conf"
  ];
}
