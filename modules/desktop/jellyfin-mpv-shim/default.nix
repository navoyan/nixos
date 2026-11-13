{
  pkgs,
  lib,
  localLib,
  config,
  ...
}: let
  inherit (lib) getExe;

  managedConfPath = "~/nixos/modules/desktop/jellyfin-mpv-shim/conf.json";

  printDefaultConf =
    # python
    ''
      import json
      # upstream: https://github.com/jellyfin/jellyfin-mpv-shim/raw/master/jellyfin_mpv_shim/conf.py
      from jellyfin_mpv_shim.conf import settings
      print(json.dumps(settings.dict(), indent=4, sort_keys=True))
    '';
  defaultConfFile =
    pkgs.runCommand "jellyfin-mpv-shim-default-conf.json" {
      nativeBuildInputs = [
        (pkgs.python3.withPackages (ps: [
          (ps.toPythonModule pkgs.jellyfin-mpv-shim)
        ]))
      ];
    }
    "python -c '${printDefaultConf}' > $out";

  prepareConf = pkgs.writeShellScript "jellyfin-mpv-shim-prepare-conf" ''
    set -euo pipefail

    conf=~/.config/jellyfin-mpv-shim/conf.json
    conf_generated=~/.config/jellyfin-mpv-shim/conf.generated.json
    rm -f "$conf_generated"

    ${getExe pkgs.jq} --indent 4 -s '.[0] * .[1]' ${defaultConfFile} ${managedConfPath} > "$conf_generated"
    chmod a-w "$conf_generated"
    install -m 644 "$conf_generated" "$conf"
  '';
in {
  imports = [
    ../mpv
  ];

  my.jails.jellyfin-mpv-shim = {
    enable = true;
    bootstrapService.enable = false;
    package = localLib.wrap.pkg pkgs.jellyfin-mpv-shim {
      wrapperArgs = ["--run" prepareConf];
    };
    inherit (config.my.jails.mpv) basePermissions;
    permissions = combinators:
      with combinators; [
        gui
        gpu

        network
        fake-machine-id

        (add-pkg-deps [
          (pkgs.mpv.override {
            scripts = [pkgs.mpvScripts.mfpbar];
          })
        ])

        (mkdir-readwrite (noescape "~/.config/jellyfin-mpv-shim"))
        (mkdir-readwrite (noescape "~/.cache/jellyfin-mpv-shim"))
      ];
  };
}
