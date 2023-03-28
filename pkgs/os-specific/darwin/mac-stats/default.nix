# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause
{ lib, stdenv, fetchdmg }:

let
  version = "2.8.14.1";
in
stdenv.mkDerivation {
  pname = "mac-stats";
  inherit version;

  # NOTE: This is a fork of the original mac-stats project, with telemetry removed.
  src = fetchdmg {
    url = "https://github.com/jakwings/mac-stats/releases/download/v${version}/Stats-v${version}.dmg";
    hash = "sha256-FRa3zizZSXbkXk6+J7kc/8ZRlw5/gaqRot1i7SSVLcI=";
  };

  installPhase = ''
    mkdir -p $out/Applications
    cp -r Stats.app $out/Applications
  '';

  meta = with lib; {
    description = "MacOS system monitor in your menu bar - fork without telemetry";
    homepage = "https://github.com/jakwings/mac-stats";
    license = licenses.mit;
    maintainers = with maintainers; [ cfeeley ];
  };
}
