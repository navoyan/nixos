{
  nixpkgs,
  nixpkgs-qt6-10,
  nur,
  ...
} @ inputs: let
  inherit (nixpkgs) lib;
  inherit (lib.fixedPoints) composeManyExtensions;

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
    |> composeManyExtensions
    |> (composed: composed final prev);
in {
  overlays = {
    default = (import ../pkgs inputs).overlay;

    qutebrowser = mkOverlay [
      ./qutebrowser.nix
    ];
    pinentry-qt = mkOverlay [
      ./pinentry-qt.nix
    ];
    depotdownloader = mkOverlay [
      ./depotdownloader.nix
    ];
    xdg-dbus-proxy-unicast-signals = mkOverlay [
      ./xdg-dbus-proxy-unicast-signals/overlay.nix
    ];
    sofka = composeManyExtensions [
      inputs.sofka.overlays.default
      (mkOverlay [./sofka.nix])
    ];
  };
}
