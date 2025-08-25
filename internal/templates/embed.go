package templates

import "embed"

// FS contains the embedded Nix module templates.
//
//go:embed *.nix
var FS embed.FS
