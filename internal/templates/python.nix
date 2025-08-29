{ pkgs, ... }:
{
  treefmt.programs = {
    ruff-check.enable = true;
    ruff-format.enable = true;
    # black.enable = true;
  };

  make-shells.python = {
    packages = with pkgs; [
      python3
      uv

      basedpyright
      ruff
    ];

    shellHook = ''
      uv -q venv --allow-existing
      source .venv/bin/activate
    '';

    env = {
      UV_PYTHON_DOWNLOADS = "never";
      UV_NO_MANAGED_PYTHON = "1";
    };
  };

  packages.myPythonTool = pkgs.writeShellScriptBin "myscript" ''
    echo "hello from python side"
  '';
}
