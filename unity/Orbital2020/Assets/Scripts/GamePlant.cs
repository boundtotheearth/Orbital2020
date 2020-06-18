using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class GamePlant
{
    public string plantType;
    public string property;
    public bool isWatered;
    public int gridX;
    public int gridY;
    public int growthStage;

    public GamePlant(InventoryItem plantData, PlantableTile tile)
    {
        this.plantType = plantData.plantType;
        this.property = plantData.property;
        this.growthStage = 0;
        this.isWatered = false;
        this.gridX = tile.gridPosition.x;
        this.gridY = tile.gridPosition.y;
    }

    public GamePlant(string plantType, string property, bool isWatered, int gridX, int gridY, int growthStage)
    {
        this.plantType = plantType;
        this.property = property;
        this.isWatered = isWatered;
        this.gridX = gridX;
        this.gridY = gridY;
        this.growthStage = growthStage;
    }

    public override string ToString()
    {
        return string.Join(",",
            plantType,
            property,
            isWatered.ToString(),
            gridX.ToString(),
            gridY.ToString(),
            growthStage.ToString()
            );
    }
}
