using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class GamePlant : MonoBehaviour, IPointerClickHandler
{
    public SpriteRenderer spriteRenderer;

    public PlantData plantData;
    public bool isWatered;

    public void initialize(PlantData plantData)
    {
        spriteRenderer = GetComponent<SpriteRenderer>();
        this.plantData = plantData;

        UpdateSprite();
        isWatered = false;
    }

    public void OnPointerClick(PointerEventData eventData)
    {
        Grow();
        Debug.Log("Here1");
    }

    void Grow()
    {
        plantData.growthStage++;
        if(plantData.growthStage > 2)
        {
            plantData.growthStage = 0;
        }
        UpdateSprite();
        Debug.Log("Here2");
    }

    void UpdateSprite()
    {
        spriteRenderer.sprite = plantData.gameSprites[plantData.growthStage];
    }
}
