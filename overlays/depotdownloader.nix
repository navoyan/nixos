{prev, ...}: {
  depotdownloader = prev.depotdownloader.overrideAttrs (old: {
    version = "unstable-2026-10-09";
    src = prev.fetchFromGitHub {
      owner = "oureveryday";
      repo = "DepotDownloaderMod";
      rev = "24d9931789fc35de6becf2e2a498d01cfcd0dc03";
      hash = "sha256-uxsYrLRlpw0BMbP8bEFCzJYuPIP/+NQ2ZBYdz9+MWak=";
    };
    dotnetProjectFiles = ["DepotDownloaderMod.sln"];
    projectFile = "DepotDownloaderMod.sln";
    dotnetFlags = (old.dotnetFlags or []) ++ ["-p:TreatWarningsAsErrors=false"];
    meta.mainProgram = "DepotDownloaderMod";
  });
}
