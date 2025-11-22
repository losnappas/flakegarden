{ pkgs, ... }:
{
  make-shells.pipewire-alsa = {
    env.LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      (pkgs.alsa-lib-with-plugins.override {
        plugins = [
          pkgs.alsa-plugins
          pkgs.pipewire
        ];
      })
      pkgs.pipewire
    ];
  };
}
