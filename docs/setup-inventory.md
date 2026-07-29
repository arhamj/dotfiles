# Setup Inventory: Global vs Work vs Leave-As-Is

Status: RESOLVED (2026-07-29). Kept for the record.

Final outcome: no profile split. One minimal global config for NEW machines
only; the machine this was captured from is left unmanaged. Promoted to
global beyond the original proposal: yazi, k9s, lazydocker, tuxedo, btop,
cloc, yt-dlp. Removed entirely: jiggler, hiddenbar, .stCommitMsg, ffmpeg
(dup), both gcloud casks. coreutils and cmake excluded (dependency-pulled
when needed). cleanup = "none" everywhere; doctor.sh is the drift alarm.
Everything else: `docs/deferred-setup.md`. Source of truth is now
`configuration.nix` + `home.nix`, not this file.

---

Original review document below.

## How to use: every config item on this machine is sorted into one of three
buckets by recommendation. Move items between buckets (edit this file or just
tell me the moves). When you sign off, I encode it:

- **GLOBAL** -> `configuration.nix` + `home.nix` (core). Lands on every machine
  you ever bootstrap: work, personal, future.
- **WORK** -> `hosts/work.nix`. Only this machine (and future work machines).
- **LEAVE AS IS** -> not declared anywhere. See the important note below.

## Important: what "leave as is" means for brew packages

For **manually installed** tools (Android SDK, flutter, gcloud's home-folder
install, antigravity, rye, solana) leave-as-is is truly neutral: the tool
stays on disk, its PATH lines leave the repo, and it works again the moment
you re-add two lines.

For **brew-installed** packages there is no neutral option if zap is on -
undeclared means uninstalled at the next rebuild. My recommendation given
your "never lose anything" rule: **start with `cleanup = "none"` on all
profiles** (rebuilds never uninstall anything) and let `doctor.sh` be the
drift alarm - it already diffs installed brews against the declarations.
Promote things into the repo deliberately, prune with `brew uninstall`
deliberately, and turn zap on for a profile later only once its declaration
has proven complete. (Open question 1 below.)

## Symlinked configs - all proposed GLOBAL

These cost nothing, install nothing, and define "your" environment on any
machine. If any feel work-specific, say so.

- WezTerm config (coolnight, random tab names, Ctrl+A leader)
- Neovim (vendored kickstart + lazy-lock pins)
- Hammerspoon (hyper bindings, mic mute, tailscale, audio watcher)
- herdr config.toml
- .gitconfig + .gitignore_global (see open question 4: work email)
- Claude settings.json (herdr hooks, fixed statusline)
- AGENTS.md fanned out to claude / codex / opencode / pi

Note: the Hammerspoon hyper bindings depend on Raycast's hyper key, so
Raycast is proposed as a GLOBAL cask below.

## macOS defaults - all proposed GLOBAL

Kun's set, already approved: dark mode, fast key repeat, menu bar autohide,
show all extensions, dock autohide, Finder list view, clean desktop,
tap-to-click.

## Shell config (home.nix)

### GLOBAL

- `brew shellenv` (zprofile) - PATH for everything brew installs
- `~/.local/bin` PATH - herdr, claude, cursor-agent, no-mistakes, hypa live here
- `EDITOR=nvim`
- starship prompt
- zoxide init + `cd=z`, `ls=eza --icons=always`
- oh-my-zsh plugins: git, web-search
- aliases: vi=nvim, clc, lg=lazygit, ld/lzd=lazydocker
- nvm init (pi itself runs on nvm node)
- pyenv init
- cargo env (guarded)
- go/bin PATH
- bun PATH (also a proposed global brew)
- `codex` alias with CODEX_HOME pin (encodes a real bug you already hit)
- `~/.config/zsh/secrets.zsh` hook (gitignored; machine-local secrets)
- `~/.config/zsh/local.zsh` hook (NEW: gitignored; machine-local PATH/exports
  - this is the escape hatch for anything machine-specific that should not
  be committed)

### WORK

- `code=cursor` alias (cursor is a work machine thing?)
- WIKI env var (iCloud Obsidian path - global instead if your personal Macs
  share the Apple ID)
- swiftly env (Swift toolchain - kept because xcodegen/iOS tooling suggests
  active use; move to leave-as-is if not)

### LEAVE AS IS (lines removed; tools stay on disk; re-add when needed)

