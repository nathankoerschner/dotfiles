# Dotfiles

Everything needed to bring a Mac to parity with the main machine: configs
(stowed with `stow --dotfiles`), a `Brewfile`, an idempotent `bootstrap`, and
per-machine snapshots under `machines/` so drift shows up in git.

Machines stay in sync over git only; nothing is shared over the network.

## New machine

Goal: get a ChatGPT agent running first, then let it do the rest.

### 1. Get ChatGPT going (by hand, ~5 min)

1. Sign in to the Mac with the Apple ID; connect Wi-Fi.
2. Install [ChatGPT desktop](https://developers.openai.com/codex/app/) from a
   browser, sign in with the normal ChatGPT account, and pick **Codex**.
   Plain ChatGPT auth works until step 3; TrueFoundry isn't needed yet.
3. Grant it computer-use access (Accessibility, Screen Recording) when it asks.

### 2. Hand off to ChatGPT

Paste this into a Codex chat:

```text
Set up this Mac to parity with my main machine using my dotfiles. Read
https://github.com/nathankoerschner/dotfiles/blob/main/README.md first, then run
the bootstrap:

  zsh -c "$(curl -fsSL https://raw.githubusercontent.com/nathankoerschner/dotfiles/main/bootstrap)"

It is idempotent: re-run it after anything that needed me (Command Line Tools
dialog, sudo password, gh auth login, app sign-ins). Work through the
"Needs attention" list it prints and the "After bootstrap" section of the
README. Bring me in only for passwords, sign-ins, MFA, and macOS permission
prompts. Never print, commit, or paste secrets into chat. Finish by running
~/dotfiles/snapshot and reporting what is still different from the other
machine's snapshot in ~/dotfiles/machines/.
```

### 3. What bootstrap does

`~/dotfiles/bootstrap [--macos]`, safe to re-run:

1. Xcode Command Line Tools, Homebrew, clones this repo to `~/dotfiles`.
2. `brew bundle` (`Brewfile`: CLIs, apps, global npm/uv tools). Apps already
   installed by hand make their cask fail; that's harmless.
3. oh-my-zsh, then vendor-installed CLIs: bun, herdr, claude, codex, amp, omp.
4. Stows every package into `~`. Any real file in the way moves to
   `~/.dotfiles-backup/<timestamp>/`.
5. Links and loads `macos-launchagents/*.plist`.
6. `mise install`, `herdr/setup.sh` (needs the Herdr server running), nvim
   plugins at the versions in `lazy-lock.json`.
7. `--macos`: applies the `macos` defaults script (Dock, keyboard, Finder,
   never-sleep power settings; uses sudo). Reboot afterward.
8. Clones every repo in `machines/*/repos.txt` into `~` (after `gh auth login`).
9. Prints a secrets checklist and anything that needs attention.

### 4. Secrets (move by hand; never commit)

Transfer these from the old machine via 1Password (or AirDrop), keeping file
modes at `0600`:

| File | Contents |
|---|---|
| `~/.zshenv.local` | `TFY_TOKEN`, `BRAVE_API_KEY` (see *Machine-local AI gateway*) |
| `~/.gitconfig.local` | `[user]` name/email |
| `~/.zprofile.local` | machine-local profile overrides |
| `~/.config/mcp/arcade-school.headers`, `tsa-courses.headers` | `Authorization: Bearer <token>` |
| `~/.local/share/arcade-linear-return/mcp-destination/client-metadata.json` | Linear MCP OAuth client |
| `~/.pi/agent/auth.json` | or just run `pi` and `/login` |

After `~/.zshenv.local` exists, run `tfy-env` (or log out and back in) and
restart ChatGPT desktop: the stowed Codex config routes it through TrueFoundry.

### 5. After bootstrap (by hand)

- `gh auth login`, then re-run bootstrap to clone repos.
- Sign in: Chrome (turn on sync, set as default browser), 1Password, Slack,
  Discord, Linear, Granola, Spotify, Tailscale, Jump Desktop.
- Alfred: activate Powerpack, set the preferences folder to `~/.alfred`, turn
  off the Spotlight shortcut.
- Hammerspoon: grant Accessibility and enable launch at login. Change Caps Lock
  to Control in System Settings > Keyboard.
- Open Ghostty (starts Herdr); re-run bootstrap if it warned about Herdr.
- Apps with no cask: see `manual-apps.txt`.
- Mission Control shortcuts aren't scriptable; set them by hand.
- Optional: `:MasonInstall sqlfmt` in nvim where SQL formatting is wanted.

## Remote Herdr

On the remote Mac: enable Remote Login (`sudo systemsetup -setremotelogin on`),
sign in to Tailscale, and keep sleep off (`bootstrap --macos`). From here,
`ssh-copy-id nathan@<host>`, then either:

- `ssh nathan@<host>` + `herdr`: runs entirely remote, like tmux.
- `herdr machine add nathan@<host> --label <host>`: shows it in the sidebar
  next to Local; drive it with `herdr --machine <host> ...`.

Remote agents use that machine's repos and secrets.

## Keeping machines at parity

Run `~/dotfiles/snapshot --commit` after installing or removing things. It
writes `machines/<host>/` (Brewfile dump, apps, repos, LaunchAgents, mise and
bun globals) and commits it. `machines/<host>/unmanaged.txt` is the drift
report:

- *installed here but not in Brewfile*: add it to `Brewfile` (or
  `manual-apps.txt`) so other machines get it, or uninstall it.
- *declared but not brew-installed here*: run bootstrap, or ignore apps that
  were installed by hand before this machine used the Brewfile.

On the other machine, `git pull && ./bootstrap` picks up the change. Config
files are symlinks into this repo, so config edits are already tracked:
commit them, pull elsewhere.

Paths in several configs assume the user is `nathan` (`/Users/nathan/...`).

Small helper scripts live in `bin/dot-local/bin` and stow into `~/.local/bin`.

Every top-level directory except `machines/` and `macos-launchagents/` is a stow package; `bootstrap` lists them in `STOW_PACKAGES`.

## Agent skills

User skills live in `agents/dot-agents/skills/<skill>/SKILL.md`. Stowing the `agents` package symlinks them into `~/.agents/skills/<skill>/SKILL.md`, which is what pi (and other tools) load via `settings.json` (`"skills": ["~/.agents/skills"]`).

`settings.json` also points at `~/arcade.school/.agents/skills` so the arcade repo's skills (`/skill:arcade-*`) are available from any cwd. This is the main checkout only, not worktrees; those skills assume you `cd` into a checkout before running repo commands.

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

## Herdr config

`herdr/dot-config/herdr/config.toml` stows to `~/.config/herdr/config.toml`.
Only config, plugins, and agent integrations are tracked; Herdr's sockets, logs,
`session.json`, and `plugins.json` stay local. Apply config changes with
`herdr server reload-config`.

- `herdr/plugins/`: `recent-agents` (sidebar Agents sorted newest state change
  first) and `tab-bubbles` (● on a tab per agent that finished or needs input
  while you weren't looking; visiting clears it).
- Agent integrations (`herdr integration install <agent>` output) are stowed
  from `pi/`, `claude/` (`hooks/` + `settings.json` hook), and `codex/`
  (`herdr-agent-state.sh`, `hooks.json`).
- After stowing on a new machine, run `herdr/setup.sh` to register the plugins.

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
