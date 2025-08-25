package main

import (
	"context"
	"os"

	"github.com/charmbracelet/fang"
	cli "github.com/losnappas/flakegarden/internal/cli"
	"github.com/spf13/cobra"
)

func main() {
	root := &cobra.Command{
		Use:   "flakegarden",
		Short: "Shadcn-like Nix flake module manager",
	}

	root.AddCommand(cli.AddCmd())
	root.AddCommand(cli.ListCmd())

	if err := fang.Execute(context.Background(), root); err != nil {
		os.Exit(1)
	}
}
