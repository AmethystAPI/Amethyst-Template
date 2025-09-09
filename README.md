# Usage Guide

Start by selecting `Use this template` > `Create a new Repository` and setup a repository. Next clone the repository, and replace the information at the start of the `xmake.lua` file.

```lua
-- Mod Options
local mod_name = "Amethyst-Template" -- Replace with the name of your mod
local targetMajor, targetMinor, targetPatch = 1, 21, 3 -- Replace with the target minecraft version
```

Next replace `Amethyst-Template` in `data/config.json` to your mods name. To build the addon for your pack you can use [rgl](https://github.com/ink0rr/rgl)
```
cd data
rgl watch
```

## Loading BP/RP's

To load BP/RP's alongside your mod, add a `manifest.json` to `data/packs/(RP|BP)` and Amethyst-Runtime will automatically load the pack.
