{
  pkgs,
  lib,
  ...
}: {
  systemd.user.services.lxqt-polkit = {
    wantedBy = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];
    environment = {
      QT_PLUGIN_PATH = lib.makeSearchPath "lib/qt-6/plugins" [
        pkgs.qt6Packages.qt6ct
        pkgs.klassy
      ];
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = lib.getExe pkgs.lxqt.lxqt-policykit;
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
