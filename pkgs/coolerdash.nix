{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  cairo,
  curl,
  fontconfig,
  gdk-pixbuf,
  jansson,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "coolerdash";
  version = "3.3.6";

  src = fetchFromGitHub {
    owner = "damachine";
    repo = "coolerdash";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BxlcKNr75bJRKkv8Jd9gvPc9xKgdBM7a8JbDZRw/T2o=";
  };

  # CoolerControl launches the plugin through the path in its manifest
  postPatch = ''
    substituteInPlace etc/coolercontrol/plugins/coolerdash/manifest.toml \
      --replace-fail \
        'executable = "/usr/libexec/coolerdash/coolerdash"' \
        'executable = "${placeholder "out"}/libexec/coolerdash/coolerdash"'
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    cairo
    curl
    fontconfig
    gdk-pixbuf
    jansson
  ];

  makeFlags = [
    "REALOS=no"
    "prefix=${placeholder "out"}"
    "PLUGINDIR=${placeholder "out"}/share/coolercontrol/plugins/coolerdash"
  ];

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Plug-in for CoolerControl that extends the LCD functionality with additional features";
    homepage = "https://github.com/damachine/coolerdash";
    changelog = "https://github.com/damachine/coolerdash/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    mainProgram = "coolerdash";
    platforms = lib.platforms.linux;
  };
})
