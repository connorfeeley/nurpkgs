# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ lib, fetchFromGitHub, gcc10Stdenv, ccacheStdenv, buildLinux, linuxManualConfig, kernelPatches, ... } @ args:

let
  stdenv = gcc10Stdenv;

  xlnx_2021_2 = {
    rev = "xilinx-v2021.2"; # ex: 2021.2
    version = "5.10.0";
    prefix = ""; # ex: _update1
    suffix = "xilinx-v2021.2"; # ex: xlnx_rebase_v5.15_LTS_
    hash = "sha256-69jOJObVePDJ1Z31o1rXgg2XHtahB1SVxmA5hSMy0Ds=";
  };

  xlnxKernelsFor = { rev, version, prefix ? "", suffix ? "", hash }:
    lib.overrideDerivation
      (buildLinux (args // {
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
        };

        buildPackages = args.buildPackages;
        inherit kernelPatches;
      } // (args.argsOverride or { })))
      (oldAttrs: {
        kernelPreferBuiltin = true;
        ignoreConfigErrors = true;
        autoModules = true;
        depsBuildBuild = [ stdenv.cc ];
      });

  xlnx_2021_2-kernel = xlnxKernelsFor xlnx_2021_2;

  manualKernel = linuxManualConfig {
    inherit (xlnx_2021_2-kernel) src version modDirVersion;
    configfile = ./xilinx_zynqmp_defconfig;
    allowImportFromDerivation = false;
    inherit stdenv;
  };
in
{
  inherit xlnx_2021_2 manualKernel xlnx_2021_2-kernel;
}
