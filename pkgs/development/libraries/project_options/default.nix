# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "project-options";
  version = "0.26.3";

  src = fetchFromGitHub {
    owner = "aminya";
    repo = "project_options";
    rev = "v${version}";
    hash = "sha256-kLGeWkfPQw0nQFVHrma9SETznHP5k9n7paaXDwzpTXE=";
  };

  patchPhase =
    let
      cmake-forward-arguments = fetchFromGitHub {
        owner = "polysquare";
        repo = "cmake-forward-arguments";
        rev = "v1.0.0";
        hash = "sha256-M55CbVZlI8g2KPZaZoEQnJ5L1ghlLewI8717CrrAGS8=";
      };
      ycm = fetchFromGitHub {
        owner = "robotology";
        repo = "ycm";
        rev = "v0.13.0";
        hash = "sha256-vvrYfGFkZ2sMefjy4gLVzmn2rFw2UVGdIecOLCWHDx8=";
      };
    in
    ''
      substituteInPlace src/PackageProject.cmake \
        --replace 'URL https://github.com/polysquare/cmake-forward-arguments/archive/refs/tags/v1.0.0.zip' "SOURCE_DIR ${cmake-forward-arguments}" \
        --replace 'URL https://github.com/robotology/ycm/archive/refs/tags/v0.13.0.zip' "SOURCE_DIR ${ycm}"
    '';
  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';
}
