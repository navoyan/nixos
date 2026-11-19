{
  lib,
  config,
  ...
}: let
  inherit
    (lib)
    isString
    types
    ;
  inherit (lib.options) mkOption;
  inherit (lib.strings) concatStringsSep;
  inherit (lib.path) subpath;
  inherit
    (lib.attrsets)
    genAttrs
    mergeAttrsList
    concatMapAttrs
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
        type = with types;
          attrsOf (oneOf [
            str
            (listOf baseRelType)
          ]);
        default = {};
      });
  };

  config.my.hjem = {config, ...}: let
    symlinkSourceBase = "${config.directory}/nixos/modules";
  in {
    xdg = genAttrs xdgDirs (xdgDir: {
      files =
        cfg.${xdgDir}
        |> concatMapAttrs (
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
                  normalize = path: concatStringsSep "/" (subpath.components path);
                  target = normalize "${targetBase}/${file.rel}";
                  source = normalize "${file.base}/${file.rel}";
                in {
                  "${target}" = {
                    source = "${symlinkSourceBase}/${source}";
                  };
                }
              )
              |> mergeAttrsList
        );
    });
  };
}
