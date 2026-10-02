# Architecture

`ReplicatedStorage.Shared.Config` contains immutable tuning. `ServerScriptService`
owns the arena, crystals, player attributes, collection, deposits, purchases,
and rounds. `StarterPlayerScripts` renders a read-only attribute-driven HUD.

Touch interactions are server-observed, so V1 needs no client-to-server remote.
This deliberately minimizes its exploit surface while retaining multiplayer-safe
authoritative state.
