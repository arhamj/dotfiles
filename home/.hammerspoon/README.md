# Hammerspoon Configuration

## Setup

### Raycast (Hyper Key)

1. Install `Raycast`
```
brew install --cask raycast
```
2. Setup Hyper key mapping in Raycast settings:
```
Caps Lock => Cmd + Opt + Ctrl + Shift
```

### Hammerspoon

1. Install `Hammerspoon`
```
brew install --cask hammerspoon
```
2. Provide appropriate permissions
3. Clone repo
```
git clone https://github.com/arhamj/hammerspoon.git ~/.hammerspoon
```
4. Make spoons directory
```
mkdir ~/.hammerspoon/Spoons
```
5. Reload `Hammerspoon` config

## Active Features

### App Launcher
- `Hyper + a` = Arc Browser
- `Hyper + c` = Cursor
- `Hyper + p` = Postman
- `Hyper + w` = Bitwarden
- `Hyper + h` = Hammerspoon
- `Hyper + n` = Notes
- `Hyper + s` = Slack

**Note**: `Hyper + t` is reserved for Tailscale toggle, WezTerm binding may be overridden

### System Controls
- `Hyper + m` = Toggle microphone mute
- `Hyper + 0` = Reload Hammerspoon config
- `Hyper + t` = Toggle Tailscale connection
- `Cmd + q` = Slow quit (hold to quit apps)
- `Ctrl + \`` = Toggle WezTerm visibility

### Network Tools
- Ping utility (background network monitoring)

## Disabled Features

### Commented Out Apps
```lua
-- b = "Brave Browser"
-- d = "Discord" 
-- g = "Goland"
```

### Commented Out Modules
```lua
-- require 'tunnelblick'  -- VPN connection toggle
-- require 'pomodoro'     -- Pomodoro timer
```

## Notes

- **Hyper Key**: `Caps Lock` mapped to `Cmd + Opt + Ctrl + Shift` via Raycast
- **Tailscale** intelligently detects connection state and toggles
- **Microphone mute** provides system-wide mute functionality
