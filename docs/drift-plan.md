# Dotfiles Drift Analysis and Rebuild Plan

Date: 2026-07-29
Goal: turn this repo into a clone-and-run setup for a fresh MacBook, with drift
impossible by construction. Input: kun-chen-environment-setup-guide.md and
github.com/kunchenguid/dotfiles as the reference architecture.

---

## 1. Current state: what this repo is vs what your Mac actually runs

The repo is a one-time dump ("Initial dotfile dump", July 6) of four things:
`.tmux.conf`, `.wezterm.lua`, `.hammerspoon/`, `.config/nvim/`. Nothing in it
is symlinked, installed, or referenced by the live system. It is a snapshot,
not a system. Every file has drifted since, some catastrophically.

### Drift report (repo vs live)

| Area | Repo has | Live system has | Drift |
|---|---|---|---|
| tmux | `.tmux.conf` | Identical file, but tmux is **dead** - you use Herdr | Config matches, tool abandoned. Dead weight. |
| Herdr | nothing | `~/.config/herdr/config.toml` (onboarding done, agent panel sort, pane border labels) | **Untracked entirely.** Your daily multiplexer is not in the repo at all. |
| WezTerm | stale copy (font size 19, tab bar off, WebGpu, blur 10) | Random-word tab titles, tmux-style leader (`Ctrl+A`) with split/pane keys, opacity 0.94, blur 24, MesloLGS Nerd Font Mono 15, padding, 10k scrollback, SteadyBar cursor | **Heavily drifted.** Live file is a superset with real daily config the repo lacks. |
| Neovim | Old custom config (packer-era, `lua/arhamj/...`, mason/null-ls/lspsaga) | A **separate git clone of kickstart.nvim** with its own remote, one 42KB `init.lua`, own lazy-lock | **Total replacement.** The repo's nvim config is abandoned; the live one is an uncommitted fork of upstream. |
| Hammerspoon | July 6 snapshot | Live loads `audio_watcher` + `tailscale` (repo loads `tunnelblick` + `pomodoro` instead), has new `tailscale.lua`, modified `audio_watcher`, `hyper_bindings`, `mic_mute`, `README`, plus runtime `Spoons/` | **Drifted.** Live is the truth; repo is stale. |
| Shell (zsh) | nothing | oh-my-zsh + powerlevel10k + p10k.zsh, zoxide/eza aliases, nvm/pyenv/bun/flutter/android/go/gcloud PATH soup, **hardcoded Bitwarden client secret** | **Untracked entirely** - and contains a secret that must never be committed. |
| zprofile / zshenv | nothing | brew shellenv, rye, swiftly, cargo, foundry | Untracked. |
| Git | nothing | `~/.gitconfig` with SSH signing, commit template, global gitignore | Untracked. |
| Karabiner | nothing | caps_lock -> hyper (cmd+ctrl+alt+shift), which your Hammerspoon `HYPER` bindings depend on | Untracked. Without it, Hammerspoon bindings are dead on a new Mac. |
| Agent layer | nothing | `~/AGENTS.md` (your global rules), symlinked **only** to `~/.claude/CLAUDE.md`; `~/.codex/AGENTS.md` is an **empty file**; opencode and pi get nothing global | Partially wired, broken for Codex, absent for pi/opencode. |
| Claude Code | nothing | Rich `settings.json`: herdr + superset hooks, axi SessionStart hooks, model pin, effortLevel, plugins, statusline pointing at **`~/.claude/statusline-command.sh` which does not exist** | Untracked, and contains a **broken statusline reference** (silent bug today). |
| pi | nothing | `settings.json` (provider/model/theme), extensions (`herdr-agent-state.ts`, `superset-hooks.ts`) | Untracked. |
| Packages | nothing | 57 brew leaves + 46 casks installed ad hoc | Undeclared. No way to reproduce. |
| macOS defaults | nothing | Whatever was clicked in System Settings over the years | Undeclared. |
| Nix | nothing | Not installed | The entire reproducibility backbone from the guide was never adopted. |

### What has NOT drifted

- `.tmux.conf` is byte-identical - but only because nothing uses it.
- The core Hammerspoon modules (hyper_bindings, hold_to_quit, ping, reload_config) still match their intent; only the load list and a few files changed.
- `~/AGENTS.md` content is stable and already symlinked into Claude correctly. The pattern works; it just was never extended.

### Why it drifted (root cause)

The repo is **copies, not sources**. Editing `~/.wezterm.lua` edits a file
git cannot see. There is no install step, no symlink, no package declaration,
no system-settings declaration, and no enforcement. Drift was not a risk; it
was guaranteed. Kun's guide predicted exactly this and solves it with two
mechanisms we should adopt verbatim.

---

