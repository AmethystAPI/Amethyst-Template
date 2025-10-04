-- Mod Options
local mod_name = "Amethyst-Template" -- Replace with the name of your mod
local targetMajor, targetMinor, targetPatch = 1, 21, 3 -- 1.21.0.3 (Other versions not supported by Amethyst)

option("automated_build")
    set_default(false)
    set_showmenu(true)
    set_description("Flag to indicate this is an automated build")
option_end()

local automated = is_config("automated_build", true)

local build_script_path
if automated then
    build_script_path = path.join("Amethyst", "AmethystAPI", "mod_build.lua")
else
    build_script_path = path.join(os.getenv(("AMETHYST_SRC")), "AmethystAPI", "mod_build.lua")
end

if not os.isfile(build_script_path) then
    print("Failed to find build script!" .. build_script_path)
else 
    includes(build_script_path)
    build_mod(mod_name, targetMajor, targetMinor, targetPatch, automated)
end