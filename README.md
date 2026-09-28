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

## Private chat (OpenRouter)

`ag-private` is a private chat page for personal questions: `http://ag:7375/` (or `http://100.107.192.32:7375/`), Tailscale only. Unlike everything else on ag, its inference goes straight to OpenRouter on Nathan's **personal** account, never TrueFoundry, Jev, or the ag inbox.

- Key: `OPENROUTER_API_KEY` in `~/.zshenv.local` (personal OpenRouter account, paid with Nathan's personal card). pi's `openrouter` provider in `models.json` reads the same variable. Without it the page answers "OPENROUTER_API_KEY isn't set on ag yet."
- Every request sends `provider: {data_collection: "deny", zdr: true}` (no provider training or retention). In the OpenRouter account settings, keep prompt logging off.
- Chats are stored only on ag in `~/private-chat/<id>.json` (dir 0700, files 0600); nothing about their content is logged. Model picker: Claude Opus 5.5 (default), GPT-6 Sol, Gemini 3.8 Flash (`MODELS` in the script; only models with a zero-data-retention endpoint work, e.g. Claude Fable has none).
- Phone: Back Tap triple tap → shortcut **Private ag** (`ios-shortcuts/private-ag.md`).
- Code: `bin/dot-local/bin/ag-private`; LaunchAgent `com.nathan.ag-private` (only runs on ag). Server output: `/tmp/ag-private.log`. Restart: `launchctl kickstart -k gui/$(id -u)/com.nathan.ag-private`.

## ag inbox

The ag inbox (`ag-inbox`) is the top-level endpoint that starts a new session: POST a prompt and ag opens a new Herdr tab running pi with it as the first prompt. Every capture path goes through it: the Mac quick capture, the iPhone Action Button, and file-inbox's "New session".

- Test page: http://ag:7373/ (or `http://100.107.192.32:7373/`). Tailscale only; it listens on ag's Tailscale IP.
- API: `curl -X POST http://ag:7373/prompt -d 'your prompt'` → `202`, no body. Form posts take `text` and an optional `id`; a repeated `id` within 24 hours is acknowledged without opening a second tab (so the phone's offline queue can resend safely).
- Screenshots: a multipart form can add `screenshot` (image file) plus `app`/`window` (frontmost app and window title). It's saved to `~/inbox/capture/`, and Jev (via TrueFoundry) judges from the prompt and window context whether the agent needs it (attached when P ≥ 0.5, or if Jev fails). `attach=always` skips Jev. Attached means the prompt ends with the file path for pi to read.
- **Mac quick capture: Cmd+Shift+Space** (Hammerspoon, `hammerspoon/dot-hammerspoon/ag_inbox.lua`). Snapshots the screen with the focused window, then opens a small prompt form: Enter sends, Shift+Enter is a newline, Esc cancels. Click the thumbnail to annotate in CleanShot; its Cmd+S saves over the file and the form shows the annotated version, which is always attached. The form is a webview built once at load and only shown/hidden, so it opens in ~0.1–0.2 s, most of it the screenshot. Upload runs in the background with `curl`; on failure an alert shows and the prompt is copied to the clipboard. Needs Screen Recording permission for Hammerspoon (without it, captures are text-only).
- iPhone screenshots: the Action Button capture sends `screenshot` plus `source=iphone`, and Jev gets a phone-specific question (no app/window context).
- Shared files and links (iPhone share sheet, `ios-shortcuts/share-to-ag.md`): `file` (repeatable) is always attached, saved to `~/inbox/share/` (HEIC and other formats pi can't read are converted to JPEG); `url`/`shared` carry a shared link or text. With files or a link, `text` may be empty, and the agent is told to work out what's most likely wanted.
- **Follow-ons go to their thread.** In parallel with routing, Jev checks whether the capture is new context for something already open ("the thing I was calling study film…", "for the consent sankey, also…"). One request, two questions over `{new_message}`: a `noul` (does it refer back to ongoing work?) and a `choice` over every open pi session (one per tab, described as `Workspace › Tab` plus its first and latest prompt, read from the pi session file) plus `none`. Ongoing ≥ 0.7 and match ≥ 0.8: the capture (after the screenshot gate) is prompted straight into that session, prefixed as inbox context, and a Herdr toast names it; no new tab. Ongoing ≥ 0.5 and match ≥ 0.3: a new Inbox session opens as usual, but its prompt names the likely session and how to forward it once Nathan confirms. Otherwise, or on a Jev failure, a playbook match, or a session blocked on a dialog: a normal new session. Adds ~0.6 s. Clear follow-ups score 0.97–1.0; a vague "any update on that thing?" ~0.6 (→ hint). Log step `thread` (action, `ongoing`, `p`, tab), then `followed` or `follow_failed`; tune the thresholds (`FOLLOW`/`HINT` in `ag-inbox`) from it.
- Otherwise every capture opens a tab in the **Inbox** workspace (created if missing). A fast multimodal model (TrueFoundry Gemini Flash Lite; it sees shared images, not the Jev-gated screenshot) names the tab and picks a playbook. Nothing is focused, so attached clients aren't disturbed.
- **Playbooks** (`ag-inbox/dot-config/ag-inbox/playbooks/*.md` → `~/.config/ag-inbox/playbooks/`, re-read on every request): set workflows for typical kinds of captures. Each is a Markdown file with frontmatter `name` and `when` (what the router matches on); its body is prepended to the prompt when matched. Add a file to add a workflow; no restart needed. Current: `contact` (a name + phone/email, or a contact card/business card image → look them up, add to Contacts, message them as Nathan, drafting for his OK unless he said what to send). Contacts and Messages run on the client Mac via `client-people` (`find`/`add`/`text`), since ag's own iCloud sync isn't reliable.
- Dry run: form field `dry=1` routes and gates only and returns `{label, playbook, thread, prompt}` as JSON, opening nothing (`thread` = the follow-on decision).
- Inbox is pinned first in the sidebar (`herdr/plugins/pin-inbox`), and sessions file themselves: on your first reply (the 2nd prompt a pi process sees), `pi/dot-pi/agent/extensions/herdr-inbox-file.ts` has a fast model pick an existing topic workspace from workspace and tab names, then moves the pane into a new tab there (focus follows if you're looking at it, otherwise a Herdr toast). If nothing fits, it stays in Inbox. Log: `~/.local/state/herdr-inbox-file/log.jsonl`.
- Code: `bin/dot-local/bin/ag-inbox`; LaunchAgent: `com.nathan.ag-inbox` (only runs on ag).
- Log: `~/.local/state/ag-inbox/log.jsonl`, one line per step (`received → screenshot → routed → tab → pi_started → sent`, or `route_failed`/`jev_failed`/`duplicate`/`failed`). Server output: `/tmp/ag-inbox.log`.
- Restart after edits: `launchctl kickstart -k gui/$(id -u)/com.nathan.ag-inbox`.
- Voice: a multipart `audio` field (or a queued audio file sent as `text`) is saved to `~/inbox/capture/` and transcribed with Whisper via TrueFoundry (`whisper-1`, falling back to `openai-esw/whisper-1`); the transcript is the prompt (log step `transcribed`, or `stt_failed`, in which case the agent gets the file path).
- iPhone Action Button capture (voice by default, typed on a second press; screenshot either way): `ios-shortcuts/capture-to-ag.md`. iPhone share sheet: `ios-shortcuts/share-to-ag.md`.

## Tickler (deferred tasks)

GTD tickler for Herdr. Say it in plain text to any pi agent ("do X Friday at 9", "send this back to me in two weeks"); the agent calls the `tickler` tool. At that time a new tab `⏰ <title>` opens in the same Herdr workspace (falls back to `Inbox`), running pi **forked from the conversation that deferred it**, with the task as its first prompt. Nothing is focused; a Herdr notification fires.

- Tool: `pi/dot-pi/agent/extensions/tickler.ts` (schedule / list / cancel). CLI: `bin/dot-local/bin/tickler add|list|cancel|fire`.
- LaunchAgent `com.nathan.tickler` runs `tickler fire` every 60s, only on ag (the host). Items missed while asleep fire on wake and say they're late.
- State: `~/.local/state/tickler/<id>.json`; log `log.jsonl` beside them (`added → fired`, or `failed` with the error). launchd output: `/tmp/tickler.log`.
- **Presence trigger** ("resume this next time I'm on the client"): the agent schedules with `when: "online"` instead of a time (CLI `tickler add --when online …`). It opens as `🟢 <title>` on Nathan's next arrival at the client after it was queued, once. Uses `presence` below.

## Presence ("Nathan is online")

`presence` on ag answers "is Nathan actually at the client Mac right now?" Run `presence` (one line) or `presence status --json`.

- **How:** LaunchAgent `com.nathan.presence` runs `presence poll` every 30s, only on ag. One SSH call to the client (`$PRESENCE_CLIENT`, default `nathan-dev-client`; ControlMaster keeps it ~0.2s) reads HID idle time (real keyboard/mouse/trackpad input), `IOConsoleLocked`, and the console user. Nothing runs on the client, so there's no client setup; a sleeping client just stops answering.
- **Debounce:** **online** after ≥ 90s of continuous activity (input within the last minute, unlocked), so a brief wake doesn't count. **Offline** when locked, unreachable 3 polls in a row (asleep / off Tailscale), or no input for 15 min. Short idle stretches (reading) stay online. While a `client-cua` job runs on the client, its synthetic input is ignored (state held, arrival streak reset).
- **Arrival:** on each offline → online transition it runs `tickler fire`, which launches the `when online` items queued before that arrival (plus the every-minute backstop). `tickler fire` takes a lock so the two runs can't double-fire.
- State: `~/.local/state/presence/state.json` (`state`, `online_since`, `last_seen`, `idle_s`, …); transitions in `log.jsonl` beside it. launchd output: `/tmp/presence.log`. State older than 5 min reads as `unknown` (poller not running).
- Not detected: Nathan on the phone only, or at a client not in `machines/README.md`. Jump Desktop input from ag into the client would count as presence.

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
- In use here:
  - `pi/dot-pi/agent/extensions/herdr-tab-name.ts`: keeps Herdr tab names accurate (`noul`: does the label still fit the recent prompts?; see Herdr config).
  - `ag-inbox` screenshot gate: `noul`, does the capture need the screenshot? (see "ag inbox").
  - `ag-inbox` follow-on routing: `noul` (refers to ongoing work?) + `choice` over open sessions and `none`, to deliver a capture into the session it continues (see "ag inbox"). A worked example of the "pick from a list with a no-match option" pattern; with 60+ options, including each session's latest prompt noticeably raised the right answer's probability.

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
- **Session deep links**: `session-link` prints `http://<ag>:7374/m/<pi session id>`.
  `file-inbox` resolves the session's current pane (it survives the Inbox auto-filer)
  and 302s to `moshi://herdr?workspace=…&tab=…&pane=…`, which resumes Moshi's
  already-open ag card on that pane (Moshi can't open a new connection from a link).
  The http hop exists because iMessage doesn't linkify `moshi://`.
- **Phone texts when agents finish**: `pi/dot-pi/agent/extensions/ag-notify.ts` texts
  `✅ Done` or `⚠️ Attention needed` + tab name, a one-line "what happened / what to do"
  headline (fast LLM), and the `session-link`, when a turn ends while Nathan is away
  (`presence`) or after a turn of 2+ minutes. `AG_NOTIFY=always|off` overrides per session.
  Sent by `ag-text`: Telegram bot "ag" if Keychain items `ag telegram bot` (token) and
  `ag telegram chat` (chat id) exist, else iMessage from the client Mac (needs it awake).
  Log: `~/.local/state/ag-notify/log.jsonl`.
- **Shortcuts**: the same Herdr shortcuts as the Mac, per
  [`herdr/SHORTCUTS.md`](herdr/SHORTCUTS.md). Moshi forwards Cmd keys to Herdr,
  except Cmd+N/W/O/K/V/1–9, which it keeps for itself; use `Ctrl+B` + key for those.
- **Line breaks**: Shift+Tab inserts a newline in Pi (Moshi's Shift+Enter arrives
  as plain Enter). Set in `pi/dot-pi/agent/keybindings.json`, so it applies on every
  client; thinking-level cycling moved from Shift+Tab to Alt+T. Open Pi sessions need `/reload`.

## Herdr config

Tab names stay accurate on their own (`pi/dot-pi/agent/extensions/herdr-tab-name.ts`). On every prompt, in the background: a default numeric tab gets named by a fast LLM; otherwise Jev scores whether the label still fits the last 3 prompts, and if P(accurate) < 0.6 the LLM renames it. Renaming a tab by hand pins it for that session. Decisions are logged to `~/.local/state/herdr-tab-name/log.jsonl` (label, `p_accurate`, keep/rename) for tuning the threshold. Open pi sessions need `/reload` to pick up changes.

`herdr/dot-config/herdr/config.toml` stows to `~/.config/herdr/config.toml`.
Only config, plugins, and agent integrations are tracked; Herdr's sockets, logs,
`session.json`, and `plugins.json` stay local. Apply config changes with
`herdr server reload-config`.

- `herdr/plugins/`: `recent-agents` (sidebar Agents sorted newest state change
  first), `tab-bubbles` (● on a tab per agent that finished or needs input
  while you weren't looking; visiting clears it), and `pin-inbox` (keeps the
  Inbox workspace first).
- Panes can move between workspaces (Inbox auto-filing), so `HERDR_TAB_ID` and
  `HERDR_WORKSPACE_ID` can go stale; `HERDR_PANE_ID` stays valid (Herdr aliases
  it). Resolve the live location with `herdr pane get "$HERDR_PANE_ID"`.
- Agent integrations (`herdr integration install <agent>` output) are stowed
  from `pi/`, `claude/` (`hooks/` + `settings.json` hook), and `codex/`
  (`herdr-agent-state.sh`, `hooks.json`).
- After stowing on a new machine, run `herdr/setup.sh` to register the plugins.
- Shortcuts: canonical list and per-device behavior in
  [`herdr/SHORTCUTS.md`](herdr/SHORTCUTS.md) (spec `shortcuts.json`, verified by
  `herdr-shortcuts-check`).

## Memory watch

`bin/dot-local/bin/mem-watch` (LaunchAgent `com.nathan.mem-watch`, every 5 min, all
machines) logs a memory sample to `~/Library/Logs/mem-watch.log` and notifies Nathan
(at most hourly per alert) when macOS memory pressure is warn/critical, swap in use
is >= 8 GB, or a single process holds >= 3 GB. Alerts from the host go to the
client's notifications (over SSH) plus a Herdr toast. Run `mem-watch` for a status
table of every machine. Thresholds: `MEMWATCH_SWAP_GB`, `MEMWATCH_PROC_GB`.

## Pi session hibernation

Idle pi sessions cost ~100-200 MB each, and dozens stay open as GTD items. Like
Chrome's tab discarding, `bin/dot-local/bin/pi-hibernate` (LaunchAgent
`com.nathan.pi-hibernate`, KeepAlive, only on ag) stops idle ones and wakes them on
demand: every 10 min it hibernates pi panes whose Herdr state is `idle` (`done` keeps
its badge), that aren't focused or in the Inbox workspace, whose session file is
unchanged for 2 h (30 min under macOS memory pressure), and whose pi has no child
processes besides MCP helpers. The pane then shows a sleep screen; focusing the pane
(the daemon watches Herdr focus events) or pressing any key runs
`pi --session <file>`, restoring the full conversation. Ctrl+C on the sleep screen
drops to a shell. Manual: `pi-hibernate sweep [-n] [--all]`, `pi-hibernate pane <id>`,
`pi-hibernate status`. Thresholds: `PI_HIBERNATE_IDLE_MIN`,
`PI_HIBERNATE_PRESSURE_IDLE_MIN`. Log: `~/.local/state/pi-hibernate/log`. Scrollback
and in-flight process state don't survive; the conversation does.

## Shared MCP gateway (Pi)

Pi's stdio MCP bridges (`linear`, `arcade_school`, `honeycomb`, `tsa_courses`) run
**once per machine** instead of once per Pi session: `bin/dot-local/bin/mcp-gateway`
(LaunchAgent `com.nathan.mcp-gateway`, KeepAlive, all machines) runs each server's
`mcp-remote` behind its own pinned `mcp-proxy` (via `uvx`) on
`127.0.0.1:7381`–`7384/mcp`, and `pi/dot-pi/agent/mcp.json` points at those URLs
(`slack` stays direct HTTP). Per-session bridges cost ~100 MB each (96 sessions used
~9.5 GB on ag). Server commands and ports live in the script; logs in
`$TMPDIR/mcp-gateway/<server>.log`. Check with `mcp-gateway status`. After editing
it, `launchctl kickstart -k gui/$UID/com.nathan.mcp-gateway`; open Pi sessions
reconnect on their own.

## Texas Sports Academy MCP (arcade.school)

Pi (via the shared MCP gateway above) and Codex register `arcade_school` using
`mcp-remote@0.8.3`, bridging stdio locally to Streamable HTTP at
`https://api.texassportsacademy.com/mcp`. Bun must be installed at `~/.bun/bin/bunx`.

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
- **Reviewing on the phone**: on ag, `show` also publishes HTML pages, folders, and Markdown
  (rendered with pandoc) to `~/review/<name>/` and prints `phone: http://100.107.192.32:7374/r/<name>/`.
  `file-inbox` serves them to the tailnet, adding a phone viewport and a **Comment** button to HTML.
  A comment posts to `/r/<name>/comment` and is sent as a prompt to the pi session that ran `show`
  (matched by `$PI_SESSION_FILE` in `~/review/<name>/.meta.json`, so it survives pane moves), with
  the section heading he was reading. If that session is gone, it opens a new Inbox session.
  Nothing is exposed beyond Tailscale. Old pages in `~/review` can be deleted anytime.
- **Client desktop automation**: `client-cua "<task>"` runs Codex computer use on the client's GUI
  session (via `launchctl submit`; plain ssh can't see the screen).
- **Phone → ag**: `file-inbox` (LaunchAgent `com.nathan.file-inbox`, port 7374, Tailscale only)
  saves uploads to `~/inbox/phone` and can prompt a recent pi session or open a new one. The iOS
  Shortcut is documented in `ios-shortcuts/send-to-ag.md`. Log: `/tmp/file-inbox.log`.
- **Links to Herdr tabs**: `herdr-link <tab_id>` / `herdr-link --grep <regex>` prints
  `http://ag:7374/focus?tab=<id>`. Cmd+click in Ghostty → file-inbox runs `herdr tab focus`, then
  redirects to `hammerspoon://herdr-return` (client Hammerspoon closes the browser tab, refocuses
  Ghostty). Plain http because Herdr strips OSC 8 and Ghostty only auto-links standard schemes.
