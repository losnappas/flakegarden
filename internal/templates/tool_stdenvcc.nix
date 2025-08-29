{ pkgs, ... }:
{
  make-shells.stdenvcc = {
    env.LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.stdenv.cc.cc.lib
      # pkgs.zlib # libz.so.1
      # pkgs.libGL # libGL.so.1
      # pkgs.glib.out # libgthread-2.0.so.1
    ];
  };
}
