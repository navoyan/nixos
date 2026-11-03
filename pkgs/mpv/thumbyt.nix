{
  buildLua,
  fetchFromCodeberg,
}:
buildLua {
  pname = "thumbyt";
  version = "unstable-2026-09-11";

  scriptPath = "thumbyt/thumbyt.lua";
  src = fetchFromCodeberg {
    owner = "NRK";
    repo = "mpv-toolbox";
    rev = "ca506127fe7a3f9235ead023d95c855f6c71c3d6";
    hash = "sha256-wDxfhPipWs6UlnjD8dXU9RxjQH9vSuK1LrOEtisyl3w=";
  };

  meta.homepage = "https://codeberg.org/NRK/mpv-toolbox";
}
