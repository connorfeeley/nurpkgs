{ lib
, fetchFromGitHub
, buildNpmPackage
, python3
, ninja
, clang
}:

# stdenv.mkDerivation rec {

# }

buildNpmPackage rec {
  pname = "rescript-compiler";
  version = "10.1.4";

  npmDepsHash = "sha256-sHqsc3hayG4hpo/V3YEsVzLkXD1KkCbB/K7H5i+FVwg=";

  # The prepack script runs the build script, which we'd rather do in the build phase.
  # npmPackFlags = [ "--ignore-scripts" ];

  # NODE_OPTIONS = "--openssl-legacy-provider";

  nativeBuildInputs = [ python3 ninja clang ];

  src = fetchFromGitHub {
    owner = "rescript-lang";
    repo = "rescript-compiler";
    rev = version;
    hash = "sha256-tU1Oq30reLgEfM2QaiYBoRfbB+HRZrGENT6U/iP7By8=";
  };

  meta = with lib; {
    description = "The compiler for ReScript";
    homepage = "https://github.com/rescript-lang/rescript-compiler.git";
    changelog = "https://github.com/rescript-lang/rescript-compiler/blob/${src.rev}/CHANGELOG.md";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ cfeeley ];
  };
}
