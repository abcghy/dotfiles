package tui

import (
	"arch-install/internal/models"
	"fmt"
	"strings"

	"github.com/charmbracelet/bubbles/list"
	tea "github.com/charmbracelet/bubbletea"
)

// DevEnvItem represents a development environment option
type DevEnvItem struct {
	name        string
	description string
	version     string
	method      string
	selected    bool
}

func (i DevEnvItem) Title() string {
	prefix := "☐ "
	if i.selected {
		prefix = "☑ "
	}
	title := prefix + i.name
	if i.version != "" {
		title += fmt.Sprintf(" (v%s)", i.version)
	}
	return title
}

func (i DevEnvItem) Description() string {
	desc := i.description
	if i.version != "" {
		desc += " ✓ already installed"
	} else {
		desc += fmt.Sprintf(" (%s)", i.method)
	}
	return desc
}

func (i DevEnvItem) FilterValue() string { return i.name }

// DevEnvView handles development environment selection
type DevEnvView struct {
	list   list.Model
	items  []DevEnvItem
	done   bool
	width  int
	height int
}

// NewDevEnvView creates a new dev environment selection view
func NewDevEnvView(cfg *models.Config, installed *models.InstalledInfo) *DevEnvView {
	var items []DevEnvItem

	if devEnvs, ok := cfg.Optional["dev-env"]; ok {
		for _, env := range devEnvs.Items {
			version := installed.DevEnvs[env.Name]
			items = append(items, DevEnvItem{
				name:        env.Name,
				description: env.Description,
				version:     version,
				method:      env.Method,
				selected:    false,
			})
		}
	}

	listItems := make([]list.Item, len(items))
	for i := range items {
		listItems[i] = items[i]
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

	l := list.New(listItems, delegate, 100, 15)
	l.Title = "Select Development Environments (Space to toggle)"
	l.SetShowStatusBar(false)
	l.SetFilteringEnabled(false)

	return &DevEnvView{
		list:  l,
		items: items,
	}
}

// Update handles user input
func (v *DevEnvView) Update(msg tea.Msg) ([]string, bool, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.String() {
		case " ":
			// Toggle selection
			idx := v.list.Index()
			if idx >= 0 && idx < len(v.items) {
				v.items[idx].selected = !v.items[idx].selected
				// Update list
				listItems := make([]list.Item, len(v.items))
				for i := range v.items {
					listItems[i] = v.items[i]
				}
				v.list.SetItems(listItems)
			}
			return nil, false, nil
		case "enter":
			v.done = true
			var selected []string
			for _, item := range v.items {
				if item.selected && item.version == "" {
					// Only select if not already installed
					selected = append(selected, item.name)
				}
			}
			return selected, true, nil
		}
	}

	var cmd tea.Cmd
	v.list, cmd = v.list.Update(msg)
	return nil, false, cmd
}

// View renders the dev environment selection screen
func (v *DevEnvView) View() string {
	var b strings.Builder
	b.WriteString(titleStyle.Render("Select Development Environments"))
	b.WriteString("\n\n")
	b.WriteString(subtitleStyle.Render("Choose programming language environments:"))
	b.WriteString("\n\n")
	b.WriteString(v.list.View())
	b.WriteString("\n")
	b.WriteString(helpStyle.Render("Space: Toggle • Enter: Continue • Esc: Back"))
	return b.String()
}

// SetSize updates the view dimensions
func (v *DevEnvView) SetSize(width, height int) {
	v.width = width
	v.height = height
	// Reserve space for title, subtitle, help text, and footer
	listHeight := height - 12
	if listHeight < 10 {
		listHeight = 10
	}
	listWidth := width - 4
	if listWidth < 60 {
		listWidth = 60
	}
	v.list.SetSize(listWidth, listHeight)
}
