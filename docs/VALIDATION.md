# Crystal Rush harness validation — 2026-10-02

The full repository gate and single-player Studio/MCP runtime acceptance passed.
The baseline was PR #1 at `4c7d23e`; the existing implementation and pinned Rokit
toolchain were preserved. No place was published and no dependencies were added.

## Runtime fixes

- Collected crystals became invisible while remaining collidable. A real touch
  probe observed `Transparency=1`, `CanTouch=false`, `CanCollide=true`. Crystals
  now remain non-colliding, including while collected and after respawn.
- The status HUD overlapped Roblox chat. It now sits at the bottom center, caps
  its width at 460 pixels, and scales text to fit narrower viewports.
- The initial acceptance probe could not require Config inside MCP's capability
  sandbox. The corrected probe takes repository tuning as a factory argument;
  no runtime capability or gameplay authority was changed. Its first failed
  diagnostic appeared in Output. The corrected suite was repeated in a fresh
  playtest, with empty final Output and no server/client errors or warnings.

## Repository checks

`./scripts/verify.sh` passed formatting, Selene linting (zero errors/warnings),
Rojo sourcemap generation, Roblox-aware luau-lsp analysis of source **and tests**,
economy unit tests, and Rojo build. `git diff --check` passed.

`tests/StudioAcceptance.luau` contains bounded client movement and server-state
probes. Client steps position the character near a target and use Humanoid
movement and real physics touch events. They never set carried crystals, coins,
upgrade level, rewards, or round time. Server probes check authoritative state.

## Studio evidence

The official `Roblox_Studio` server exposed its tools and targeted the rebuilt
`CrystalRushRuntimeAcceptance.rbxlx` instance. All four game script/module sources
were compared with disk and matched exactly after the playtest. Persistent
`Script.Source` was never edited through MCP.

Studio constructed an arena containing 18 crystals and 22 total parts. The
following milestones passed in a real client/server playtest:

| Scenario | Carried | Coins | SpeedLevel | WalkSpeed |
| --- | ---: | ---: | ---: | ---: |
| Fresh spawn / insufficient-funds rejection | 0 | 0 | 0 | 16 |
| Collect three | 3 | 0 | 0 | 16 |
| Deposit three | 0 | 30 | 0 | 16 |
| First purchase | 0 | 0 | 1 | 20 |
| Fill capacity; sixth crystal rejected | 5 | 0 | 1 | 20 |
| Deposit five | 0 | 50 | 1 | 20 |
| Second purchase | 0 | 20 | 2 | 24 |
| Collect and deposit five more | 0 | 70 | 2 | 24 |
| Third purchase | 0 | 40 | 3 | 28 |
| Fourth purchase rejected despite sufficient coins | 0 | 40 | 3 | 28 |
| Character death and automatic respawn | 0 | 40 | 3 | 28 |

The rejected sixth crystal remained visible and available. Collected crystals
respawned and could be collected again. All crystal collision checks passed.
The server timer counted down naturally through zero and restarted at 180;
the observer recorded `Ticked=true`, `SawZero=true`, and `Restarted=true`.

The client HUD matched replicated carried count, coins, speed level, and timer,
including after respawn. At a 797×693 viewport its 460×56 status panel fit fully
on screen; `TextFits=true`. Screenshots confirm it is clear of the chat area.

Server and client `LogService` checks each returned an empty error/warning list.
Studio MCP `get_console_output` returned an empty string after the clean suite
and after stopping play. The temporary round observer and its event connection
were removed; no test objects remained. Studio was returned to Edit mode.

- [Machine-readable acceptance observations](evidence/studio-acceptance.json)
- [First upgrade screenshot](evidence/crystal-rush-first-upgrade.jpg)
- [Completed acceptance screenshot](evidence/crystal-rush-complete.jpg)

## Harness lessons and limits

Verify the loaded Studio source after every rebuild: file-open attempts encountered
auto-recovery and stale instances during setup. A direct file-open event eventually
loaded the intended build, and source comparison identified the correct instance.
For repeated source changes, a configured Rojo plugin/live sync should avoid this
rebuild/reopen friction. Use bounded movement probes when navigation tools stall,
and treat MCP sandbox import restrictions separately from game failures.

This evidence covers one Studio player and the tested desktop viewport.
Multiplayer concurrency and mobile layouts were not playtested.
