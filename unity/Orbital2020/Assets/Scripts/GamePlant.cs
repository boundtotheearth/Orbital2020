using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GamePlant : MonoBehaviour
{
    public SpriteRenderer spriteRenderer;

    public PlantData plantData;
    public bool isWatered;
    public int growthStage;

    public void initialize(PlantData plantData)
    {
        spriteRenderer = GetComponent<SpriteRenderer>();
        this.plantData = plantData;

        spriteRenderer.sprite = plantData.gameSprite;
        isWatered = false;
        growthStage = 0;
    }
}
