{ config, lib, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";

  home.sessionVariables.EDITOR = "nvim";

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid

    # oh-my-zsh stays for its plugin aliases (git, web-search);
    # the prompt comes from starship, so no omz theme.
    oh-my-zsh = {
      enable = true;
      theme = "";
      plugins = [ "git" "web-search" ];
    };

    shellAliases = {
      ls = "eza --icons=always";
      cd = "z";
      vi = "nvim";
      clc = "clear";
      code = "cursor";
      lg = "lazygit";
      ld = "lazydocker";
      lzd = "lazydocker";
      # Hand-run codex stays on the API-key home (fleet-dispatched codex gets
      # the same pin from firstmate's config/codex-home). An alias, not an
      # export: a global CODEX_HOME leaks into the ChatGPT desktop app, which
      # then adopts the API-key home instead of the ChatGPT account.
      codex = ''CODEX_HOME="$HOME/.codex-cli" codex'';
    };

    # .zshrc, before compinit
    initContentBeforeCompInit = ''
      # Docker CLI completions
      fpath=(${config.home.homeDirectory}/.docker/completions $fpath)
    '';

    # .zshrc body
    initContent = ''
      # nvm
      export NVM_DIR="$HOME/.nvm"
      [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
      [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

      # pyenv
      export PYENV_ROOT="$HOME/.pyenv"
      [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
      command -v pyenv >/dev/null && eval "$(pyenv init -)"

      # zoxide (smarter cd; aliased to `cd` above)
      command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

      # tool paths
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
      export PATH="$HOME/development/flutter/bin:$PATH"
      export ANDROID_HOME="$HOME/Library/Android/sdk"
      export PATH="$PATH:$ANDROID_HOME/emulator"
      export PATH="$PATH:$ANDROID_HOME/platform-tools"
      export PATH="$PATH:$HOME/.pub-cache/bin"
      export PATH="$PATH:$HOME/go/bin"
      export PATH="$PATH:$HOME/.antigravity/antigravity/bin"
      export PATH="$PATH:$HOME/.bun/bin"
      # Do NOT export CPATH here: it leaks macOS SDK headers into iOS/clang
      # builds ("redefinition of module") and breaks Xcode.

      export WIKI="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/wiki"

      # Google Cloud SDK (manual install under ~)
      if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
      if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

      # machine-local secrets, never committed (see README)
      if [ -f "$HOME/.config/zsh/secrets.zsh" ]; then . "$HOME/.config/zsh/secrets.zsh"; fi
    '';

    # .zshenv - keep minimal, sourced by every zsh including non-interactive
    envExtra = ''
      [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
      export PATH="$PATH:$HOME/.foundry/bin"
    '';

    # .zprofile - login shells
    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
      [ -f "$HOME/.rye/env" ] && source "$HOME/.rye/env"
      [ -f "$HOME/.swiftly/env.sh" ] && . "$HOME/.swiftly/env.sh"
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # Edit-in-place: the real files live in this repo, ~ just points at them.
  home.file.".wezterm.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.wezterm.lua";
  home.file.".hammerspoon".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.hammerspoon";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".gitconfig".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.gitconfig";
  home.file.".gitignore_global".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.gitignore_global";
  home.file.".stCommitMsg".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.stCommitMsg";
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";

  # File-level link, not the dir: herdr writes logs/session/sockets there.
  home.file.".config/herdr/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr/config.toml";

  # One AGENTS.md, fanned out to every agent harness.
  home.file."AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".pi/agent/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
}
