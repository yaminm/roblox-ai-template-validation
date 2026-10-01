# Codex Start Here

You are validating an AI-first Roblox development harness, not merely finishing a demo game.

Read, in order:
1. `AGENTS.md`
2. `docs/HARNESS_CONTEXT.md`
3. `GAME.md`
4. `docs/OWNERSHIP.md`
5. `docs/ARCHITECTURE.md`
6. `docs/TESTING.md`
7. `docs/SECURITY.md`

Then inspect the repository and current Git state. Do not assume the existing implementation is correct.

## Mission

Bring the Crystal Rush validation project to a genuinely verified playable state using the repository's intended harness:

- install/use the pinned toolchain;
- get repository verification passing;
- build/sync through Rojo;
- connect to Roblox Studio through the official Studio MCP server;
- inspect the resulting DataModel;
- playtest the game;
- exercise the full V1 loop: collect crystal -> carry -> deposit -> coins -> buy speed upgrade;
- inspect Output and relevant state;
- fix defects you encounter;
- re-run verification after fixes.

Do not expand product scope unless it is necessary to validate the harness.

If repository setup, agent instructions, tooling, verification scripts, or ownership rules create unnecessary friction, treat that as a harness/template defect and improve the reusable design rather than adding an opaque one-off workaround.

Do not claim completion unless both repository verification and required Studio/MCP runtime verification have actually passed. If a required environment capability is unavailable, state exactly what remains pending.

At the end, report:
- what you changed;
- commands/checks run and their results;
- Studio/MCP scenarios exercised and observed evidence;
- harness/template improvements you recommend;
- remaining risks or unverified items.