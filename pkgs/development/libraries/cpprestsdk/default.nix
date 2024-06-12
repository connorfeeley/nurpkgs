# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ lib
, stdenv
, fetchFromGitHub
, websocketpp
, cmake
, ninja
, openssl
, boost
, zlib
, fetchpatch
, Security
}:

stdenv.mkDerivation rec {
  pname = "cpprestsdk";
  version = "2.10.18";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = pname;
    rev = version;
    sha256 = "sha256-RCt6BIFxRDTGiIjo5jhIxBeCOQsttWViQcib7M0wZ5Y=";
  };

  patches = [
    # Fix build with GCC >= 12
    (fetchpatch {
      url = "https://github.com/microsoft/cpprestsdk/pull/1742/commits/3dc3f2b3b2d0a42de12aa1fcfaf261a4d2c242b0.patch";
      sha256 = "sha256-aF+poF+Q+c2NkXLUZjcQ6m0NgPLZGDniSJpROMlewXk=";
    })
  ] ++ (lib.optionals stdenv.isDarwin [
    # Find openssl on macOS
    (fetchpatch {
      url = "https://github.com/microsoft/cpprestsdk/pull/1439/commits/ccd74e1b62fcffa3c7ac37fc90152433b20baf2f.patch";
      sha256 = "sha256-W2OmlXNI5UJyrPCF3vftVjKrk4K5msBh+I3f6YG6pnI=";
    })
  ]);

  env = {
    NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-Wno-unused-but-set-parameter";
    NIX_CXXFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-Wno-unused-but-set-parameter";
  };

  buildInputs = [ boost ] ++ (lib.optionals stdenv.isDarwin [ Security ]);
  propagatedBuildInputs = [ zlib websocketpp openssl ];
  nativeBuildInputs = [ cmake ninja ];

  # Fails in sandbox
  doCheck = false;

  outputs = [ "out" ] ++ [
    # FIXME: header install tries to install into existing pplx directory
    # "dev"
  ];

  meta = with lib; {
    description = "The C++ REST SDK is a Microsoft project for cloud-based client-server communication in native code using a modern asynchronous C++ API design. This project aims to help C++ developers connect to and interact with services.";
    homepage = "https://github.com/microsoft/cpprestsdk";
    platforms = platforms.unix;
    license = licenses.mit;
    maintainers = with maintainers; [ cfeeley ];
  };
}
