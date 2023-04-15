# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ lib
, buildPythonApplication
, setuptools
, setuptools_scm
, setuptools-rust
, wheel
, regex
, requests
# , blobfile
, fetchFromGitHub
, rustPlatform
}:

buildPythonApplication rec {
  pname = "tiktoken";
  version = "0.3.3";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "openai";
    repo = "tiktoken";
    rev = version;
    hash = "sha256-5YucJjoYAUTRy7oJ3yb2uE1UZDLIPXnV0bJIDgwGOeA=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    setuptools
    setuptools_scm
    setuptools-rust
    wheel

    rustPlatform.cargoSetupHook
    rustPlatform.rust.cargo
    rustPlatform.rust.rustc
  ];

  propagatedBuildInputs = [
    regex
    requests
  ];

  passthru.optional-dependencies = {
    blobfile = [
      # blobfile
    ];
  };

  pythonImportsCheck = [ "tiktoken" ];

  meta = with lib; {
    description = "Tiktoken is a fast BPE tokeniser for use with OpenAI's models";
    homepage = "https://github.com/openai/tiktoken";
    changelog = "https://github.com/openai/tiktoken/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ cfeeley ];
  };
}
