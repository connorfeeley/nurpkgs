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
      linux_xlnx = recurseIntoAttrs (callPackage ./pkgs/os-specific/linux/kernel/xilinx-kernels.nix { });
    }));
in
{
  linux_xlnx = recurseIntoAttrs (linuxPackagesFor kernels.linux_xlnx);
}
