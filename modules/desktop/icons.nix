{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) generators;
in {
  environment.systemPackages = [
    pkgs.adwaita-icon-theme
  ];

  my.hjem.xdg.data.files = {
    "icons/default/index.theme" = {
      generator = generators.toINI {};
      value = {
        "Icon Theme".Inherits = "Adwaita";
      };
    };
  };
}
