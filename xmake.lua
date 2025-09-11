-- Mod Options
local mod_name = "Amethyst-Template" -- Replace with the name of your mod
local targetMajor, targetMinor, targetPatch = 1, 21, 3 -- Replace with the target minecraft version

option("automated_build")
    set_default(false)
    set_showmenu(true)
    set_description("Flag to indicate this is an automated build")
option_end()

set_languages("c++23")

local automated = is_config("automated_build", true)
local modFolder
local amethystApiPath

if automated then
    modFolder = path.join(os.projectdir(), "dist")
    amethystApiPath = path.join(os.projectdir(), "Amethyst", "AmethystAPI")
else
    set_symbols("debug")
    local amethystSrc = os.getenv("AMETHYST_SRC")
    amethystApiPath = amethystSrc and path.join(amethystSrc, "AmethystAPI") or nil

    local amethystFolder = path.join(
        os.getenv("localappdata"),
        "Packages",
        "Microsoft.MinecraftUWP_8wekyb3d8bbwe",
        "LocalState",
        "games",
        "com.mojang",
        "amethyst"
    )

    modFolder = path.join(
        amethystFolder,
        "mods",
        string.format("%s@dev", mod_name)
    )
end

-- Only include AmethystAPI if present on disk at configure-time
if amethystApiPath and os.isdir(amethystApiPath) then
    includes(amethystApiPath)
    includes(path.join(amethystApiPath, "packages", "libhat"))
end

-- RelWithDebInfo flags
add_cxxflags("/O2", "/DNDEBUG", "/MD", "/EHsc", "/FS", "/MP")
add_ldflags("/OPT:REF", "/OPT:ICF", "/INCREMENTAL:NO", {force = true})

set_targetdir(modFolder)
set_toolchains("msvc", {asm = "nasm"})

set_project(mod_name)

package("Runtime-Importer")
    set_kind("binary")
    set_homepage("https://github.com/AmethystAPI/Runtime-Importer")
    set_description("The runtime importer enables importing functions and variables from the game just by defining annotations in header files")

    on_load(function (package)
        import("net.http")
        import("core.base.json")
        import("utils.archive")

        local releases_file = path.join(os.tmpdir(), "runtime-importer.releases.json")
        http.download("https://api.github.com/repos/AmethystAPI/Runtime-Importer/releases/latest", releases_file)

        local importer_dir = path.join(os.curdir(), ".importer");
        local bin_dir = path.join(importer_dir, "bin");
        local release = json.loadfile(releases_file)
        local latest_tag = release.tag_name
        local installed_version_file = path.join(importer_dir, "version.txt")
        local installed_version = os.isfile(installed_version_file) and io.readfile(installed_version_file) or "0.0.0"
        local should_reinstall = installed_version ~= latest_tag
        
        if should_reinstall then
            print("Runtime-Importer is outdated, reinstalling...")
            print("Latest version is " .. latest_tag)
            local url = "https://github.com/AmethystAPI/Runtime-Importer/releases/latest/download/Runtime-Importer.zip"
            local zipfile = path.join(os.tmpdir(), "Runtime-Importer.zip")
            print("Installing Runtime-Importer...")

            http.download(url, zipfile)
            archive.extract(zipfile, bin_dir)
            io.writefile(installed_version_file, latest_tag)
        end

        package:addenv("PATH", bin_dir)

        local generated_dir = path.join(importer_dir)
        local pch_file = path.join(generated_dir, "pch.hpp.pch")
        local should_regenerate_pch = os.exists(pch_file) == false or should_reinstall

        if should_regenerate_pch then
            print("Generating precompiled header of STL...")
            os.mkdir(generated_dir)

            local clang_args = {
                path.join(bin_dir, "clang++.exe"),
                "-x", "c++-header",
                path.join(path.join(bin_dir, "utils"), "pch.hpp"),
                "-std=c++23",
                "-fms-extensions",
                "-fms-compatibility",
                "-o", pch_file
            }
            os.exec(table.concat(clang_args, " "))
        end
    end)

    on_install(function (package)
    end)
package_end()

add_requires("Runtime-Importer", {system = false})

target(mod_name)
    set_kind("shared")
    add_deps("AmethystAPI", "libhat")

    -- Hard fail if AmethystAPI is missing
    on_load(function (t)
        if not (amethystApiPath and os.isdir(amethystApiPath)) then
            raise("AmethystAPI not found at: " .. tostring(amethystApiPath) ..
                  "\nCI: ensure repo is checked out to Amethyst/AmethystAPI" ..
                  "\nLocal: set AMETHYST_SRC to point to your Amethyst clone.")
        end
    end)
    
    -- Force rebuild when any source file changes
    set_policy("build.optimization.lto", true )
    set_policy("build.across_targets_in_parallel", true )

    add_files("src/**.cpp")

    -- Uncomment if you plan to use ASM
    -- add_files("src/**.asm")
    --     set_toolset("as", "nasm")
    --     add_asflags("-f win64", { force = true })

    add_defines(
        string.format('MOD_TARGET_VERSION_MAJOR=%d', targetMajor),
        string.format('MOD_TARGET_VERSION_MINOR=%d', targetMajor),
        string.format('MOD_TARGET_VERSION_PATCH=%d', targetMajor),
        'ENTT_PACKED_PAGE=128',
        'AMETHYST_EXPORTS'
    )

    -- Deps
    add_packages("Runtime-Importer")
    add_packages("AmethystAPI", "libhat")
    add_links("user32", "oleaut32", "windowsapp", path.join(os.curdir(), ".importer/lib/Minecraft.Windows.lib"))

    add_includedirs("src", {public = true})
    add_headerfiles("src/**.hpp")

    before_build(function (target)
        local importer_dir = path.join(os.curdir(), ".importer");
        local generated_dir = path.join(importer_dir)
        local input_dir = path.join(amethystApiPath, "src"):gsub("\\", "/")
        local include_dir = path.join(amethystApiPath, "include"):gsub("\\", "/")
        
        local gen_sym_args = {
            "Amethyst.SymbolGenerator.exe",
            "--input", string.format("%s", input_dir),
            "--output", string.format("%s", generated_dir),
            "--filters", "minecraft",
            "--",
            "-x c++",
            "-include-pch", path.join(generated_dir, "pch.hpp.pch"),
            "-std=c++23",
            "-fms-extensions",
            "-fms-compatibility",
            string.format('-I%s', include_dir),
            string.format('-I%s', input_dir)
        }
        print('Generating *.symbols.json files for headers...')
        os.exec(table.concat(gen_sym_args, " "))

        local gen_lib_args = {
            "Amethyst.LibraryGenerator.exe",
            "--input", string.format("%s/symbols", generated_dir),
            "--output", string.format("%s/lib", generated_dir)
        }
        print('Generating Minecraft.Windows.lib file...')
        os.exec(table.concat(gen_lib_args, " "))
    end)

    after_build(function (target)
        local importer_dir = path.join(os.curdir(), ".importer");
        local generated_dir = path.join(importer_dir)
        local src_json = path.join("mod.json")
        local dst_json = path.join(modFolder, "mod.json")
        if not os.isdir(modFolder) then
            os.mkdir(modFolder)
        end
        os.cp(src_json, dst_json)

        local tweaker_args = {
            "Amethyst.ModuleTweaker.exe",
            "--module", target:targetfile(),
            "--symbols", string.format("%s/symbols", generated_dir)
        }
        print('Tweaking output file...')
        os.exec(table.concat(tweaker_args, " "))
    end)