/*
Qt-6.10.2 dependencies.
ISSUE: https://github.com/qutebrowser/qutebrowser/issues/8925
*/
{pkgsQt610, ...}: {
  qutebrowser = pkgsQt610.qutebrowser.overrideAttrs (old: {
    qtWrapperArgs =
      (old.qtWrapperArgs or [])
      ++ [
        "--suffix"
        "QT_PLUGIN_PATH"
        ":"
        "${pkgsQt610.qt6Packages.qt6ct}/lib/qt-6/plugins"

        # GL drivers (radeonsi_dri.so):
        "--set"
        "LIBGL_DRIVERS_PATH"
        "${pkgsQt610.mesa}/lib/dri"

        # VA-API video decode (radeonsi_drv_video.so):
        "--set"
        "LIBVA_DRIVERS_PATH"
        "${pkgsQt610.mesa}/lib/dri"

        # make libglvnd's EGL use the pinned Mesa, not /run/opengl-driver:
        "--set"
        "__EGL_VENDOR_LIBRARY_FILENAMES"
        "${pkgsQt610.mesa}/share/glvnd/egl_vendor.d/50_mesa.json"
      ];
  });
}
