# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ lib, stdenv, fetchdmg }:

let
  version = "230420";
in
stdenv.mkDerivation {
  pname = "tinkertool";
  inherit version;

  src = fetchdmg {
    url = "https://www.bresink.eu/download2.php?ln=1&dl=TinkerTool8&MBSKey=7ef238f6c768c5f511885ba9525b1457";
    hash = "";
  };

  installPhase = ''
    mkdir -p $out/Applications
    cp -r TinkerTool.app $out/Applications
  '';

  meta = with lib; {
    description = "Configure extra macOS options";
    homepage = "http://www.bresink.com/osx/TinkerTool.html";
    license = licenses.unfree;
    maintainers = with maintainers; [ cfeeley ];
  };
}
