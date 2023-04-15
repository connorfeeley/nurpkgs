# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ lib
, buildPythonApplication
, setuptools_scm
, fetchFromGitHub
}:

buildPythonApplication rec {
  pname = "sourcery";
  version = "1.2.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "sourcery-ai";
    repo = "sourcery";
    rev = "v${version}";
    hash = "sha256-KQLTOCMLczUwO6E3uZCdTUfvnr1D3sl4Bw6lWjPXkh8=";
  };

  buildInputs = [ setuptools_scm ];

  meta = with lib; {
    description = "Automatically review and improve your Python code. ⭐\u{a0}this repo and Sourcery Starbot will send you a PR. Or install our CLI to improve your code locally";
    homepage = "https://github.com/sourcery-ai/sourcery";
    license = licenses.mit;
    maintainers = with maintainers; [ cfeeley ];
  };
}
