#include "dllmain.hpp"

// Ran when the mod is loaded into the game by AmethystRuntime
ModFunction void Initialize(AmethystContext* ctx) 
{
    // Logging from <Amethyst/Log.h>
    Log::Info("Hello, Amethyst World!");

    // Add a listener to a built in amethyst event
    ctx->mEventManager.onStartJoinGame.AddListener(&OnStartJoinGame);
}

// Subscribed to amethysts on start join game event in Initialize
void OnStartJoinGame(ClientInstance* client)
{
    Log::Info("The player has joined the game!");
}