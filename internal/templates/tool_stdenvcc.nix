{ pkgs, ... }:
{
  make-shells.stdenvcc = {
    env.LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.stdenv.cc.cc.lib
    ];
  };
}
