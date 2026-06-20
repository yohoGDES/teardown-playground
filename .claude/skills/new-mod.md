# new-mod

Scaffold a new Teardown mod in the monorepo.

## Usage

/new-mod <mod-name>

## Steps

1. Read CLAUDE.md to confirm the required mod structure.
2. Create the folder `mods/<mod-name>/` with:
   - `info.txt` — prompt the user for name, author, description if not provided; version defaults to "1.0"
   - `main.lua` — starter template with `init()`, `tick(dt)`, and a `draw()` stub; include a DebugPrint in init() confirming the mod loaded
3. Tell the user the mod is ready and remind them to enable it in the Teardown Mods menu after syncing to the Steam Deck.

## main.lua template

```lua
local modName = "MOD_NAME"

function init()
    DebugPrint(modName .. " loaded")
end

function tick(dt)
end

function draw()
end
```

Replace MOD_NAME with the actual mod name from info.txt.
