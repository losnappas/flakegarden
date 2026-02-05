{ pkgs, ... }:
{
  treefmt.programs.just.enable = true;

  make-shells.just = {
    packages = with pkgs; [
      just
    ];
  };
}
