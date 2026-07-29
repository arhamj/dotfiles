# dotfiles

My personal Mac setup, managed with nix-darwin and home-manager.
One repo, one command, and a fresh Mac ends up configured the same way every time.

Architecture and anti-drift design borrowed from
[kunchenguid/dotfiles](https://github.com/kunchenguid/dotfiles) - see
`DRIFT-PLAN.md` for the drift analysis that motivated this structure and
`kun-chen-environment-setup-guide.md` for the original guide.

## What you get

Running the switch builds:

- System settings (dark mode, key repeat, dock, Finder, trackpad)
- Homebrew apps (casks and CLI tools), with `cleanup = "zap"`: anything not
  declared in `configuration.nix` gets uninstalled on every switch
- Shell (zsh + oh-my-zsh plugins, starship prompt, zoxide/eza, all PATH setup)
- Editor (kickstart-based Neovim config, vendored)
- Terminal (WezTerm: coolnight colors, random tab names, Ctrl+A leader keys)
- Window/automation layer (Hammerspoon hyper bindings, hyper key via Raycast)
- Agent configs (one `AGENTS.md` fanned out to Claude, Codex, opencode, and pi;
  Claude `settings.json` with herdr hooks)
- Git config (SSH signing, global ignores, commit template)

## Prerequisites

- Apple Silicon Mac, by default.
- Intel Mac: in `configuration.nix`, set `nixpkgs.hostPlatform = "x86_64-darwin";`.

## Fresh-machine setup

On a brand new Mac, from a bare clone:

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

### Homebrew cleanup warning

`configuration.nix` sets `homebrew.onActivation.cleanup = "zap"`: every switch
removes any brew package not listed in `brews`/`casks`. That is deliberate -
it makes ad-hoc `brew install` self-defeating so everything gets declared.
If something you want disappears, add it to `configuration.nix`.

## Daily use

Edit the config files under `home/` in place - they ARE your live config, no
rebuild needed for symlinked files (WezTerm hot-reloads, nvim reads on next
launch). You only run:

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

## Repo tour

- `flake.nix` - entry point: nixpkgs (pinned), nix-darwin, home-manager, nix-homebrew.
- `configuration.nix` - system level: macOS defaults, Homebrew taps/brews/casks.
- `home.nix` - user level: zsh, starship, and every symlink described below.
- `bootstrap.sh` / `rebuild.sh` / `doctor.sh` - install / apply / verify.
- `home/` - the real config files, symlinked into place.

## How the symlinks work

`home.nix` uses `mkOutOfStoreSymlink` to point paths like `~/.config/nvim`
straight at `home/.config/nvim` in this repo, so live config and git can never
drift - they are the same bytes. `~/.config/herdr/config.toml` is linked at
file level because herdr writes logs/sessions into that directory (gitignored).

`home/AGENTS.md` is the single agent policy file, symlinked to
`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.config/opencode/AGENTS.md`,
`~/.pi/agent/AGENTS.md`, and `~/AGENTS.md`.

## Secrets

Never commit secrets. `home.nix` sources `~/.config/zsh/secrets.zsh` if it
exists (the filename is gitignored). Put tokens and client secrets there.

## What is intentionally NOT managed here

- `herdr` and `claude` also self-install to `~/.local/bin` (which wins on
  PATH); the brew/cask entries are the fresh-machine fallback.
- `~/.claude/hooks/` and `~/.pi/agent/extensions/` - installed and managed by
  herdr/superset themselves.
- `~/.agents/skills/` - managed by the skills installer (`.skill-lock.json`).
- `~/.pi/agent/settings.json` - mixes user config with runtime state.
- Hammerspoon `Spoons/` - downloaded at runtime by SpoonInstall.

## Notes

The first `nvim` launch on a fresh machine bootstraps lazy.nvim and plugins
from GitHub (needs network once). Hammerspoon needs Accessibility and
Screen Recording permissions after first launch.
