{
  config,
  inputs,
  lib,
  user,
  ...
}: {
  imports = [
    inputs.hjem.nixosModules.default
    (lib.mkAliasOptionModule ["hj"] ["hjem" "users" user])
  ];

  hj.directory = "/home/${user}";

  hj.files = {
    ".bash_profile".source = config.hj.environment.loadEnv;
  };
}
