{ ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    stdlib = ''
      layout_poetry() {
        if [[ ! -f pyproject.toml ]]; then
          echo "No pyproject.toml found"
          exit 1
        fi

        venv="$(dirname "$(poetry run which python)")"
        export VIRTUAL_ENV="$(echo "$venv" |  rev | cut -d'/' -f2- | rev)"
        export POETRY_ACTIVE=1
        PATH_add "$venv"
      }
    '';
  };
}
