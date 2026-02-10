package tui

import (
	"arch-install/internal/models"
	"strings"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

// ConfirmView displays the final confirmation screen
type ConfirmView struct {
	result    *models.WizardResult
	confirmed bool
}

// NewConfirmView creates a new confirmation view
func NewConfirmView(result *models.WizardResult) *ConfirmView {
	return &ConfirmView{
		result: result,
	}
}

// Update handles user input
func (v *ConfirmView) Update(msg tea.Msg) (bool, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.String() {
		case "y", "Y":
			v.confirmed = true
			return true, tea.Quit
		case "n", "N", "q":
			return false, tea.Quit
		}
	}
	return false, nil
}

// View renders the confirmation screen
func (v *ConfirmView) View() string {
	var b strings.Builder

	b.WriteString(titleStyle.Render("📋 Installation Summary"))
	b.WriteString("\n\n")

	b.WriteString(subtitleStyle.Render("The following will be installed:"))
	b.WriteString("\n\n")

	// Categories
	if len(v.result.Categories) > 0 {
		b.WriteString(itemStyle.Render("📁 Categories:"))
		b.WriteString("\n")
		for _, cat := range v.result.Categories {
			b.WriteString(descriptionStyle.Render("  • " + cat))
			b.WriteString("\n")
		}
		b.WriteString("\n")
	}

	// Fonts
	if len(v.result.Fonts) > 0 {
		b.WriteString(itemStyle.Render("🔤 Fonts:"))
		b.WriteString("\n")
		for _, font := range v.result.Fonts {
			b.WriteString(descriptionStyle.Render("  • " + font))
			b.WriteString("\n")
		}
		b.WriteString("\n")
	}

	// Development Environments
	if len(v.result.DevEnvs) > 0 {
		b.WriteString(itemStyle.Render("⚙️  Development Environments:"))
		b.WriteString("\n")
		for _, env := range v.result.DevEnvs {
			b.WriteString(descriptionStyle.Render("  • " + env))
			b.WriteString("\n")
		}
		b.WriteString("\n")
	}

	// Optional Tools
	if len(v.result.OptionalTools) > 0 {
		b.WriteString(itemStyle.Render("🛠️  Optional Tools:"))
		b.WriteString("\n")
		for _, tool := range v.result.OptionalTools {
			b.WriteString(descriptionStyle.Render("  • " + tool))
			b.WriteString("\n")
		}
		b.WriteString("\n")
	}

	// Extra Packages
	if len(v.result.ExtraPackages) > 0 {
		b.WriteString(itemStyle.Render("📦 Extra Packages:"))
		b.WriteString("\n")
		for _, pkg := range v.result.ExtraPackages {
			b.WriteString(descriptionStyle.Render("  • " + pkg))
			b.WriteString("\n")
		}
		b.WriteString("\n")
	}

	// Multilib notice
	if v.result.EnableMultilib {
		b.WriteString(itemStyle.Render("⚠️  Note: Will enable multilib repository for Steam"))
		b.WriteString("\n\n")
	}

	// Confirmation prompt
	b.WriteString(lipgloss.NewStyle().
		Bold(true).
		Foreground(lipgloss.Color("#0066CC")).
		PaddingLeft(2).
		Render("Proceed with installation? [Y/n] "))

	b.WriteString("\n\n")
	b.WriteString(helpStyle.Render("Y: Yes • n: No/Cancel"))

	return b.String()
}
