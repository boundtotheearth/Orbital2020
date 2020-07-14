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
    public InventoryItem data;

    public void initialize(InventoryItem inventoryItem)
    {
        gameObject.SetActive(true);
        data = inventoryItem;
        nameText.text = PlantFactory.Instance().GetName(data.plantType);
        icon.sprite = PlantFactory.Instance().GetIconSprite(data.plantType);
        selectionBar.SetActive(false);
    }

    public void Select()
    {
        selectionBar.SetActive(true);
        isSelected = true;
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
