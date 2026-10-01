# Agent contract

Read `CODEX_START_HERE.md` and the documents it links before editing. Git is
canonical for source and configuration. Never edit Rojo-owned `Script.Source`
through Studio. Run `./scripts/verify.sh` before committing, then build with
Rojo and validate gameplay through Roblox Studio MCP. Never describe runtime
work as verified unless the Studio playtest was actually performed.

Keep server authority for inventory, currency, purchases, and cooldowns. Do
not add dependencies or publish a place without human approval.
