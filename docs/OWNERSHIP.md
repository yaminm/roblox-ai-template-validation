# Ownership

`src`, `tests`, project/configuration files, scripts, and durable documentation
are Git-owned and sync to Studio with Rojo. The runtime arena is intentionally
constructed by the server from repository-owned source. Studio owns transient
playtest state and visual inspection only; temporary probes must be removed.
