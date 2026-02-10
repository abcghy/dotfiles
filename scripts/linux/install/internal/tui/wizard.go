package tui

import (
	"arch-install/internal/models"
	"fmt"
	"os"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

// Wizard manages the entire installation wizard
type Wizard struct {
	config    *models.Config
	installed *models.InstalledInfo

	// State
	currentStep int
	result      *models.WizardResult
	quitting    bool
	width       int
	height      int

	// Views
	welcomeView  *WelcomeView
	presetView   *PresetView
	categoryView *CategoryView
	fontView     *FontView
	devEnvView   *DevEnvView
	optionalView *OptionalView
	confirmView  *ConfirmView
}

// RunWizard starts the TUI wizard and returns the user's selections
// Falls back to simple text-based wizard if TUI fails
func RunWizard(cfg *models.Config, installed *models.InstalledInfo) (*models.WizardResult, error) {
	// Try TUI first
	result, err := runTUIWizard(cfg, installed)
	if err != nil {
		// Fall back to simple wizard
		fmt.Fprintf(os.Stderr, "Note: Using simple text mode (TUI error: %v)\n", err)
		return RunSimpleWizard(cfg, installed)
	}
	return result, nil
}

func runTUIWizard(cfg *models.Config, installed *models.InstalledInfo) (*models.WizardResult, error) {
	w := &Wizard{
		config:      cfg,
		installed:   installed,
		currentStep: 0,
		result: &models.WizardResult{
			Categories:    []string{},
			Fonts:         []string{},
			OptionalTools: []string{},
			DevEnvs:       []string{},
			ExtraPackages: []string{},
		},
	}

	// Initialize views
	w.initViews()

	// Run the wizard with alt screen for full terminal coverage
	p := tea.NewProgram(w,
		tea.WithInput(os.Stdin),
		tea.WithOutput(os.Stdout),
		tea.WithAltScreen(),       // Use full terminal screen
		tea.WithMouseCellMotion(), // Enable mouse support
	)
	m, err := p.Run()
	if err != nil {
		return nil, err
	}

	finalWizard := m.(*Wizard)
	if finalWizard.quitting || finalWizard.result == nil {
		return nil, nil // User cancelled
	}

	return finalWizard.result, nil
}

func (w *Wizard) initViews() {
	w.welcomeView = NewWelcomeView()
	w.presetView = NewPresetView(w.config)
	w.categoryView = NewCategoryView(w.config, w.installed)
	w.fontView = NewFontView(w.config, w.installed)
	w.devEnvView = NewDevEnvView(w.config, w.installed)
	w.optionalView = NewOptionalView(w.config, w.installed)
	w.confirmView = NewConfirmView(w.result)
}

// Init implements tea.Model
func (w *Wizard) Init() tea.Cmd {
	return nil
}

// Update implements tea.Model
func (w *Wizard) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		// Track terminal size
		w.width = msg.Width
		w.height = msg.Height
		// Update all views with new size
		w.updateViewsSize(msg.Width, msg.Height)
		return w, nil

	case tea.KeyMsg:
		key := msg.String()

		// Global keys
		switch key {
		case "ctrl+c", "q":
			w.quitting = true
			w.result = nil
			return w, tea.Quit
		case "esc":
			if w.currentStep > 0 {
				w.currentStep--
				// Reinitialize confirm view with current result
				if w.currentStep == 6 {
					w.confirmView = NewConfirmView(w.result)
				}
				return w, nil
			}
		}

		// Route to current step
		switch w.currentStep {
		case 0:
			return w.updateWelcome(msg)
		case 1:
			return w.updatePreset(msg)
		case 2:
			return w.updateCategory(msg)
		case 3:
			return w.updateFont(msg)
		case 4:
			return w.updateDevEnv(msg)
		case 5:
			return w.updateOptional(msg)
		case 6:
			return w.updateConfirm(msg)
		}
	}

	// Also update current view for non-key messages
	switch w.currentStep {
	case 0:
		_, _ = w.welcomeView.Update(msg)
	case 1:
		_, _, _ = w.presetView.Update(msg)
	case 2:
		_, _, _ = w.categoryView.Update(msg)
	case 3:
		_, _, _ = w.fontView.Update(msg)
	case 4:
		_, _, _ = w.devEnvView.Update(msg)
	case 5:
		_, _, _ = w.optionalView.Update(msg)
	case 6:
		_, _ = w.confirmView.Update(msg)
	}

	return w, nil
}

