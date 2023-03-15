# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ pkgs
, linuxKernel
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
  kernelPatches = callPackage ./pkgs/os-specific/linux/kernel/patches.nix { };

  kernels = recurseIntoAttrs (lib.makeExtensible (self: with self;
    let callPackage = newScope self; in {
      linux_xlnx = callPackage ./pkgs/os-specific/linux/kernel/xilinx-kernels.nix { };
    }));
in
{
  linux_xlnx = recurseIntoAttrs (linuxPackagesFor kernels.linux_xlnx);
}
