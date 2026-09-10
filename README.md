# dotfiles

My personal Mac setup, managed with nix-darwin and home-manager.
One repo, one command, and a fresh Mac ends up configured the same way every time.

Scope: **minimal and global**. This repo is for setting up NEW machines.
It declares only what belongs on every Mac I use - anything machine-specific
or occasional lives outside the repo (see "Extending" below). Architecture
and anti-drift design borrowed from
[kunchenguid/dotfiles](https://github.com/kunchenguid/dotfiles) - see
`docs/drift-plan.md` for the analysis.

## What a fresh machine gets

- System settings (dark mode, key repeat, dock, Finder, trackpad)
- Homebrew itself, plus a small declared set (full list in `configuration.nix`):
  - CLI: herdr, neovim, nvm, pyenv, zoxide, eza, bat, fd, ripgrep, fzf,
    jq, gh, lazygit, lazydocker, yazi, btop, cloc, yt-dlp, k9s, tuxedo
  - Apps: ghostty, wezterm, claude-code, hammerspoon, raycast, maccy, rectangle,
    monitorcontrol, Nerd Fonts
- Shell (zsh + oh-my-zsh plugins, starship prompt)
- Editor (kickstart-based Neovim config, plugin versions pinned by lazy-lock)
- Terminals (Ghostty and WezTerm: Matrix, Coolnight, and Catppuccin Macchiato colors, JetBrains Mono Nerd Font,
  Ctrl+A leader keys; Ghostty also has a Quake-style quick terminal)
- Hammerspoon hyper bindings (hyper key comes from Raycast)
- Agent configs (one `AGENTS.md` fanned out to Claude, Codex, opencode, and pi;
  Claude `settings.json` with herdr hooks)
- Git config (SSH signing, global ignores)

## Prerequisites

- Apple Silicon Mac, by default.
- Intel Mac: in `configuration.nix`, set `nixpkgs.hostPlatform = "x86_64-darwin";`.

## Fresh-machine setup

Full step-by-step, including the pre-flight (SSH key, Command Line Tools)
and the post-bootstrap manual finishes: `docs/new-machine-setup.md`.

```sh
git clone git@github.com:arhamj/dotfiles.git
cd dotfiles
./bootstrap.sh
```

`bootstrap.sh` does five things, in order:

1. Installs Determinate Nix, if it isn't already installed.
2. Symlinks this repo to `~/.dotfiles` (required: `home.nix` resolves config
   paths through it).
3. Checks the `user` in `flake.nix` against your macOS username and offers to
   fix it.
4. Fetches Hammerspoon's `SpoonInstall.spoon` if missing (gitignored; it
   bootstraps every other spoon at first Hammerspoon launch).
5. Runs the first `darwin-rebuild switch`.

On a machine with existing dotfiles, conflicting files are moved aside to
`<name>.hm-backup` automatically.

After the first switch, finish these by hand (none are declarable):

