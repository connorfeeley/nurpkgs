{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "rclone-tui";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "darkhz";
    repo = "rclone-tui";
    rev = "v${version}";
    hash = "sha256-aU37Co/g6LTLEvKim5qFnz3lie5ZoTFj66jMYx/dO1U=";
  };

  vendorHash = "sha256-QUD4N+pAwxXyVF4W4HaQ/8Gcfu7idYk8KsbNAYF2y9g=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "Cross-platform manager for rclone";
    homepage = "https://github.com/darkhz/rclone-tui";
    license = licenses.mit;
    maintainers = with maintainers; [ cfeeley ];
  };
}
