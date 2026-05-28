# Dotfiles

Various scripts avilable in the Bin folder.

Uses `stow` (and it's glorious `--dotfiles` option) to manage all dotfiles.

## Agent skills

User skills live in `agents/dot-agents/skills/<skill>/SKILL.md`. Stowing the `agents` package symlinks them into `~/.agents/skills/<skill>/SKILL.md`, which is what pi (and other tools) load via `settings.json` (`"skills": ["~/.agents/skills"]`).

Codex system skills live alongside under `agents/dot-agents/.system/` and stow to `~/.agents/.system/`.

## Pi config

Pi extensions and non-secret settings are tracked in `pi/dot-pi`.

Live paths resolve like this:
- `~/.pi/agent/extensions/*.ts` -> `~/dotfiles/pi/dot-pi/agent/extensions/*.ts`
- `~/.pi/agent/settings.json` -> `~/dotfiles/pi/dot-pi/agent/settings.json`

Intentionally not tracked in dotfiles:
- `~/.pi/agent/auth.json`
- `~/.pi/agent/sessions/`
- repo-local `.pi/todos/`

# Steps to follow to setup a new machine:

Basic Setup
- clone dotfiles 
    - run macos script, restart
- Install Brew
- Install stow
- download Chrome
    - signin
    - configure sync 
    - add 1password
    - set as default browser
- download Alfred
    - activate powerpack
    - turn off spotlight search
    - stow dotfile, set preferences location 
Dev Env Setup
- stow zshrc
- stow pi
- brew install hammerspoon
    - enable accessibility & start on login
    - change caps lock to control in system prefs
- brew Install Ghosty
- brew install tmux
- install ohmyzsh (get command from site)
- brew install fzf
- brew install ripgrep
- stow bin 
    - confirm tmux sessionizer works
- brew install neovim
    - brew install lua
    - brew install luarocks (required for Mason to install luacheck)
    - brew install node
    - start nvim and watch everything install through lazy
    - on machines where you want SQL formatting, run `:MasonInstall sqlfmt` (not in `ensure_installed` since it's not required on all systems)
- brew install --cask cleanshot

# Misc
- brew install gh
    - gh auth login
- configure git
- SnowSQL
- Install Jump Desktop and configure it for connecting to relevant machines.
- Install and sign in to Slack
- Install Transmit for S3 file access


- Unmount installation discs and clear downloads
