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
  ];

  buildInputs = [ boost ];
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
    license = licenses.mit;
    maintainers = with maintainers; [ cfeeley ];
  };
}
