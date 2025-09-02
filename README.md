# Usage Guide

Start by selecting `Use this template` > `Create a new Repository` and setup a repository. Next clone the repository, and replace the information at the start of the `xmake.lua` file.

```cmake
-- Mod Options
local mod_name = "Amethyst-Template" -- Replace with the name of your mod
local targetMajor, targetMinor, targetPatch = 1, 21, 3 -- Replace with the target minecraft version
```

Next replace `Amethyst-Template` in `data/config.json` to your mods name. To build the addon for your pack you can use [rgl](https://github.com/ink0rr/rgl)
```
cd data
rgl watch
```