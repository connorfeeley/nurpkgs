# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause
{ lib, stdenv, fetchFromGitHub, undmg }:

stdenv.mkDerivation rec {
  pname = "better-display";
  version = "1.4.6";

  src = fetchFromGitHub {
    owner = "waydabber";
    repo = "BetterDisplay";
    rev = "v${version}";
    hash = "sha256-Fu0K4xfxg0PipZUbACxRjG+hP3q9d95CVfjYUUjo83E=";
  };

  nativeBuildInputs = [ undmg ];

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
