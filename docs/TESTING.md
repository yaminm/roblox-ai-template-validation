# Testing

Run `./scripts/bootstrap.sh` to install pinned Aftman tools and then
`./scripts/verify.sh`. Verification formats/checks Luau, runs static analysis and
unit tests, and creates `build/CrystalRush.rbxlx` with Rojo.

Runtime acceptance requires the official Roblox Studio MCP server: open the
Rojo-synced place, inspect expected services, start a playtest, collect three
crystals, deposit them, buy speed, confirm attributes (`Carried=0`, `Coins=30`,
then `Coins=0`, `SpeedLevel=1`) and WalkSpeed 20, and
confirm Output has no new errors. Runtime verification cannot be substituted by
a build.
