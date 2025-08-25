package cli

import (
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"

	templates "github.com/losnappas/flakegarden/internal/templates"
	"github.com/spf13/cobra"
)

func AddCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "add [module...]",
		Short: "Add a module or multiple modules (e.g., python). Start an interactive picker if no modules are provided",
		Args:  cobra.ArbitraryArgs,
		RunE: func(cmd *cobra.Command, args []string) error {
			modules, err := listModules()
			if err != nil {
				return err
			}
			if len(args) == 0 {
				picked, err := pickModules(modules)
				if err != nil {
					return err
				}
				args = picked
			}
			for _, arg := range args {
				if err := addModule(arg); err != nil {
					return err
				}
			}
			return nil
		},
	}
	return cmd
}

func ListCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "list",
		Short: "List available modules",
		RunE: func(cmd *cobra.Command, args []string) error {
			modules, err := listModules()
			if err != nil {
				return err
			}
			for _, m := range modules {
				fmt.Printf("%s\n", m)
			}
			return nil
		},
	}
	return cmd
}

func listModules() ([]string, error) {
	entries, err := templates.FS.ReadDir(".")
	if err != nil {
		return nil, fmt.Errorf("failed to read embedded templates: %w", err)
	}

	var modules []string
	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		name := e.Name()
		if strings.HasSuffix(name, ".nix") {
			modules = append(modules, strings.TrimSuffix(name, ".nix"))
		}
	}

	sort.Strings(modules)
	return modules, nil
}

func addModule(name string) error {
	// Ensure nix/garden directory
	if err := os.MkdirAll("nix/garden", 0o755); err != nil {
		return err
	}
	path := filepath.Join("nix/garden", name+".nix")
	if _, err := os.Stat(path); err == nil {
		return nil
	}
	data, err := templates.FS.ReadFile(name + ".nix")
	if err != nil {
		return fmt.Errorf("failed to read embedded template %s: %w", name+".nix", err)
	}
	content := strings.TrimSpace(string(data)) + "\n"
	if err := os.WriteFile(path, []byte(content), 0o644); err != nil {
		return err
	}
	fmt.Println("Wrote", path)
	return nil
}
