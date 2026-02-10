package tui

import (
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

// WelcomeView is the first step of the wizard
type WelcomeView struct {
	done bool
}

// NewWelcomeView creates a new welcome view
func NewWelcomeView() *WelcomeView {
	return &WelcomeView{}
}

// Update handles user input
func (v *WelcomeView) Update(msg tea.Msg) (bool, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.String() {
		case "enter", " ", "y", "Y":
			v.done = true
			return true, nil
		}
	}
	return false, nil
}

// View renders the welcome screen
func (v *WelcomeView) View() string {
	content := titleStyle.Render("🚀 Arch Linux Installation Wizard") + "\n\n"
	content += subtitleStyle.Render("Welcome to the interactive Arch Linux package installer!") + "\n\n"

	content += itemStyle.Render("This wizard will help you install:") + "\n"
	content += descriptionStyle.Render("• Essential system tools and utilities") + "\n"
	content += descriptionStyle.Render("• Development environments and tools") + "\n"
	content += descriptionStyle.Render("• Fonts for proper text display") + "\n"
	content += descriptionStyle.Render("• Entertainment and productivity applications") + "\n\n"

	content += itemStyle.Render("Features:") + "\n"
	content += descriptionStyle.Render("✓ Intelligent detection of already installed software") + "\n"
	content += descriptionStyle.Render("✓ Multiple presets for different use cases") + "\n"
	content += descriptionStyle.Render("✓ Customizable package selection") + "\n"
	content += descriptionStyle.Render("✓ Automatic yay installation if needed") + "\n\n"

	content += lipgloss.NewStyle().
		Foreground(lipgloss.Color("#0066CC")).
		PaddingLeft(2).
		Render("Press Enter to continue or Ctrl+C to exit")

	return content
}
