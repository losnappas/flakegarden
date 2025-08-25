package cli

import (
	"os"

	"github.com/charmbracelet/bubbles/list"
	tea "github.com/charmbracelet/bubbletea"
	"golang.org/x/term"
)

// pickModules launches an interactive multi-select picker using Bubble Tea.
func pickModules(names []string) ([]string, error) {
	// Very small custom selector to avoid heavy dependencies if term not available
	// Fall back to simple prompt via STDIN: comma-separated.
	if !term.IsTerminal(int(os.Stdin.Fd())) || !term.IsTerminal(int(os.Stdout.Fd())) {
		return []string{}, nil
	}

	return teaMultiSelect(names)
}

type multiModel struct {
	list   list.Model
	chosen map[int]bool
}

type stringItem string

func (s stringItem) Title() string       { return string(s) }
func (s stringItem) Description() string { return "" }
func (s stringItem) FilterValue() string { return string(s) }

func teaMultiSelect(items []string) ([]string, error) {
	var litems []list.Item
	for _, n := range items {
		litems = append(litems, stringItem(n))
	}
	l := list.New(litems, list.NewDefaultDelegate(), 0, 0)
	l.Title = "Select modules (space to toggle, enter to confirm)"
	m := multiModel{list: l, chosen: map[int]bool{}}
	p := tea.NewProgram(m, tea.WithOutput(os.Stdout))
	res, err := p.Run()
	if err != nil {
		return nil, err
	}
	mm := res.(multiModel)
	var picked []string
	for i, it := range mm.list.Items() {
		if mm.chosen[i] {
			t := it.FilterValue()
			picked = append(picked, t)
		}
	}
	return picked, nil
}

func (m multiModel) Init() tea.Cmd { return nil }

func (m multiModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.list.SetSize(msg.Width, msg.Height)
	case tea.KeyMsg:
		switch msg.String() {
		case "esc", "ctrl+c", "ctrl-g":
			return m, tea.Quit
		case " ":
			idx := m.list.Index()
			m.chosen[idx] = !m.chosen[idx]
			return m, nil
		case "enter":
			return m, tea.Quit
		}
	}
	var cmd tea.Cmd
	m.list, cmd = m.list.Update(msg)
	return m, cmd
}

func (m multiModel) View() string {
	// Mark selected items
	items := m.list.Items()
	var marked []list.Item
	for i, it := range items {
		title := it.FilterValue()
		if m.chosen[i] {
			title = "[x] " + title
		} else {
			title = "[ ] " + title
		}
		marked = append(marked, stringItem(title))
	}
	old := m.list.Items()
	m.list.SetItems(marked)
	out := m.list.View()
	m.list.SetItems(old)
	return out
}
