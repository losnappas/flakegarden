#!/usr/bin/env bash
set -euo pipefail

TEMPLATES_DIR="templates"

# Function to display help message
show_help() {
  echo "Usage: flakegarden <command> [options]"
  echo ""
  echo "Commands:"
  echo "  add [template]    Add a new template to your project."
  echo "                    If no template is specified, a list of available templates will be shown."
  echo "  --help            Show this help message."
}

# Function to add a template
add_template() {
  if [ -z "$1" ]; then
    selection=$(find "$TEMPLATES_DIR" -mindepth 1 -exec basename {} \; | fzf --multi)
  else
    selection="${1%.nix}.nix"
  fi

  if [ -z "$selection" ]; then
    echo "No file selected"
    exit 1
  fi

  mkdir -p nix/garden
  echo "$selection" | while read -r file; do
    if [ ! -f "nix/garden/$file" ]; then
      install -m 644 "$TEMPLATES_DIR/$file" "nix/garden/$file"
    else
      echo "File nix/garden/$file already exists, skipping."
    fi
  done
}

# Main script logic
case "${1:-}" in
--help)
  show_help
  ;;
add)
  add_template "${2:-}"
  ;;
*)
  show_help
  ;;
esac
