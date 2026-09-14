# Dotfiles

Small helper scripts live in `bin/dot-local/bin` and stow into `~/.local/bin`.

Uses `stow` (and it's glorious `--dotfiles` option) to manage all dotfiles.

## Agent skills

User skills live in `agents/dot-agents/skills/<skill>/SKILL.md`. Stowing the `agents` package symlinks them into `~/.agents/skills/<skill>/SKILL.md`, which is what pi (and other tools) load via `settings.json` (`"skills": ["~/.agents/skills"]`).

Codex system skills live alongside under `agents/dot-agents/.system/` and stow to `~/.agents/.system/`.

## Pi config

Pi extensions and non-secret settings are tracked in `pi/dot-pi`.

Live paths resolve like this:
- `~/.pi/agent/extensions/*.ts` -> `~/dotfiles/pi/dot-pi/agent/extensions/*.ts`
- `~/.pi/agent/settings.json` -> `~/dotfiles/pi/dot-pi/agent/settings.json`

Pi's default model and Ctrl+P rotation are configured only in `settings.json`
(`defaultProvider`/`defaultModel`/`enabledModels`); nothing in the shell
config overrides them.

Intentionally not tracked in dotfiles:
- `~/.pi/agent/auth.json`
- `~/.pi/agent/sessions/`
- repo-local `.pi/todos/`

## Texas Sports Academy MCP (arcade.school)

Pi and Codex register `arcade_school` using `mcp-remote@0.8.3`, bridging stdio
locally to Streamable HTTP at `https://api.texassportsacademy.com/mcp`.
Bun must be installed at `~/.bun/bin/bunx`. Config paths currently target
`/Users/nathan`; adjust them when setting up a different home directory.

The credential is **not tracked**. Provision it through an approved secure channel
into `~/.config/mcp/arcade-school.headers` (directory mode `0700`, file mode
`0600`) with a single line:

```text
Authorization: Bearer <private token>
```

The configs pass only the header-file path, never the token, as process arguments.
Do not enable `mcp-remote --debug` or share the credential file or session exports
containing credentials. The key has no automatic expiration; rotate/revoke it
through the issuer if exposed. Missing credentials cause the bridge to fail closed.
Restart Pi/Codex after provisioning or rotating the file. In Pi, check
`/mcp arcade_school` and call `mcp_arcade_school_whoami` to verify identity.

Access uses the production read-only database role and the full MCP toolset.
Start with `whoami`, then `list_tables` and `describe_table` before querying.
Raw device events are in `public.device_events`; `device_analytics` rollups
are not accessible with this role. Private S3 screenshots/archives require
separate access. Academic XP is in the `student_portal.strata_*` tables;
`public.xp_events` is the separate family rewards system.

Follow-up analysis: count distinct students each day who join the arcade but do
not attend the daily call. Identify the arcade-join and call-attendance sources,
student identity join, day/time zone, and reporting date range before calculating;
a missing attendance record alone should not be treated as proof of absence until
attendance coverage is verified.

## Machine-local AI gateway

AI tools use their standard OAuth/API authentication by default. To opt one
machine into TrueFoundry, add only the gateway token to `~/.zshenv.local`:

```sh
export TFY_TOKEN="..."
```

On opted-in machines, the shell routes Claude Code, Pi, and Codex through
TrueFoundry. Keep `~/.zshenv.local` untracked; machines without `TFY_TOKEN`
continue using the standard providers configured by each tool.

## TMUX Cheat Sheet

`Prefix` means press `Ctrl+B`, release it, then press the shortcut key.

| Shortcut | Action |
|---|---|
| `Prefix f` | Open the project sessionizer |
| `Prefix L` | Switch to the last-used session |
| `Prefix (` / `Prefix )` | Previous / next session |
| `Prefix s` | Pick a session |
| `Prefix c` | Create a window |
| `Prefix n` / `Prefix p` | Next / previous window |
| `Prefix 1`–`9` | Jump to a numbered window |
| `Prefix %` / `Prefix "` | Split right / split down |
| `Prefix h/j/k/l` | Move between panes |
| `Prefix z` | Zoom or unzoom the current pane |
| `Prefix x` | Close the current pane |
| `Prefix i` | Copy the current pane ID |

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
    - brew install m1ddc (used by Hammerspoon to set external monitor brightness)
    - enable accessibility & start on login
    - change caps lock to control in system prefs
- brew Install Ghosty
- brew install tmux
- install ohmyzsh (get command from site)
- brew install fzf
- brew install ripgrep
- stow bin
    - confirm tmux sessionizer works
- brew install uv
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
- Install Jump Desktop and configure it for connecting to relevant machines.
- Install and sign in to Slack
- Install Transmit for S3 file access


- Unmount installation discs and clear downloads
