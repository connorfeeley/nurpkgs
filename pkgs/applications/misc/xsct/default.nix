# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ stdenv
, lib
, fetchurl
, patchelf
, procps
, makeWrapper
, ncurses
, zlib
, libX11
, libXrender
, libxcb
, libXext
, libXtst
, libXi
, libxcrypt
, glib
, freetype
, gtk2
, glibc
, gperftools
, fontconfig
, liberation_ttf
}:

let
  releaseMajor = "2021";
  releaseMinor = "2";
  version = "${releaseMajor}-${releaseMinor}";

  src = fetchurl {
    url = "http://petalinux.xilinx.com/sswreleases/rel-v${releaseMajor}/xsct-trim/xsct-${version}.tar.xz";
    hash = "sha256-sDjp8QHGiuaRYW0JdmUeK+nQReGjbZl7/kMcFSarepw=";
  };
in
stdenv.mkDerivation rec {
  pname = "xsct";
  inherit version src;

  nativeBuildInputs = [ zlib ];
  buildInputs = [ patchelf procps ncurses makeWrapper ];

  builder = ./builder-xsct.sh;
  inherit ncurses;
  libPath = lib.makeLibraryPath [
    stdenv.cc.cc
    ncurses
    zlib
    libX11
    libXrender
    libxcb
    libXext
    libXtst
    libXi
    freetype
    gtk2
    glib
    libxcrypt
    gperftools
    glibc.dev
    fontconfig
    liberation_ttf
  ];

  meta = with lib; {
    homepage = "https://www.xilinx.com/htmldocs/xilinx2019_1/SDK_Doc/xsct/intro/xsct_introduction.html";
    description = "Xilinx Software Command-Line Tools";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [ maintainers.cfeeley ];
  };
}
