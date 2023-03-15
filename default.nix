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
      tests = callPackage ./pkgs/test { };
      darwin = callPackage ./darwin-packages.nix { };
    in
    {
      aranet4 = callPackage ./pkgs/development/python-modules/aranet4 { };
      inherit cpprestsdk;
      inherit darwin;
      kobopatch = callPackage ./pkgs/applications/misc/kobopatch { };
      nmos-cpp = callPackage ./pkgs/development/libraries/nmos-cpp { inherit cpprestsdk; };
      # qemu-xilinx = pkgs.callPackage ./pkgs/applications/virtualization/qemu { };
      inherit tests;
      toronto-backgrounds = callPackage ./pkgs/data/misc/toronto-backgrounds { };
      xsct = callPackage ./pkgs/applications/misc/xsct { };

      fetchdmg = callPackage ./pkgs/build-support/fetchdmg { }
        // {
        tests = tests.fetchdmg;
      };
    });
in
top-level // {
  # The `lib`, `modules`, and `overlay` names are special
  # lib = import ./lib { inherit pkgs; }; # functions
  # modules = import ./modules; # NixOS modules
  # overlays = import ./overlays; # nixpkgs overlays
}
