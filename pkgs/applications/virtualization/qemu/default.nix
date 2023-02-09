{ lib, fetchurl, fetchFromGitHub, afl, qemu, ... }:
let
  version = "xilinx_v2022.2";
  src = fetchFromGitHub {
    owner = "Xilinx";
    repo = "qemu";
    rev = "${version}";
    sha256 = "sha256-uLpmhexfanj2v8CSiAro6vLy/yY8UBTWuRd7ddlhaeI=";
  };
in
{
  qemu-xilinx = qemu.overrideAttrs (old: {
    inherit version src;
  });
}
