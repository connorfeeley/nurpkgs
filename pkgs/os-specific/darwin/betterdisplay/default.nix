# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause
{ lib, stdenv, fetchdmg }:

stdenv.mkDerivation rec {
  pname = "betterdisplay";
  version = "1.4.6";

  src = fetchdmg {
    url = "https://github.com/waydabber/BetterDisplay/releases/download/v${version}/BetterDisplay-v${version}.dmg";
    hash = "sha256-MKlJOFRpYDx2bnGrm08gQ40YLatD3sI10f1Z4uwh3so=";
  };

  installPhase = ''
    mkdir -p $out/Applications
    cp -r BetterDisplay.app $out/Applications
  '';

  meta = with lib; {
    description = "Unlock your displays on your Mac! Smooth scaling, HiDPI unlock, XDR/HDR extra brightness upscale, DDC, brightness and dimming, dummy displays, PIP and lots more!";
    homepage = "https://github.com/waydabber/BetterDisplay";
    license = with licenses; [ ];
    platforms = platforms.darwin;
    maintainers = with maintainers; [ cfeeley ];
  };
}
