package tui

import (
	"arch-install/internal/models"
	"strings"

	"github.com/charmbracelet/bubbles/list"
	tea "github.com/charmbracelet/bubbletea"
)

// OptionalItem represents an optional tool
type OptionalItemView struct {
	name        string
	description string
	installed   bool
	selected    bool
}

func (i OptionalItemView) Title() string {
	prefix := "☐ "
	if i.selected {
		prefix = "☑ "
	}
	title := prefix + i.name
	if i.installed {
		title += " ✓"
	}
	return title
}

func (i OptionalItemView) Description() string {
	desc := i.description
	if i.installed {
		desc += " (already installed)"
	}
	return desc
}

func (i OptionalItemView) FilterValue() string { return i.name }

// OptionalView handles optional tool selection
type OptionalView struct {
	list   list.Model
	items  []OptionalItemView
	done   bool
	width  int
	height int
}

// NewOptionalView creates a new optional tool selection view
func NewOptionalView(cfg *models.Config, installed *models.InstalledInfo) *OptionalView {
	var items []OptionalItemView

	if tools, ok := cfg.Optional["tools"]; ok {
		for _, tool := range tools.Items {
			items = append(items, OptionalItemView{
				name:        tool.Name,
				description: tool.Description,
				installed:   installed.OptionalTools[tool.Name],
				selected:    tool.SelectedByDefault && !installed.OptionalTools[tool.Name],
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
	l.Title = "Select Optional Tools (Space to toggle)"
	l.SetShowStatusBar(false)
	l.SetFilteringEnabled(true)

	return &OptionalView{
		list:  l,
		items: items,
	}
}

// Update handles user input
func (v *OptionalView) Update(msg tea.Msg) ([]string, bool, tea.Cmd) {
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

// View renders the optional tools selection screen
func (v *OptionalView) View() string {
	var b strings.Builder
	b.WriteString(titleStyle.Render("Select Optional Tools"))
	b.WriteString("\n\n")
	b.WriteString(subtitleStyle.Render("Choose specialized tools (none selected by default):"))
	b.WriteString("\n\n")
	b.WriteString(v.list.View())
	b.WriteString("\n")
	b.WriteString(helpStyle.Render("Space: Toggle • Enter: Continue • /: Filter • Esc: Back"))
	return b.String()
}

// SetSize updates the view dimensions
func (v *OptionalView) SetSize(width, height int) {
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
