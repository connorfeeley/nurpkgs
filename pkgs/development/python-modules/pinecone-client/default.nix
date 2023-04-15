# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pinecone-client";
  version = "2.2.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "pinecone-io";
    repo = "pinecone-python-client";
    rev = version;
    hash = "sha256-Ngh9E0N7i+rQPyErLFvppC10J5W1g3kEqj/X2GaeczI=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    setuptools_scm
    dnspython
    loguru
    numpy
    python-dateutil
    pyyaml
    requests
    tqdm
    typing-extensions
    urllib3
  ];

  pythonImportsCheck = [ "pinecone-client" ];

  meta = with lib; {
    description = "The Pinecone Python client";
    homepage = "https://github.com/pinecone-io/pinecone-python-client";
    changelog = "https://github.com/pinecone-io/pinecone-python-client/blob/${src.rev}/CHANGELOG.md";
    license = with licenses; [ ];
    maintainers = with maintainers; [ cfeeley ];
  };
}
