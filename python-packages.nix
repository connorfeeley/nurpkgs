# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ lib, newScope, pkgs }:

lib.makeScope newScope (self: let inherit (self) callPackage; in {
  aranet4 = callPackage ./pkgs/development/python-modules/aranet4 { };
})
