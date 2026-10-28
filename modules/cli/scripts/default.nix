{
  config,
  pkgs,
  ...
}: let
  scriptsDir = "${config.programs.nh.flake}/modules/cli/scripts";

  os = pkgs.writeShellApplication {
    name = "os";
    runtimeEnv = {
      NH_FLAKE = config.programs.nh.flake;
    };
    text = ''
      exec "${scriptsDir}/os.sh" "$@"
    '';
  };
in {
  environment.systemPackages = [
    os
  ];
}
