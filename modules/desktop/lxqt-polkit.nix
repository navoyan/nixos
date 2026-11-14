{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) getExe;
  inherit (lib.strings) makeSearchPath;
in {
  systemd.user.services.lxqt-polkit = {
    wantedBy = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];
    environment = {
      QT_PLUGIN_PATH = makeSearchPath "lib/qt-6/plugins" [
        pkgs.qt6Packages.qt6ct
        pkgs.klassy
      ];
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = getExe pkgs.lxqt.lxqt-policykit;
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
