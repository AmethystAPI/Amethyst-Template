#include "dllmain.h"

// Ran when the mod is loaded into the game by AmethystRuntime
ModFunction void Initialize(HookManager* hookManager, Amethyst::EventManager* eventManager, InputManager* inputManager) 
{
    // Logging from <Amethyst/Log.h>
    Log::Info("Hello, Amethyst World!");

    // Add a listener to a built in amethyst event
    eventManager->onStartJoinGame.AddListener(OnStartJoinGame);
}

// Subscribed to amethysts on start join game event in Initialize
void OnStartJoinGame(ClientInstance* client)
{
    Log::Info("The player has joined the game!");
}