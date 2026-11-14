{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  bluez,
  dbus,
  libopus,
  systemdLibs,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "vds";
  version = "0.4.0-rc1";

  src = fetchFromGitHub {
    owner = "hurryman2212";
    repo = "vds";
    tag = finalAttrs.version;
    hash = "sha256-Lw+CUzRKYGYLyy0rfphFXaWKSYpPS6mnuKDHnDu48/w=";
  };

  # The version is derived from git tags, which are not available in the sandbox
  postPatch = ''
    substituteInPlace cmake/generate_build_info.cmake \
      --replace-fail \
        'set(VDS_VERSION_COMMAND "''${VDS_VERSION_SCRIPT}")' \
        'set(VDS_VERSION_COMMAND echo "${finalAttrs.version}")'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    bluez
    dbus
    libopus
    systemdLibs
  ];

  postInstall = ''
    install -Dm444 ../99-vds-dualsense-udev.rules -t $out/lib/udev/rules.d
    install -Dm444 ../99-vds-dualsense-wireplumber.conf -t $out/share/wireplumber/wireplumber.conf.d
  '';

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Virtual DualSense Bluetooth-to-USB bridge";
    homepage = "https://github.com/hurryman2212/vds";
    changelog = "https://github.com/hurryman2212/vds/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    mainProgram = "vdsctl";
    platforms = lib.platforms.linux;
  };
})
