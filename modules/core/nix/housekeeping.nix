{lib, ...}: let
  inherit (lib.cli) toCommandLineShellGNU;
in {
  programs.nh.clean = {
    enable = true;
    dates = "weekly";
    extraArgs = toCommandLineShellGNU {} {
      keep-since = "7d";
      keep = 10;
    };
  };

  nix.optimise = {
    automatic = true;
    dates = ["daily"];
  };
}
