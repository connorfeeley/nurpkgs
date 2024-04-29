# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ lib
, buildPythonApplication
, chardet
, pymupdf
, fetchPypi
, toml
, poetry-core
}:

buildPythonApplication rec {
  pname = "pdftocgen";
  version = "1.3.4";
  format = "pyproject";

  src = fetchPypi {
    pname = "pdf_tocgen";
    inherit version;
    hash = "sha256-CQdYgyYUcn6vH9C6AHXVoQ648mjR1TT6vXExFwqKx54=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    toml
    pymupdf
    chardet
  ];

  pythonImportsCheck = [ "pdftocgen" ];

  meta = with lib; {
    description = "Automatically generate table of contents for pdf files";
    homepage = "https://krasjet.com/voice/pdf.tocgen/";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ cfeeley ];
  };
}
