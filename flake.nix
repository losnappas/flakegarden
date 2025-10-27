{
  description = "A basic flake";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    flake-root.url = "github:srid/flake-root";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    make-shell.url = "github:nicknovitski/make-shell";
  };

  outputs =
    inputs@{ flake-parts, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-root.flakeModule
        inputs.treefmt-nix.flakeModule
        inputs.flake-parts.flakeModules.flakeModules
      ];
      systems = import inputs.systems;
      perSystem =
        {
          config,
          inputs',
          lib,
          pkgs,
          system,
          ...
        }:
        {

          # Per-system attributes can be defined here. The self' and inputs'
          # module parameters provide easy access to attributes of the same
          # system.
          packages.default = config.packages.flakegarden;

          treefmt = {
            inherit (config.flake-root) projectRootFile;
            programs = {
              nixfmt.enable = true;
              shfmt.enable = true;
            };
          };

          devShells.default = pkgs.mkShell {
            # Sets up FLAKE_ROOT var.
            inputsFrom = [ config.flake-root.devShell ];
            packages = with pkgs; [
              config.packages.flakegarden
              fzf
            ];
            env = {
              PROJECT_FORMATTER = lib.getExe config.formatter;
            };
          };

          packages.flakegarden = pkgs.stdenv.mkDerivation {
            name = "flakegarden";
            src = ./.;
            buildInputs = with pkgs; [
              fzf
            ];
            installPhase = ''
              mkdir -p $out/bin
              cp -r ${./templates} $out/templates
              cp ${./flakegarden.sh} $out/bin/flakegarden
              chmod +x $out/bin/flakegarden
              substituteInPlace $out/bin/flakegarden \
                --replace-fail "TEMPLATES_DIR=\"templates\"" "TEMPLATES_DIR=\"$out/templates\"" \
                --replace-fail "VERSION=\"dev\"" "VERSION=\"git-${
                  self.shortRev or self.dirtyShortRev or "unknown"
                }\""
            '';
          };
        };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

        # A small lib for flake consumers
        lib = {
          # Usage:
          # - `imports = inputs.flakegarden.lib.importDir ./nix;`
          importDir =
            dir:
            if builtins.pathExists dir then
              inputs.nixpkgs.lib.mapAttrsToList (path: _: inputs.nixpkgs.lib.path.append dir path) (
                builtins.readDir dir
              )
            else
              [ ];

        };

        # Flake module that wires make-shells.default, combining all subshells.
        flakeModule = {
          imports = [
            inputs.make-shell.flakeModules.default
            inputs.flake-root.flakeModule
          ];
          perSystem =
            {
              config,
              inputs',
              self',
              ...
            }:
            {
              make-shells.default = {
                inputsFrom = [
                  config.flake-root.devShell
                ];
                imports =
                  let
                    others = builtins.removeAttrs config.make-shells [ "default" ];
                    # Use other shells' option sets directly; drop computed fields.
                    asModules = builtins.map (
                      cfg:
                      builtins.removeAttrs cfg [
                        "finalPackage"
                        "stdenv"
                        "finalEnv"
                      ]
                    ) (builtins.attrValues others);
                  in
                  asModules;
                packages = [ inputs'.flakegarden.packages.default ];
              };
            };
        };

        templates.default = {
          path = ./template;
          description = "Default flakegarden template";
        };
      };
    };
}
