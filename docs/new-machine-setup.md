# New Machine Setup

From unboxing to fully working environment. Assumes a fresh macOS install.

## 0. Before anything (5 minutes, manual)

- Sign into iCloud / Apple ID if you use it
- Install Command Line Tools (git needs it): `xcode-select --install`
- Set up your GitHub SSH key (`~/.ssh/id_ed25519`) - needed to clone and
  for commit signing

## 1. Clone and bootstrap

```sh
git clone git@github.com:arhamj/dotfiles.git
cd dotfiles
./bootstrap.sh
```

One script, five steps: installs Determinate Nix, symlinks the repo to
`~/.dotfiles`, checks the username in `flake.nix`, fetches Hammerspoon's
SpoonInstall, runs the first `darwin-rebuild switch`. The first build is
slow (downloads brew + all packages). Grab coffee.

## 2. Manual finishes (none of these are declarable)

- **Open a new terminal** - starship prompt, aliases, and PATH come alive
- **Raycast**: launch it, sign in / set it up, and **enable the hyper key**
  (caps lock -> cmd+ctrl+alt+shift). Hammerspoon's bindings are dead without it
- **Hammerspoon**: launch it, grant Accessibility and Screen Recording
  permissions when prompted, then reload config (or it auto-loads)
- **Agent harnesses**: install their native selves - claude and herdr
  self-install to `~/.local/bin`, pi and codex via npm.
- **Secrets**: create `~/.config/zsh/secrets.zsh` with any tokens
  (gitignored, sourced automatically)
- **Machine-specific extras**: create `~/.config/zsh/local.zsh` if this
  machine needs PATH lines or exports that don't belong in the repo
  (gitignored, sourced automatically)
- **nvim**: first launch bootstraps lazy.nvim and installs plugins from
  GitHub at the pinned `lazy-lock.json` versions (needs network, once)
- Sign into browsers, 1Password, etc. - whatever this machine needs beyond
  the declared set, install freely (rebuilds never uninstall anything)

## 3. Verify

```sh
./doctor.sh
```

Should print `no drift detected` (brew lines about anything you installed
beyond the declared set are expected - those are the promote-or-prune
reminders, see README "Extending").

Spot-check the symlinks are live:

- Edit `home/.wezterm.lua` (e.g. change `font_size`), save - WezTerm
  hot-reloads instantly, and `git status` shows the change
- `echo 'alias t="date"' >> home/AGENTS.md` is visible to every agent
  harness... then revert it :)

## 4. Daily workflow

- Edit anything under `home/` - it's live immediately, no rebuild
- Changed packages, system defaults, or shell config? `./rebuild.sh`
- `doctor.sh` nags you about undeclared brews: promote them into
  `configuration.nix` (commit) or `brew uninstall` them
- Old tools you might want back: `docs/deferred-setup.md` has copy-paste
  snippets
