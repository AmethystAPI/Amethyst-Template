# Amethyst-Template

Opinionated template for an Amethyst Mod, will be the base mod used in all amethyst guides! Follow the steps below to build the mod

## How to configure

1. Open `xmake.lua` and configure the mod options:
```
-- Mod Options
local mod_name = "Amethyst-Template" -- Replace with the name of your mod
```

2. Open `data/packs/RP/manifest.json` and replace the name, and generate the two new UUIDv4s [here](https://www.uuidgenerator.net/version4)

3. Open `.github/build.yml` and replace the mod name
```
env:
    MOD_NAME: Amethyst-Template # Replace with your mod name
```

4. Open `mod.json` and fill in all the mod options there too.
```
{
    "meta": {
        "name": "Amethyst-Template",
        "version": "1.0.0",
        "namespace": "amethyst_template",
        "author": "FrederoxDev"
    }
}
```

5. Open `data/packs/RP/textures/item_texture.ts` and edit the project namespace to match the `mod.json`
```
const projectNamespace = "amethyst_template";
```

## Building

1. To generate a visual studio solution run the command:
```
xmake project -k vsxmake -m "release"
```

2. Open the `.sln` file in `./vsxmake2022`

3. To build your project, either press `Ctrl+Shift+B` in visual studio OR run the `xmake` command

4. To build your RP/BP run these commands
```
cd data
rgl watch
```

## Additional Information

Any textures placed into the textures/items