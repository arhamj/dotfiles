# Deferred Setup Snippets

Everything that was deliberately left out of the dotfiles, with the exact
lines to re-add when you actually need the tool again. Two ways to re-add:

- **One machine only**: put the lines in `~/.config/zsh/local.zsh`
  (gitignored, sourced automatically).
- **Every machine**: add the lines to `home.nix` (`initContent`) and the
  package to `configuration.nix`, then `./rebuild.sh` and commit.

## Android (with Android Studio)

```sh
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
```

## Flutter / Dart

```sh
export PATH="$HOME/development/flutter/bin:$PATH"
export PATH="$PATH:$HOME/.pub-cache/bin"
```

## Solana / crypto

```sh
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
export PATH="$PATH:$HOME/.foundry/bin"
```

## gcloud

Pick ONE installation method. The brew cask is the declarable one:
add `"google-cloud-sdk"` to casks in `configuration.nix`. If you keep the
manual home-folder install instead:

```sh
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi
```

## Antigravity

Its own installer re-adds the PATH line. Since home-manager makes `.zshrc`
read-only, put it in `local.zsh` yourself if the installer fails:

```sh
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
```

## Swift (swiftly)

```sh
. "$HOME/.swiftly/env.sh"
```

## Java (jenv + temurin)

Add `"jenv"` to brews and `"temurin@21"` to casks in `configuration.nix`,
then:

```sh
command -v jenv >/dev/null && eval "$(jenv init -)"
```

## Docker Desktop

Add `"docker-desktop"` to casks in `configuration.nix`. The CLI completions
then work via home-manager's compinit if you add to `initContentBeforeCompInit`:

```nix
initContentBeforeCompInit = ''
  fpath=(${config.home.homeDirectory}/.docker/completions $fpath)
'';
```

## Obsidian wiki path

```sh
export WIKI="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/wiki"
```

## Cursor alias

```sh
alias code="cursor"
```

## Notes

- **rye**: not coming back. The project was abandoned by its author in favor
  of `uv` (`brew install uv`).
- **coreutils / cmake**: deliberately excluded. Both install themselves as
  dependencies when something needs them; add only if you hit a script that
  requires GNU userland tools.
- **jiggler / hiddenbar**: removed by choice, not deferred.
