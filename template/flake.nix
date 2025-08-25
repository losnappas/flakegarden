{
  description = "Project using flakegarden CLI to add language modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    make-shell.url = "github:nicknovitski/make-shell";
    flake-root.url = "github:srid/flake-root";

    flakegarden.url = "github:losnappas/flakegarden";
    flakegarden.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-root.flakeModule
        inputs.treefmt-nix.flakeModule
        inputs.make-shell.flakeModules.default
        inputs.flakegarden.flakeModule
      ];
      systems = import inputs.systems;
      perSystem =
        {
          pkgs,
          config,
          self',
          lib,
          ...
        }:
        {
          imports = inputs.flakegarden.lib.importDir ./nix;

          treefmt = {
            inherit (config.flake-root) projectRootFile;
            programs = {
              nixfmt.enable = true;
            };
          };

          make-shells.default = {
            inputsFrom = [
              config.flake-root.devShell
            ];

            packages = [
              pkgs.nil
            ];

            shellHook = ''
              echo testing
            '';

            env.PROJECT_FORMATTER = lib.getExe config.formatter;
          };

          # packages.default = self'.packages.myDefaultPackage;
        };

      flake = { };
    };
}
