using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class InventoryController : MonoBehaviour, UIScreen
{
    public GameController gameController;
    public UIController uiController;
    public GameObject uiObject;

    public InventoryItemUI selectedPlant;

    public Text nameText;
    public Text descriptionText;
    public Text rarityText;

    public GameObject inventoryItemUIPrefab;
    public GameObject inventoryArea;
    public List<InventoryItemUI> inventoryItemUIs;

    public void initialize(List<InventoryItem> inventoryItems)
    {
        uiController = GetComponentInParent<UIController>();

        inventoryItemUIs = new List<InventoryItemUI>(GetComponentsInChildren<InventoryItemUI>(true));

        //Insantiate ui elements if there isn't enough
        int missing = inventoryItems.Count - inventoryItemUIs.Count;
        for(int i = 0; i < missing; i++)
        {
            GameObject ui = Instantiate(inventoryItemUIPrefab, inventoryArea.transform);
            //Set onclick event
            InventoryItemUI uiScript = ui.GetComponent<InventoryItemUI>();
            ui.GetComponent<Button>().onClick.AddListener(delegate { onSelectPlant(uiScript); });
            inventoryItemUIs.Add(uiScript);
        }

        //Initialize ui elements
        for (int i = 0; i < inventoryItems.Count; i++)
        {
            InventoryItemUI ui = inventoryItemUIs[i];
            InventoryItem item = inventoryItems[i];
            ui.initialize(item);
        }

        //Set first item as default selected
        if(inventoryItemUIs.Count > 0)
        {
            onSelectPlant(inventoryItemUIs[0]);
        }
    }

    public void Open()
    {
        uiObject.SetActive(true);
    }

    public void Close()
    {
        uiObject.SetActive(false);
    }

    public void onSelectPlant(InventoryItemUI plant)
    {
        if (selectedPlant)
        {
            selectedPlant.UnSelect();
        }
        plant.Select();
        selectedPlant = plant;
        nameText.text = selectedPlant.plantData.plantName;
        descriptionText.text = selectedPlant.plantData.description;
        rarityText.text = selectedPlant.plantData.rarity.ToString();
    }

    public void StartPlant()
    {
        if (selectedPlant)
        {
            gameController.startPlant(selectedPlant.plantData);
            uiController.closeScreen();
        } else
        {
            Debug.Log("Please select a plant");
        }
        
    }
}
