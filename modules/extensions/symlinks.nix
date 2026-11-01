{
  lib,
  config,
  ...
}: let
  inherit
    (lib)
    genAttrs
    isString
    mkOption
    types
    ;

  xdgDirs = ["config" "data" "cache" "state"];

  baseRelType = types.submodule {
    options = {
      base = mkOption {
        type = types.str;
      };
      rel = mkOption {
        type = types.str;
      };
    };
  };

  cfg = config.my.outOfStoreSymlinks;
in {
  options = {
    my.outOfStoreSymlinks = genAttrs xdgDirs (_:
      mkOption {
        type = types.attrsOf (
          types.oneOf [
            types.str
            (types.listOf baseRelType)
          ]
        );
        default = {};
      });
  };

  config.hj = {config, ...}: let
    symlinkSourceBase = "${config.directory}/nixos/modules";
  in {
    xdg = genAttrs xdgDirs (xdgDir: {
      files =
        cfg.${xdgDir}
        |> lib.concatMapAttrs (
          targetBase: source:
            if isString source
            then {
              ${targetBase} = {
                source = "${symlinkSourceBase}/${source}";
              };
            }
            else
              source
              |> map (
                file: let
                  normalize = path: lib.concatStringsSep "/" (lib.path.subpath.components path);
                  target = normalize "${targetBase}/${file.rel}";
                  source = normalize "${file.base}/${file.rel}";
                in {
                  "${target}" = {
                    source = "${symlinkSourceBase}/${source}";
                  };
                }
              )
              |> lib.mergeAttrsList
        );
    });
  };
}
