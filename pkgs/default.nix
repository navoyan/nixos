{nixpkgs, ...}: let
  system = "x86_64-linux";
  pkgs = nixpkgs.legacyPackages.${system};
in {
  overlay = self: super: {
    mpvScripts = super.mpvScripts.overrideScope (mself: msuper: {
      mfpbar = mself.callPackage ./mpv/mfpbar.nix {};
      thumbyt = mself.callPackage ./mpv/thumbyt.nix {};
    });
    apple-color-emoji = self.callPackage ./apple-color-emoji.nix {};
  };

  packages.${system} = with pkgs; {
    mpv-mfpbar = mpvScripts.callPackage ./mpv/mfpbar.nix {};
    mpv-thumbyt = mpvScripts.callPackage ./mpv/thumbyt.nix {};
    apple-color-emoji = callPackage ./apple-color-emoji.nix {};
  };
}
