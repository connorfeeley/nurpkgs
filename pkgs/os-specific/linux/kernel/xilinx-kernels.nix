# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ lib, fetchFromGitHub, gcc10Stdenv, ccacheStdenv, buildLinux, linuxManualConfig, kernelPatches, ... } @ args:

let
  stdenv = gcc10Stdenv;

  kernels.v2021_2 = {
    rev = "xilinx-v2021.2"; # ex: xilinx-v2021.2
    version = "5.10.0";
    suffix = "xilinx-v2021.2"; # appended to version; ex: 5.10.0-xilinx-v2021.2
    hash = "sha256-69jOJObVePDJ1Z31o1rXgg2XHtahB1SVxmA5hSMy0Ds=";
  };

  xlnxKernelsFor = { rev, version, prefix ? "", suffix ? "", hash }:
    buildLinux (args // {
        inherit version;
        modDirVersion = lib.versions.pad 3 "${version}-${suffix}";

        src = fetchFromGitHub {
          owner = "Xilinx";
          repo = "linux-xlnx";
          inherit rev hash;
        };

        extraMeta = {
          branch = rev;
          maintainers = with lib.maintainers; [ cfeeley ];
          description = "The official Linux kernel from Xilinx.";
          platforms = lib.platforms.aarch64;
        };
      } // (args.argsOverride or { }));

  # Cannot be built directly, but can be used as a source for linuxManualConfig
  xilinx_v2021_2 = xlnxKernelsFor kernels.v2021_2;

  # Can be built directly
  zynqmp-v2021_2 = linuxManualConfig {
    inherit (xilinx_v2021_2) src version modDirVersion;
    configfile = ./xilinx_zynqmp_defconfig;
    allowImportFromDerivation = false;
    inherit stdenv;
  };
in
{
  inherit xilinx_v2021_2 zynqmp-v2021_2;
}
