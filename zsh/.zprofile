eval "$(/opt/homebrew/bin/brew shellenv)"

eval export PATH="/Users/nathankoerschner/Library/Caches/fnm_multishells/25092_1693234322700/bin":$PATH
export FNM_LOGLEVEL="info"
export FNM_ARCH="arm64"
export FNM_NODE_DIST_MIRROR="https://nodejs.org/dist"
export FNM_COREPACK_ENABLED="false"
export FNM_MULTISHELL_PATH="/Users/nathankoerschner/Library/Caches/fnm_multishells/25092_1693234322700"
export FNM_VERSION_FILE_STRATEGY="local"
export FNM_RESOLVE_ENGINES="false"
export FNM_DIR="/Users/nathankoerschner/Library/Application Support/fnm"

autoload -U add-zsh-hook
_fnm_autoload_hook () {
    if [[ -f .node-version || -f .nvmrc ]]; then
    fnm use --silent-if-unchanged
fi

}

add-zsh-hook chpwd _fnm_autoload_hook \
    && _fnm_autoload_hook

rehash



# added by Snowflake SnowSQL installer v1.2
export PATH=/Applications/SnowSQL.app/Contents/MacOS:$PATH
