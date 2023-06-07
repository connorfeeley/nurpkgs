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
    in
    {
      inherit cpprestsdk;
      darwin = callPackage ./darwin-packages.nix { };
      fetchdmg = callPackage ./pkgs/build-support/fetchdmg { } // { tests = tests.fetchdmg; };
      kobopatch = callPackage ./pkgs/applications/misc/kobopatch { };
      linuxKernel = pkgs.recurseIntoAttrs (callPackage ./linux-kernels.nix { });
      llama-cpp = callPackage ./pkgs/development/libraries/llama-cpp { inherit (pkgs.darwin.apple_sdk.frameworks) Accelerate; };
      mdio-tools = callPackage ./pkgs/os-specific/linux/mdio-tools { };
      nmos-cpp = callPackage ./pkgs/development/libraries/nmos-cpp { inherit cpprestsdk; };
      pythonPackages = pkgs.lib.recurseIntoAttrs (pkgs.python3.pkgs.callPackage ./python-packages.nix { });
      rclone-tui = callPackage ./pkgs/applications/misc/rclone-tui { };
      rescript = pkgs.ocamlPackages.callPackage ./pkgs/development/compilers/rescript { };
      inherit tests;
      time = callPackage ./pkgs/development/libraries/time { };
      toronto-backgrounds = callPackage ./pkgs/data/misc/toronto-backgrounds { };
      xantfarm = callPackage ./pkgs/applications/misc/xantfarm { };
      xilinx-qemu = pkgs.callPackage ./pkgs/applications/virtualization/xilinx-qemu { inherit (pkgs.darwin.apple_sdk.frameworks) CoreAudio Cocoa; inherit (pkgs.darwin.stubs) rez setfile; };
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
