# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)
source $ZSH/oh-my-zsh.sh
# use Vim keys for navigating the autosuggest list
bindkey -M vicmd "k" up-line-or-beginning-search
bindkey -M vicmd "j" down-line-or-beginning-search
# Use Ctrl-P (previous) and Ctrl-N (next) for navigating the autosuggest list
bindkey '^P' up-line-or-beginning-search
bindkey '^N' down-line-or-beginning-search
# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"


alias dotfile="echo '~/.zshrc'"
alias youtube-to-mp3="yt-dlp -x --audio-format mp3 --concat-playlist always --yes-playlist"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/nathankoerschner/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/nathankoerschner/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/nathankoerschner/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/nathankoerschner/google-cloud-sdk/completion.zsh.inc'; fi


#pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# dotfile git directory
alias config='/usr/bin/git --git-dir=/Users/nathankoerschner/.cfg/ --work-tree=/Users/nathankoerschner'

bindkey -e # v for vi mode, e for emacs mode

alias daasity_dbt='source /Users/nathankoerschner/all-client-dbt/daasity-dbt-env/bin/activate'

# Vim
export EDITOR=nvim

export PATH="/Users/nathankoerschner/.local/bin/:$PATH"
alias bigquery-query='bq query --use_legacy_sql=false'
alias generate-iphone-8plus-sized-screenshot-from-iphone-se-screenshot='magick convert  -resize 1242x2209 -crop 1242x2208+0+0'
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"



[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

bindkey -M vicmd v edit-command-line
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line
# export FZF_DEFAULT_OPTS='--bind "ctrl-j:down,ctrl-k:up,alt-j:preview-down,alt-k:preview-up"'
bindkey "ç" fzf-cd-widget # step around mac default alt + c
