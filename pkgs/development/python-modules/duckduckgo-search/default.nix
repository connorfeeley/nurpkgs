{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "duckduckgo-search";
  version = "2.8.5";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "deedy5";
    repo = "duckduckgo_search";
    rev = "v${version}";
    hash = "sha256-UXh3+kBfkylt5CIXbYTa/vniEETUvh4steUrUg5MqYU=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
  ];

  propagatedBuildInputs = with python3.pkgs; [
    click
    requests
  ];

  pythonImportsCheck = [ "duckduckgo_search" ];

  meta = with lib; {
    description = "Search for words, documents, images, videos, news, maps and text translation using the DuckDuckGo.com search engine. Downloading files and images to a local hard drive";
    homepage = "https://github.com/deedy5/duckduckgo_search";
    license = licenses.mit;
    maintainers = with maintainers; [ cfeeley ];
  };
}
