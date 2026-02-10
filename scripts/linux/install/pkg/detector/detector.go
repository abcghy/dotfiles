package detector

import (
	"arch-install/internal/models"
	"fmt"
	"os/exec"
	"strings"
)

// DetectAll performs comprehensive detection of installed software
func DetectAll(cfg *models.Config) *models.InstalledInfo {
	info := &models.InstalledInfo{
		Categories:    make(map[string]bool),
		Packages:      make(map[string]bool),
		Fonts:         make(map[string]bool),
		DevEnvs:       make(map[string]string),
		OptionalTools: make(map[string]bool),
	}

	// Detect categories and packages
	for catID, category := range cfg.Categories {
		catInstalled := true
		for _, pkg := range category.Packages {
			if !isPackageInstalled(pkg) {
				catInstalled = false
				break
			}
		}
		info.Categories[catID] = catInstalled

		// Check individual packages
		for _, pkg := range category.Packages {
			info.Packages[pkg] = isPackageInstalled(pkg)
		}
		for _, pkg := range category.AURPackages {
			info.Packages[pkg] = isPackageInstalled(pkg)
		}
	}

	// Detect fonts
	for _, font := range cfg.FontsCategory.FontPackages {
		info.Fonts[font.Name] = isPackageInstalled(font.Name)
	}

	// Detect optional tools
	if tools, ok := cfg.Optional["tools"]; ok {
		for _, tool := range tools.Items {
			info.OptionalTools[tool.Name] = isPackageInstalled(tool.Name)
		}
	}

	// Detect development environments with versions
	if devEnvs, ok := cfg.Optional["dev-env"]; ok {
		for _, env := range devEnvs.Items {
			version := detectDevEnvVersion(env)
			info.DevEnvs[env.Name] = version
		}
	}

	return info
}

// isPackageInstalled checks if a package is installed via pacman
func isPackageInstalled(pkgName string) bool {
	cmd := exec.Command("pacman", "-Q", pkgName)
	err := cmd.Run()
	return err == nil
}

// detectDevEnvVersion detects if a dev environment is installed and returns its version
func detectDevEnvVersion(env models.OptionalItem) string {
	if env.DetectCmd == "" {
		return ""
	}

	// Split the command (e.g., "python --version")
	parts := strings.Fields(env.DetectCmd)
	if len(parts) == 0 {
		return ""
	}

	cmd := exec.Command(parts[0], parts[1:]...)
	output, err := cmd.CombinedOutput()
	if err != nil {
		// Try alternative commands
		return detectAlternative(env.Name)
	}

	version := strings.TrimSpace(string(output))
	// Clean up version string
	version = strings.TrimPrefix(version, env.Name+" ")
	version = strings.TrimPrefix(version, "v")
	version = strings.TrimSpace(version)

	return version
}

// detectAlternative tries alternative detection methods
func detectAlternative(name string) string {
	switch name {
	case "python":
		// Try python3
		cmd := exec.Command("python3", "--version")
		output, err := cmd.Output()
		if err == nil {
			return strings.TrimSpace(strings.TrimPrefix(string(output), "Python "))
		}
	case "nodejs":
		// Check if node is available through fnm or other means
		cmd := exec.Command("which", "node")
		if err := cmd.Run(); err == nil {
			cmd = exec.Command("node", "--version")
			output, err := cmd.Output()
			if err == nil {
				return strings.TrimSpace(strings.TrimPrefix(string(output), "v"))
			}
		}
	case "rust":
		// Check for rustup
		cmd := exec.Command("which", "rustc")
		if err := cmd.Run(); err == nil {
			cmd = exec.Command("rustc", "--version")
			output, err := cmd.Output()
			if err == nil {
				fields := strings.Fields(string(output))
				if len(fields) >= 2 {
					return fields[1]
				}
			}
		}
	case "go":
		cmd := exec.Command("go", "version")
		output, err := cmd.Output()
		if err == nil {
			fields := strings.Fields(string(output))
			if len(fields) >= 3 {
				return strings.TrimPrefix(fields[2], "go")
			}
		}
	}
	return ""
}

// IsYayInstalled checks if yay is available
func IsYayInstalled() bool {
	cmd := exec.Command("which", "yay")
	err := cmd.Run()
	return err == nil
}

// GetYayVersion returns the installed yay version
func GetYayVersion() string {
	cmd := exec.Command("yay", "--version")
	output, err := cmd.Output()
	if err != nil {
		return ""
	}
	fields := strings.Fields(string(output))
	if len(fields) >= 2 {
		return fields[1]
	}
	return ""
}

// PrintDetectionSummary prints a summary of detected software
func PrintDetectionSummary(info *models.InstalledInfo) {
	fmt.Println("\n📋 Detection Summary:")
	fmt.Println("====================")

	fmt.Println("\nCategories:")
	for cat, installed := range info.Categories {
		if installed {
			fmt.Printf("  ✓ %s (installed)\n", cat)
		} else {
			fmt.Printf("  ✗ %s (not installed)\n", cat)
		}
	}

	fmt.Println("\nDevelopment Environments:")
	for env, version := range info.DevEnvs {
		if version != "" {
			fmt.Printf("  ✓ %s (v%s)\n", env, version)
		} else {
			fmt.Printf("  ✗ %s (not installed)\n", env)
		}
	}

	if IsYayInstalled() {
		fmt.Printf("\n✓ Yay installed (v%s)\n", GetYayVersion())
	} else {
		fmt.Println("\n✗ Yay not installed (will be installed)")
	}
}
