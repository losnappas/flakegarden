{ pkgs, ... }:
let
  # hp = pkgs.haskell.packages.ghc98;
  hp = pkgs.haskellPackages;
in
{
  treefmt.programs = {
    cabal-fmt.enable = true;
    ormolu.enable = true;
    # cabal-gild.enable = true;
    # stylish-haskell.enable = true;
    # fourmolu.enable = true;
    # hlint.enable = true;
  };

  make-shells.haskell = {
    packages = [
      hp.ghc
      hp.haskell-language-server
      hp.cabal-install
      # hp.stack
    ];
  };

  # packages.defaultHaskellProgram = {};
}
