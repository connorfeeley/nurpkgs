{ lib, stdenv, fetchFromGitHub, xcbuildHook, Foundation }:
stdenv.mkDerivation rec {
  pname = "sloth";
  version = "3.2";

  src = fetchFromGitHub {
    owner = "sveinbjornt";
    repo = pname;
    rev = version;
    sha256 = "sha256-DTfC8feFWWX71py1ZBoBAK+Qbo5A8MK1fweAlGBSA60=";
  };

  nativeBuildInputs = [ xcbuildHook ];
  buildInputs = [ Foundation ];

  meta = with lib; {
    description = "Mac app that shows all open files, directories, sockets, pipes and devices in use by all running processes. Nice GUI for lsof.";
    homepage = "https://github.com/sveinbjornt/sloth";
    license = licenses.bsd3;
    maintainers = with maintainers; [ cfeeley ];
    broken = true;
  };
}
