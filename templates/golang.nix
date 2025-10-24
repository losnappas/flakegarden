{ pkgs, lib, ... }:
{
  treefmt.programs = {
    gofmt.enable = true;
    gofumpt.enable = true;
    goimports.enable = true;
    golines.enable = true;
  };

  make-shells.golang = {
    packages = with pkgs; [
      go
      gopls
      delve
      gomodifytags
      impl
      go-tools
      gotests
    ];
  };

  packages.defaultGoProgram = pkgs.buildGoModule {
    pname = "program";
    version = "1.0.0";
    src = ./.;
    vendorHash = lib.fakeHash;

    # meta = with lib; {
    #   description = "Description";
    #   homepage = "";
    #   license = licenses.unlicense;
    # };
  };
}