## 2. What Kun's repo does that kills drift (and what we take from it)

1. **nix-darwin + home-manager + nix-homebrew, pinned nixpkgs.** macOS
   defaults, brew packages, user packages, shell, prompt - all declared in
   `configuration.nix` / `home.nix`. One `./rebuild.sh` applies everything.
2. **`homebrew.onActivation.cleanup = "zap"`.** Every rebuild *deletes* any
   brew package not declared. Ad-hoc `brew install` becomes self-defeating,
   so everything gets declared. This is enforcement, not discipline.
3. **`mkOutOfStoreSymlink`.** `~/.config/nvim` *is* `home/.config/nvim` in
   the repo. Editing live config edits the git-tracked file. Repo and system
   cannot drift because they are the same bytes.
4. **One `AGENTS.md` fanned out by symlink** to every harness
   (Claude/Codex/opencode/pi), so agent policy is single-sourced.
5. **`bootstrap.sh`**: fresh Mac -> clone -> one script installs Determinate
   Nix, symlinks the repo to a stable path (`~/.dotfiles`), personalizes the
   username, runs first switch. **`rebuild.sh`** for every change after.
6. **`.gitignore` for runtime artifacts** (herdr logs/session/sock) so a
   symlinked config dir does not pollute git.

Architecture is config-agnostic: we keep your actual preferences (coolnight
colors, p10k or starship, kickstart nvim, Hammerspoon setup) and pour them
into Kun's structure.

---

## 3. The rebuild plan

New repo layout (mirrors Kun, adapted):

```
dotfiles/
  flake.nix            # entry point: nixpkgs (pinned), nix-darwin, home-manager, nix-homebrew
  flake.lock           # pinned revisions - commit it
  configuration.nix    # macOS defaults + homebrew (brews/casks, cleanup="zap")
  home.nix             # user packages, zsh, git, env, all symlinks
  bootstrap.sh         # fresh Mac -> working system, one command
  rebuild.sh           # apply any change
  doctor.sh            # (new, optional) verify symlinks + report undeclared brews
  home/
    .wezterm.lua            # your live config (random tab names, leader keys, coolnight)
    .hammerspoon/           # live config, Spoons/ gitignored
    .config/
      nvim/                 # your kickstart fork, vendored (upstream .git removed)
      herdr/config.toml     # only this file; logs/session gitignored
      karabiner/karabiner.json
    .claude/settings.json   # cleaned (see below)
    .zshrc, .zprofile, .zshenv  # sanitized (see below)
    .gitconfig, .gitignore_global
    .p10k.zsh
    AGENTS.md               # your global rules, single source
  .gitignore           # herdr runtime artifacts, Spoons/, result, .DS_Store, secrets
```

### Phase 1 - Re-structure and capture the live truth (no behavior change)

1. Restructure repo to the layout above; delete `.tmux.conf` and the stale
   `.config/nvim` (arhamj/packer config) and stale `.wezterm.lua`.
2. Copy live -> repo: `.wezterm.lua`, `.hammerspoon/`, herdr `config.toml`,
   karabiner.json, `.gitconfig`, `.gitignore_global`, `.p10k.zsh`.
3. Vendor the kickstart nvim fork: copy `~/.config/nvim` into
   `home/.config/nvim`, remove its `.git` (kickstart is designed to be
   forked; keeping the upstream remote inside your dotfiles is what made it
   invisible to this repo). Keep its lazy-lock.json.
4. Move `~/AGENTS.md` to `home/AGENTS.md`.

### Phase 2 - Secrets and broken bits (do before anything is committed/pushed)

5. **Remove the Bitwarden `BW_CLIENTID`/`BW_CLIENTSECRET` from `.zshrc`.**
   Replace with an untracked `~/.config/zsh/secrets.zsh` sourced if present,
   gitignored. (Also consider rotating that secret; it has lived in
   plaintext and shell history.)
