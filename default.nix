# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ system ? builtins.currentSystem
, overlays ? [ (import ./overlays).maintainer ]
, pkgs ? import <nixpkgs> { inherit system overlays; }
, ...
}:
let
  top-level = pkgs.lib.makeScope pkgs.newScope (self:
    let inherit (self) callPackage;
      cpprestsdk = callPackage ./pkgs/development/libraries/cpprestsdk { inherit (pkgs.darwin.apple_sdk.frameworks) Security; };
      darwin = callPackage ./darwin-packages.nix { };
      pythonPackages = pkgs.lib.recurseIntoAttrs (pkgs.python3.pkgs.callPackage ./python-packages.nix { });
      linuxKernel = pkgs.recurseIntoAttrs (callPackage ./linux-kernels.nix { });
      tests = callPackage ./pkgs/test { };
    in
    {
      inherit pythonPackages;
      inherit cpprestsdk;
      inherit darwin;
      fetchdmg = callPackage ./pkgs/build-support/fetchdmg { } // { tests = tests.fetchdmg; };
      kobopatch = callPackage ./pkgs/applications/misc/kobopatch { };
      inherit linuxKernel;
      llama-cpp = callPackage ./pkgs/development/libraries/llama-cpp { inherit (pkgs.darwin.apple_sdk.frameworks) Accelerate; };
      nmos-cpp = callPackage ./pkgs/development/libraries/nmos-cpp { inherit cpprestsdk; };
      rclone-tui = callPackage ./pkgs/applications/misc/rclone-tui { };
      time = callPackage ./pkgs/development/libraries/time { };
      xilinx-qemu = pkgs.callPackage ./pkgs/applications/virtualization/xilinx-qemu { inherit (pkgs.darwin.apple_sdk.frameworks) CoreAudio Cocoa; inherit (pkgs.darwin.stubs) rez setfile; };
      inherit tests;
      toronto-backgrounds = callPackage ./pkgs/data/misc/toronto-backgrounds { };
      xantfarm = callPackage ./pkgs/applications/misc/xantfarm { };
      xsct = callPackage ./pkgs/applications/misc/xsct { };
    });
  special = {
    # The `lib`, `modules`, and `overlay` names are special
    # lib = import ./lib { inherit pkgs; }; # functions
    # modules = import ./modules; # NixOS modules
    # overlays = import ./overlays; # nixpkgs overlays
  };
in
top-level // special
