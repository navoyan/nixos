{
  pkgs,
  my,
  ...
}: let
  inherit
    (my.lib)
    jail
    symlinks
    ;

  _7z = pkgs._7zip-zstd-rar;
  _7zPermissions = combinators:
    with combinators; [
      mount-cwd
    ];
  _7zJailedPackages =
    ["7z" "7za" "7zr" "7zz"]
    |> map (bin: jail.pkg bin _7z _7zPermissions);

  yazi = pkgs.yazi.override {
    _7zz = jail.bin "7zz" _7z _7zPermissions;
    extraPackages = with pkgs; [socat exiftool];
  };
in {
  environment.systemPackages =
    [yazi]
    ++ _7zJailedPackages;

  my.outOfStoreSymlinks.config.yazi = symlinks.sources "cli/yazi" [
    "./yazi.toml"
    "./keymap.toml"
    "./theme.toml"
    "./package.toml"
    "./init.lua"
    "./plugins/confirm-paste-force.yazi"
  ];

  my.hjem.xdg.mime-apps = {
    added-associations = {
      "folder/local" = "yazi.desktop";
    };
    default-applications = {
      "folder/local" = "yazi.desktop";
      "inode/directory" = "yazi.desktop";
    };
  };
}