6. Fix the broken Claude statusline: either commit a
   `statusline-command.sh` into the repo or point the setting at an
   existing command (Kun's jq one-liner is a good drop-in).
7. Sanitize `.zshrc`: keep aliases, zoxide/eza init, and the tool PATHs you
   actually use; drop dead entries (`.rye` is gone, duplicated pyenv lines,
   duplicate PATH exports).

### Phase 3 - Nix backbone (adopt from Kun, adjusted)

8. Copy `flake.nix`, `bootstrap.sh`, `rebuild.sh` from Kun's repo; set
   `user = "arhmjn"`, host label `mac`.
9. `configuration.nix`: adopt his macOS defaults block (verify each against
   your taste - dock autohide, key repeat, tap-to-click, Finder list view),
   plus your homebrew declaration: port all 57 brew leaves and 46 casks you
   want to keep, pruned (e.g. drop `tmux`; keep `hammerspoon`,
   `karabiner-elements`, `wezterm`, `font-meslo-lg-nerd-font`, `raycast`,
   etc.). **Because of `cleanup = "zap"`, anything not listed gets
   uninstalled on first switch** - so this list must be complete before
   running bootstrap. We will generate it from `brew leaves` + `brew list
   --cask` so nothing is lost.
10. `home.nix`:
    - packages: keep yours brew-based where casks/GUI, add nix CLI tools if
      you want them managed there (ripgrep/fd/fzf/jq already exist as brew;
      pick one manager per tool to avoid duplicates - recommendation: leave
      brew as the single package manager for now, use home-manager only for
      symlinks/shell/git. Simpler, same anti-drift guarantee).
    - zsh: either keep oh-my-zsh+p10k (home-manager can manage both) or
      switch to starship (Kun's choice, far less machinery). **Decision
      needed - recommendation: keep p10k for now, migrate later.**
    - symlinks via `mkOutOfStoreSymlink` for every `home/` path, including:
      - `~/.wezterm.lua`, `~/.hammerspoon`, `~/.config/nvim`,
        `~/.config/karabiner`, `~/.gitconfig`, `~/.p10k.zsh`
      - `~/.config/herdr/config.toml` (file-level, not the dir - herdr
        writes logs/session there)
      - `~/.claude/settings.json`
    - AGENTS.md fan-out: `~/.claude/CLAUDE.md` (replaces your manual
      symlink), `~/.codex/AGENTS.md` (**fixes the empty file**),
      `~/.config/opencode/AGENTS.md`, `~/.pi/agent/AGENTS.md`.
    - git: declare user/email/ssh-signing in `programs.git` or symlink
      `.gitconfig` (recommendation: symlink, since it already exists and is
      machine-agnostic except the signing key path, which is standard).

### Phase 4 - Prove it

11. Run `./bootstrap.sh` on this Mac. First switch will zap undeclared
    brews - we review the generated list together first.
12. Verify: edit `home/.wezterm.lua` -> WezTerm hot-reloads (proves the
    symlink direction); `git status` shows the edit (proves trackability).
13. The real acceptance test, when you get the new MacBook: clone, run
    `./bootstrap.sh`, and the whole environment - Hammerspoon hyper keys,
    Herdr, WezTerm, kickstart nvim, agent rules - comes back.

---

## 4. How drift stays dead after this

| Mechanism | Kills which drift |
|---|---|
| `mkOutOfStoreSymlink` for every config | Live edits land in git automatically; "forgot to copy back" becomes impossible. `git status` *is* the drift detector. |
| `cleanup = "zap"` on every rebuild | Undeclared brew installs self-destruct, forcing declaration. |
| Single AGENTS.md fan-out | Agent rules can never diverge between harnesses (Codex's empty file bug class is gone). |
| `flake.lock` + pinned nixpkgs | No surprise upstream changes; upgrades are deliberate (`nix flake update`). |
| `bootstrap.sh` / `rebuild.sh` | One command each way; no manual steps to forget. |
| `doctor.sh` (optional extra Kun doesn't have) | Verifies symlinks resolve into the repo and diffs `brew leaves` against `configuration.nix` - a cheap alarm for anything the construction missed. |
| Runtime artifacts gitignored | herdr logs/sessions, Hammerspoon Spoons, lazy-lock churn never dirty the repo. |

## 5. Decisions (resolved 2026-07-29)

1. **Shell prompt**: switch to starship. oh-my-zsh stays only for its plugin
   aliases (git, web-search); powerlevel10k and `~/.p10k.zsh` are dropped.
2. **Neovim**: vendor the kickstart fork into `home/.config/nvim` (upstream
   `.git` removed).
3. **Package pruning**: declared in `configuration.nix`. Pruned: `tmux`
   (dead - Herdr replaced it), `warp` (WezTerm won), `battery-toolkit`
   (untrusted third-party tap, redundant with AlDente). Everything else from
   `brew leaves` / `brew list --cask` carried over, plus `herdr` and
   `claude-code` as fresh-machine fallbacks for the `~/.local/bin` installs.
4. **Bitwarden secret**: removed from `.zshrc` by hand; shell now sources
   untracked `~/.config/zsh/secrets.zsh` (gitignored) for machine-local secrets.
5. **macOS defaults**: Kun's set adopted wholesale.
6. **`.dotfiles` stable path**: yes - repo symlinks to `~/.dotfiles` via
   `bootstrap.sh`/`rebuild.sh` while living in `~/projects/personal/dotfiles`.

Implementation: Phase 1 (restructure + live capture) and Phase 3 (nix
backbone) are committed. Phase 4 (bootstrap + verify) is run by the user
since it needs sudo.
