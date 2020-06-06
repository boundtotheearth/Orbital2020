using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class InventoryItemUI : MonoBehaviour
{
    public GameObject selectionBar;
    public Text nameText;
    public Image icon;

    public bool isSelected = false;
    public PlantData plantData;

    public void initialize(InventoryItem inventoryItem)
    {
        gameObject.SetActive(true);
        plantData = inventoryItem;
        nameText.text = plantData.plantName;
        icon.sprite = plantData.iconSprite;
        selectionBar.SetActive(false);
    }

    public void Select()
    {
        if (!isSelected)
        {
            selectionBar.SetActive(true);
            isSelected = true;
        }
    }

    public void UnSelect()
    {
        selectionBar.SetActive(false);
        isSelected = false;
    }

    public void reset()
    {
        gameObject.SetActive(false);
    }
}
