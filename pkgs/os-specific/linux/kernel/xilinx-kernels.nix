# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ lib, fetchFromGitHub, buildLinux, ... } @ args:

let
  xlnx_2021_2 = {
    rev = "2021.2"; # ex: 2021.2
    version = "5.10.0";
    prefix = ""; # ex: _update1
    suffix = ""; # ex: xlnx_rebase_v5.15_LTS_
    hash = "";
  };

  xlnxKernelsFor = { rev, version, prefix ? "", suffix ? "", hash}: buildLinux (args // {
    inherit version;
    modDirVersion = lib.versions.pad 3 "${version}-${suffix}";

    src = fetchFromGitHub {
      owner = "Xilinx";
      repo = "linux-xlnx";
      inherit rev hash;
    };

    extraMeta = {
      branch = lib.versions.majorMinor version + "/master";
      maintainers = with lib.maintainers; [ cfeeley ];
      description = "The official Linux kernel from Xilinx.";
    };

  } // (args.argsOverride or { }));
in
{
  xlnx_2021_2 = xlnxKernelsFor xlnx_2021_2;
}
