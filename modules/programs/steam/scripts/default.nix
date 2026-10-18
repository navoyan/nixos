{
  config,
  pkgs,
  localLib,
  ...
}: let
  scriptsDir = "${config.programs.nh.flake}/modules/programs/steam/scripts";

  depotDownloaderMod = pkgs.depotdownloader.overrideAttrs (old: {
    version = "unstable-2026-10-09";
    src = pkgs.fetchFromGitHub {
      owner = "oureveryday";
      repo = "DepotDownloaderMod";
      rev = "24d9931789fc35de6becf2e2a498d01cfcd0dc03";
      hash = "sha256-0GlsP9XtwrfMhMEkIQN1Iokz4VguXxKOa1PjSKYLxqs=";
    };
    dotnetProjectFiles = ["DepotDownloaderMod.sln"];
    projectFile = "DepotDownloaderMod.sln";
    dotnetFlags = (old.dotnetFlags or []) ++ ["-p:TreatWarningsAsErrors=false"];
    meta.mainProgram = "DepotDownloaderMod";
  });
  depotDownloaderModJailed = localLib.jail.bin "DepotDownloaderMod" depotDownloaderMod (combinators:
    with combinators; [
      network

      # manifests:
      (readwrite (noescape "~/.local/share/steam-manifests"))

      # Steam apps:
      (readwrite (noescape "~/.local/share/Steam/steamapps/common"))
      (readwrite (noescape "~/Data/Steam/steamapps/common"))
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
      exec "${scriptsDir}/depotdl.sh" "$@"
    '';
  };

  scoperun = pkgs.writeShellApplication {
    name = "scoperun";
    runtimeInputs = with pkgs; [
      gamescope
      mangohud
    ];
    text = ''
      exec "${scriptsDir}/scoperun.sh" "$@"
    '';
  };

  wlrun = pkgs.writeShellApplication {
    name = "wlrun";
    runtimeInputs = with pkgs; [
      gamescope
      mangohud
    ];
    text = ''
      exec "${scriptsDir}/wlrun.sh" "$@"
    '';
  };
in {
  environment.systemPackages = [depotdl];

  programs.steam.extraPackages = [
    scoperun
    wlrun
  ];
}
