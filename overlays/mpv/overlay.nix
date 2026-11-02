/*
Unreleased git version
*/
{
  self,
  super,
  ...
}: {
  mpv-unwrapped = super.mpv-unwrapped.overrideAttrs (old: {
    version = "v0.41.0-UNKNOWN";
    src = self.fetchFromGitHub {
      owner = "mpv-player";
      repo = "mpv";
      rev = "654e9382c0bbccb09ccac348f792e9d378e9c7a9";
      hash = "sha256-2oPLH6ewbMp8Y/HK+Kpm5qVcvK2BO7C+XUmqI/wnRaI=";
    };
    postPatch = self.lib.concatStringsSep "\n" [
      # Don't reference compile time dependencies or create a build outputs cycle between out and dev
      # bash
      ''
        substituteInPlace meson.build \
          --replace-fail "conf_data.set_quoted('CONFIGURATION', meson.build_options().strip().replace('\\\\', '\\\\\\\\'))" \
                         "conf_data.set_quoted('CONFIGURATION', '<omitted>')"
      ''
      # A trick to patchShebang everything except mpv_identify.sh
      # bash
      ''
        pushd TOOLS
        mv mpv_identify.sh mpv_identify
        patchShebangs *.py *.sh
        mv mpv_identify mpv_identify.sh
        popd
      ''
    ];
  });
}
