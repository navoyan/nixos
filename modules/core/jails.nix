{
  pkgs,
  lib,
  my,
  config,
  ...
}: let
  inherit
    (lib)
    getExe
    types
    ;
  inherit
    (lib.options)
    literalExpression
    mkEnableOption
    mkOption
    mkPackageOption
    ;
  inherit
    (lib.attrsets)
    concatMapAttrs
    filterAttrs
    mapAttrsToList
    ;
  inherit (lib.strings) toLower;

  # connects to the jail socket and passes argv
  jailTx = jailName:
    pkgs.writeShellScriptBin jailName ''
      ${pkgs.s6}/bin/s6-sudo "$XDG_RUNTIME_DIR/h2jc/${jailName}/sock" "$@"
    '';

  # serves connections accepted on the jail socket:
  jailRx = jailName: jailCfg:
    my.lib.jail.bin "${jailName}-jail-rx" jailCfg.package (
      combinators:
        (jailCfg.allPermissions combinators)
        ++ (with combinators; [
          (add-pkg-deps [pkgs.s6])
          (wrap-entry (entry:
            # bash
            ''
              handler() {
                ${entry}
              }
              export -f handler

              exec s6-ipcserverd -c 8 \
                s6-sudod "$BASH" -c 'handler "$@"' handler
            ''))
        ])
    );

  mkPermissionsOption = extraAttrs:
    mkOption {
      type = types.anything;
      example =
        literalExpression
        # nix
        ''
          combinators:
            with combinators; [
            ]
        '';
    }
    // extraAttrs;

  jailSubmodule = types.submodule ({
    name,
    config,
    ...
  }: {
    options = {
      enable = mkEnableOption "jail for ${name}";
      package = mkPackageOption pkgs name {};
      bootstrapService = mkOption {
        type = types.submodule {
          options = {
            enable = mkOption {
              type = types.bool;
              example = true;
            };
          };
        };
      };
      basePermissions = mkPermissionsOption {
        default = _combinators: [];
      };
      permissions = mkPermissionsOption {};
      allPermissions = mkOption {
        type = types.anything;
        readOnly = true;
        internal = true;
      };
    };
    config = {
      allPermissions = combinators:
        (config.basePermissions combinators)
        ++ (config.permissions combinators);
    };
  });

  enabledJails = config.my.jails |> filterAttrs (_: jailCfg: jailCfg.enable);
  bootstrappedJails = enabledJails |> filterAttrs (_: jailCfg: jailCfg.bootstrapService.enable);
in {
  options.my.jails = mkOption {
    type = types.attrsOf jailSubmodule;
  };

  config = {
    environment.systemPackages =
      [
        pkgs.bubblewrap # for man pages and tricks
      ]
      ++ (enabledJails
        |> mapAttrsToList (
          jailName: jailCfg:
            if jailCfg.bootstrapService.enable
            then
              pkgs.symlinkJoin {
                name = "${jailCfg.package.name}-jail-tx";
                paths = [
                  (jailTx jailName)
                  jailCfg.package
                ];
              }
            else (my.lib.jail.pkg jailName jailCfg.package jailCfg.allPermissions)
        ));

    systemd.user.sockets =
      bootstrappedJails
      |> concatMapAttrs (jailName: _: {
        "${toLower jailName}-jail" = {
          wantedBy = ["sockets.target"];
          socketConfig = {
            ListenStream = "%t/h2jc/${jailName}/sock";
            Accept = false;
            SocketMode = "0600";
            DirectoryMode = "0700";
          };
        };
      });

    systemd.user.services =
      bootstrappedJails
      |> concatMapAttrs (jailName: jailCfg: {
        "${toLower jailName}-jail" = {
          enable = true;
          wantedBy = ["graphical-session.target"];
          path = ["/run/current-system/sw"];
          serviceConfig = {
            Type = "exec";
            StandardInput = "socket";
            ExecStart = getExe (jailRx jailName jailCfg);
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };
      });

    # derive fake machine-id from host /etc/machine-id:
    systemd.services.jail-fake-machine-id = {
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      path = [pkgs.coreutils];
      script = ''
        mkdir -p /run/jail
        echo "jail:$(< /etc/machine-id)" \
          | sha256sum \
          | cut -c1-32 \
          > /run/jail/fake-machine-id
      '';
    };
  };
}
