{ user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = true;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click
  };
  nix-homebrew = {
    enable = true;
    inherit user;
  };
  homebrew = {
    enable = true;
    # Never uninstall anything automatically. doctor.sh diffs installed vs
    # declared packages so drift is visible; prune by hand, promote by
    # editing this file. Flip to "zap" if you ever want hard lockdown.
    onActivation.cleanup = "none";
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    taps = [
      "oven-sh/bun" # bun
    ];
    brews = [
      "herdr"
      # shell + editor core
      "neovim"
      "nvm"
      "pyenv"
      "zoxide"
      "eza"
      "bat"
      "oven-sh/bun/bun"
      # everyday cli
      "fd"
      "ripgrep"
      "fzf"
      "jq"
      "gh"
      "lazygit"
      "lazydocker"
      "yazi"
      "btop"
      "cloc"
      "yt-dlp"
      # infra
      "k9s"
      "tuxedo"
    ];
    casks = [
      # terminal
      "wezterm"
      # system layer (raycast provides the hyper key hammerspoon binds to)
      "hammerspoon"
      "raycast"
      # fonts
      "font-meslo-lg-nerd-font"
      "font-symbols-only-nerd-font"
      # quality of life
      "maccy"
      "rectangle"
      "monitorcontrol"
    ];
  };
}
