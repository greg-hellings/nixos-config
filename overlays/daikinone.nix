{
  buildHomeAssistantComponent,
  fetchFromGitHub,
  lib,

  pydantic,
  backoff,
}:

buildHomeAssistantComponent rec {
  pname = "ha-daikinone";
  domain = "daikinone";
  version = "v0.7.0";
  owner = "zlangbert";

  src = fetchFromGitHub {
    owner = "jf-navica";
    repo = pname;
    rev = "69e6ef12c6289c3d83452d9946c5e0fbf87b73bb";
    #hash = "sha256-dINPgBdjQ0Ls+0yHiBsUjtHcvsPTfTq2VB1h07r0gpk=";
    hash = "sha256-kYwS4BYDMMI6VkJVbf/Cpy2f88uXfhnqKLIGJgSlZVY=";
  };

  dependencies = [
    pydantic
    backoff
  ];

  meta = with lib; {
    description = "Daikin One Home Assistant integration";
    maintainers = with maintainers; [ greg ];
  };
}
