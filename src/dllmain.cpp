#include "dllmain.hpp"

// Subscribed to amethysts on start join game event in Initialize
void OnStartJoinGame(OnStartJoinGameEvent& event)
{
    Log::Info("OnStartJoinGame!");
}

// Ran when the mod is loaded into the game by AmethystRuntime
ModFunction void Initialize(AmethystContext& ctx, const Amethyst::Mod& mod) 
{
    // Initialize Amethyst mod backend
    Amethyst::InitializeAmethystMod(ctx, mod);

    // Logging from <Amethyst/Log.h>
    Log::Info("Hello, Amethyst World!");

    // Add a listener to a built in amethyst event
    Amethyst::GetEventBus().AddListener<OnStartJoinGameEvent>(&OnStartJoinGame);
}
