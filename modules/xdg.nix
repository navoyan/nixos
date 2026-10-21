{
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    genAttrs
    isString
    mkOption
    types
    ;

  cfg = config.my.outOfStoreSymlinks;

  symlinkSourceBase = "${config.programs.nh.flake}/modules";
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

  config = {
    hj.xdg = genAttrs xdgDirs (xdgDir: {
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
