# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ lib, stdenv, fetchurl, dpkg, file, glibc, gcc, kernel, kmod, pciutils, pahole, installShellFiles }:

stdenv.mkDerivation rec {
  name = "mft-${version}";
  version = "4.22.1-11";

  src = fetchurl {
    url = "https://www.mellanox.com/downloads/MFT/${name}-x86_64-deb.tgz";
    hash = "sha256-FCknQ9jmjUkU2fkOeI2O62BPl/J8IWb4Rsl6xHa8olA=";
  };

  hardeningDisable = [ "pic" "format" ];

  buildInputs = [ dpkg file pahole ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=$(out)"
  ];

  postUnpack = ''
    dpkg-deb -R $sourceRoot/SDEBS/kernel-mft-dkms_${version}_all.deb $TMPDIR
    rm -rf $TMPDIR/DEBIAN

    dpkg-deb -R $sourceRoot/DEBS/mft_${version}_amd64.deb $TMPDIR
    rm -rf $TMPDIR/DEBIAN

    dpkg-deb -R $sourceRoot/DEBS/mft-oem_${version}_amd64.deb $TMPDIR
    rm -rf $TMPDIR/DEBIAN
  '';

  patchPhase = ''
    substituteInPlace $TMPDIR/etc/init.d/mst \
      --replace "/sbin/modprobe" "${kmod}/bin/modprobe" \
      --replace "/usr/bin/lspci" "${pciutils}/bin/lspci" \
      --replace "/sbin/lsmod" "${kmod}/bin/lsmod"

    substituteInPlace $TMPDIR/etc/mft/mft.conf \
      --replace "/usr" "$out"

    substituteInPlace $TMPDIR/usr/src/kernel-mft-dkms-${lib.versions.major version}.${lib.versions.minor version}.${lib.versions.patch version}/mst_backward_compatibility/*/Makefile \
      --replace '/lib/modules/$(KVERSION)/build' '$(KSRC)'
  '';

  # build kernel modules
  buildPhase = ''
    pushd $TMPDIR/usr/src/kernel-mft-dkms-${lib.versions.major version}.${lib.versions.minor version}.${lib.versions.patch version}
    make KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      KERNELRELEASE=${kernel.modDirVersion} \
      KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      INSTALL_MOD_PATH=$out
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/
    cp ./mst_backward_compatibility/*/*.ko $out/lib/modules/${kernel.modDirVersion}/
    popd
  '';

  installPhase = ''
    mkdir -p $out
    cp -r $TMPDIR/{etc,usr/{bin,lib64,share}} $out

    mkdir -p $out/share/completions
    substituteInPlace $(find $out/etc/bash_completion.d -type f) --replace "/etc/bash_completion.d" "$out/share/completions"
    mv $(find $out/etc/bash_completion.d -type f) $out/share/completions

    substituteInPlace $out/etc/init.d/mst --replace "mbindir=/usr/bin" "mbindir=$out/bin"
    substituteInPlace $out/etc/init.d/mst --replace "mlibdir=/usr/lib64" "mlibdir=$out/lib64"
    unlink $out/bin/mst
    ln -sf $out/etc/init.d/mst $out/bin/mst
    for BIN in $(find $out/bin -type f); do
      if $(file $BIN | grep -q "ELF"); then
        echo "Patching $BIN"
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath "${glibc}/lib:${gcc.cc}/lib:${stdenv.cc.cc.lib}/lib:$out/lib" $BIN
      elif ! $(file $BIN | grep -q "binary data"); then
        echo "Patching $BIN"
        substituteInPlace $BIN --replace "mbindir=/usr/bin" "mbindir=$out/bin"
        substituteInPlace $BIN --replace "mlibdir=/usr/lib64" "mlibdir=$out/lib64"
      else
        echo "Skipping $BIN"
      fi
    done
    for LIB in $(find $out/lib64/mft/python_tools -type f); do
      if $(file $LIB | grep -q "ELF"); then
        echo "Patching $LIB"
        patchelf --set-rpath "${glibc}/lib:${gcc.cc}/lib:${stdenv.cc.cc.lib}/lib:$out/lib" $LIB
      elif ! $(file $LIB | grep -q "binary data"); then
        echo "Patching $LIB"
        substituteInPlace $LIB --replace "mbindir=/usr/bin" "mbindir=$out/bin"
        substituteInPlace $LIB --replace "mlibdir=/usr/lib64" "mlibdir=$out/lib64"
      else
        echo "Skipping $LIB"
      fi
    done
  '';

  postInstall = ''
    installShellCompletion share/completions/foobar.{bash,fish,zsh}
  '';

  # check all ELF files to have their dependencies
  checkPhase = ''
    for BIN in $(ls $out/bin); do
      if $(file $BIN | grep "ELF"); then
        # Test our binary to see if it was correctly patched
        set +e
        ldd $BIN | grep -q -v "not found"
        ST="$?"
        set -e
        if [ "$ST" -ge "0" ]; then
          echo "Failed testing $BIN"
          exit 1;
        fi
      fi
    done
  '';

  dontStrip = true;

  meta = with lib; {
    description = "Mellanox Firmware Tools";
    homepage = "https://network.nvidia.com/products/adapter-software/firmware-tools/";
    license = licenses.unfree;
    maintainers = with maintainers; [ cfeeley ];
    platforms = platforms.linux;
  };
}
