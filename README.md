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
| `~/.profile.local` | machine-local POSIX login-shell additions (optional; the tracked `~/.profile` puts Homebrew first for `sh -lc`, e.g. the arcade pre-push hook) |
| `~/.config/mcp/arcade-school.headers`, `tsa-courses.headers` | `Authorization: Bearer <token>` |
| `~/.local/share/arcade-linear-return/mcp-destination/client-metadata.json` | Linear MCP OAuth client |
| `~/.pi/agent/auth.json` | or just run `pi` and `/login` |
| `~/.secrets/discord_token` | Discord token for the `discord-export` skill (DiscordChatExporter reads it as `DISCORD_TOKEN`); dir `0700` |
| `~/.alchemy/config.json`, `~/.alchemy/credentials/playcademy-arcade/cloudflare.json` | Alchemy `playcademy-arcade` Cloudflare profile (API token); arcade's `bun scripts/db --stage production` needs it plus `cloudflared` |

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

On every other machine (see `machines/README.md`), `git pull && ./bootstrap` picks up the change. Config
files are symlinks into this repo, so config edits are already tracked:
commit them, pull elsewhere.

Configs use `$HOME`, so they symlink on any user. Exception: `~/.codex/config.toml`
is a per-host copy (Codex rewrites it with absolute paths). Per-host Ghostty
settings go in untracked `~/.config/ghostty/local.conf`.

Small helper scripts live in `bin/dot-local/bin` and stow into `~/.local/bin`.

Every top-level directory except `machines/` (inventory + snapshots), `macos-launchagents/` and `ios-shortcuts/` is a stow package; `bootstrap` lists them in `STOW_PACKAGES`.

## Agent skills

User skills live in `agents/dot-agents/skills/<skill>/SKILL.md`. Stowing the `agents` package symlinks them into `~/.agents/skills/<skill>/SKILL.md`, which is what pi (and other tools) load via `settings.json` (`"skills": ["~/.agents/skills"]`).

`settings.json` also points at `~/arcade.school/.agents/skills` so the arcade repo's skills (`/skill:arcade-*`) are available from any cwd. This is the main checkout only, not worktrees; those skills assume you `cd` into a checkout before running repo commands.

Codex system skills live alongside under `agents/dot-agents/.system/` and stow to `~/.agents/.system/`.

## Global agent instructions

Pi, Claude Code, and Codex all load one file, `pi/dot-pi/agent/AGENTS.md` (the `claude` and `codex` packages symlink to it). That file is generated: edit the sources in `agents.md/` and run `agents.md/build`. Each top-level section is its own file in `agents.md/sections/`, concatenated in filename order (`010-…`, `020-…`; renumber to reorder); a line `<!-- include: NAME.md -->` pulls in a longer doc from `agents.md/includes/` with its headings nested. `bootstrap` rebuilds it, and a pre-commit hook rejects a stale build.

