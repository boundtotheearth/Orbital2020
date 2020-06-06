using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SeedPack : PlantData
{
    public SeedPack(string plantName, PlantRarity rarity)
    {
        this.plantName = plantName;
        this.rarity = rarity;
    }
}
