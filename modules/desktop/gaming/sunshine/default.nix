{my, ...}: let
  inherit (my.lib) symlinks;
in {
  services.sunshine = {
    enable = true;
    openFirewall = true;
    autoStart = false;
  };

  hardware.display.outputs = {
    "HDMI-A-1".mode = "2560x1440@60e";
  };

  my.outOfStoreSymlinks.config.sunshine = symlinks.sources "desktop/gaming/sunshine" [
    "./sunshine.conf"
  ];
}
