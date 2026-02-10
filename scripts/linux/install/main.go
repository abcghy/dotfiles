package main

import (
	"encoding/json"
	"fmt"
	"os"

	"arch-install/internal/config"
	"arch-install/internal/models"
	"arch-install/internal/tui"
	"arch-install/pkg/detector"
	"golang.org/x/term"
)

// InstallManifest contains all packages to be installed
type InstallManifest struct {
	PacmanPackages []string `json:"pacman_packages"`
	AurPackages    []string `json:"aur_packages"`
	DevEnvs        []string `json:"dev_envs"`
	EnableMultilib bool     `json:"enable_multilib"`
	Summary        Summary  `json:"summary"`
}

type Summary struct {
	Categories    []string `json:"categories"`
	Fonts         []string `json:"fonts"`
	OptionalTools []string `json:"optional_tools"`
	ExtraPackages []string `json:"extra_packages"`
}

// isTerminal checks if the given file descriptor is a terminal
func isTerminal(fd uintptr) bool {
	return term.IsTerminal(int(fd))
}

func main() {
	// Check for test mode
	if len(os.Args) > 1 && os.Args[1] == "--test-config" {
		testConfig()
		return
	}

	// Load configuration
	cfg, err := config.Load("config/packages.toml")
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error loading config: %v\n", err)
		os.Exit(1)
	}

	// Detect installed software
	installed := detector.DetectAll(cfg)

	// Run TUI wizard
	result, err := tui.RunWizard(cfg, installed)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error running wizard: %v\n", err)
		os.Exit(1)
	}

	// If user cancelled, exit gracefully
	if result == nil {
		os.Exit(0)
	}

	// Build install manifest
	manifest := buildManifest(cfg, result)

	// Save manifest to file for shell script to read
	manifestPath := os.Getenv("TEMP_DIR")
	if manifestPath == "" {
		manifestPath = "/tmp"
	}
	manifestPath += "/manifest.json"

	jsonData, err := json.MarshalIndent(manifest, "", "  ")
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error marshaling manifest: %v\n", err)
		os.Exit(1)
	}

	err = os.WriteFile(manifestPath, jsonData, 0644)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error saving manifest: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Manifest saved to: %s\n", manifestPath)
}

func testConfig() {
	cfg, err := config.Load("config/packages.toml")
	if err != nil {
		fmt.Fprintf(os.Stderr, "✗ Error loading config: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("✓ Configuration loaded successfully!")
	fmt.Printf("\n📁 Categories (%d):\n", len(cfg.Categories))
	for id, cat := range cfg.Categories {
		fmt.Printf("  • %s: %s (%d packages)\n", id, cat.Name, len(cat.Packages))
	}

	fmt.Printf("\n🔤 Fonts (%d):\n", len(cfg.FontsCategory.FontPackages))
	for _, font := range cfg.FontsCategory.FontPackages {
		if font.Recommended {
			fmt.Printf("  ★ %s (recommended)\n", font.Name)
		}
	}

	fmt.Printf("\n⚙️  Optional Tools (%d):\n", len(cfg.Optional["tools"].Items))
	for _, tool := range cfg.Optional["tools"].Items {
		fmt.Printf("  • %s\n", tool.Name)
	}

	fmt.Printf("\n💻 Dev Environments (%d):\n", len(cfg.Optional["dev-env"].Items))
	for _, env := range cfg.Optional["dev-env"].Items {
		fmt.Printf("  • %s (%s)\n", env.Name, env.Method)
	}

	fmt.Printf("\n📋 Presets (%d):\n", len(cfg.Presets))
	for id, preset := range cfg.Presets {
		fmt.Printf("  • %s: %s\n", id, preset.Name)
	}

	fmt.Println("\n✓ All configuration validated successfully!")
}

func buildManifest(cfg *models.Config, result *models.WizardResult) InstallManifest {
	manifest := InstallManifest{
		PacmanPackages: []string{},
		AurPackages:    []string{},
		DevEnvs:        result.DevEnvs,
		EnableMultilib: result.EnableMultilib,
		Summary: Summary{
			Categories:    result.Categories,
			Fonts:         result.Fonts,
			OptionalTools: result.OptionalTools,
			ExtraPackages: result.ExtraPackages,
		},
	}

	// Track added packages to avoid duplicates
	added := make(map[string]bool)

	// Add packages from categories
	for _, catID := range result.Categories {
		if cat, ok := cfg.Categories[catID]; ok {
			// Add regular packages
			for _, pkg := range cat.Packages {
				if !added[pkg] {
					manifest.PacmanPackages = append(manifest.PacmanPackages, pkg)
					added[pkg] = true
				}
			}
			// Add AUR packages
			for _, pkg := range cat.AURPackages {
				if !added[pkg] {
					manifest.AurPackages = append(manifest.AurPackages, pkg)
					added[pkg] = true
				}
			}
		}
	}

	// Add fonts from fonts category
	for _, fontPkg := range cfg.FontsCategory.FontPackages {
		for _, selectedFont := range result.Fonts {
			if fontPkg.Name == selectedFont {
				if fontPkg.AUR {
					if !added[fontPkg.Name] {
						manifest.AurPackages = append(manifest.AurPackages, fontPkg.Name)
						added[fontPkg.Name] = true
					}
				} else {
					if !added[fontPkg.Name] {
						manifest.PacmanPackages = append(manifest.PacmanPackages, fontPkg.Name)
						added[fontPkg.Name] = true
					}
				}
			}
		}
	}

	// Add optional tools
	if tools, ok := cfg.Optional["tools"]; ok {
		for _, tool := range tools.Items {
			for _, selectedTool := range result.OptionalTools {
				if tool.Name == selectedTool {
					if tool.AUR {
						if !added[tool.Name] {
							manifest.AurPackages = append(manifest.AurPackages, tool.Name)
							added[tool.Name] = true
						}
					} else {
						if !added[tool.Name] {
							manifest.PacmanPackages = append(manifest.PacmanPackages, tool.Name)
							added[tool.Name] = true
						}
					}
				}
			}
		}
	}

	// Add extra packages (like steam)
	for _, pkg := range result.ExtraPackages {
		if !added[pkg] {
			manifest.PacmanPackages = append(manifest.PacmanPackages, pkg)
			added[pkg] = true
		}
	}

	return manifest
}
