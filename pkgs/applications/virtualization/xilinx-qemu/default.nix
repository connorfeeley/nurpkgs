{ lib
, stdenv
, bison
, buildPackages
, curl
, fetchFromGitHub
, flex
, glib
, gnutls
, libgcrypt
, lzo
, ncurses
, nettle
, perl
, pixman
, pkg-config
, snappy
, texinfo
, vde2
, zlib
  # Darwin dependencies
, patchelf
, rez
, setfile
, Cocoa
, CoreAudio
}:

stdenv.mkDerivation rec {
  pname = "xilinx-qemu";
  version = "2021.1";

  src = fetchFromGitHub {
    owner = "Xilinx";
    repo = "qemu";
    rev = "xilinx-v${version}";
    hash = "sha256-SdoCRjsU0cUACESNCcMO2cDlFJhfnyL+uRp3hDnHbFE=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    (buildPackages.python3.withPackages (p: [ p.libfdt ]))
    bison
    flex
    pkg-config
  ] ++ lib.optionals stdenv.isDarwin [ rez setfile patchelf ];

  buildInputs = [
    curl
    glib
    gnutls
    libgcrypt
    lzo
    ncurses
    nettle
    perl
    pixman
    snappy
    texinfo
    vde2
    zlib
  ] ++ lib.optionals stdenv.isDarwin [ CoreAudio Cocoa ];

  preConfigure = ''
    # Prevent trying to install to /var
    substituteInPlace Makefile \
      --replace 'install-datadir install-localstatedir install-includedir' 'install-datadir install-includedir'
  '';

  configureFlags = [
    "--disable-kvm"
    "--disable-xen"
    "--enable-fdt"
    "--enable-gcrypt"
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--target-list=aarch64-softmmu,microblazeel-softmmu"
  ];

  enableParallelBuilding = true;
  doCheck = false; # Failures: 117 127 143 156 191

  meta = with lib; {
    homepage = "https://docs.xilinx.com/v/u/en-US/ug1169-xilinx-qemu";
    description = "Xilinx's fork of Quick EMUlator (QEMU) with improved support and modelling for the Xilinx platforms.";
    maintainers = [ maintainers.cfeeley ];
    license = licenses.gpl2Plus;
  };
}
