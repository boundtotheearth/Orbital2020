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
    public Vector3 originalPosition;
    public PlantableTile tile;

    public void initialize(PlantData plantData, PlantableTile tile)
    {
        spriteRenderer = GetComponent<SpriteRenderer>();
        this.plantData = plantData;
        this.originalPosition = transform.position;
        this.tile = tile;

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
        if (moveDeleting)
        {
            Vector2 screenPosition = eventData.position;
            Vector3 worldPosition = Camera.main.ScreenToWorldPoint(screenPosition);
            worldPosition.z = 0;

            transform.position = worldPosition;
            //Debug.Log(worldPosition);

            gameObject.layer = LayerMask.NameToLayer("Dragging");
        }
    }

    public void OnEndDrag(PointerEventData eventData)
    {
        //this works because the plant being dragged is put in a "dragging" layer,
        //which is ignored by the raycasting camera
        GameObject destinationObject = eventData.pointerCurrentRaycast.gameObject;
        if (destinationObject)
        {
            GamePlant plant = destinationObject.GetComponent<GamePlant>();
            if (plant)
            {
                //Dragged to plant
                PlantableTile temp = this.tile;
                movePlant(plant.tile, false);
                plant.movePlant(temp, false);

                tile.setPlant(plant);

                plant.tile.setPlant(this);
            }

            PlantableTile newTile = destinationObject.GetComponent<PlantableTile>();
            if (newTile)
            {
                //Dragged to empty tile
                this.tile.clear();
                movePlant(newTile);
                newTile.setPlant(this);
            }
        }

        //Nothing to drag to
        transform.position = originalPosition;
        gameObject.layer = LayerMask.NameToLayer("Default");
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

    public void movePlant(PlantableTile tile, bool clearOld = true)
    {
        transform.position = tile.transform.position;
        originalPosition = transform.position;
        transform.parent = tile.transform;
        if (clearOld)
        {
            this.tile.clear();
        }
        this.tile = tile;
        tile.setPlant(this);
    }
}
