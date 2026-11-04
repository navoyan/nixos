{
  nixpkgs,
  nixpkgs-qt6-10,
  nur,
  ...
} @ inputs: let
  inherit (nixpkgs) lib;

  mkOverlay = files: final: prev: let
    pkgsQt610 = import nixpkgs-qt6-10 {
      system = prev.stdenv.hostPlatform.system;
      overlays = [
        nur.repos.ilya-fedin.overlays.qt6ct
      ];
    };

    toOverlay = file: final: prev:
      import file {
        inherit
          pkgsQt610
          final
          prev
          ;
      };
  in
    files
    |> map toOverlay
    |> lib.composeManyExtensions
    |> (composed: composed final prev);
in {
  overlays = {
    default = (import ../pkgs inputs).overlay;

    mpv = mkOverlay [
      ./mpv/overlay.nix
      ./mpv/thumbfast.nix
    ];
    qutebrowser = mkOverlay [
      ./qutebrowser.nix
    ];
    tack = mkOverlay [
      ./tack.nix
    ];
    pinentry-qt = mkOverlay [
      ./pinentry-qt.nix
    ];
  };
}
