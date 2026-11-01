{
  config,
  lib,
  inputs,
  ...
}: let
  inherit
    (lib)
    types
    genAttrs
    ;
  inherit (lib.options) mkOption;
in {
  imports = [inputs.hjem.nixosModules.default];

  options = {
    my.manageHomeForUsers = mkOption {
      type = types.listOf types.str;
    };

    hj = mkOption {
      type = types.deferredModule;
      default = {};
      description = "Module applied to every managed user's hjem config";
    };
  };

  config = {
    hjem.users = genAttrs config.my.manageHomeForUsers (user: {
      user = user;
      directory = "/home/${user}";
      files = {
        ".bash_profile".source = config.hjem.users.${user}.environment.loadEnv;
      };
    });

    hjem.extraModules = [config.hj];
  };
}