- ANDROID_HOME + emulator + platform-tools (re-add with Android Studio)
- `.pub-cache/bin` (Dart - re-add with flutter)
- flutter bin PATH (untouched since May 2025)
- solana PATH (untouched since May 2025)
- foundry PATH (Dec 2025 - borderline, your call)
- antigravity PATH (its installer re-adds itself on reinstall)
- gcloud manual SDK lines (you also have TWO brew casks for gcloud - see
  casks below; keep at most one installation method)
- rye env (project abandoned by its author in favor of uv, which you have)
- docker completions fpath (Docker Desktop is not declared anywhere - see
  open question 3)
- `.stCommitMsg` commit template (the file is empty - either write a real
  template or drop the gitconfig line)

## Brew formulae

### GLOBAL (the "any machine" CLI set)

- herdr
- neovim
- nvm
- pyenv
- zoxide
- eza
- bat
- fd
- ripgrep
- fzf
- jq
- gh
- lazygit
- oven-sh/bun/bun

### WORK

- argocd
- awscli
- biome
- bitwarden-cli
- bookokrat
- btop
- cloc
- cmake
- coreutils
- d99kris/nchat/nchat
- ffmpeg-full (superset; drop plain ffmpeg)
- gammons/tap/slk
- glow
- gnu-sed
- helix
- helm
- htop
- imagemagick-full
- jenv (pairs with temurin@21 cask - move both to leave-as-is if JVM work
  is not current)
- just
- k9s
- lazydocker
- libpq
- mongosh
- nushell
- pnpm
- poppler
- protoc-gen-go
- rainfrog
- resvg
- sevenzip
- shellcheck
- tctl
- temporal
- terraform
- tuxedo
- watch
- xcodegen
- yazi
- yq
- yt-dlp

### LEAVE AS IS

- ffmpeg (redundant with ffmpeg-full)

## Brew casks

### GLOBAL

- wezterm
- hammerspoon
- raycast (hyper key dependency for Hammerspoon)
- claude-code (fallback for the ~/.local/bin install)
- font-meslo-lg-nerd-font (terminal font)
- font-symbols-only-nerd-font (nvim icons)
- maccy (clipboard)
- rectangle (window management)
- hiddenbar
- monitorcontrol
- notunes
- appcleaner
- aldente (battery)
- jiggler

(Quality-of-life OS utilities are in global on the theory that you would
want them on every Mac you own. Move to WORK if work-only.)

### WORK

- 1password-cli
- android-file-transfer
- arc
- arduino-ide
- brave-browser
- capcut
- chatgpt
- clocker
- conductor
- discord
- font-fira-code
- google-chrome
- handy
- headlamp
- localsend
- logi-options+
- mongodb-compass
- opensuperwhisper
- postman
- protonvpn
- redis-insight
- slack
- temurin@21
- webtorrent
- whatsapp

### LEAVE AS IS

- gcloud-cli (redundant with google-cloud-sdk cask + manual install)
- google-cloud-sdk (you have the manual install; pick one method when you
  next need gcloud)

## Open questions

1. **Zap policy** - recommendation: `cleanup = "none"` everywhere for now,
   doctor.sh as the alarm, opt into zap per-profile later. Agree?
2. **Profile names** - this machine becomes `work`. The abstract config is
   `minimal` (what a fresh personal MacBook would get). OK?
3. **Docker Desktop** - not installed via brew and not declared, but
   lazydocker + the completions line assume it. Add `docker-desktop` cask
   to WORK, or drop the assumption?
4. **Git identity on a work machine** - your gitconfig uses your personal
   GitHub noreply email and personal SSH signing key. If work repos should
   use a work email, the clean pattern is a gitconfig `includeIf
   gitdir:~/work/` block pointing at a gitignored work-specific file.
   Want that, or is personal identity fine everywhere?
5. **Fonts** - fira-code is in WORK but font-fira-code may be used by an
   editor theme somewhere. Keep in WORK or promote?

## After sign-off

I encode this as: core (`configuration.nix` + `home.nix`) = GLOBAL,
`hosts/work.nix` = WORK, deferred snippets documented in
`docs/deferred-setup.md` for copy-paste re-adding, `bootstrap.sh <profile>`
+ `.host` file so rebuilds remember which profile a machine is. One
reorganizing commit; nothing about how this machine runs changes until you
run bootstrap.
