# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ lib, buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "kobopatch";
  version = "0.15.1";

  src = fetchFromGitHub {
    owner = "pgaskin";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-vUz4yS1YJlRqUK6y97afCxeL4qAQBFcJlmBPWuGRhWo=";
  };

  vendorSha256 = "sha256-PiBrsYbHOzeRzcP0z1kW5lQvDoSiw3WSYy3FZDSu0SQ=";

  meta = with lib; {
    description = "An improved patching system for Kobo eReaders.";
    homepage = "https://github.com/pgaskin/kobopatch";
    license = licenses.mit;
    maintainers = with maintainers; [ cfeeley ];
    broken = true;
    platforms = platforms.unix;
  };
}
