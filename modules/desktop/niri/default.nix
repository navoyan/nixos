{
  pkgs,
  lib,
  ...
}: let
  niriInstance = lib.getExe (
    pkgs.writeShellScriptBin "niri-instance" ''
      /run/current-system/sw/bin/niri --session
    ''
  );
in {
  environment.systemPackages = with pkgs; [
    niri
    xwayland-satellite
  ];

  programs = {
    uwsm = {
      enable = true;
      waylandCompositors.niri = {
        prettyName = "Niri";
        comment = "Niri compositor managed by UWSM";
        binPath = niriInstance;
      };
    };
  };

  my.outOfStoreSymlinks.config.niri = "desktop/niri";
}
