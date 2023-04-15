# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ lib
, stdenv
, buildPythonApplication
, pillow
, beautifulsoup4
, black
, colorama
, coverage
, docker
, duckduckgo-search
, flake8
, g-tts
, isort
, numpy
, openai
, orjson
, pinecone-client
, playsound
, pre-commit
, python-dotenv
, pyyaml
, readability-lxml
, redis
, requests
, selenium
, sourcery
, tiktoken
, webdriver-manager
, fetchFromGitHub
}:

buildPythonApplication rec {
  pname = "auto-gpt";
  version = "0.2.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "Significant-Gravitas";
    repo = "Auto-GPT";
    rev = "v${version}";
    hash = "sha256-Q6jrQHuUJQywgbM19Mi6b3CZp+lBJtFboWCBbtVOgyc=";
  };

  propagatedBuildInputs = [
    pillow
    beautifulsoup4
    black
    colorama
    coverage
    docker
    duckduckgo-search
    flake8
    g-tts
    isort
    numpy
    openai
    orjson
    pinecone-client
    playsound
    pre-commit
    python-dotenv
    pyyaml
    readability-lxml
    redis
    requests
    selenium
    sourcery
    tiktoken
    webdriver-manager
  ];

  pythonImportsCheck = [ "auto-gpt" ];

  meta = with lib; {
    broken = stdenv.isDarwin;
    description = "An experimental open-source attempt to make GPT-4 fully autonomous";
    homepage = "https://github.com/Significant-Gravitas/Auto-GPT";
    license = licenses.mit;
    maintainers = with maintainers; [ cfeeley ];
  };
}
