{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "maclaunch";
  version = "2.4";

  src = fetchFromGitHub {
    owner = "hazcod";
    repo = pname;
    rev = version;
    sha256 = "sha256-JK2P2RI1iwir1C0yMM0OFq7tpL00SVPvjqSbuRL4DmE=";
  };

  installPhase = ''
    install -Dm 755 maclaunch.sh $out/bin/maclaunch
  '';

  meta = with lib; {
    description = "Manage your macOS startup items.";
    homepage = "https://github.com/hazcod/maclaunch";
    license = licenses.mit;
    maintainers = with maintainers; [ cfeeley ];
    platforms = platforms.darwin;
  };
}
