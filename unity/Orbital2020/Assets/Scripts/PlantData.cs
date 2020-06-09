using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlantData : Object
{
    public string plantName;
    public string description;
    public PlantRarity rarity;
    public int growthStage;
    public Sprite iconSprite;
    public Sprite portraitSprite;
    public Sprite[] gameSprites;

    public PlantData()
    {

    }

    public PlantData(string plantName,
        string description,
        PlantRarity rarity,
        int growthStage,
        Sprite iconSprite,
        Sprite portraitSprite,
        Sprite[] gameSprites)
    {
        this.plantName = plantName;
        this.description = description;
        this.rarity = rarity;
        this.growthStage = growthStage;
        this.iconSprite = iconSprite;
        this.portraitSprite = portraitSprite;
        this.gameSprites = gameSprites;
    }

    public PlantData(PlantType type)
    {
        this.plantName = type.plantName;
        this.description = type.description;
        this.rarity = type.rarity;
        this.growthStage = 0;
        this.iconSprite = type.iconSprite;
        this.portraitSprite = type.portraitSprite;
        this.gameSprites = type.gameSprites;
    }

    public override string ToString()
    {
        return plantName + " "
            + description + " "
            + rarity.ToString();
    }
}
