{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (lib) types;
  inherit (lib.options) mkOption;
in {
  imports = [
    inputs.hjem.nixosModules.default
    ./symlinks.nix
  ];

  options = {
    my.hjem = mkOption {
      type = types.deferredModule;
      default = {};
      description = "Module applied to every managed user's hjem config";
    };
  };

  config = {
    hjem.extraModules = [
      config.my.hjem
      ({config, ...}: {
        files = {
          ".bash_profile".source = config.environment.loadEnv;
        };
      })
    ];
  };
}
