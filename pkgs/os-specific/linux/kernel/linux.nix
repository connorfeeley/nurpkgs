# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ lib
, callPackage
, linuxPackagesFor
, kernelPatches
, ... }:

let
  modDirVersion = "5.10.0";

  linuxPkg = { fetchFromGitHub, buildLinux, ... } @ args:
    buildLinux (args // {
      inherit modDirVersion kernelPatches;
      version = "${modDirVersion}-xilinx-v2021.2";

      src = fetchFromGitHub {
        owner = "Xilinx";
        repo = "linux-xlnx";
        rev = "xilinx-v${modDirVersion}";
        hash = "sha256-69jOJObVePDJ1Z31o1rXgg2XHtahB1SVxmA5hSMy0Ds=";
      };

      defconfig = "xilinx_zynqmp_defconfig";

      structuredExtraConfig = with lib.kernel; {
        KEXEC = yes;
        SERIAL_8250_DW = yes;
        PINCTRL_STARFIVE = yes;
        DW_AXI_DMAC_STARFIVE = yes;
        PTP_1588_CLOCK = yes;
        STMMAC_ETH = yes;
        STMMAC_PCI = yes;
      };

      extraMeta.branch = "xilinx-v${modDirVersion}";
      extraMeta.platforms = ["aarch64-linux"];

      postInstall = (lib.optionalString (args ? postInstall) args.postInstall) + ''
        mkdir -p "$out/nix-support"
        cp -v "$buildRoot/.config" "$out/nix-support/build.config"
        '';
    } // (args.argsOverride or { }));
in lib.recurseIntoAttrs (linuxPackagesFor (callPackage linuxPkg { }))
