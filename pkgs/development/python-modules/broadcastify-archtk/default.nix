{ lib
, buildPythonApplication
, beautifulsoup4
, configparser
, requests
, selenium
, tqdm
, fetchFromGitHub
}:

buildPythonApplication rec {
  pname = "broadcastify-archtk";
  version = "1.0.2";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "ljhopkins2";
    repo = "broadcastify-archtk";
    rev = "v${version}";
    hash = "sha256-Lyg7iHwT3oXT/UmcTPOl8SZJA4Uo9wdyoPhWVGQj6n8=";
  } + "/code";

  propagatedBuildInputs = [
    beautifulsoup4
    configparser
    requests
    selenium
    tqdm
  ];

  pythonImportsCheck = [ "broadcastify_archtk" ];

  postPatch = ''
    substituteInPlace requirements.txt \
      --replace "beautifulsoup4==4.7.1" "beautifulsoup4" \
      --replace "configparser==3.7.4" "configparser" \
      --replace "requests==2.21.0" "requests" \
      --replace "selenium==3.141.0" "selenium" \
      --replace "tqdm==4.31.1" "tqdm"
  '';

  meta = {
    description = "The Broadcastify Archive Toolkit for python";
    homepage = "https://github.com/ljhopkins2/broadcastify-archtk";
    license = lib.licenses.agpl3Only;
    maintainers = [ lib.maintainers.cfeeley ];
  };
}
