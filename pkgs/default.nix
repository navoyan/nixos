{nixpkgs, ...}: let
  system = "x86_64-linux";
  pkgs = nixpkgs.legacyPackages.${system};
in {
  packages.${system} = with pkgs; {
    mpv-mfpbar = mpvScripts.callPackage ./mpv/mfpbar.nix {};
    mpv-thumbyt = mpvScripts.callPackage ./mpv/thumbyt.nix {};
    apple-color-emoji = callPackage ./apple-color-emoji.nix {};
  };

  overlay = final: prev: {
    mpvScripts = prev.mpvScripts.overrideScope (mfinal: mpref: {
      mfpbar = mfinal.callPackage ./mpv/mfpbar.nix {};
      thumbyt = mfinal.callPackage ./mpv/thumbyt.nix {};
    });
    apple-color-emoji = final.callPackage ./apple-color-emoji.nix {};
  };
}
