# Crystal Rush Validation — Canonical Context for Coding Agents

## Purpose

This repository is the real-world validation project for `yaminm/roblox-ai-game-template`.

Its primary goal is not to become a polished commercial game. Its job is to prove that the reusable Roblox AI development harness works end to end with coding agents, especially Codex.

A successful validation means an agent can enter the repository with a short instruction, discover the repository contract itself, make changes safely, run repository verification, sync through Rojo, connect to Roblox Studio through the official MCP server, playtest the game, observe failures, fix them, and produce evidence before claiming completion.

## Parent harness decisions

The following decisions are already settled unless a concrete validation failure proves they need revision:

- Git/filesystem is canonical for Luau source, configuration, tests, durable docs, and reproducible/simple world definitions.
- Rojo is the default filesystem-to-Studio bridge.
- Do not use Script Sync on Rojo-owned scripts.
- Roblox Studio is the authoritative engine/runtime/visual environment.
- Roblox Studio MCP is used for DataModel inspection, playtests, Output, interaction, screenshots, temporary probes, and appropriate Studio-owned workflows.
- MCP must not permanently edit Rojo-owned Script.Source.
- Native Luau is preferred, normally `--!strict`.
- Keep the baseline framework-light: no Knit/React/state/network/persistence framework until a real requirement justifies one.
- Server owns authoritative game state/economy/security-sensitive outcomes; clients send intent and render presentation.
- `AGENTS.md` is the operational contract for coding agents.
- A plausible code diff is not completion. Runtime changes require Studio/MCP verification.
- Safe/local actions should be highly automatable; destructive/production actions require explicit human approval.
- Creator Store / third-party scripts are untrusted until inspected.

## Validation game: Crystal Rush

### North star

A tiny multiplayer-ready arena that proves the harness can implement, secure, verify, and debug a complete Roblox gameplay loop.

### Core loop

`collect crystal -> carry crystal -> deposit at base -> earn coins -> buy speed -> collect faster`

### V1 scope

- A small runtime arena exists.
- Crystals can be collected.
- Carry capacity is enforced.
- Crystals respawn.
- A deposit zone converts carried crystals to coins.
- HUD shows carried crystals, coins, and round state/timer.
- A speed upgrade can be purchased.
- Purchase decisions and currency mutation are server-authoritative.
- Remote input is validated/rate-limited where relevant.
- Economy/domain math has fast pure tests.
- Static verification and Rojo build pass.
- Gameplay is actually exercised through Roblox Studio MCP.

### Explicit non-goals

Do not expand this project into persistence, matchmaking, monetization, polished art, production deployment, complex content pipelines, or large gameplay scope unless doing so is explicitly required to validate a harness capability.

## What this project is supposed to test

Crystal Rush intentionally touches multiple layers:

- `server`: authoritative rules, collection/deposit/economy/round flow;
- `client`: UI and user intent;
- `shared`: configuration/domain logic/types/contracts;
- networking/remotes;
- world/DataModel organization;
- security boundaries;
- unit/static verification;
- Rojo sync/build;
- Studio runtime behavior;
- MCP inspection and playtesting;
- visual/UI verification;
- eventually multiplayer scenario testing.

## Required agent workflow

Before editing:
1. Read `AGENTS.md`.
2. Read `GAME.md`.
3. Read this document.
4. Read `docs/OWNERSHIP.md`, `docs/ARCHITECTURE.md`, `docs/TESTING.md`, and `docs/SECURITY.md`.
5. Inspect the current repo and Git status before assuming the implementation state.

For implementation:
1. Make the smallest coherent change.
2. Keep persistent source changes on disk, not in MCP Script.Source.
3. Run `lune run scripts/verify.luau` and repair failures.
4. Start/sync Rojo according to the repository setup.
5. Use Roblox Studio MCP to inspect relevant instances.
6. Start a playtest and exercise the actual changed behavior.
7. Read Output and resolve new errors/warnings caused by the change.
8. Use visual evidence for UI/world changes.
9. Repeat until the acceptance criteria really pass.

Completion must report:
- files/behavior changed;
- exact verification commands/results;
- Studio/MCP runtime scenarios exercised;
- observed evidence;
- anything still unverified or risky.

Do not claim Studio/MCP verification passed if Studio/MCP was unavailable.

## Guardrails

### Source ownership

`src/**`, tests, configs, and durable docs are filesystem/Git owned.

MCP may inspect them after Rojo sync, but it must not create a second persistent source of truth by editing their Studio Source.

Temporary probes/test objects created through Studio must be removed or intentionally promoted to a repository-owned representation.

### Security

Treat every client call as untrusted. Validate type, range/value, permission/context, and rate where appropriate.

Never trust client-supplied currency, inventory, rewards, purchase success, cooldown completion, or other authoritative outcomes.

### Change discipline

Do not do unrelated refactors. Do not add frameworks/dependencies because they are fashionable or convenient. Dependency changes require explicit human approval and a clear rationale.

Do not invent many planning documents. Update durable docs when the architecture/policy truly changes; significant decisions belong in an ADR.

### Production/destructive actions

Do not publish/deploy, mutate production DataStores/Open Cloud, upload paid/public assets, force-push, delete branches, or perform broad destructive changes without explicit human approval.

## Current status and next mission

The project was created as the validation copy of the reusable template and contains an initial Crystal Rush V1 implementation. It has not yet been proven end-to-end on the user's workstation with Roblox Studio MCP.

The next mission for Codex is therefore validation and repair, not feature expansion:

1. inspect the repository and understand its contract;
2. make the local toolchain/install/bootstrap work cleanly;
3. get fast verification passing;
4. build/sync the project through Rojo;
5. connect to Roblox Studio MCP;
6. confirm the expected DataModel structure;
7. run Crystal Rush;
8. exercise collect -> carry -> deposit -> coins -> speed upgrade;
9. inspect server/client Output;
10. find and fix any setup/runtime/gameplay defects;
11. verify again and provide evidence.

If the harness itself causes friction or requires repeated ad-hoc instructions, treat that as a template defect. Prefer improving the reusable harness/guardrails rather than adding a one-off workaround only to the validation game.

## Success criterion

The validation succeeds when Codex can complete the mission above from repository context plus a short kickoff prompt, with minimal human hand-holding. The point is to prove the harness makes the coding agent dependable, not merely that Crystal Rush can run.