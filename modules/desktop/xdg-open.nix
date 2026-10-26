{
  pkgs,
  lib,
  ...
}: let
  handlrXdgOpen = pkgs.writeShellScriptBin "xdg-open" ''
    exec ${lib.getExe pkgs.handlr-regex} open "$@"
  '';
in {
  environment.systemPackages = [
    pkgs.handlr-regex
    (lib.hiPrio handlrXdgOpen)
  ];
}
