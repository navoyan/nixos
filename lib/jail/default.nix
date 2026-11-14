{
  config,
  inputs,
  pkgs,
  lib,
  ...
} @ args: let
  inherit (lib) getExe;
  inherit (lib.attrsets) mergeAttrsList;
in rec {
  bin = inputs.jail-nix.lib.extend {
    # see: overlays/xdg-dbus-proxy-unicast-signals/overlay.nix
    pkgs = pkgs // {xdg-dbus-proxy = pkgs.xdg-dbus-proxy-unicast-signals;};

    additionalCombinators = builtinCombinators:
      import ./combinators
      |> map (combinator:
        import combinator (
          args
          // {
            inherit builtinCombinators;
            inherit (bin) combinators;
          }
        ))
      |> mergeAttrsList;

    basePermissions = combinators:
      with combinators; [
        # defaults:
        base
        bind-nix-store-runtime-closure
        fake-passwd

        # essential env:
        (fwd-env "USER")
        (fwd-env "XDG_RUNTIME_DIR")
        (fwd-env "XDG_CURRENT_DESKTOP")
        (fwd-env "NIXOS_OZONE_WL")

        # bash:
        (add-pkg-deps [pkgs.bash])
        (ro-bind "${pkgs.bash}/bin/bash" "/bin/bash")
        (ro-bind "${pkgs.coreutils}/bin/env" "/usr/bin/env")

        # locale:
        (add-pkg-deps [pkgs.glibcLocales])
        (set-env "LOCALE_ARCHIVE" "${pkgs.glibcLocales}/lib/locale/locale-archive")

        # config:
        (set-hostname config.networking.hostName)
        (defer (readonly (noescape "~/nixos")))
      ];
  };

  pkg = name: pkg: permissions:
    pkgs.symlinkJoin {
      inherit (pkg) name;
      meta = pkg.meta // {mainProgram = name;};
      paths = [pkg];
      postBuild = ''
        ln -sf ${getExe (bin name pkg permissions)} $out/bin/${name}
      '';
      passthru.unjailed = pkg;
    };
}
