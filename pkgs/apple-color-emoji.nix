{
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "apple-color-emoji";
  version = "macos-26-20260722-484daf4e";

  src = fetchurl {
    url = "https://github.com/samuelngs/apple-emoji-ttf/releases/download/${finalAttrs.version}/AppleColorEmoji-Linux.ttf";
    hash = "sha256-43x69iZaxKCvbVe8ZehhCad22ZZug0MzRVf2PaSCUW8=";
  };
  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/share/fonts/truetype/AppleColorEmoji.ttf
    runHook postInstall
  '';

  meta.homepage = "https://github.com/samuelngs/apple-emoji-ttf";
})
