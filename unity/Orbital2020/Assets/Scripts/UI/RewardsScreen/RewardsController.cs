using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RewardsController : MonoBehaviour, UIScreen
{
    public UIController uiController;
    public GameObject uiObject;
    public SeedPackUI[] seedPackUIs;

    public void initialize(List<SeedPack> seedPacks)
    {
        uiController = GetComponentInParent<UIController>();
        seedPackUIs = GetComponentsInChildren<SeedPackUI>(true);
        //Initialize individual ui elements with the right data
        for (int i = 0; i < seedPacks.Count; i++)
        {
            SeedPack pack = seedPacks[i];
            SeedPackUI ui = seedPackUIs[i];
            ui.initialize(pack);
        }
    }

    public void Open()
    {
        uiObject.SetActive(true);
    }

    public void Close()
    {
        foreach(SeedPackUI ui in seedPackUIs)
        {
            ui.reset();
        }

        //uiController.closeScreen();
        uiObject.SetActive(false);
    }
}
