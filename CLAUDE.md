# Teardown Playground — Claude Code Context

## What This Repo Is

A monorepo for Teardown game mods. Each mod lives in its own subfolder under `mods/`.
Development happens on a Mac via Claude Code web; mods are tested by pulling to a Steam Deck.

## Repo Structure

```
teardown-playground/
├── mods/                        # One subfolder per mod
│   └── <mod-name>/
│       ├── info.txt             # Required mod manifest
│       ├── main.lua             # Entry point (always named main.lua)
│       └── ...                  # Assets, extra scripts, etc.
├── docs/
│   └── teardown-modding/        # Scraped offline copy of teardowngame.com/modding/
│       ├── index.md
│       ├── api.md
│       └── ...
├── scripts/
│   ├── fetch_docs.py            # Re-scrape the official docs → docs/teardown-modding/
│   └── requirements.txt
└── .claude/
    └── skills/                  # Custom Claude Code skills for this project
```

## Mod Structure

Every mod must have:

```
info.txt        -- manifest (see below)
main.lua        -- entry point; must define at least init() and tick(dt)
```

### info.txt format

```
name = My Mod Name
author = Your Name
version = 1.0
description = What this mod does
```

### Lua callbacks (API v2.0+)

Teardown 2.0 introduced a client/server architecture for multiplayer. The same
script runs on both; you implement callbacks on the `server` and/or `client` tables:

```lua
function server.init()      end  -- once at load
function server.tick(dt)    end  -- once per frame (dt 0.0–0.0333)
function server.update(dt)  end  -- fixed 60Hz, at most twice per frame
function client.draw()      end  -- 2D overlay; Ui* functions only work here
```

Communication between the server and client halves uses the `shared` table
(server-writable, client read-only).

**For simple single-player mods**, the legacy bare callbacks still work and are
the easiest starting point — `function init()`, `function tick(dt)`,
`function draw()`. These run as the server part. Prefer them for early
experiments; move to explicit `server.`/`client.` only when you need multiplayer
or client-side rendering.

See `docs/teardown-modding/api.md` for the full callback list and signatures.

## Lua Style Guide

- Use `local` for all variables unless a global is required by the API
- Name functions with camelCase, files with kebab-case
- Keep `tick()` lean — expensive work belongs in coroutines or spread across frames
- Always guard entity handles: check `IsHandleValid(handle)` before using them
- No global state mutation between `tick()` calls unless stored via `SetValue`/`GetValue`

## API Reference

Offline docs are in `docs/teardown-modding/`. Key files:
- `api.md` — full Lua API function reference
- `index.md` — modding overview and getting started
- `voxscript.md` — VoxScript API for procedural voxel manipulation

To refresh the docs:
```bash
pip install -r scripts/requirements.txt
python scripts/fetch_docs.py
```

The game also ships `script_defs.lua` and `voxscript_defs.lua` inside the Teardown install
directory — copy these into `docs/` from the Steam Deck for IDE autocomplete support.

Steam Deck paths (Teardown runs under Proton, so paths are inside the Wine prefix):
- Game install: `~/.local/share/Steam/steamapps/common/Teardown/`
- User mods: `~/.local/share/Steam/steamapps/compatdata/1167630/pfx/drive_c/users/steamuser/Documents/Teardown/mods/`

## Deploy / Test Workflow

1. Write and commit mod on Mac
2. `git push` to GitHub
3. On Steam Deck (Konsole, Desktop Mode):
   ```bash
   cd ~/.local/share/Steam/steamapps/compatdata/1167630/pfx/drive_c/users/steamuser/Documents/Teardown/mods/teardown-playground
   git pull
   ```
4. Launch Teardown → Mods menu → enable the mod → test

First-time setup on Steam Deck:
```bash
cd ~/.local/share/Steam/steamapps/compatdata/1167630/pfx/drive_c/users/steamuser/Documents/Teardown/mods/
git clone https://github.com/yohogdes/teardown-playground.git
```

## Key Teardown API Facts

- Coordinate system: Y is up
- All measurements are in meters
- `FindBody`, `FindVehicle`, `FindShape` etc. search by tag name set in the level editor
- Tags are set in XML level files with `tags="foo bar"`
- `QueryRaycast(pos, dir, maxDist)` returns `hit, dist, normal, shape`
- UI is drawn in `draw()` via `UiText`, `UiRect`, etc. — not in `tick()`
- `DebugPrint(str)` writes to the in-game console (tilde key)

## Branching

- `master` — stable, tested mods only (default branch)
- `claude/*` — active development branches (Claude Code sessions)
- Feature branches: `feat/<mod-name>/<description>`

## Push Workflow (Claude Code Web)

Claude Code web sessions cannot push directly to GitHub (connector is read-only).
Workflow: Claude writes files here → sends them as downloads → commit from Mac:

```bash
cd ~/Documents/Sites/teardown-playground
git add -A
git commit -m "your message"
git push -u origin master
```
