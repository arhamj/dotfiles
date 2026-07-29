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
    onActivation.cleanup = "zap";  # remove anything not listed here
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    taps = [
      "d99kris/nchat"   # nchat
      "gammons/tap"     # slk
      "oven-sh/bun"     # bun
    ];
    brews = [
      "herdr"
      # cli tools
      "argocd"
      "awscli"
      "bat"
      "biome"
      "bitwarden-cli"
      "bookokrat"
      "btop"
      "cloc"
      "cmake"
      "coreutils"
      "d99kris/nchat/nchat"
      "eza"
      "fd"
      "ffmpeg"
      "ffmpeg-full"
      "fzf"
      "gammons/tap/slk"
      "gh"
      "glow"
      "gnu-sed"
      "helix"
      "helm"
      "htop"
      "imagemagick-full"
      "jenv"
      "jq"
      "just"
      "k9s"
      "lazydocker"
      "lazygit"
      "libpq"
      "mongosh"
      "neovim"
      "nushell"
      "nvm"
      "oven-sh/bun/bun"
      "pnpm"
      "poppler"
      "protoc-gen-go"
      "pyenv"
      "rainfrog"
      "resvg"
      "ripgrep"
      "sevenzip"
      "shellcheck"
      "tctl"
      "temporal"
      "terraform"
      "tuxedo"
      "watch"
      "xcodegen"
      "yazi"
      "yq"
      "yt-dlp"
      "zoxide"
    ];
    casks = [
      # terminals + editors
      "wezterm"
      # agent harnesses (claude also self-installs to ~/.local/bin, which wins on PATH)
      "claude-code"
      # system utilities
      "hammerspoon"
      "raycast"
      "rectangle"
      "maccy"
      "hiddenbar"
      "aldente"
      "jiggler"
      "monitorcontrol"
      "notunes"
      "appcleaner"
      "localsend"
      "1password-cli"
      # fonts
      "font-fira-code"
      "font-meslo-lg-nerd-font"
      "font-symbols-only-nerd-font"
      # browsers + comms
      "arc"
      "brave-browser"
      "google-chrome"
      "slack"
      "discord"
      "whatsapp"
      # dev tools
      "chatgpt"
      "clocker"
      "conductor"
      "gcloud-cli"
      "google-cloud-sdk"
      "handy"
      "headlamp"
      "mongodb-compass"
      "opensuperwhisper"
      "postman"
      "protonvpn"
      "redis-insight"
      "temurin@21"
      # hardware / misc
      "android-file-transfer"
      "arduino-ide"
      "capcut"
      "logi-options+"
      "webtorrent"
    ];
  };
}
