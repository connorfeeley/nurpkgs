# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ lib
, stdenv
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
, lzma
}:

stdenv.mkDerivation rec {
  pname = "makedumpfile";
  version = "a34f017965583e89c4cb0b00117c200a6c191e54";

  src = fetchFromGitHub {
    owner = "makedumpfile";
    repo = pname;
    rev = version;
    sha256 = "sha256-H3rTI+CeQzI8l9KnCqcHHNIqla1Twsr+9CpwRt1cp10=";
  };

  buildInputs = [ elfutils zlib bzip2 lzma ];

  makeFlags = [ "LINKTYPE=dynamic" "PREFIX=$out" "DESTDIR=$out" ];

  meta = with lib; {
    description = "Make Linux crash dump small by filtering and compressing pages";
    homepage = "https://github.com/makedumpfile/makedumpfile";
    platforms = platforms.linux;
    license = licenses.gpl2;
    maintainers = with maintainers; [ cfeeley ];
  };
}
