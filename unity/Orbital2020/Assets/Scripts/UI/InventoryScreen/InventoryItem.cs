using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InventoryItem : PlantData
{
    public InventoryItem(PlantData plantData)
    {
        this.plantName = plantData.plantName;
        this.description = plantData.description;
        this.rarity = plantData.rarity;
        this.iconSprite = plantData.iconSprite;
        this.portraitSprite = plantData.portraitSprite;
        this.gameSprite = plantData.gameSprite;
    }
}
