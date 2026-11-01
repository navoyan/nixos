{pkgs, ...}: let
  scriptsDir = "~/nixos/modules/desktop/scripts";

  awwwReset = pkgs.writeShellApplication {
    name = "awww-reset";
    inheritPath = false;
    runtimeInputs = with pkgs; [
      bashNonInteractive
      awww
    ];
    text = ''
      exec ${scriptsDir}/awww-reset.sh "$@"
    '';
  };

  pickwall = pkgs.writeShellApplication {
    name = "pickwall";
    inheritPath = false;
    runtimeInputs = with pkgs; [
      bashNonInteractive
      coreutils
      findutils
      util-linux
      rofi
      imagemagick
      fd
      awww
    ];
    text = ''
      exec ${scriptsDir}/pickwall.sh "$@"
    '';
  };
in {
  environment.systemPackages = [
    awwwReset
    pickwall
  ];

  hj.environment.sessionVariables = {
    AWWW_TRANSITION = "any";
    AWWW_TRANSITION_FPS = "180";
  };
}
