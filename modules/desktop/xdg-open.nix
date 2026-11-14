{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) getExe hiPrio;

  handlrXdgOpen = pkgs.writeShellScriptBin "xdg-open" ''
    exec ${getExe pkgs.handlr-regex} open "$@"
  '';
in {
  environment.systemPackages = [
    pkgs.handlr-regex
    (hiPrio handlrXdgOpen)
  ];
}
