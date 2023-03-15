# SPDX-FileCopyrightText: 2023 Connor Feeley
# SPDX-License-Identifier: BSD-3-Clause
#
# SPDX-FileCopyrightText: 2003-2023 Eelco Dolstra and the Nixpkgs/NixOS contributors
# SPDX-License-Identifier: MIT

{ testers, fetchdmg, ... }:

let
  version = "1.4.6";
  url = "https://github.com/waydabber/BetterDisplay/releases/download/v${version}/BetterDisplay-v${version}.dmg";
in
{
  simple = testers.invalidateFetcherByDrvHash fetchdmg {
    inherit url;
    hash = "sha256-MKlJOFRpYDx2bnGrm08gQ40YLatD3sI10f1Z4uwh3so=";
  };

  postFetch = testers.invalidateFetcherByDrvHash fetchdmg {
    inherit url;
    hash = "sha256-SSd+1KN59jc68Y4Go1q869Texat6wdDPRiRby1HmNG4=";
    postFetch = "touch $out/filee";
  };
}
