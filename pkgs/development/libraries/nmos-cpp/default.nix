{ lib
, stdenv
, fetchFromGitHub
, cmake
, boost
, cpprestsdk
, nlohmann_json
, zlib
, avahi-compat
, dbus
}:

stdenv.mkDerivation rec {
  pname = "nmos-cpp";
  version = "6fdaefc917cc352d51ad2f991f1c99b0908acca2";

  src = fetchFromGitHub {
    owner = "sony";
    repo = pname;
    rev = version;
    sha256 = "sha256-28+lzndESqg2tC7lpMM2rg9zSuL/WJpBx+NwnGVCfyU=";
  };

  buildInputs = [ boost cpprestsdk nlohmann_json avahi-compat dbus ];
  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DNMOS_CPP_USE_CONAN=OFF" ];

  preConfigure = "cd Development";

  # Fails due to:
  #     The program 'nmos-cpp-test' uses the Apple Bonjour compatibility layer of Avahi.
  #     Please fix your application to use the native API of Avahi!
  doCheck = false;

  outputs = [ "out" "dev" ];

  meta = with lib; {
    description = "An NMOS (Networked Media Open Specifications) Registry and Node in C++ (IS-04, IS-05)";
    homepage = "https://github.com/sony/nmos-cpp";
    platforms = platforms.unix;
    license = licenses.asl20;
    maintainers = with maintainers; [ cfeeley ];
  };
}
