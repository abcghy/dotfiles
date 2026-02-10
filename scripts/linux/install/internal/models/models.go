package models

// Category represents a group of packages
type Category struct {
	Name        string   `toml:"name"`
	Description string   `toml:"description"`
	Packages    []string `toml:"packages"`
	AURPackages []string `toml:"aur"`
}

// FontCategory represents the fonts category with detailed metadata
type FontCategory struct {
	Name         string        `toml:"name"`
	Description  string        `toml:"description"`
	FontPackages []FontPackage `toml:"packages"`
}

// FontPackage represents a font with metadata
type FontPackage struct {
	Name        string `toml:"name"`
	Description string `toml:"description"`
	Recommended bool   `toml:"recommended"`
	AUR         bool   `toml:"aur"`
}

// OptionalItem represents an optional tool or dev environment
type OptionalItem struct {
	Name              string `toml:"name"`
	Description       string `toml:"description"`
	SelectedByDefault bool   `toml:"selected_by_default"`
	AUR               bool   `toml:"aur"`
	Method            string `toml:"method"`
	DetectCmd         string `toml:"detect_cmd"`
}

// OptionalSection represents a section of optional items
type OptionalSection struct {
	Name        string         `toml:"name"`
	Description string         `toml:"description"`
	Items       []OptionalItem `toml:"items"`
}

// Preset represents a predefined installation configuration
type Preset struct {
	Name           string   `toml:"name"`
	Description    string   `toml:"description"`
	Categories     []string `toml:"categories"`
	FontSelections []string `toml:"font_selections"`
	OptionalTools  []string `toml:"optional_tools"`
	DevEnvs        []string `toml:"dev_envs"`
	ExtraPackages  []string `toml:"extra_packages"`
}

// RawConfig represents the raw TOML structure before processing
type RawConfig struct {
	Categories map[string]interface{}     `toml:"categories"`
	Optional   map[string]OptionalSection `toml:"optional"`
	Presets    map[string]Preset          `toml:"presets"`
}

// Config represents the processed configuration
type Config struct {
	Categories    map[string]Category
	FontsCategory FontCategory
	Optional      map[string]OptionalSection
	Presets       map[string]Preset
}

// InstalledInfo tracks what software is already installed
type InstalledInfo struct {
	Categories    map[string]bool   // category -> installed
	Packages      map[string]bool   // package name -> installed
	Fonts         map[string]bool   // font name -> installed
	DevEnvs       map[string]string // dev env -> version (empty if not installed)
	OptionalTools map[string]bool   // tool name -> installed
}

// WizardResult contains the user's selections
type WizardResult struct {
	Categories     []string `json:"categories"`
	Fonts          []string `json:"fonts"`
	OptionalTools  []string `json:"optional_tools"`
	DevEnvs        []string `json:"dev_envs"`
	ExtraPackages  []string `json:"extra_packages"`
	EnableMultilib bool     `json:"enable_multilib"`
}
