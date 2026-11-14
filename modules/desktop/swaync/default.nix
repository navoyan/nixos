{pkgs, ...}: let
  backlight = pkgs.writeShellApplication {
    name = "swaync-backlight";
    runtimeInputs = [pkgs.ddcutil];
    text = ''
      case "$1" in
          set) ddcutil setvcp 0x10 "$2" ;;
          get) ddcutil getvcp 0x10 | grep -oP "current value =\s+\K[0-9]+" ;;
      esac
    '';
  };
in {
  hardware.i2c.enable = true;

  environment.systemPackages = [
    pkgs.swaynotificationcenter
    backlight
  ];

  my.outOfStoreSymlinks.config.swaync = "desktop/swaync";
}
