# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ lib
, buildPythonApplication
, requests
, setuptools_scm
, tqdm
, python-dotenv
, fetchFromGitHub
}:

buildPythonApplication rec {
  pname = "webdriver-manager";
  version = "3.8.6";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "SergeyPirogov";
    repo = "webdriver_manager";
    rev = "v${version}";
    hash = "sha256-5fyzwoqbW5Nkt+YDltnHk+OizlZC7wpSNzmz8apEPu4=";
  };

  propagatedBuildInputs = [ requests setuptools_scm tqdm python-dotenv ];

  pythonImportsCheck = [ "webdriver_manager" ];

  meta = with lib; {
    description = "";
    homepage = "https://github.com/SergeyPirogov/webdriver_manager";
    changelog = "https://github.com/SergeyPirogov/webdriver_manager/blob/${src.rev}/CHANGELOG.md";
    license = licenses.asl20;
    maintainers = with maintainers; [ cfeeley ];
  };
}
