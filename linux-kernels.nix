# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ pkgs
, linuxKernel
, kernelPatches
, config
, buildPackages
, callPackage
, makeOverridable
, recurseIntoAttrs
, dontRecurseIntoAttrs
, linuxPackagesFor
, stdenv
, stdenvNoCC
, newScope
, lib
, fetchurl
, gcc10Stdenv
}:


let
  kernels = recurseIntoAttrs (lib.makeExtensible (self:
    let callPackage = newScope self; in {
      kernelPatches = callPackage ./pkgs/os-specific/linux/kernel/patches.nix { };
      linux_xlnx = callPackage ./pkgs/os-specific/linux/kernel/xilinx-kernels.nix {
        buildPackages = buildPackages // { stdenv = buildPackages.gcc10Stdenv; };
      };
      # linux_xlnx = callPackage ./pkgs/os-specific/linux/kernel/linux.nix {
      #   buildPackages = buildPackages // { stdenv = buildPackages.gcc10Stdenv; };
      # };

  linuxConfig = {
    src,
    version ? (builtins.parseDrvName src.name).version,
    makeTarget ? "defconfig",
    name ? "kernel.config",
  }: stdenvNoCC.mkDerivation {
    inherit name src;
    depsBuildBuild = [ buildPackages.stdenv.cc ]
      ++ lib.optionals (lib.versionAtLeast version "4.16") [ buildPackages.bison buildPackages.flex ];
    postPatch = ''
      patchShebangs scripts/
    '';
    buildPhase = ''
      set -x
      make \
        ARCH=${stdenv.hostPlatform.linuxArch} \
        HOSTCC=${buildPackages.stdenv.cc.targetPrefix}gcc \
        ${makeTarget}
    '';
    installPhase = ''
      cp .config $out
    '';
  };
    }));
in
{
  linux_xlnx = recurseIntoAttrs (linuxPackagesFor kernels.linux_xlnx);
  kernelPatches = recurseIntoAttrs (linuxPackagesFor kernels.linux_xlnx.kernelPatches);
}
