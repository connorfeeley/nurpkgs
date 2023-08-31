{ lib
, fetchFromGitHub
, nodejs
, nodePackages
, buildDunePackage
, ounit2
, cppo
, js_of_ocaml-compiler
, python3
, ninja
}:

buildDunePackage rec {
  pname = "rescript";
  duneVersion = "2";
  version = "v11.0.0-rc.2"; # TODO: update to v11.0.0 when released

  minimalOCamlVersion = "4.10";

  src = fetchFromGitHub {
    owner = "rescript-lang";
    repo = "rescript-compiler";
    rev = version;
    hash = "sha256-3yp7brVbfuTR6UwS+GeukT/Z00AIJBOUbu6G96+4k6M=";
    fetchSubmodules = true;
  };

  buildInputs = [ js_of_ocaml-compiler ounit2 ];
  nativeBuildInputs = [ cppo nodejs python3 ninja ];
  propagatedBuildInputs = [ ];

  checkInputs = [ ounit2 ];
  nativeCheckInputs = [ nodePackages.prettier ];

  doCheck = true;
  checkPhase = ''
    node scripts/ciTest.js ${lib.concatStringsSep " -" [
      # Most test suites make impure filesystem accesses:
      # "ounit"
      # "mocha"
      # "theme"
      # "bsb"

      "format"
    ]}
  '';

  meta = with lib; {
    description = "The compiler for ReScript";
    homepage = "https://github.com/rescript-lang/rescript-compiler.git";
    changelog = "https://github.com/rescript-lang/rescript-compiler/blob/${src.rev}/CHANGELOG.md";
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [ cfeeley ];
  };
}
