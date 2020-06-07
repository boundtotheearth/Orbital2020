using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlantData : Object
{
    public string plantName;
    public string description;
    public PlantRarity rarity;
    public Sprite iconSprite;
    public Sprite portraitSprite;
    public Sprite gameSprite;

    public PlantData()
    {

    }

    public PlantData(string plantName,
        string description,
        PlantRarity rarity,
        Sprite iconSprite,
        Sprite portraitSprite,
        Sprite gameSprite)
    {
        this.plantName = plantName;
        this.description = description;
        this.rarity = rarity;
        this.iconSprite = iconSprite;
        this.portraitSprite = portraitSprite;
        this.gameSprite = gameSprite;
    }

    public PlantData(PlantType type)
    {
        this.plantName = type.plantName;
        this.description = type.description;
        this.rarity = type.rarity;
        this.iconSprite = type.iconSprite;
        this.portraitSprite = type.portraitSprite;
        this.gameSprite = type.gameSprite;
    }

    public override string ToString()
    {
        return plantName + " "
            + description + " "
            + rarity.ToString();
    }
}
