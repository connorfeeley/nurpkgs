# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ lib, fetchpatch, fetchurl }:

{
  use-after-free-realloc-gcc12 = rec {
    name = "use-after-free-realloc";
    patch = fetchpatch {
      name = name + ".patch";
      url = "https://github.com/torvalds/linux/commit/52a9dab6d892763b2a8334a568bd4e2c1a6fde66.patch";
      hash = "";
    };
  };
}
