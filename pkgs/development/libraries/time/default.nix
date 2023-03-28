{ lib
, buildGoModule
, fetchFromGitHub
, libpcap
, tzdata
}:

buildGoModule rec {
  pname = "time";
  version = "2023-03-28";

  src = fetchFromGitHub {
    owner = "facebook";
    repo = "time";
    rev = "54fdb4d166257d6eb1003a4d7c2ccb87179fe5d1";
    hash = "sha256-sM76MJE6a7jiwhUWMdXULNkoe7WtGPH7QLpuEreKBfY=";
  };

  vendorSha256 = "sha256-HilPAPGLWEA9dY72Hqa7WnFBWrAXoigBwbw4RLWN1L8=";

  buildInputs = [ libpcap tzdata ];

  postPatch = ''
    # Fix hardcoded path to leap second information
    # NOTE: not find-replacing /usr/share/zoneinfo since /usr/share/zoneinfo/right/Fake is a default output path
    ${lib.concatMapStringsSep "\n" (file:
      "substituteInPlace ${file} --replace /usr/share/zoneinfo/right/UTC ${tzdata}/share/zoneinfo/right/UTC") [
      "cmd/ntpcheck/cmd/utils.go"
      "leapsectz/leapsectz.go"
    ]}
  '';

  ldflags = [ "-s" "-w" ];

  # Tests require network access and take ~10 minutes to run (for unsandboxed builds)
  doCheck = false;

  meta = with lib; {
    description = "Meta's Time libraries";
    homepage = "https://github.com/facebook/time";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ cfeeley ];
  };
}
