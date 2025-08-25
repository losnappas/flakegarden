{ pkgs, ... }:
{
  treefmt.programs = {
    biome.enable = true;
    # prettier.enable = true;
  };

  make-shells.typescript = {
    packages = with pkgs; [
      vtsls
      package-version-server
      vscode-langservers-extracted
      tailwindcss-language-server

      bun
      # nodejs
      # pnpm
    ];
  };
}
