using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GamePlant
{
    public string plantType;
    public string property;
    public bool isWatered;
    public Vector2Int gridPosition;
    public int growthStage;

    public GamePlant(InventoryItem plantData, PlantableTile tile)
    {
        this.plantType = plantData.plantType;
        this.property = plantData.property;
        this.growthStage = 0;
        this.isWatered = false;
        this.gridPosition = tile.gridPosition;
    }

    public override string ToString()
    {
        return string.Join(",",
            plantType,
            property,
            isWatered.ToString(),
            gridPosition.x.ToString(),
            gridPosition.y.ToString(),
            growthStage.ToString()
            );
    }
}
