using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class GamePlant : MonoBehaviour, IPointerClickHandler, IDragHandler, IEndDragHandler
{
    public delegate void OnDeleteCallback();

    public SpriteRenderer spriteRenderer;

    public PlantData plantData;
    public bool isWatered;
    public GameObject movingSprite;
    public OnDeleteCallback deleteCallback;
    public bool moveDeleting;

    public void initialize(PlantData plantData)
    {
        spriteRenderer = GetComponent<SpriteRenderer>();
        this.plantData = plantData;

        UpdateSprite();
        isWatered = false;
    }

    public void OnPointerClick(PointerEventData eventData)
    {
        if (!eventData.dragging && !moveDeleting)
        {
            Grow();
        }
    }

    public void OnDrag(PointerEventData eventData)
    {
        Vector2 screenPosition = eventData.position;
        Vector3 worldPosition = Camera.main.ScreenToWorldPoint(screenPosition);
        worldPosition.z = 0;

        transform.position = worldPosition;
        //Debug.Log(worldPosition);
    }

    public void OnEndDrag(PointerEventData eventData)
    {

    }

    void Grow()
    {
        plantData.growthStage++;
        if(plantData.growthStage > 2)
        {
            plantData.growthStage = 0;
        }
        UpdateSprite();
    }

    void UpdateSprite()
    {
        spriteRenderer.sprite = plantData.gameSprites[plantData.growthStage];
    }

    public void startMoveDelete()
    {
        moveDeleting = true;
        movingSprite.SetActive(true);
    }

    public void endMoveDelete()
    {
        moveDeleting = false;
        movingSprite.SetActive(false);
    }

    public void setDeleteCallback(OnDeleteCallback callback)
    {
        this.deleteCallback = callback;
    }

    public void deletePlant()
    {
        deleteCallback();
        Destroy(gameObject);
    }
}