// View implements tea.Model
func (w *Wizard) View() string {
	if w.quitting {
		return "Installation cancelled.\n"
	}

	var view string
	switch w.currentStep {
	case 0:
		view = w.welcomeView.View()
	case 1:
		view = w.presetView.View()
	case 2:
		view = w.categoryView.View()
	case 3:
		view = w.fontView.View()
	case 4:
		view = w.devEnvView.View()
	case 5:
		view = w.optionalView.View()
	case 6:
		view = w.confirmView.View()
	}

	// Add a small footer with progress
	progress := fmt.Sprintf("\n\n%s Step %d/7 - Press Ctrl+C to cancel",
		lipgloss.NewStyle().Foreground(lipgloss.Color("#666666")).Render("ℹ️"),
		w.currentStep+1)

	return view + progress
}

func (w *Wizard) updateWelcome(msg tea.Msg) (tea.Model, tea.Cmd) {
	done, cmd := w.welcomeView.Update(msg)
	if done {
		w.currentStep++
		return w, nil
	}
	return w, cmd
}

func (w *Wizard) updatePreset(msg tea.Msg) (tea.Model, tea.Cmd) {
	preset, done, cmd := w.presetView.Update(msg)
	if done {
		if preset == "custom" {
			w.currentStep++ // Go to category selection
		} else {
			// Apply preset
			w.applyPreset(preset)
			w.currentStep = 3 // Skip to font selection
		}
		return w, nil
	}
	return w, cmd
}

func (w *Wizard) updateCategory(msg tea.Msg) (tea.Model, tea.Cmd) {
	categories, done, cmd := w.categoryView.Update(msg)
	if done {
		w.result.Categories = categories
		w.currentStep++
		return w, nil
	}
	return w, cmd
}

func (w *Wizard) updateFont(msg tea.Msg) (tea.Model, tea.Cmd) {
	fonts, done, cmd := w.fontView.Update(msg)
	if done {
		w.result.Fonts = fonts
		w.currentStep++
		return w, nil
	}
	return w, cmd
}

func (w *Wizard) updateDevEnv(msg tea.Msg) (tea.Model, tea.Cmd) {
	envs, done, cmd := w.devEnvView.Update(msg)
	if done {
		w.result.DevEnvs = envs
		w.currentStep++
		return w, nil
	}
	return w, cmd
}

func (w *Wizard) updateOptional(msg tea.Msg) (tea.Model, tea.Cmd) {
	tools, done, cmd := w.optionalView.Update(msg)
	if done {
		w.result.OptionalTools = tools
		w.currentStep++
		// Update confirm view with final result
		w.confirmView = NewConfirmView(w.result)
		return w, nil
	}
	return w, cmd
}

func (w *Wizard) updateConfirm(msg tea.Msg) (tea.Model, tea.Cmd) {
	confirmed, cmd := w.confirmView.Update(msg)
	if confirmed {
		return w, tea.Quit
	}
	return w, cmd
}

func (w *Wizard) applyPreset(presetID string) {
	preset, ok := w.config.Presets[presetID]
	if !ok {
		return
	}

	w.result.Categories = preset.Categories
	w.result.Fonts = preset.FontSelections
	w.result.OptionalTools = preset.OptionalTools
	w.result.DevEnvs = preset.DevEnvs
	w.result.ExtraPackages = preset.ExtraPackages

	// Check if steam is included (needs multilib)
	for _, pkg := range preset.ExtraPackages {
		if pkg == "steam" {
			w.result.EnableMultilib = true
			break
		}
	}
}

// updateViewsSize updates all views with new terminal dimensions
func (w *Wizard) updateViewsSize(width, height int) {
	if w.presetView != nil {
		w.presetView.SetSize(width, height)
	}
	if w.categoryView != nil {
		w.categoryView.SetSize(width, height)
	}
	if w.fontView != nil {
		w.fontView.SetSize(width, height)
	}
	if w.devEnvView != nil {
		w.devEnvView.SetSize(width, height)
	}
	if w.optionalView != nil {
		w.optionalView.SetSize(width, height)
	}
}

// Styles for the TUI (Light Mode)
var (
	titleStyle = lipgloss.NewStyle().
			Bold(true).
			Foreground(lipgloss.Color("#0066CC")).
			MarginLeft(2).
			MarginTop(1)

	subtitleStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#666666")).
			MarginLeft(2)

	itemStyle = lipgloss.NewStyle().
			PaddingLeft(4)

	selectedItemStyle = lipgloss.NewStyle().
				PaddingLeft(2).
				Foreground(lipgloss.Color("#0066CC")).
				Bold(true)

	descriptionStyle = lipgloss.NewStyle().
				Foreground(lipgloss.Color("#444444")).
				PaddingLeft(6)

	installedStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#008800"))

	checkStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#008800"))

	uncheckStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#666666"))

	helpStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#444444")).
			MarginTop(1)
)
