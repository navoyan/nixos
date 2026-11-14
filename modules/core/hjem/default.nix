{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (lib) types;
  inherit (lib.options) mkOption;
  inherit (lib.attrsets) genAttrs;
in {
  imports = [
    inputs.hjem.nixosModules.default
    ./symlinks.nix
  ];

  options = {
    my.manageHomeForUsers = mkOption {
      type = with types; listOf str;
    };

    hj = mkOption {
      type = types.deferredModule;
      default = {};
      description = "Module applied to every managed user's hjem config";
    };
  };

  config = {
    hjem.users = genAttrs config.my.manageHomeForUsers (user: {
      inherit user;
      directory = "/home/${user}";
      files = {
        ".bash_profile".source = config.hjem.users.${user}.environment.loadEnv;
      };
    });

    hjem.extraModules = [config.hj];
  };
}
