---
title: Kun Chen Environment Setup Guide (Step by Step)
type: synthesis
created: 2026-07-29
updated: 2026-07-29
tags: [agentic-engineering, nix, dotfiles, dev-environment, reproducibility, guide]
sources: [kun-chen-dev-environment]
---

# Kun Chen Environment Setup Guide (Step by Step)

A step-by-step condensation of kun-chen-dev-environment (the 44-min from-a-fresh-Mac build). The guiding principle throughout is reproducibility: *everything* is declared in a git repo, so one command rebuilds the whole machine from any state. Reference implementation: Kun's public dotfiles (github.com/kunchenguid/dotfiles).

## Phase 0 - Prerequisites

Start from a fresh macOS install with only:
- Chrome, Git, and your GitHub SSH key set up

Everything else gets declared, never click-installed.

## Phase 1 - The reproducibility backbone (nix)

**Step 1: Install Determinate Nix.** Run the installer command from determinate.systems, then run its post-install command to refresh the shell environment. This is the *only* imperative install in the whole build.

**Step 2: Create the dotfiles repo + stable symlink.**
- Create a new git repo.
- Create a symlink at a **fixed location** (`~/dotfiles`) pointing at wherever you cloned the repo. Every script and config later references this stable path, so the clone location never matters.

**Step 3: nix-darwin for macOS system settings.**
- Copy the nix-darwin boilerplate into `flake.nix`; rename the default placeholders; **pin nixpkgs to a stable version** ("so we don't get surprises").
- Create `configuration.nix`: set `nix.enable = false` (Determinate already manages Nix), `allowUnfree`, your host platform (Apple Silicon vs Intel), primary user, and `stateVersion = 6` (set once, never touch).

**Step 4: First build + `rebuild.sh`.**
- Track everything in git (flakes require it), then run the darwin-rebuild command. The first build is slow.
- Create an executable `rebuild.sh` wrapping that command - from now on, applying any config change is `./rebuild.sh`.

**Step 5: Declare macOS preferences.** In `configuration.nix`, add system settings: dark theme, fast key repeat + short delay, autohide menu bar, always show file extensions, autohide dock, Finder list view, clean desktop, trackpad tap-to-click. (Full catalog is in the nix-darwin repo.) Rebuild; the dock immediately starts autohiding.

## Phase 2 - Package management with discipline

**Step 6: Homebrew *via* Nix (nix-homebrew).**
- Add nix-homebrew as a flake input + module in `flake.nix`.
- Add the homebrew block in `configuration.nix` with **`cleanup = "zap"`** - every rebuild *deletes* any brew package not declared in the config. Deliberate: ad-hoc `brew install` becomes self-defeating, forcing everything through the config so the system stays reproducible by construction.
- Declare casks here - start with WezTerm. Rebuild, verify with `brew --version`.

**Step 7: home-manager for the user level.**
- Add home-manager as flake input + module; wire `home.nix` to your username.
- Ensure `configuration.nix` sets the user's home directory correctly.
- Create `home.nix`: your username, and the key trick - **symlink each program's config dir into the repo** (e.g. `~/.config/wezterm` → `~/dotfiles/...`). Because the config dir is a symlink, runtime changes land in git automatically; system and repo can never drift.
- Declare user-level packages here - including **fonts** (Hack Nerd Font, no manual download) - and env vars (`EDITOR=nvim`). Rebuild.

## Phase 3 - Shell and terminal

**Step 8: zsh with the good stuff.** In `home.nix`: enable autosuggestions (ghost text from history), syntax highlighting, a `Ctrl+F` bind to accept suggestions, and your aliases. ("When I die, it's going to feel awesome knowing that these aliases gave me a few more hours of life.")

**Step 9: Starship prompt.** Another `home.nix` snippet: home-manager installs and configures Starship. Keep it simple; customize later.

**Step 10: WezTerm config.** Create `wezterm.lua` in the repo (already symlinked into place). It just returns a config object; WezTerm **hot-reloads on save**, so iterate live:
- Color scheme: Rosé Pine Moon
- Font: Hack Nerd Font, size 15
- Background opacity + blur, hide tab bar when single-tab, remove the window frame entirely

Kun's rationale: "if I enjoy the experience, I will stay focused more easily and end up doing better work."

