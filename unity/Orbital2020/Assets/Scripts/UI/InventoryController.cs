using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class InventoryController : MonoBehaviour, UIScreen
{
    public GameController gameController;
    public UIController uiController;
    public GameObject uiObject;
    public GameObject inventoryArea;
    public List<InventoryPlant> inventory;
    public InventoryPlant selectedPlant;
    public Image portraitImage;

    // Start is called before the first frame update
    void Start()
    {
        uiController = GetComponentInParent<UIController>();
        foreach(InventoryPlant plant in inventory)
        {
            GameObject.Instantiate(plant, inventoryArea.transform);
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void onSelectPlant(InventoryPlant plant)
    {
        if(selectedPlant)
        {
            selectedPlant.UnSelect();
        }
        selectedPlant = plant;
        portraitImage.sprite = selectedPlant.portraitSprite;
    }

    public void Open()
    {
        uiObject.SetActive(true);
    }

    public void Close()
    {
        uiObject.SetActive(false);
    }

    public void StartPlant()
    {
        gameController.startPlant();
        uiController.closeScreen();
    }
}
