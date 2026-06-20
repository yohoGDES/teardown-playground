# validate-mod

Check that a mod in this repo is correctly structured before syncing to the Steam Deck.

## Usage

/validate-mod <mod-name>

If no mod name is given, validate all mods in the mods/ directory.

## Checks

For each mod folder:

1. `info.txt` exists and contains `name`, `author`, `version`, and `description` fields
2. `main.lua` exists
3. `main.lua` defines an `init()` function and a `tick(dt)` function
4. No syntax errors detectable by static inspection (look for unmatched `end`, `do`, `then`)
5. No hardcoded Windows or Mac paths (flag anything with backslashes or `/Users/` `/home/`)

Report: pass/fail per check, with file and line number for any failures.
