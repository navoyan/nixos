{
  inputs,
  pkgs,
  lib,
  tack,
  ...
}: let
  inherit
    (lib)
    cli
    getExe
    mkAfter
    mkDefault
    mkForce
    mkIf
    types
    ;
  inherit (lib.options) mkOption;

  system = pkgs.stdenv.hostPlatform.system;
in
  inputs.git-hooks.lib.${system}.run {
    src = ../.;
    package = pkgs.prek;

    hookModule = {config, ...}: {
      options = {
        excludeGlobs = mkOption {
          type = with types; listOf str;
          default = [];
        };
      };
      config = {
        raw.exclude = mkIf (config.excludeGlobs != []) (
          mkForce {glob = config.excludeGlobs;}
        );
        priority = mkDefault 100;
      };
    };

    ## https://github.com/cachix/git-hooks.nix/raw/master/modules/hooks.nix
    hooks = {
      trim-trailing-whitespace.enable = true;
      check-added-large-files.enable = true;
      check-executables-have-shebangs.enable = true;
      check-symlinks.enable = true;
      editorconfig-checker = {
        enable = true;
        # fork of existing gtk theme, should not diverge from upstream too much:
        excludeGlobs = ["modules/desktop/gtk/themes/TokyoNight/**"];
      };
      typos.enable = true;

      ## nix
      nix-flake-check = {
        enable = true;
        entry = "nix flake check";
        types = ["nix"];
        pass_filenames = false;
        stages = ["pre-push"];
      };
      alejandra = {
        enable = true;
        settings.verbosity = "quiet";
        excludeGlobs = [".tack/**"];
      };
      statix.enable = true;
      deadnix.enable = true;
      tack-init-resolver = {
        enable = true;
        package = tack;
        entry = "${getExe tack} init --resolver";
        types = ["nix"];
        pass_filenames = false;
      };
      ## sh
      shellcheck = {
        enable = true;
        excludeGlobs = [".envrc" "**/direnvrc"];
      };
      shfmt = {
        enable = true;
        entry = "${getExe pkgs.shfmt} --write";
      };
      ## lua
      stylua.enable = true;
      ## py
      ruff-format.enable = true;
      ## js/json
      biome = {
        enable = true;
        excludeGlobs = ["*lock.json"];
        types_or = mkAfter ["jsonc"];
        settings.flags = cli.toCommandLineShellGNU {} {
          indent-style = "space";
          indent-width = 4;
        };
      };
      ## yaml
      check-yaml.enable = true;
      ## css
      biome-css = {
        enable = true;
        entry = "${getExe pkgs.biome} check";
        types_or = ["css"];
        args = cli.toCommandLineGNU {} {
          write = true;
          indent-style = "space";
          indent-width = 4;
          skip-parse-errors = true;
          css-linter-enabled = "false";
        };
      };
      ## toml
      tombi-format = {
        enable = true;
        package = pkgs.tombi;
        entry = "${getExe pkgs.tombi} format";
        types = ["toml"];
        excludeGlobs = ["*.lock"];
      };
      tombi-lint = {
        enable = true;
        package = pkgs.tombi;
        entry = "${getExe pkgs.tombi} lint";
        types = ["toml"];
        excludeGlobs = ["*.lock"];
      };
    };
  }
