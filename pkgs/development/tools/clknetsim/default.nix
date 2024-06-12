# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ lib
, stdenv
, fetchurl
, fetchFromGitLab
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

stdenv.mkDerivation rec {
  pname = "clknetsim";
  version = "2023-11-15";

  src = fetchFromGitLab {
    owner = "chrony";
    repo = "clknetsim";
    rev = "5d1dc05806155924d7f0a004f7e0643b866c7807";
    hash = "sha256-IDj3LjPmXnaCF6X4yWuNMzOiOerCXsvp7az2hPdaCNc=";
  };

  buildInputs = [ elfutils zlib bzip2 lzma ncurses gdb ];
  nativeBuildInputs = [ wget texinfo6 bison ];

  enableParallelBuilding = true;

  installPhase = ''
    mkdir -p $out/{bin,lib}
    cp clknetsim clknetsim.so clknetsim.bash $out/bin
    cp clknetsim.so $out/lib/
  '';

  meta = with lib; {
    platforms = platforms.linux;
    maintainers = with maintainers; [ cfeeley ];
  };
}
