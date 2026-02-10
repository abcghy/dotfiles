package tui

import (
	"arch-install/internal/models"
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

// SimpleWizard provides a text-based alternative to the TUI
type SimpleWizard struct {
	config    *models.Config
	installed *models.InstalledInfo
	reader    *bufio.Reader
}

// RunSimpleWizard runs a text-based wizard that works in any terminal
func RunSimpleWizard(cfg *models.Config, installed *models.InstalledInfo) (*models.WizardResult, error) {
	w := &SimpleWizard{
		config:    cfg,
		installed: installed,
		reader:    bufio.NewReader(os.Stdin),
	}

	result := &models.WizardResult{
		Categories:    []string{},
		Fonts:         []string{},
		OptionalTools: []string{},
		DevEnvs:       []string{},
		ExtraPackages: []string{},
	}

	fmt.Println("\n🚀 Arch Linux Installation Wizard")
	fmt.Println("=================================\n")

	// Welcome
	if !w.askYesNo("Welcome! This wizard will help you install packages. Continue?") {
		return nil, nil
	}

	// Preset selection
	preset := w.selectPreset()
	if preset == "" {
		return nil, nil
	}

	if preset != "custom" {
		// Apply preset
		if p, ok := cfg.Presets[preset]; ok {
			result.Categories = p.Categories
			result.Fonts = p.FontSelections
			result.OptionalTools = p.OptionalTools
			result.DevEnvs = p.DevEnvs
			result.ExtraPackages = p.ExtraPackages
			for _, pkg := range p.ExtraPackages {
				if pkg == "steam" {
					result.EnableMultilib = true
				}
			}
		}
	} else {
		// Custom selection
		// Categories
		fmt.Println("\n📁 Select Categories:")
		for id, cat := range cfg.Categories {
			installedMarker := ""
			if w.installed.Categories[id] {
				installedMarker = " (already installed)"
			}
			if w.askYesNo(fmt.Sprintf("  Install %s%s?", cat.Name, installedMarker)) {
				result.Categories = append(result.Categories, id)
			}
		}

		// Fonts
		fmt.Println("\n🔤 Select Fonts:")
		for _, font := range cfg.FontsCategory.FontPackages {
			recommended := ""
			if font.Recommended {
				recommended = " ★"
			}
			installedMarker := ""
			if w.installed.Fonts[font.Name] {
				installedMarker = " ✓"
			}
			desc := fmt.Sprintf("  %s%s%s - %s", font.Name, recommended, installedMarker, font.Description)
			if w.askYesNo(desc) {
				result.Fonts = append(result.Fonts, font.Name)
			}
		}

		// Dev environments
		fmt.Println("\n💻 Select Development Environments:")
		for _, env := range cfg.Optional["dev-env"].Items {
			version := w.installed.DevEnvs[env.Name]
			if version != "" {
				fmt.Printf("  %s v%s already installed, skipping\n", env.Name, version)
			} else {
				if w.askYesNo(fmt.Sprintf("  Install %s (%s)?", env.Name, env.Method)) {
					result.DevEnvs = append(result.DevEnvs, env.Name)
				}
			}
		}

		// Optional tools
		fmt.Println("\n⚙️  Select Optional Tools (none selected by default):")
		for _, tool := range cfg.Optional["tools"].Items {
			installedMarker := ""
			if w.installed.OptionalTools[tool.Name] {
				installedMarker = " ✓"
			}
			if w.askYesNo(fmt.Sprintf("  Install %s%s? %s", tool.Name, installedMarker, tool.Description)) {
				result.OptionalTools = append(result.OptionalTools, tool.Name)
			}
		}
	}

	// Confirmation
	fmt.Println("\n📋 Installation Summary:")
	fmt.Printf("  Categories: %v\n", result.Categories)
	fmt.Printf("  Fonts: %v\n", result.Fonts)
	fmt.Printf("  Dev Environments: %v\n", result.DevEnvs)
	fmt.Printf("  Optional Tools: %v\n", result.OptionalTools)
	fmt.Printf("  Extra Packages: %v\n", result.ExtraPackages)
	if result.EnableMultilib {
		fmt.Println("  ⚠️  Will enable multilib repository")
	}

	if !w.askYesNo("\nProceed with installation?") {
		return nil, nil
	}

	return result, nil
}

func (w *SimpleWizard) askYesNo(prompt string) bool {
	fmt.Printf("%s [Y/n]: ", prompt)
	input, _ := w.reader.ReadString('\n')
	input = strings.TrimSpace(strings.ToLower(input))
	return input == "" || input == "y" || input == "yes"
}

func (w *SimpleWizard) selectPreset() string {
	fmt.Println("\n📋 Select Installation Preset:")
	fmt.Println("  1. Minimal Install - Basic system + Terminal environment")
	fmt.Println("  2. Developer Workstation - Complete setup for programming")
	fmt.Println("  3. Gaming & Entertainment - Optimized for gaming and media")
	fmt.Println("  4. Full Install - Install everything")
	fmt.Println("  5. Custom Selection - Manually select packages")
	fmt.Println("  0. Cancel")

	for {
		fmt.Print("\nEnter choice (0-5): ")
		input, _ := w.reader.ReadString('\n')
		input = strings.TrimSpace(input)

		choice, err := strconv.Atoi(input)
		if err != nil {
			fmt.Println("Invalid input, please enter a number")
			continue
		}

		switch choice {
		case 0:
			return ""
		case 1:
			return "minimal"
		case 2:
			return "developer"
		case 3:
			return "gaming"
		case 4:
			return "full"
		case 5:
			return "custom"
		default:
			fmt.Println("Invalid choice, please enter 0-5")
		}
	}
}
