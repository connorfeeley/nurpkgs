{ lib, stdenv, fetchFromGitHub, installShellFiles, nix-update-script }:
let
  completions = [
    "asr"
    "bless"
    "dscl"
    "hdiutil"
    "launchctl"
    "log"
    "pkgbuild"
    "pkgutil"
    "autopkg"
    "diskutil"
    "dsimport"
    "installer"
    "networksetup"
    "pkginfo"
    "quickpkg"
  ];
in
stdenv.mkDerivation rec {
  pname = "apple_complete";
  version = "20230206";

  src = fetchFromGitHub {
    owner = "Honestpuck";
    repo = pname;
    rev = "32e6ac89dc1bd267821f54f3181260dc4be38e6b";
    sha256 = "sha256-NuRUXlfSCzygLYfP0p/9cpel4GB0OJ04OQ6vc5wZqHQ=";
  };

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    ${lib.concatMapStringsSep "\n" (comp: ''
      installShellCompletion --bash ${comp}
      installShellCompletion --zsh ${comp}
    '') completions}
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "bash completion for some of Apple's MacOS tools and common macadmin tools. Can be used with `zsh`";
    homepage = "https://github.com/Honestpuck/apple_complete";
    license = licenses.asl20;
    maintainers = with maintainers; [ cfeeley ];
  };
}
