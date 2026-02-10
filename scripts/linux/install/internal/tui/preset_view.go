package tui

import (
	"arch-install/internal/models"

	"github.com/charmbracelet/bubbles/list"
	tea "github.com/charmbracelet/bubbletea"
)

// PresetItem represents a preset option
type PresetItem struct {
	id          string
	name        string
	description string
}

func (i PresetItem) Title() string       { return i.name }
func (i PresetItem) Description() string { return i.description }
func (i PresetItem) FilterValue() string { return i.name }

// PresetView handles preset selection
type PresetView struct {
	list      list.Model
	done      bool
	selection string
	width     int
	height    int
}

// NewPresetView creates a new preset selection view
func NewPresetView(cfg *models.Config) *PresetView {
	items := []list.Item{
		PresetItem{
			id:          "minimal",
			name:        "Minimal Install",
			description: "Essential system + Terminal environment only",
		},
		PresetItem{
			id:          "developer",
			name:        "Developer Workstation",
			description: "Complete setup for programming and development",
		},
		PresetItem{
			id:          "gaming",
			name:        "Gaming & Entertainment",
			description: "Optimized for gaming and media consumption",
		},
		PresetItem{
			id:          "full",
			name:        "Full Install",
			description: "Install everything (may take a long time)",
		},
		PresetItem{
			id:          "custom",
			name:        "Custom Selection",
			description: "Manually select categories and packages",
		},
	}

	delegate := list.NewDefaultDelegate()
	delegate.Styles.SelectedTitle = selectedItemStyle
	delegate.Styles.SelectedDesc = descriptionStyle
	delegate.Styles.NormalTitle = itemStyle
	delegate.Styles.NormalDesc = descriptionStyle
	// Increase description width to prevent truncation
	delegate.Styles.SelectedDesc.MaxWidth(80)
	delegate.Styles.NormalDesc.MaxWidth(80)
	delegate.SetSpacing(1)

	l := list.New(items, delegate, 80, 20)
	l.Title = "Select Installation Preset"
	l.SetShowStatusBar(false)
	l.SetFilteringEnabled(false)

	return &PresetView{
		list: l,
	}
}

// Update handles user input
func (v *PresetView) Update(msg tea.Msg) (string, bool, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		if msg.String() == "enter" {
			if i, ok := v.list.SelectedItem().(PresetItem); ok {
				v.selection = i.id
				v.done = true
				return v.selection, true, nil
			}
		}
	}

	var cmd tea.Cmd
	v.list, cmd = v.list.Update(msg)
	return "", false, cmd
}

// View renders the preset selection screen
func (v *PresetView) View() string {
	return v.list.View()
}

// SetSize updates the view dimensions
func (v *PresetView) SetSize(width, height int) {
	v.width = width
	v.height = height
	// Reserve space for footer
	listHeight := height - 6
	if listHeight < 10 {
		listHeight = 10
	}
	listWidth := width - 4
	if listWidth < 60 {
		listWidth = 60
	}
	v.list.SetSize(listWidth, listHeight)
}
