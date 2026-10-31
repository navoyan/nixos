{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # allows pipewire to use the realtime scheduler for increased performance:
  security.rtkit.enable = true;

  my.outOfStoreSymlinks.config.pipewire = "desktop/pipewire";
}
