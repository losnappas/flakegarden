{ pkgs, ... }:
{
  make-shells.nvidia = {
    env = {
      LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
        pkgs.cudaToolkit
        pkgs.cudaPackages.cudnn
        "/run/opengl-driver"
      ];
      CUDA_HOME = pkgs.cudatoolkit;
    };
  };
}
