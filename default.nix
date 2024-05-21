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

{ pkgs ? import <nixpkgs> { inherit overlays; }
, overlays ? [ (import ./overlays).maintainer ]
, ...
}:
let
  top-level = pkgs.lib.makeScope pkgs.newScope (self:
    let inherit (self) callPackage;
      cpprestsdk = callPackage ./pkgs/development/libraries/cpprestsdk { inherit (pkgs.darwin.apple_sdk.frameworks) Security; };

      tests = callPackage ./pkgs/test { };

      project_options = callPackage ./pkgs/development/libraries/project_options { };
      sourcetrail-ng =
        let
          llvmPackages = pkgs.llvmPackages_15;
        in
        pkgs.libsForQt5.callPackage ./pkgs/development/tools/sourcetrail-ng {
          stdenv = if pkgs.stdenv.cc.isClang then llvmPackages.stdenv else pkgs.stdenv;
          inherit llvmPackages project_options;
          inherit (pkgs.darwin.apple_sdk_11_0.frameworks) CoreFoundation;
        };
      pythonPackages = pkgs.lib.recurseIntoAttrs (pkgs.python3.pkgs.callPackage ./python-packages.nix { });
    in
    {
      inherit cpprestsdk;
      clknetsim = callPackage ./pkgs/development/tools/clknetsim { };
      crash-utility = callPackage ./pkgs/development/tools/crash-utility { };
      darwinPackages = callPackage ./darwin-packages.nix { };
      fetchdmg = callPackage ./pkgs/build-support/fetchdmg { } // { tests = tests.fetchdmg; };
      github-copilot-cli = callPackage ./pkgs/applications/misc/github-copilot-cli/default.nix { };
      kobopatch = callPackage ./pkgs/applications/misc/kobopatch { };
      # linux-xlnx = pkgs.recurseIntoAttrs (callPackage ./linux-kernels.nix { });
      llama-cpp = callPackage ./pkgs/development/libraries/llama-cpp { inherit (pkgs.darwin.apple_sdk.frameworks) Accelerate; };
      mdio-tools = callPackage ./pkgs/os-specific/linux/mdio-tools { };
      mft = callPackage ./pkgs/applications/misc/mft { kernel = pkgs.linux; };
      nmos-cpp = callPackage ./pkgs/development/libraries/nmos-cpp { inherit cpprestsdk; };
      pg-osc = callPackage ./pkgs/applications/database/ps-osc { };
      inherit project_options;
      inherit (pythonPackages) pdftocgen;
      rescript = pkgs.ocaml-ng.ocamlPackages_4_14.callPackage ./pkgs/development/compilers/rescript { };
      inherit sourcetrail-ng;
      inherit tests;
      makedumpfile = callPackage ./pkgs/development/tools/makedumpfile { };
      meta-time = callPackage ./pkgs/development/libraries/time { };
      toronto-backgrounds = callPackage ./pkgs/data/misc/toronto-backgrounds { };
      xantfarm = callPackage ./pkgs/applications/misc/xantfarm { };
      xilinx-qemu = pkgs.callPackage ./pkgs/applications/virtualization/xilinx-qemu { inherit (pkgs.darwin.apple_sdk.frameworks) CoreAudio Cocoa; inherit (pkgs.darwin.stubs) rez setfile; };
      xsct = callPackage ./pkgs/applications/misc/xsct { };
    });
  special = {
    # The `lib`, `modules`, and `overlay` names are special
    # lib = import ./lib { inherit pkgs; }; # functions
    # modules = import ./modules; # NixOS modules
    overlays = import ./overlays; # nixpkgs overlays
  };
in
top-level // special
