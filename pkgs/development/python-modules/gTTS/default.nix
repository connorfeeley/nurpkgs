{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "g-tts";
  version = "2.3.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "pndurette";
    repo = "gTTS";
    rev = "v${version}";
    hash = "sha256-dbIcx6U5TIy3CteUGrZqcWqOJoZD2HILaJmKDY+j/II=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    click
    requests
  ];

  passthru.optional-dependencies = with python3.pkgs; {
    docs = [
      sphinx
      sphinx-autobuild
      sphinx-click
      sphinx-mdinclude
      sphinx-rtd-theme
    ];
    tests = [
      pytest
      pytest-cov
      testfixtures
    ];
  };

  pythonImportsCheck = [ "gTTS" ];

  meta = with lib; {
    description = "Python library and CLI tool to interface with Google Translate's text-to-speech API";
    homepage = "https://github.com/pndurette/gTTS";
    changelog = "https://github.com/pndurette/gTTS/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ cfeeley ];
  };
}
