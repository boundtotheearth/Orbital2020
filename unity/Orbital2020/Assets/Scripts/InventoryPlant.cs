using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class InventoryPlant : Plant
{
    public InventoryController inventoryController;
    public GameObject selectionBar;
    public Text nameText;
    public Image icon;

    public int plantCount;
    public bool isSelected = false;

    // Start is called before the first frame update
    void Start()
    {
        inventoryController = transform.GetComponentInParent<InventoryController>();

        nameText.text = plantName;
        icon.sprite = iconSprite;
        selectionBar.SetActive(false);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void Select()
    {
        if(!isSelected)
        {
            selectionBar.SetActive(true);
            inventoryController.onSelectPlant(this);
            isSelected = true;
        }
    }

    public void UnSelect()
    {
        selectionBar.SetActive(false);
        isSelected = false;
    }
}