## Phase 4 - Neovim (the diff-review station)

**Step 11: Scaffold modular config.** Create `~/.config/nvim` in the repo + symlink via home-manager. `init.lua` only `require`s other modules under `lua/`:
- `vim-config.lua` - sensible defaults: space as leader, tabs→spaces (2), current + relative line numbers (for `5k`-style jumps), smart case search, system clipboard, `scrolloff=16`, persistent undo.
- `plugins.lua` - lazy.nvim bootstrap, loading every file under `lua/plugins/`.

**Step 12: Plugins** (each a small file in `lua/plugins/`):
- `navigation.lua` - **snacks.nvim** (picker/notifier/input; `<leader>f` files, `<leader>s` grep, `<leader>b` buffers, `gd` definition) and **oil.nvim** (`<leader>e`; the file system as an editable buffer - copy lines to copy files, `dd` to delete, `:w` to apply).
- `git.lua` - **neogit** + **gitsigns** (line blame). Kun's framing: "with agentic engineering becoming my primary way of coding, the most common reason I come to Neovim is to quickly review diffs and manage the state of git." Note the `event = BufWinEnter` lazy-loading pattern.
- `ui.lua` - **which-key** (popup of available keys after `<leader>`).
- `keys.lua` - favorite binds: ESC saves the file (the save urge coincides with leaving insert mode), Ctrl+A select-all, and a fix for Vim's paste-replacement clobbering the clipboard.

(LSP/Treesitter deliberately skipped - covered by other videos.)

## Phase 5 - The agent layer

**Step 13: Herdr** (terminal multiplexer, "built in this agent era").
- Add as a brew (not cask) in `configuration.nix`.
- Create `config.toml` in the repo + symlink; Kun's is mostly tmux-compatible keybinds to preserve muscle memory from years of tmux.
- The payoff: the sidebar shows per-agent status (working/waiting), consistently across harnesses. Also possibly the only multiplexer that works on Windows.

**Step 14: Claude Code** (as the demo harness - the setup is deliberately agent-agnostic).
- Add the cask via brew config; symlink `~/.claude/settings.json` into the repo.
- One harness-specific customization: `/statusline` showing model name + % context used - this is what feeds Herdr's status display.

**Step 15: Global AGENTS.md.** One central memory file in the repo (`home/agents.md`); home-manager symlinks it into every agent's expected location (`~/.claude/CLAUDE.md`, plus Codex/OpenCode/Pi/Grok equivalents). "I want all my agents... to behave somewhat consistently and follow my rules." Kun's rules (see system-prompts): no em dashes; no agent co-author on commits; never hand-edit autogenerated files; **don't weight development cost in technical decisions** (agents inherit human-scale cost estimates from training data and wrongly prefer cheap, unscalable solutions); reproduce bugs E2E before fixing; pixel-perfect E2E testing; fix lint/test failures and flakiness even when unrelated.

## Phase 6 - Proof

**Step 16: Verify reproducibility.** From *any* machine state: fresh Mac → clone the repo → run `rebuild.sh` → the entire environment returns. That's the answer to the video's motivating question: "if my AI agent did something stupid and completely destroyed my system, can I recover it instantly?"

## The two design commitments

1. **Agent-agnosticism** - investment goes into layers that survive harness churn: terminal, multiplexer, editor, memory file. See agent-agnostic-setup.
2. **Reproducibility as agent-disaster insurance** - not convenience but recovery; the environment-level complement to adversarial-code-review at the code level. See reproducible-dev-environment.

## Where to go next

This guide is the substrate layer of the Kun Chen series. On top of it:
- **Workflow**: the David Ondrej interview - First Mate orchestration, no-mistakes, axi.
- **Concrete recipe**: the firstmate-herdr-pi-replication-guide builds the First Mate coordinator (Pi + Herdr + Treehouse) on exactly this substrate.
- **Application**: kun-chen-full-stack-app shows the whole stack exercised on one real build (Eddie's Wallet).

## Connections

- Related entities: kun-chen, nix, herdr, pi, first-mate
- Related concepts: reproducible-dev-environment, agent-agnostic-setup, system-prompts, agentic-engineering, agent-manager-pattern

## Sources

- kun-chen-dev-environment
