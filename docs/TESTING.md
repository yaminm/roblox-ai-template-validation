# Testing

Install Rokit and have Python 3 available, then run:

```sh
./scripts/bootstrap.sh
./scripts/verify.sh
```

`rokit.toml` is the only tool manifest. Bootstrap installs its exact Rojo,
luau-lsp, Lune, Selene, and StyLua versions; it never updates pins. If GitHub CLI
is logged into github.com, bootstrap reuses that credential for Rokit through
an atomic, owner-only `auth.toml` write. Tokens are never printed or passed in
command arguments. To select a personal account on a workstation with multiple
accounts, set `git config --local harness.githubUser YOUR_LOGIN` (or export
`ROKIT_GITHUB_USER`). Bootstrap requests that account explicitly and never falls
back to a different CLI account. Without that login it uses existing Rokit authentication;
if GitHub rate-limits downloads, sign in with `gh auth login --hostname github.com`
and rerun bootstrap. Do not paste credentials into repository files.

The GitHub Actions workflow `.github/workflows/verify.yml` runs on pull requests
and pushes to `main`. It installs Rokit 1.2.0, runs the same bootstrap, then
`./scripts/verify.sh`; there is no separate CI verification path. Its read-only
GitHub token is passed through GitHub CLI to the existing private Rokit credential
writer, avoiding unauthenticated download rate limits.

Bootstrap also downloads checksum-pinned Roblox definitions from luau-lsp
1.70.1. Verification checks Git whitespace errors in staged and unstaged changes,
the definitions, formatting, linting, Rojo sourcemap,
Roblox-aware type analysis, and unit tests, then creates
`build/CrystalRush.rbxlx`. The single shell entry point is the verification gate;
Lune runs only the pure unit tests. Run either script from any directory.

Selene uses the checked-in `tooling/roblox.yml` snapshot rather than its floating
network cache. The snapshot was generated with Selene 0.31.0 on 2026-10-01.
Review explicit snapshot and analyzer-definition updates when changing tool pins.
After bootstrap, verification requires no network access.

## Studio acceptance

Open the built place in Roblox Studio, or run `rojo serve default.project.json`
and connect the Rojo plugin to the local server. Git remains authoritative for
scripts; never repair persistent source through Studio MCP.

Enable the official built-in MCP server in Studio: Assistant → … → Manage MCP
Servers → **Enable Studio as MCP server**. On macOS its stdio proxy is
`/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP`. An MCP initialization
response alone does not prove Studio is connected: the proxy must expose tools
and successfully inspect the intended Studio instance. An empty tool list means
runtime acceptance is pending. See the [official connection guide](https://create.roblox.com/docs/studio/mcp).

Runtime acceptance requires the official Roblox Studio MCP server: open the
Rojo-synced place, inspect expected services, start a playtest, collect three
crystals, deposit them, buy speed, confirm attributes (`Carried=0`, `Coins=30`,
then `Coins=0`, `SpeedLevel=1`) and WalkSpeed 20, and
confirm Output has no new errors. Runtime verification cannot be substituted by
a build.

Also exercise carry capacity, crystal respawn, insufficient funds, the three-level
speed cap, HUD values and timer, and character respawn. Collect and purchase
through actual touch interactions; do not grant currency or mutate gameplay
attributes to manufacture a passing result. Read server and client Output, capture
visual evidence, and remove temporary probes before ending the playtest.

`tests/StudioAcceptance.luau` provides bounded MCP probes for this flow. Read the
file from disk and evaluate it inside a function through `execute_luau`, then call
the returned factory with tuning evaluated from the repository's `Config.lua`,
then call the resulting table's methods. The MCP sandbox cannot necessarily
`require` an existing game module; passing tuning avoids changing its capabilities.
Do not create or edit a Studio script to load the probe.
`collect`, `visitPad`, `checkCapacity`, `checkRespawn`, and `checkHUD` run on Client;
`expectServer`, `beginRoundProbe`, `finishRoundProbe`, and `respawnCharacter` run
on Server. Movement starts the character near a target, then uses Humanoid
movement and actual physics touch events. Rewards and purchases use the game's
handlers; the probe never writes inventory, coins, speed level, or round time.

From a fresh playtest, check server state `(Carried, Coins, SpeedLevel)` at these
milestones: `(0,0,0)` → collect three `(3,0,0)` → deposit `(0,30,0)` → buy speed
`(0,0,1)` with WalkSpeed 20. Fill to five, attempt a sixth, deposit for 50 coins,
and earn enough through additional collection/deposit cycles to reach level
three. Attempt another purchase with sufficient coins and confirm the cap.
The round observer requires a natural countdown through zero and restart; it
removes its temporary folder and event connection when finished. Stop play after
reading both server state and client HUD and checking Output.

The completed 2026-10-02 acceptance run is recorded in [VALIDATION.md](VALIDATION.md).
