{
  nixpkgs,
  nixpkgs-qt6-10,
  nur,
  ...
} @ inputs: let
  inherit (nixpkgs) lib;

  mkOverlay = files: self: super: let
    pkgsQt610 = import nixpkgs-qt6-10 {
      system = super.stdenv.hostPlatform.system;
      overlays = [
        nur.repos.ilya-fedin.overlays.qt6ct
      ];
    };

    toOverlay = file: self: super:
      import file {
        inherit
          pkgsQt610
          self
          super
          ;
      };
  in
    files
    |> map toOverlay
    |> lib.composeManyExtensions
    |> (composed: composed self super);
in {
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
}
