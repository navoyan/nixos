{
  inputs,
  pkgs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
in {
  programs.tack = {
    enable = true;
    package = inputs.tack.packages.${system}.default;
    nixConfTokens = true;
  };
}
