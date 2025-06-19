# Dotfiles

Various scripts avilable in the Bin folder.

Uses `stow` (and it's glorious `--dotfiles` option) to manage all dotfiles.

# Steps to follow to setup a new machine:

Basic Setup
- fork dotfiles 
    - run macos script, restart
- Install Brew
    - install stow
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
- brew install hammerspoon
    - enable accessibility & start on login
    - change caps lock to control in system prefs
- brew Install Ghosty
- brew install tmux
- install ohmyzsh (get command from site)
- brew install fzf
- stow bin 
    - confirm tmux sessionizer works
- brew install neovim
    - brew install lua
    - brew install node
    - start nvim and watch everything install through lazy

# Misc
- brew install gh
    - gh auth login
- configure git
- SnowSQL
- Install Jump Desktop and configure it for connecting to relevant machines.
- Install and sign in to Slack
- Install Transmit for S3 file access


- Unmount installation discs and clear downloads
