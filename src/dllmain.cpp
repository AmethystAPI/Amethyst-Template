#include "dllmain.hpp"

// Subscribed to amethysts on start join game event in Initialize
void OnStartJoinGame(OnStartJoinGameEvent& event)
{
    Log::Info("The player has joined the game!");
}

// Ran when the mod is loaded into the game by AmethystRuntime
ModFunction void Initialize(AmethystContext& ctx) 
{
    // Initialize Amethyst mod backend
    Amethyst::InitializeAmethystMod(ctx);

    // Logging from <Amethyst/Log.h>
    Log::Info("Hello, Amethyst World!");

    // Add a listener to a built in amethyst event
    Amethyst::GetEventBus().AddListener<OnStartJoinGameEvent>(&OnStartJoinGame);
}
