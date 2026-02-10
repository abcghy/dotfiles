package config

import (
	"arch-install/internal/models"
	"fmt"

	"github.com/BurntSushi/toml"
)

// Load reads the TOML configuration file and processes it
func Load(path string) (*models.Config, error) {
	// First, load raw TOML structure
	var raw struct {
		Categories map[string]toml.Primitive         `toml:"categories"`
		Optional   map[string]models.OptionalSection `toml:"optional"`
		Presets    map[string]models.Preset          `toml:"presets"`
	}

	meta, err := toml.DecodeFile(path, &raw)
	if err != nil {
		return nil, fmt.Errorf("failed to decode TOML: %w", err)
	}

	cfg := &models.Config{
		Categories: make(map[string]models.Category),
		Optional:   raw.Optional,
		Presets:    raw.Presets,
	}

	// Process each category
	for catID, primitive := range raw.Categories {
		if catID == "fonts" {
			// Handle fonts category specially
			var fontsCat models.FontCategory
			if err := meta.PrimitiveDecode(primitive, &fontsCat); err != nil {
				return nil, fmt.Errorf("failed to decode fonts category: %w", err)
			}
			cfg.FontsCategory = fontsCat
		} else {
			// Handle regular categories
			var cat models.Category
			if err := meta.PrimitiveDecode(primitive, &cat); err != nil {
				return nil, fmt.Errorf("failed to decode category %s: %w", catID, err)
			}
			cfg.Categories[catID] = cat
		}
	}

	return cfg, nil
}
