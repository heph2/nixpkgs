{ lib
, buildPythonPackage
, fetchFromGitHub

# propagates
, blinker
, cryptography
, pyjwt

# test
, mock
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "oauthlib";
  version = "3.2.0";
  format = "setuptools";

  # master supports pyjwt==1.7.1
  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    hash = "sha256-41JFURG8G8BjlAlNu2+lbj84XR/trAk1U5OPYxPq+5M=";
  };

  propagatedBuildInputs = [
    blinker
    cryptography
    pyjwt
  ];

  checkInputs = [
    mock
    pytestCheckHook
  ];

  meta = with lib; {
    homepage = "https://github.com/idan/oauthlib";
    description = "A generic, spec-compliant, thorough implementation of the OAuth request-signing logic";
    maintainers = with maintainers; [ prikhi ];
    license = licenses.bsd3;
  };
}
