{pkgs, ...}: let
  scriptsDir = "~/nixos/modules/core/nh";

  osScript = pkgs.writeShellApplication {
    name = "os";
    text = ''
      exec ${scriptsDir}/os.sh "$@"
    '';
  };
in {
  programs.nh.enable = true;

  hj = {config, ...}: {
    environment.sessionVariables = {
      NH_FLAKE = "${config.directory}/nixos";
    };
  };

  environment.systemPackages = [
    osScript
  ];
}
