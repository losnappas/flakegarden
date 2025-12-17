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
  #
  # And this at the top level of `flake.nix`:
  #
  # nixConfig = {
  #   extra-substituters = [
  #     "https://nix-community.cachix.org"
  #   ];
  #   extra-trusted-public-keys = [
  #     "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  #   ];
  # };
  #
  # And then remove this comment.

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
