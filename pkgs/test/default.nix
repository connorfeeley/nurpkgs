# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ callPackage }:

{
  fetchdmg = callPackage ../build-support/fetchdmg/tests.nix { };
}
