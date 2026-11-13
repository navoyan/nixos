{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.strings) escapeShellArgs;
in {
  pkg = pkg: {
    bin ? pkg.meta.mainProgram,
    wrapperArgs,
  }:
    pkgs.symlinkJoin {
      inherit (pkg) name meta;
      paths = [pkg];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/${bin} ${escapeShellArgs wrapperArgs}
      '';
      passthru.unwrapped = pkg;
    };
}
