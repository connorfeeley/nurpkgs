# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ config, lib, pkgs, ... }:

let
  inherit (pkgs.lib) mkOption mkEnableOption literalExample types;

  cfg = config.programs.mellanoxFirmwareTools;

  mft = pkgs.mft.override { kernel = config.boot.kernelPackages.kernel; };
in
{
  options.programs.mellanoxFirmwareTools = {
    enable = mkEnableOption "Mellanox Firmware Tools";

    package = mkOption {
      type = types.package;
      default = mft;
      defaultText = literalExample "pkgs.mft";
      example = literalExample "pkgs.mft";
      description = "The package to use for Mellanox Firmware Tools.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Include Mellanox Firmware Tools kernel modules
    boot.extraModulePackages = [ cfg.package ];

    # mst, mlxlink, mlxcables, etc.
    environment.systemPackages = [ cfg.package ];

    # mst start script requires /etc/mft
    environment.etc."mft".source = "${cfg.package}/etc/mft";
  };
}
