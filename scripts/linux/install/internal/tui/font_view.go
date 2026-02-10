package tui

import (
	"arch-install/internal/models"
	"strings"

	"github.com/charmbracelet/bubbles/list"
	tea "github.com/charmbracelet/bubbletea"
)

// FontItem represents a font option
type FontItem struct {
	name        string
	description string
	recommended bool
	installed   bool
	selected    bool
}

func (i FontItem) Title() string {
	prefix := "☐ "
	if i.selected {
		prefix = "☑ "
	}
	title := prefix + i.name
	if i.recommended {
		title += " ★"
	}
	if i.installed {
		title += " ✓"
	}
	return title
}

func (i FontItem) Description() string {
	desc := i.description
	if i.installed {
		desc += " (already installed)"
	}
	return desc
}

func (i FontItem) FilterValue() string { return i.name }

// FontView handles font selection
type FontView struct {
	list   list.Model
	items  []FontItem
	done   bool
	width  int
	height int
}

// NewFontView creates a new font selection view
func NewFontView(cfg *models.Config, installed *models.InstalledInfo) *FontView {
	var items []FontItem

	for _, font := range cfg.FontsCategory.FontPackages {
		items = append(items, FontItem{
			name:        font.Name,
			description: font.Description,
			recommended: font.Recommended,
			installed:   installed.Fonts[font.Name],
			selected:    font.Recommended && !installed.Fonts[font.Name],
		})
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

	l := list.New(listItems, delegate, 100, 18)
	l.Title = "Select Fonts to Install (★ = Recommended, Space to toggle)"
	l.SetShowStatusBar(false)
	l.SetFilteringEnabled(true)

	return &FontView{
		list:  l,
		items: items,
	}
}

// Update handles user input
func (v *FontView) Update(msg tea.Msg) ([]string, bool, tea.Cmd) {
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
				if item.selected {
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

// View renders the font selection screen
func (v *FontView) View() string {
	var b strings.Builder
	b.WriteString(titleStyle.Render("Select Fonts"))
	b.WriteString("\n\n")
	b.WriteString(subtitleStyle.Render("Choose fonts for proper text display:"))
	b.WriteString("\n\n")
	b.WriteString(v.list.View())
	b.WriteString("\n")
	b.WriteString(helpStyle.Render("Space: Toggle • Enter: Continue • /: Filter • Esc: Back"))
	return b.String()
}

// SetSize updates the view dimensions
func (v *FontView) SetSize(width, height int) {
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
