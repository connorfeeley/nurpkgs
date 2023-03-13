# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ lib, fetchurl, stdenv }:
stdenv.mkDerivation rec {
  pname = "LaunchControl";
  version = "2.3";

  src = fetchurl {
    url = "https://www.soma-zone.com/download/files/LaunchControl-${version}.tar.xz";
    hash = "sha256-t2JdJhMt5m5JV6HC9CaakiU9sI0Vn+1Iw0dGQPKMkws=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -R * $out/Applications/${pname}.app
    runHook postInstall
  '';

  meta = {
    description = "GUI for managing and debugging MacOS system and user services";
    platforms = lib.platforms.darwin;
    homepage = "https://www.soma-zone.com/LaunchControl/";
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.cfeeley ];
  };
}
