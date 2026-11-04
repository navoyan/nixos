{flake, ...}: {
  nixpkgs.overlays = [
    flake.overlays.tack
  ];

  programs.tack = {
    enable = true;
    nixConfTokens = true;
  };
}
