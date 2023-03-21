# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ stdenv, lib, buildPackages, fetchFromGitHub, perl, buildLinux, ... } @ args:

let
  version = "2021.2";
  modDirVersion = "5.15.84";
in
buildLinux (args // {
  # pname = "linux-xlnx";
  inherit version;
  inherit modDirVersion;

  src = fetchFromGitHub {
    owner = "Xilinx";
    repo = "linux-xlnx";
    rev = "xilinx-v${version}";
    hash = "sha256-69jOJObVePDJ1Z31o1rXgg2XHtahB1SVxmA5hSMy0Ds=";
  };

  features = {
    efiBootStub = false;
  } // (args.features or { });

  extraConfig = ''
  '';

  extraMeta = {
    platforms = with lib.platforms; arm ++ aarch64;
    hydraPlatforms = [ "aarch64-linux" ];
  };
})
