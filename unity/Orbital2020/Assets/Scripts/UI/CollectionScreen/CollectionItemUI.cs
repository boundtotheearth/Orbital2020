using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CollectionItemUI : MonoBehaviour
{
    public CollectionController collectionController;
    public GameObject selectionBar;
    public Text nameText;
    public Image icon;

    public bool isSelected = false;
    public PlantData plantData;

    public void initialize(CollectionItem collectionItem)
    {
        gameObject.SetActive(true);
        collectionController = transform.GetComponentInParent<CollectionController>();
        this.plantData = collectionItem;

        nameText.text = collectionItem.plantName;
        icon.sprite = collectionItem.iconSprite;
        selectionBar.SetActive(false);
    }

    public void Select()
    {
        if(!isSelected)
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