- **Raycast**: enable the hyper key (Hammerspoon's bindings depend on it)
- **Hammerspoon**: grant Accessibility and Screen Recording permissions
- **claude / herdr / pi / codex**: their own installers put them in
  `~/.local/bin` or via npm (the claude-code cask is a fallback)
- Sign into things, drop any secrets into `~/.config/zsh/secrets.zsh`

## Daily use

Edit files under `home/` in place - they ARE the live config, no rebuild
needed for symlinked files. You only run:

```sh
./rebuild.sh
```

when you change something that isn't a symlinked file: package lists, system
defaults, shell config (`home.nix`).

Check for drift any time:

```sh
./doctor.sh
```

It verifies every managed path is a symlink into this repo and diffs your
installed brews against `configuration.nix`.

## WezTerm

Press **Ctrl+A**, then **t** to cycle **Matrix -> Coolnight -> Catppuccin Macchiato -> Matrix**.
The switch applies to the current window, and Neovim running directly in WezTerm
follows the selected theme. Inside Herdr, Neovim follows Ghostty's config when
available, as described below.
Matrix is the default for new windows. Catppuccin uses WezTerm's built-in
Macchiato palette with the same opacity and blur as Coolnight.

Herdr uses its `terminal` theme so its UI and selection colors follow the host
palette too. Its **Ctrl+B** prefix remains separate from WezTerm's **Ctrl+A**.

## Ghostty

Launch Ghostty from Applications or Raycast. Its live config is
`home/.config/ghostty/config.ghostty`, linked to
`~/.config/ghostty/config.ghostty`. Edit it here and press `Cmd+Shift+,` to
reload. Configuration reference: <https://ghostty.org/docs/config>.

Ghostty uses the Catppuccin Macchiato palette, 15-point JetBrainsMono Nerd Font Mono,
a steady block cursor, 94% opacity, blur of 24, and a hidden title bar. It starts in
`~/projects`; subsequent windows and splits inherit the current directory.
Window layout and directories are restored on relaunch, but running processes
are not. Existing zsh, Starship, Atuin, aliases, and Neovim config load normally;
Neovim follows the theme selected in the Ghostty config. Neovim inside Herdr also
uses this config when available, since persistent panes can retain an old
WezTerm environment after switching terminal apps. Direct WezTerm sessions
continue to follow WezTerm's selected theme.

To switch themes, change `theme = Catppuccin Macchiato` to `theme = Matrix` or
`theme = Coolnight` in `home/.config/ghostty/config.ghostty`, then press
`Cmd+Shift+,`. All three palettes live under `home/.config/ghostty/themes/` and
match WezTerm's colors, opacity, and blur. The local Macchiato palette preserves
WezTerm's ANSI colors and cursor text, which differ from Ghostty's bundled theme.
Ghostty has no native theme-toggle action.

Press **Ctrl+backtick** to show or hide the quick terminal. It slides
down from the top, spans the screen width and half its height, follows the
active display and Space, and hides when it loses focus. Enable Ghostty in
**System Settings > Privacy & Security > Accessibility** when prompted so
the shortcut works from other apps. Ghostty must be running. The previous
Hammerspoon binding for WezTerm is commented out in `hyper_bindings.lua`.

Ghostty appears in the Dock and Cmd+Tab (`macos-hidden = never`). New regular
windows open maximized (`maximize = true`); the quick terminal keeps its
half-height drop-down layout.

After changing the title-bar style, reload the config and open a new window
(or restart Ghostty). Hidden title bars disable native macOS tabs, so new-tab
shortcuts open windows instead; use splits within the quick terminal.
Option-drag a window edge to move a titleless window.

| Shortcut | Action |
| --- | --- |
| `Ctrl+backtick` | Toggle the quick terminal globally |
| `Ctrl+A`, then `\|` / `-` | Split right / down |
| `Ctrl+A`, then `h` / `j` / `k` / `l` | Focus a split |
| `Ctrl+A`, then `z` / `x` / `c` | Zoom split / close split / new window |
| `Ctrl+A`, then `r`, then `h` / `j` / `k` / `l` | Resize one step |
| `Ctrl+A`, then `=` | Equalize splits |
| `Ctrl+A`, then `Escape` / `Ctrl+A` | Cancel leader / send literal Ctrl+A |
| `Cmd+N` / `Cmd+T` | New window |
| `Cmd+D` / `Cmd+Shift+D` | Split right / split down |
| `Cmd+F` / `Cmd+Shift+P` | Search scrollback / command palette |
| `Cmd+Ctrl+arrows` | Resize splits repeatedly |

Ghostty's leader sequences have no timeout. Repeat the full resize sequence
for each step, or use `Cmd+Ctrl+arrows`. Left Option acts as Alt for terminal
shortcuts; right Option remains available for typing special characters.

## Extending (the drift contract)

`cleanup` is deliberately `"none"`: rebuilds never uninstall anything, so
ad-hoc `brew install` on a given machine is safe. The deal is:

- **Machine-specific or trying something out** -> install freely. Shell lines
  for it go in `~/.config/zsh/local.zsh` (gitignored, sourced automatically).
- **Proven, want it everywhere** -> promote it: add the package to
  `configuration.nix` and any shell lines to `home.nix`, `./rebuild.sh`,
  commit. `doctor.sh` will keep reminding you about undeclared brews until
  you either promote or uninstall them.
- Tools you used to have but dropped are documented with copy-paste snippets
  in `docs/deferred-setup.md`.

## Secrets

Never commit secrets. `home.nix` sources `~/.config/zsh/secrets.zsh` if it
exists (the filename is gitignored).

## Repo tour

- `flake.nix` - entry point: nixpkgs (pinned), nix-darwin, home-manager, nix-homebrew.
- `configuration.nix` - system level: macOS defaults, Homebrew taps/brews/casks.
- `home.nix` - user level: zsh, starship, and every symlink described below.
- `bootstrap.sh` / `rebuild.sh` / `doctor.sh` - install / apply / verify.
- `home/` - the real config files, symlinked into place.
- `docs/` - new-machine walkthrough, deferred tool snippets, drift analysis.

## How the symlinks work

`home.nix` uses `mkOutOfStoreSymlink` to point paths like `~/.config/nvim`
straight at `home/.config/nvim` in this repo, so live config and git can never
drift - they are the same bytes. `~/.config/herdr/config.toml` is linked at
file level because herdr writes logs/sessions into that directory (gitignored).

`home/AGENTS.md` is the single agent policy file, symlinked to
`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.config/opencode/AGENTS.md`,
`~/.pi/agent/AGENTS.md`, and `~/AGENTS.md`.

## What is intentionally NOT managed here

- Anything not on the package lists - by design. Browsers, comms apps,
  work tooling: install per machine, promote later if they earn it.
- `~/.claude/hooks/` and `~/.pi/agent/extensions/` - installed and managed by
  herdr/superset themselves.
- `~/.agents/skills/` - managed by the skills installer (`.skill-lock.json`).
- `~/.pi/agent/settings.json` - mixes user config with runtime state.
- Hammerspoon `Spoons/` - downloaded at runtime by SpoonInstall.

## Notes

The first `nvim` launch on a fresh machine bootstraps lazy.nvim and plugins
from GitHub at the versions pinned in `lazy-lock.json` (needs network once).
