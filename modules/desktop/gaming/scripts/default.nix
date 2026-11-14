{
  pkgs,
  flake,
  my,
  ...
}: let
  inherit (my.lib) jail;

  scriptsDir = "~/nixos/modules/desktop/gaming/scripts";

  overlay = flake.overlays.depotdownloader;
  depotDownloaderModJailed = jail.bin "DepotDownloaderMod" pkgs.depotdownloader (combinators:
    with combinators; [
      network

      # manifests:
      (mkdir-readwrite (noescape "~/.local/share/steam-manifests"))

      # Steam apps:
      (mkdir-readwrite (noescape "~/.local/share/Steam/steamapps/common"))
      (mkdir-readwrite (noescape "~/Data/Steam/steamapps/common"))
    ]);

  depotdl = pkgs.writeShellApplication {
    name = "depotdl";
    runtimeInputs = with pkgs; [
      rbw
      fzf
      curl
      jq
      libarchive
      findutils
      gnused
      gnugrep
      depotDownloaderModJailed
    ];
    text = ''
      exec ${scriptsDir}/depotdl.sh "$@"
    '';
  };

  scoperun = pkgs.writeShellApplication {
    name = "scoperun";
    runtimeInputs = with pkgs; [
      gamescope
      mangohud
    ];
    text = ''
      exec ${scriptsDir}/scoperun.sh "$@"
    '';
  };

  wlrun = pkgs.writeShellApplication {
    name = "wlrun";
    runtimeInputs = with pkgs; [
      gamescope
      mangohud
    ];
    text = ''
      exec ${scriptsDir}/wlrun.sh "$@"
    '';
  };
in {
  nixpkgs.overlays = [overlay];

  environment.systemPackages = [depotdl];

  programs.steam.extraPackages = [
    scoperun
    wlrun
  ];
}
