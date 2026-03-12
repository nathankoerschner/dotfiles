---
name: askme
description: Deep technical interview that surfaces non-obvious pitfalls, technology interactions, and hidden assumptions in a plan or idea. Use this skill whenever the user wants their plan stress-tested, asks you to poke holes in an idea, wants a design review before implementation, says things like "what am I missing", "help me think through this", or has a plan file they want refined into a detailed spec.
argument-hint: [plan]
---

# AskMe

Conduct a deep, probing interview about a plan, design, or project idea. The goal is to reach a level of understanding where you could implement the plan without making a single assumption — every ambiguity resolved, every interaction mapped, every failure mode considered.

## Getting started

Read the plan file ($1) if one was provided. Otherwise, work from the current conversation context. If neither exists, ask what the user is building and bootstrap from there.

If you're in a repository, do a quick scan of dependency files, directory structure, and configs to understand the tech stack. This context makes your questions dramatically better — knowing that the project uses, say, both an ORM and raw SQL tells you to ask about which owns the connection lifecycle. When the plan references specific modules or your scan reveals something interesting, read those files before forming questions about them.

When a codebase observation informs your question, share it. "I noticed you have both X and Y in your deps — how do these interact for Z?" is far more useful than a generic question about dependency management. It shows the user you're grounded in their actual situation, not asking from a checklist.

## What makes a good question

The value of this skill lives entirely in the quality of the questions. Anyone can ask "what database are you using?" — the questions that matter are the ones the user *hasn't thought about yet*.

Focus on the spaces between decisions: technology interactions, implicit assumptions, failure modes, state management subtleties, API contract gaps, data consistency under concurrent access, error propagation across boundaries. These are the things that work fine in a design doc and break in production.

Respect what's already decided. If the plan says "we're using Postgres," don't ask why not MongoDB. Instead, ask about the things *around* that decision — connection pooling strategy, migration approach, how the schema handles the specific data patterns described in the plan. The user made their choices; help them see the consequences and gaps.

Tailor your domains to what's actually in the tech stack. Asking about SSR hydration when there's no SSR wastes everyone's time. Stay at the application level — architecture, data flow, APIs, state, UX — unless the plan explicitly ventures into infrastructure.

## Pacing and flow

Start with a brief calibration round — a few high-level questions to understand goals, constraints, and the user's mental model. This orients you so the deep dive hits the right areas.

Then go deep. Group questions flexibly based on complexity — sometimes a single focused question deserves its own turn, sometimes 2-3 related questions make sense together. Read the room.

If an answer reveals something fundamental is broken — an architectural incompatibility, contradictory requirements, an approach that can't work — stop the interview and work through it together. There's no point cataloging edge cases if the foundation needs rethinking. Resume once the blocker is resolved.

## When to stop

Keep going until you could write the implementation yourself without guessing. After each answer, ask yourself: "Is there anything I'd still have to assume?" If yes, you have more questions. There's no fixed number of rounds — some plans need 5 questions, some need 50.

## Writing the spec

When the interview is complete, write a refined spec that incorporates everything discovered — decisions, details, constraints, and risks woven naturally into the relevant sections. This is a full rewrite, not an addendum; restructure freely for clarity and completeness. The output should be a document someone could hand to an engineer and say "build this" with zero follow-up questions.

Write to the input file ($1), replacing the original plan. If no file was provided, ask where to save it.
