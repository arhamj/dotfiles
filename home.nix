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
      lg = "lazygit";
      ld = "lazydocker";
      lzd = "lazydocker";
      # Hand-run codex stays on the API-key home (fleet-dispatched codex gets
      # the same pin from firstmate's config/codex-home). An alias, not an
      # export: a global CODEX_HOME leaks into the ChatGPT desktop app, which
      # then adopts the API-key home instead of the ChatGPT account.
      codex = ''CODEX_HOME="$HOME/.codex-cli" codex'';
    };

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
      export PATH="$PATH:$HOME/go/bin"
      export PATH="$PATH:$HOME/.bun/bin"

      # machine-local files, never committed (gitignored):
      #   secrets.zsh - tokens and client secrets
      #   local.zsh   - machine-specific PATH lines and exports
      # Deferred tool snippets live in docs/deferred-setup.md.
      if [ -f "$HOME/.config/zsh/secrets.zsh" ]; then . "$HOME/.config/zsh/secrets.zsh"; fi
      if [ -f "$HOME/.config/zsh/local.zsh" ]; then . "$HOME/.config/zsh/local.zsh"; fi
    '';

    # .zshenv - keep minimal, sourced by every zsh including non-interactive
    envExtra = ''
      [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
    '';

    # .zprofile - login shells
    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
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
