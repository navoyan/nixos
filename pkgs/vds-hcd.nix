{
  lib,
  stdenv,
  kernel,
  kernelModuleMakeFlags,
  vds,
}:
stdenv.mkDerivation {
  pname = "vds-hcd";
  inherit (vds) version src;

  sourceRoot = "${vds.src.name}/module";

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags =
    kernelModuleMakeFlags
    ++ [
      "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      "VDS_VERSION=${vds.version}"
      "INSTALL_MOD_PATH=${placeholder "out"}"
      "INSTALL_MOD_DIR=extra"
      "DEPMOD=true"
    ];

  # The upstream Makefile only has a DKMS install target,
  # so call kbuild's modules_install directly.
  # It also signs the module and writes the certificate expected by aggregateModules
  installFlags = [
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "M=$(PWD)"
  ];

  installTargets = ["modules_install"];

  meta = {
    description = "Virtual USB host controller kernel module for vDS";
    homepage = "https://github.com/hurryman2212/vds";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    # Requires platform_driver.remove to return void
    broken = lib.versionOlder kernel.version "6.11";
  };
}
