{pkgs, ...}: let
  scriptsDir = "~/nixos/modules/core/nix/scripts";

  osScript = pkgs.writeShellApplication {
    name = "os";
    text = ''
      exec ${scriptsDir}/os.sh "$@"
    '';
  };
in {
  environment.systemPackages = [
    osScript
  ];
}
