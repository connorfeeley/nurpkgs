# SPDX-FileCopyrightText: 2024 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "tatutanatata";
  version = "2024-06-05-unstable";

  src = fetchFromGitHub {
    owner = "crepererum-oss";
    repo = pname;
    rev = "c763c1dc51f8dca973f0b2f885ce3727ce705d0c";
    hash = "sha256-WvMS+aQFBQN6LwvJATvRg0Q5iOmWBE+6KsfT7g61hR0=";
  };

  cargoHash = "sha256-q7UPo9/LCOFJCSCCmVLR0fq+bbQeA8e7MxCxWJsDzEQ=";

  doCheck = false;

  meta = with lib; {
    description = "CLI (Command Line Interface) for Tutanota, mostly meant for mass export";
    homepage = "https://github.com/crepererum-oss/tatutanatata";
    license = [ licenses.mit licenses.asl20 ];
    maintainers = [ maintainers.cfeeley ];
  };
}
