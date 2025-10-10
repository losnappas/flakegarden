{ pkgs, lib, ... }:
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
      unset PYTHONPATH # Drops nix-provided python packages.
      [[ -d .venv ]] || uv -q venv --allow-existing
      source .venv/bin/activate
    '';

    env = {
      UV_PYTHON_DOWNLOADS = "never";
      UV_NO_MANAGED_PYTHON = "1";
      UV_PYTHON = pkgs.python3.interpreter;
    }
    // lib.optionalAttrs pkgs.stdenv.isLinux {
      # Setting LD_LIBRARY_PATH makes the dynamic library loader aware of libraries without using RPATH for lookup.
      LD_LIBRARY_PATH = lib.makeLibraryPath pkgs.pythonManylinuxPackages.manylinux1;
    };
  };

  # TODO(@agent): if user wants their python program packaged via uv.lock:
  #
  # Add to `inputs` in flake.nix:
  # ```nix
  # pyproject-nix = {
  #   url = "github:pyproject-nix/pyproject.nix";
  #   inputs.nixpkgs.follows = "nixpkgs";
  # };
  # uv2nix = {
  #   url = "github:pyproject-nix/uv2nix";
  #   inputs.pyproject-nix.follows = "pyproject-nix";
  #   inputs.nixpkgs.follows = "nixpkgs";
  # };
  # pyproject-build-systems = {
  #   url = "github:pyproject-nix/build-system-pkgs";
  #   inputs.pyproject-nix.follows = "pyproject-nix";
  #   inputs.uv2nix.follows = "uv2nix";
  #   inputs.nixpkgs.follows = "nixpkgs";
  # };
  # ```
  #
  # Add in `perSystem` in flake.nix:
  # ```nix
  # _module.args = {
  #   inherit uv2nix pyproject-build-systems pyproject-nix;
  # };
  # ```
  #
  # And import them in this file.
  #
  # Lastly, uncomment the following, and fix the package path to match a script from pyproject.toml:
  #
  #
  # packages.myPythonPackage =
  #   let
  #     workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = ../..; };
  #     # Create package overlay from workspace.
  #     overlay = workspace.mkPyprojectOverlay {
  #       sourcePreference = "wheel"; # or sourcePreference = "sdist";
  #     };
  #     # - https://pyproject-nix.github.io/uv2nix/FAQ.html
  #     pyprojectOverrides = _final: _prev: {
  #       # https://pyproject-nix.github.io/pyproject.nix/build.html
  #     };
  #     pythonSet =
  #       (pkgs.callPackage pyproject-nix.build.packages {
  #         python = pkgs.python3;
  #       }).overrideScope
  #         (
  #           pkgs.lib.composeManyExtensions [
  #             pyproject-build-systems.overlays.default
  #             overlay
  #             pyprojectOverrides
  #           ]
  #         );
  #     inherit (pkgs.callPackage pyproject-nix.build.util { }) mkApplication;
  #   in
  #   mkApplication {
  #     venv = pythonSet.mkVirtualEnv "env" workspace.deps.default;
  #     package = pythonSet.<your_pyproject.toml_package>
  #   };
}
