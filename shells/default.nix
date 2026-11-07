{
  nixpkgs,
  self,
  ...
} @ inputs: let
  system = "x86_64-linux";

  pkgs = import nixpkgs {
    inherit system;
    overlays = [self.overlays.tack];
  };
  inherit (pkgs) lib;

  gitHooks = import ./git-hooks {
    inherit inputs pkgs lib;
  };
in {
  devShells.${system}.default = pkgs.mkShell {
    packages =
      gitHooks.enabledPackages
      ++ [pkgs.tack];
    shellHook =
      # bash
      ''
        git add --intent-to-add .
        ${gitHooks.shellHook}
      '';
  };
}