[`agents.md/includes/attribution.md`](agents.md/includes/attribution.md) is the single source of truth for how AI assistants label what they write for other people. Other repos (e.g. arcade.school's README) link to it rather than keeping a copy.

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

## Prompt inbox (ag)

Send-only inbox: POST free text and ag opens a new Herdr tab running pi with that text as the first prompt.

- Test page: http://ag:7373/ (or `http://100.107.192.32:7373/`). Tailscale only; it listens on ag's Tailscale IP.
- API: `curl -X POST http://ag:7373/prompt -d 'your prompt'` → `202`, no body. Form posts take `text` and an optional `id`; a repeated `id` within 24 hours is acknowledged without opening a second tab (so the phone's offline queue can resend safely).
- Every capture opens a tab in the **Inbox** workspace (created if missing); a fast model (TrueFoundry Gemini Flash Lite) only names the tab. Filing into topic workspaces is done by hand. Nothing is focused, so attached clients aren't disturbed.
- Code: `bin/dot-local/bin/prompt-inbox`; LaunchAgent: `com.nathan.prompt-inbox` (only runs on ag).
- Log: `~/.local/state/prompt-inbox/log.jsonl`, one line per step (`received → tab → pi_started → sent`, or `label_failed`/`duplicate`/`failed`). Server output: `/tmp/prompt-inbox.log`.
- Restart after edits: `launchctl kickstart -k gui/$(id -u)/com.nathan.prompt-inbox`.
- iPhone Action Button capture: `ios-shortcuts/capture-to-ag.md`.

## Tickler (deferred tasks)

GTD tickler for Herdr. Say it in plain text to any pi agent ("do X Friday at 9", "send this back to me in two weeks"); the agent calls the `tickler` tool. At that time a new tab `⏰ <title>` opens in the same Herdr workspace (falls back to `Inbox`), running pi **forked from the conversation that deferred it**, with the task as its first prompt. Nothing is focused; a Herdr notification fires.

- Tool: `pi/dot-pi/agent/extensions/tickler.ts` (schedule / list / cancel). CLI: `bin/dot-local/bin/tickler add|list|cancel|fire`.
- LaunchAgent `com.nathan.tickler` runs `tickler fire` every 60s, only on ag (the host). Items missed while asleep fire on wake and say they're late.
- State: `~/.local/state/tickler/<id>.json`; log `log.jsonl` beside them (`added → fired`, or `failed` with the error). launchd output: `/tmp/tickler.log`.

## Jev (TypeSafe System One model)

Guide for agents. Sources: [docs.typesafe.ai](https://docs.typesafe.ai/llms.txt) (source of truth; append `.md` to any page path) and the official skill, vendored at `agents/dot-agents/skills/typesafe-ai` (from [typesafe-ai/skills](https://github.com/typesafe-ai/skills)). Read the live docs before writing an integration; details below are from jev-1.13 (Sep 2026).

**What it is.** A fast decision model, not a chat LLM. You send a `state` (text, JSON object, or array) plus named typed questions; it returns typed answers with calibrated probabilities. It does not generate text, call tools, or write code, so it can't power pi or any coding agent. Use it *inside* code wherever the answer has a known shape: route, gate, score, verify.

**Split the work.** If the step creates text or plans, keep it on an LLM. If it picks from a list, scores on a rubric, or answers yes/no, use Jev. Keep exact rules, lookups, and execution in plain code.

**API.**

```bash
# Through our TrueFoundry gateway (use this; no TypeSafe key needed). The path after
# /proxy-api/jev-account/jev-endpoint/ is passed straight through to api.typesafe.ai.
curl -s https://tfy.promptlens.trilogy.com/proxy-api/jev-account/jev-endpoint/v1/systemone \
  -H "Authorization: Bearer $TFY_TOKEN" -H 'content-type: application/json' \
  -d '{"model":"jev-latest","state":"Help! My payouts have been failing for 3 days.",
       "questions":{
         "team":{"type":"choice","instructions":"Which team should handle this?",
                 "criteria":{"billing":"Payments, refunds","technical":"Bugs, outages","sales":"Pricing, upgrades"}},
         "urgent":{"type":"noul","instructions":"Does this convey urgency?"},
         "anger":{"type":"score","instructions":"How frustrated is the customer?","criteria":["Calm","Frustrated","Very angry"]}}}'
```

| Primitive | Use for | Answer |
|---|---|---|
| `choice` | one option from a set (≤255 options in `criteria` map) | `choice`, `probabilities`, `confidence` |
| `noul` | whether a condition holds | `noul` = P(yes), 0–1 |
| `score` | degree on ordered levels (2–10 in `criteria` array) | `score` (can fall between levels), `probabilities`, `confidence` |

- Question ids are for your code only and are never sent to the model, so each question must be self-contained. Point at nested state with backticked paths like `` `ticket.messages[0].text` ``.
- Ask all independent questions over the same state in **one request**. They run in parallel, and extra speculative ones are cheap. Only make a second call when an earlier answer is needed to build the next state.
- Include a no-match option when nothing may fit. Gate actions on `confidence` or probability thresholds tuned on your own data; route the uncertain ones to a person or a reasoning LLM. A `noul` near 0.5 means "unsure", not "medium".
- Models: `jev-latest` (currently `jev-1.13.0`); pin the versioned id if you tuned thresholds. 64k tokens per request (32k for state plus the longest question), text only, English is strongest. Priced per input token (about $0.042 per million); output is free. It returns `429` when rate-limited, so retry with backoff.
- SDKs: Python (`TypeSafeClient` / `AsyncTypeSafeClient`) and JavaScript; see [SDKs](https://docs.typesafe.ai/sdk.md). Try prompts in the [Playground](https://console.typesafe.ai/playground).
- Access: call Jev through TrueFoundry as above with `TFY_TOKEN` (from `~/.zshenv.local`), not `api.typesafe.ai` directly. It is a TrueFoundry "custom endpoint", so `/chat/completions` rejects it; use the `/proxy-api/` path. TypeSafe SDKs can point at that base URL.
- In use here: `pi/dot-pi/agent/extensions/herdr-tab-name.ts` (keeps Herdr tab names accurate; see Herdr config).

## Moshi (iPhone terminal)

Moshi on the iPhone connects to ag over Tailscale and attaches to Herdr.

- **Hook daemon**: `bootstrap` runs `moshi-hook-install`. It installs the
  checksum-verified prebuilt `moshi-hook` into `~/.local/bin`, because the
  Homebrew formula refuses to install when the Command Line Tools lag behind macOS.
  The daemon runs from `macos-launchagents/com.nathan.moshi-hook.plist`
  (`brew services` isn't used). Check it with `moshi-hook doctor`.
- **Agent hooks**: bootstrap installs the Pi hook only
  (`~/.pi/agent/extensions/moshi-hooks.ts`, generated, untracked).
  `moshi-hook install --target claude,codex` replaces the stowed
  `settings.json`/`hooks.json` symlinks with real files containing
  host-specific paths. If you run it, move the Moshi entries into the
  repo files and restore the symlinks.
- **Pairing** (by hand, once per host): Moshi app → Settings → Hooks →
  select ag → Retry/Pair, or run `moshi-hook host setup` and scan the QR code.
  The host secret stays in the login Keychain (`app.getmoshi.hook`), not in this repo.
- **Shortcuts**: the same Herdr shortcuts as the Mac, per
  [`herdr/SHORTCUTS.md`](herdr/SHORTCUTS.md). Moshi forwards Cmd keys to Herdr,
  except Cmd+N/W/O/K/V/1–9, which it keeps for itself; use `Ctrl+B` + key for those.

## Herdr config

Tab names stay accurate on their own (`pi/dot-pi/agent/extensions/herdr-tab-name.ts`). On every prompt, in the background: a default numeric tab gets named by a fast LLM; otherwise Jev scores whether the label still fits the last 3 prompts, and if P(accurate) < 0.6 the LLM renames it. Renaming a tab by hand pins it for that session. Decisions are logged to `~/.local/state/herdr-tab-name/log.jsonl` (label, `p_accurate`, keep/rename) for tuning the threshold. Open pi sessions need `/reload` to pick up changes.

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
- Shortcuts: canonical list and per-device behavior in
  [`herdr/SHORTCUTS.md`](herdr/SHORTCUTS.md) (spec `shortcuts.json`, verified by
  `herdr-shortcuts-check`).

## Texas Sports Academy MCP (arcade.school)

Pi and Codex register `arcade_school` using `mcp-remote@0.8.3`, bridging stdio
locally to Streamable HTTP at `https://api.texassportsacademy.com/mcp`.
Bun must be installed at `~/.bun/bin/bunx`.

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

## Client ↔ ag bridge

Nathan sits at a client machine; agents run on a host (ag). Every machine stows this repo; roles and aliases are in `machines/README.md`.

- **SSH**: `ssh/dot-ssh/config` defines an alias per machine (Tailscale IPs). Each machine needs an
  `~/.ssh/id_ed25519` authorized on the machines it talks to (manual, per device), and Remote Login on.
  Machine-only hosts go in untracked `~/.ssh/config.local`.
- **Screenshots → ag**: CleanShot X on the client saves to `~/Screenshots` (Settings → General →
  Export location; after-capture actions include *Save*). Set by hand/CUA; CleanShot stores it as
  `exportPath` in `pl.maketheweb.cleanshotx` and needs a restart to apply. `shot [n]` on ag pulls
  the newest n into `~/inbox/shots`.
- **Perplexity voice off**: on the client, Perplexity Settings → Keyboard Shortcuts → *Start voice* is
  **Disabled** (default was *Hold Fn*, which fired on Ctrl/Fn), and General → Voice → Activation is
  Disabled. Stored as `voiceTriggerMode = disabled` in `ai.perplexity.macv3`. Set by hand/CUA.
- **Paste images into agents**: Hammerspoon (client only). Every CleanShot capture is uploaded to
  `ag:~/inbox/clipboard/` the moment CleanShot writes it (it watches CleanShot's media folder and
  `~/Screenshots`), so Cmd+V in a Herdr Ghostty window just types the already-uploaded ag path
  (instant); pi attaches image paths. Other clipboard images/files upload on paste (path typed first).
  Uploads reuse one SSH connection (`ControlMaster` in `ssh/dot-ssh/config`). Text pastes untouched.
  Speed limit: on the office network the machines sit behind the same symmetric NAT, so Tailscale
  relays via DERP (~1.3 MB/s; a ~1 MB screenshot lands in ~0.8s). Check with
  `tailscale ping nathan-dev-client` (want "via <ip>", not "via DERP").
- **ag → client viewing**: `show <file|dir|url>` copies to client `~/ag-inbox` and opens it there
  (HTML files bring their referenced local assets; a folder opens its `index.html`).
  Agents call it themselves (see AGENTS.md). Servers on ag are reachable at `http://ag:<port>`.
- **Client desktop automation**: `client-cua "<task>"` runs Codex computer use on the client's GUI
  session (via `launchctl submit`; plain ssh can't see the screen).
- **Phone → ag**: `file-inbox` (LaunchAgent `com.nathan.file-inbox`, port 7374, Tailscale only)
  saves uploads to `~/inbox/phone` and can prompt a recent pi session or open a new one. The iOS
  Shortcut is documented in `ios-shortcuts/send-to-ag.md`. Log: `/tmp/file-inbox.log`.
- **Links to Herdr tabs**: `herdr-link <tab_id>` / `herdr-link --grep <regex>` prints
  `http://ag:7374/focus?tab=<id>`. Cmd+click in Ghostty → file-inbox runs `herdr tab focus`, then
  redirects to `hammerspoon://herdr-return` (client Hammerspoon closes the browser tab, refocuses
  Ghostty). Plain http because Herdr strips OSC 8 and Ghostty only auto-links standard schemes.
