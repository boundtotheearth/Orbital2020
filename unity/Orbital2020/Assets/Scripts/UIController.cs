using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIController : MonoBehaviour
{
    public GameObject currentScreen;
    public GameObject rewardsScreen;
    public GameObject collectionScreen;
    public GameObject inventoryScreen;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void OpenRewardsScreen()
    {
        if (currentScreen != null)
        {
            currentScreen.SetActive(false);
        }

        rewardsScreen.SetActive(true);
        currentScreen = rewardsScreen;
    }

    public void OpenCollectionScreen()
    {
        if (currentScreen != null)
        {
            currentScreen.SetActive(false);
        }

        collectionScreen.SetActive(true);
        currentScreen = collectionScreen;
    }

    public void OpenInventoryScreen()
    {
        if (currentScreen != null)
        {
            currentScreen.SetActive(false);
        }

        inventoryScreen.SetActive(true);
        currentScreen = inventoryScreen;
    }

    public void closeScreen()
    {
        currentScreen.SetActive(false);
        currentScreen = null;
    }
}
