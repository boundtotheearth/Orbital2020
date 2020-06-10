using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIController : MonoBehaviour
{
    public GameController gameController;

    public UIScreen currentScreen;
    public RewardsController rewardsScreen;
    public CollectionController collectionScreen;
    public InventoryController inventoryScreen;

    public void ToggleMoveDelete()
    {
        gameController.toggleMoveDelete();
    }

    public void OpenRewardsScreen(List<SeedPack> seedPacks)
    {
        closeScreen();

        rewardsScreen.initialize(seedPacks);
        rewardsScreen.Open();
        currentScreen = rewardsScreen;
    }

    public void OpenCollectionScreen(HashSet<CollectionItem> collection)
    {
        closeScreen();

        collectionScreen.initialize(collection);
        collectionScreen.Open();
        currentScreen = collectionScreen;
    }

    public void OpenInventoryScreen(List<InventoryItem> inventory)
    {
        closeScreen();

        inventoryScreen.initialize(inventory);
        inventoryScreen.Open();
        currentScreen = inventoryScreen;
    }

    public void closeScreen()
    {
        if(currentScreen != null)
        {
            //currentScreen.Close();
            currentScreen = null;
        }
    }
}
