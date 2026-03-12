# AskMe Skill — Refined Spec

## Overview

AskMe is a Claude Code skill (`/askme`) that conducts a deep, non-obvious technical interview about a plan, design, or project idea. Unlike the `interview` skill, it uses no Claude-specific tools (no `AskUserQuestion`) — just plain conversational back-and-forth — making it usable by any model within the Claude ecosystem. Its goal is to eliminate assumptions by surfacing technology interactions, edge cases, and pitfalls that the user hasn't considered.

## Location & Configuration

- **Path:** `agent-skills/_shared-skills/askme/SKILL.md`
- **Trigger:** `/askme [plan]`
- **Model:** No model hint in frontmatter — uses whatever the user's session/default model is
- **Argument:** Optional file path (`$1`). If provided, reads the file as context. If omitted, bootstraps by asking the user what they're building.

## Input Behavior

- **With file argument:** Read the plan file, then begin the interview grounded in its contents.
- **With conversation context (no file):** Use whatever has been discussed in the current conversation as the starting point.
- **Cold start (no file, no context):** Ask "What are you building?" and bootstrap from there.

## Codebase Awareness

The skill is **adaptive** about codebase exploration:

- If running inside a repository, perform a **surface scan** first (dependency files, directory structure, config files) to understand the tech stack.
- Then do **targeted deep dives** into specific files referenced by the plan or that look relevant to identified risks (e.g., if the plan mentions auth, read the auth module).
- If no codebase is available, degrade gracefully to description-only questioning.

When codebase observations inform a question, **show the reasoning** — explain what was found and why it's relevant before asking. E.g., "I see you have both X and Y in your deps — how do these interact for Z?"

## Question Philosophy

- **Never ask obvious questions.** Focus on technology interactions, hidden coupling, edge cases, failure modes, and second-order consequences.
- **Accept stated decisions.** Don't re-litigate choices already made in the plan. Probe the gaps and unknowns around those decisions instead.
- **Stack-aware domains.** Dynamically choose question domains based on the detected tech stack. Don't ask about hydration if there's no SSR; don't ask about connection pooling if there's no database.
- **App-level scope.** Focus on code architecture, data flow, APIs, state management, and UX. Don't venture into deployment/infra/ops unless the plan explicitly discusses it.

## Question Flow

1. **Quick context calibration** — One round of high-level questions to understand the user's goals, constraints, and what they've already decided. This is brief, not exhaustive.
2. **Non-obvious deep dive** — Jump into edge cases, technology interactions, and pitfalls. This is where the skill spends most of its time.
3. **Blocker resolution** — If an answer reveals a fundamental problem (architectural incompatibility, contradictory requirements), **pause the interview** to help think through the blocker before continuing.

## Interaction Style

- **Flexible grouping.** Sometimes ask one focused question, sometimes batch 2-3 related questions. Let complexity dictate.
- **Plain text questions.** No tool-based UI — just ask in conversation and wait for the user's reply.

## Termination Condition

Continue interviewing until the model has **zero remaining assumptions** — a deep enough understanding that it could implement the plan without guessing. There is no fixed round limit. The skill should self-assess whether it has enough information to produce a complete, unambiguous spec.

## Output

- **Format:** A fully rewritten, refined spec that incorporates all decisions, details, and risks discovered during the interview. The document structure may differ entirely from the original plan — optimize for clarity and completeness.
- **Risks:** Woven inline into relevant sections, not in a separate risks section.
- **Target:** Overwrite the input file (`$1`) with the refined spec. If no file was provided, ask the user where to write it.
