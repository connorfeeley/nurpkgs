# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ lib
, stdenv
, fetchurl
, fetchFromGitHub
, cmake
, boost
, cpprestsdk
, nlohmann_json
, avahi-compat
, dbus
, gtest
, elfutils
, zlib
, bzip2
, wget
, texinfo6
, lzma
, bison
, ncurses
, gdb
}:

let
  gdbVer = "10.2";
  gdbSrc = fetchurl {
    url = "http://ftp.gnu.org/gnu/gdb/gdb-${gdbVer}.tar.gz";
    hash = "sha256-szrVjWh0h6gh7I2Hjaqw9xa+YNCTby46xc8IQZznA1A=";
  };
  gdb' = gdb.overrideAttrs (oldAttrs: rec {
    src = gdbSrc;
    version = gdbVer;
  });
in

stdenv.mkDerivation rec {
  pname = "crash-utility";
  version = "8.0.3";

  src = fetchFromGitHub {
    owner = "crash-utility";
    repo = "crash";
    rev = "refs/tags/${version}";
    hash = "sha256-NWP9Zgbua2SDJi813NmhET570E/jE59darcSADIT+nw=";
  };

  buildInputs = [ elfutils zlib bzip2 lzma ncurses gdb ];
  nativeBuildInputs = [ wget texinfo6 bison ];

  makeFlags = [ "LINKTYPE=static" "DESTDIR=$out" "PREFIX=$out" "DESTDIR=$out" "V=1" "INSTALLDIR=$out/bin" ];

  postPatch = ''
    substituteInPlace Makefile --replace /usr/bin/wget ${wget}/bin/wget
    substituteInPlace Makefile --replace '/usr/bin/install' "install"
    substituteInPlace Makefile --replace 'wget $$WGET_OPTS http://ftp.gnu.org/gnu/gdb/''${GDB}.tar.gz; fi'  "cp ${gdbSrc} gdb-${gdbVer}.tar.gz; fi"
  '';
  enableParallelBuilding = true;

  meta = with lib; {
    description = "Linux kernel crash utility";
    homepage = "https://crash-utility.github.io/";
    platforms = platforms.linux;
    license = licenses.gpl2;
    maintainers = with maintainers; [ cfeeley ];

    broken = true;
  };
}
