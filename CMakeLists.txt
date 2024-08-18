####################################################################################################
set(SHARD_NAME "Shard Template")
set(SHARD_AUTHOR "Author")
set(SHARD_UUID "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX")
set(SHARD_VERSION "0.0.0")

# ADVANCED
set(SHARD_FORMAT "MOD")
set(SHARD_FORMAT_VERSION "3.0.0") # Don't modify
####################################################################################################

# CMAKE
project(SHARD_NAME CXX ASM_NASM)
cmake_minimum_required(VERSION 3.12)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /await")

# Amethyst Minecraft Folder
if (CI_CD_BUILD)
        configure_file(manifest.json.in "${CMAKE_SOURCE_DIR}/dist/${SHARD_NAME}@${SHARD_VERSION}/manifest.json" @ONLY)
        set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO "${CMAKE_SOURCE_DIR}/dist/${SHARD_NAME}@${SHARD_VERSION}")
        set(AMETHYST_SRC "${CMAKE_SOURCE_DIR}/amethyst")
else()
        set(AmethystFolder "$ENV{localappdata}/Packages/Microsoft.MinecraftUWP_8wekyb3d8bbwe/LocalState/games/com.mojang/amethyst/") 
        configure_file(manifest.json.in "${AmethystFolder}/mods/${SHARD_NAME}@${SHARD_VERSION}/manifest.json" @ONLY)
        set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO "${AmethystFolder}/mods/${SHARD_NAME}@${SHARD_VERSION}")
        set(AMETHYST_SRC "$ENV{amethyst_src}")
endif()

# Define only RelWithDebInfo as the available build configuration
set(CMAKE_CXX_STANDARD 23)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set(CMAKE_CONFIGURATION_TYPES "RelWithDebInfo" CACHE STRING "Build configurations" FORCE)
set(CMAKE_BUILD_TYPE "RelWithDebInfo" CACHE STRING "Choose the type of build, options are: RelWithDebInfo" FORCE)

# Project Files
file(GLOB_RECURSE ${PROJECT_NAME}_All
        ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/src/*.c
        ${CMAKE_CURRENT_SOURCE_DIR}/src/*.asm
        ${CMAKE_CURRENT_SOURCE_DIR}/src/*.hpp
        ${CMAKE_CURRENT_SOURCE_DIR}/src/*.h
)

add_library(${PROJECT_NAME} SHARED ${${PROJECT_NAME}_All})

# Pass mod options to the source code
target_compile_definitions(${PROJECT_NAME} PRIVATE SHARD_NAME="${SHARD_NAME}")
target_compile_definitions(${PROJECT_NAME} PRIVATE SHARD_AUTHOR="${SHARD_AUTHOR}")
target_compile_definitions(${PROJECT_NAME} PRIVATE SHARD_UUID="${SHARD_UUID}")
target_compile_definitions(${PROJECT_NAME} PRIVATE SHARD_VERSION="${SHARD_VERSION}")

target_compile_definitions(${PROJECT_NAME} PRIVATE SHARD_FORMAT="${SHARD_FORMAT}")
target_compile_definitions(${PROJECT_NAME} PRIVATE SHARD_FORMAT_VERSION="${SHARD_FORMAT_VERSION}")

# Link libraries
target_link_libraries(${PROJECT_NAME} PRIVATE
        AmethystAPI
        libhat
        ${AMETHYST_SRC}/AmethystAPI/lib/fmt.lib
)

# Enable multi processor compilation for C++, to make it go brrrrrr
target_compile_options(${PROJECT_NAME} PRIVATE
        $<$<COMPILE_LANGUAGE:CXX>:/MP>
)

# EnTT Config Options
target_compile_definitions(${PROJECT_NAME} PUBLIC ENTT_PACKED_PAGE=128)

# Get the AmethystAPI Lib
add_subdirectory("${AMETHYST_SRC}/AmethystAPI" "build")