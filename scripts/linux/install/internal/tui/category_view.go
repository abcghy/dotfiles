package tui

import (
	"arch-install/internal/models"
	"strings"

	"github.com/charmbracelet/bubbles/list"
	tea "github.com/charmbracelet/bubbletea"
)

// CategoryItem represents a category option
type CategoryItem struct {
	id          string
	name        string
	description string
	installed   bool
	selected    bool
}

func (i CategoryItem) Title() string {
	prefix := "☐ "
	if i.selected {
		prefix = "☑ "
	}
	if i.installed {
		return prefix + i.name + " ✓"
	}
	return prefix + i.name
}

func (i CategoryItem) Description() string {
	desc := i.description
	if i.installed {
		desc += " (already installed)"
	}
	return desc
}

func (i CategoryItem) FilterValue() string { return i.name }

// CategoryView handles category selection
type CategoryView struct {
	list      list.Model
	items     []CategoryItem
	done      bool
	installed *models.InstalledInfo
	width     int
	height    int
}

// NewCategoryView creates a new category selection view
func NewCategoryView(cfg *models.Config, installed *models.InstalledInfo) *CategoryView {
	var items []CategoryItem

	for id, cat := range cfg.Categories {
		if id == "fonts" {
			continue // Fonts are selected separately
		}
		items = append(items, CategoryItem{
			id:          id,
			name:        cat.Name,
			description: cat.Description,
			installed:   installed.Categories[id],
			selected:    false,
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

	l := list.New(listItems, delegate, 100, 15)
	l.Title = "Select Categories to Install (Space to toggle, Enter to continue)"
	l.SetShowStatusBar(false)
	l.SetFilteringEnabled(true)

	return &CategoryView{
		list:      l,
		items:     items,
		installed: installed,
	}
}

// Update handles user input
func (v *CategoryView) Update(msg tea.Msg) ([]string, bool, tea.Cmd) {
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
					selected = append(selected, item.id)
				}
			}
			return selected, true, nil
		}
	}

	var cmd tea.Cmd
	v.list, cmd = v.list.Update(msg)
	return nil, false, cmd
}

// View renders the category selection screen
func (v *CategoryView) View() string {
	var b strings.Builder
	b.WriteString(titleStyle.Render("Select Categories"))
	b.WriteString("\n\n")
	b.WriteString(subtitleStyle.Render("Choose which package categories to install:"))
	b.WriteString("\n\n")
	b.WriteString(v.list.View())
	b.WriteString("\n")
	b.WriteString(helpStyle.Render("Space: Toggle • Enter: Continue • /: Filter • Esc: Back"))
	return b.String()
}

// SetSize updates the view dimensions
func (v *CategoryView) SetSize(width, height int) {
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
