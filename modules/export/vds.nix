{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.vds;
in {
  options.services.vds = {
    enable = lib.mkEnableOption "vDS, Virtual USB-to-Bluetooth Bridge for DualSense";

    package = lib.mkPackageOption pkgs "vds" {};

    maxPorts = lib.mkOption {
      type = lib.types.ints.between 1 4;
      default = 4;
      description = "Number of virtual controller ports created by the `vds_hcd` kernel module.";
    };

    disableBluezInputPlugin = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to disable the `input` plugin of BlueZ.
        vDS needs to own the HID L2CAP channels of the controller,
        which the `input` plugin would otherwise claim.

        ::: {.warning}
        While the plugin is disabled,
        other Bluetooth input devices such as keyboards and mice do not work.
        :::
      '';
    };

    wireplumberRule = lib.mkOption {
      type = lib.types.bool;
      default = config.services.pipewire.wireplumber.enable;
      defaultText = lib.literalExpression "config.services.pipewire.wireplumber.enable";
      description = ''
        Whether to install the upstream WirePlumber rule,
        which sets stable device names, 4-channel output and a low priority for the microphone.
        The card profile of the controller still has to be set to `pro-audio`.
      '';
    };

    rotateLogs = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to rotate the log file of {command}`vdsd`.";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = lib.mkDefault true;
      disabledPlugins = lib.mkIf cfg.disableBluezInputPlugin ["input"];
    };

    boot = {
      extraModulePackages = [config.boot.kernelPackages.vds-hcd];
      kernelModules = ["vds_hcd"];
      extraModprobeConfig = ''
        options vds_hcd max_port=${toString cfg.maxPorts}
      '';
    };

    environment.systemPackages = [cfg.package];

    services.udev.packages = [cfg.package];

    services.pipewire.wireplumber.configPackages = lib.mkIf cfg.wireplumberRule [cfg.package];

    systemd.services.vdsd = {
      description = "vDS userspace daemon";
      wantedBy = ["multi-user.target"];
      wants = ["bluetooth.service"];
      after = [
        "bluetooth.service"
        "systemd-modules-load.service"
      ];
      unitConfig.ConditionPathExists = "/dev/vds0";
      serviceConfig = {
        ExecStart = lib.getExe' cfg.package "vdsd";
        Restart = "on-failure";
        RestartSec = 1;
        StateDirectory = "vds";
      };
    };

    services.logrotate = lib.mkIf cfg.rotateLogs {
      enable = true;
      settings.vdsd = {
        files = "/var/log/vdsd.log";
        frequency = "weekly";
        rotate = 4;
        missingok = true;
        notifempty = true;
        compress = true;
        delaycompress = true;
        create = "0660 root root";
        postrotate = "${lib.getExe' config.systemd.package "systemctl"} kill --signal=HUP vdsd.service || true";
      };
    };
  };
}
