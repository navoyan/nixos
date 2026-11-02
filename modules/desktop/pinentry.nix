{
  pkgs,
  flake,
  ...
}: {
  nixpkgs.overlays = [flake.overlays.pinentry-qt];

  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-qt;

  environment.systemPackages = [pkgs.pinentry-qt];
}
