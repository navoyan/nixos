{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.coolercontrol.plugins.coolerdash;

  pluginSrc = "${cfg.package}/share/coolercontrol/plugins/coolerdash";
  pluginDir = "/var/lib/coolercontrol/plugins/coolerdash";
  pluginUser = "cc-plugin-user";
in {
  options.programs.coolercontrol.plugins.coolerdash = {
    enable = lib.mkEnableOption "CoolerDash, a plug-in for CoolerControl extending the LCD functionality";
    package = lib.mkPackageOption pkgs "coolerdash" {};
  };

  config = lib.mkIf (config.programs.coolercontrol.enable && cfg.enable) {
    programs.coolercontrol.plugins.enable = true;

    environment.systemPackages = [cfg.package];

    systemd.services.coolercontrold.restartTriggers = [cfg.package];

    systemd.tmpfiles.settings.coolerdash = {
      ${pluginDir}."d" = {
        mode = "1775";
        user = "root";
        group = pluginUser;
      };
      "${pluginDir}/manifest.toml"."C+".argument = "${pluginSrc}/manifest.toml";
      "${pluginDir}/config.json"."C" = {
        mode = "0600";
        user = pluginUser;
        group = pluginUser;
        argument = "${pluginSrc}/config.json";
      };
      "${pluginDir}/ui"."L+".argument = "${pluginSrc}/ui";
      "${pluginDir}/shutdown.png"."L+".argument = "${pluginSrc}/shutdown.png";
    };
  };
}
