{ pkgs, ... }:
{
  # TODO(@agent): allow non-free packages:
  #
  # Add the following inside `perSystem` in `flake.nix`:
  #
  # _module.args.pkgs = import inputs.nixpkgs {
  #   inherit system;
  #   config.allowUnfree = true;
  # };

  make-shells.nvidia = {
    env = {
      LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
        pkgs.cudatoolkit
        pkgs.cudaPackages.cudnn
        "/run/opengl-driver"
      ];
      CUDA_HOME = pkgs.cudatoolkit;
    };
  };
}
