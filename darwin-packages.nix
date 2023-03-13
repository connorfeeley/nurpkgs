# SPDX-FileCopyrightText: 2023 Connor Feeley
# SPDX-License-Identifier: BSD-3-Clause
#
# SPDX-FileCopyrightText: 2003-2023 Eelco Dolstra and the Nixpkgs/NixOS contributors
# SPDX-License-Identifier: MIT

{ pkgs, generateSplicesForMkScope, makeScopeWithSplicing }:

makeScopeWithSplicing (generateSplicesForMkScope "darwin") (_: { }) (spliced: { }) (self:
let
  inherit (self) mkDerivation callPackage;
in
{
  installApplication = callPackage ./lib/installApplication.nix { };

  launchcontrol = callPackage ./pkgs/os-specific/darwin/launchcontrol { };
  apple_complete = callPackage ./pkgs/os-specific/darwin/apple_complete { };
  maclaunch = callPackage ./pkgs/os-specific/darwin/maclaunch { };
  sloth = callPackage ./pkgs/applications/misc/sloth { inherit (pkgs.darwin.apple_sdk_11_0.frameworks) Foundation; };
})
