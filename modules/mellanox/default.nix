# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ config, pkgs, ... }:

let
  mft = pkgs.mft.override { kernel = config.boot.kernelPackages.kernel; };
in
{
  # Include Mellanox Firmware Tools kernel modules
  boot.extraModulePackages = [ mft ];

  # mst, mlxlink, mlxcables, etc.
  environment.systemPackages = [ mft ];

  # mst start script requires /etc/mft
  environment.etc = {
    "mft".source = "${mft}/etc/mft";
  };
}
