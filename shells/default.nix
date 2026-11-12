{nixpkgs, ...} @ inputs: let
  system = "x86_64-linux";

  pkgs = nixpkgs.legacyPackages.${system};
  inherit (pkgs) lib;

  tack = inputs.tack.packages.${system}.default;

  gitHooks = import ./git-hooks {
    inherit inputs pkgs lib tack;
  };
in {
  devShells.${system}.default = pkgs.mkShell {
    packages =
      gitHooks.enabledPackages
      ++ [tack];
    shellHook =
      # bash
      ''
        git add --intent-to-add .
        ${gitHooks.shellHook}
      '';
  };
}
