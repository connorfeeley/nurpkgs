# SPDX-FileCopyrightText: 2023 Connor Feeley
# SPDX-License-Identifier: BSD-3-Clause
#
# SPDX-FileCopyrightText: 2003-2023 Eelco Dolstra and the Nixpkgs/NixOS contributors
# SPDX-License-Identifier: MIT

{ lib, newScope, pkgs }:

lib.makeScope newScope (self: let inherit (self) callPackage; in {
  # installApplication = callPackage ./lib/installApplication.nix { };

  apple_complete = callPackage ./pkgs/os-specific/darwin/apple_complete { };
  launchcontrol = callPackage ./pkgs/os-specific/darwin/launchcontrol { };
  maclaunch = callPackage ./pkgs/os-specific/darwin/maclaunch { };
  sloth = callPackage ./pkgs/applications/misc/sloth { inherit (pkgs.darwin.apple_sdk_11_0.frameworks) Foundation; };
})
