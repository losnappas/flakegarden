# flakegarden

A shadcn-like CLI to compose language/tooling modules into your Nix flakes.

Think: `shadcn/ui`, but for `nix`. Use `flakegarden` to add opinionated, ready-to-use modules (e.g., Python) into your project under `nix/`, so you can bootstrap devshells, tooling, and packaging with minimal fuss.

## Goals

- Provide a catalog of language/tooling modules (python, ts, rust, …)
- Let you add modules incrementally via a friendly CLI
- Keep modules as plain nix files in your repo (auditable, editable)
- Work with flakes and flake-parts setups

## Usage

Initialize a flake:

`nix flake init -t "github:losnappas/flakegarden"`

Add modules you need: 

`$ flakegarden add python`
