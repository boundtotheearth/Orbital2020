using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class PlantableTile : MonoBehaviour, IPointerClickHandler
{
    public GameController gameController;
    public bool isOccupied = false;
    public GameObject occupiedSprite;
    public GameObject availableSprite;
    public GameObject normalSprite;
    public GamePlantObject plant;
    public Vector2Int gridPosition;

    SpriteRenderer spriteRenderer;

    // Start is called before the first frame update
    void Start()
    {
        spriteRenderer = GetComponent<SpriteRenderer>();
        gameController = GetComponentInParent<GameController>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void OnPointerClick(PointerEventData eventData)
    {
        gameController.OnTileClick(this);
    }

    public void displayAvailability()
    {
        normalSprite.SetActive(false);
        if(isOccupied)
        {
            occupiedSprite.SetActive(true);
        }
        else
        {
            availableSprite.SetActive(true);
        }
    }

    public void stopDisplayAvailability()
    {
        normalSprite.SetActive(true);
        availableSprite.SetActive(false);
        occupiedSprite.SetActive(false);
    }

    public void setPlant(GamePlantObject plant)
    {
        clear();
        this.plant = plant;
        isOccupied = true;
    }

    public void clear()
    {
        isOccupied = false;
        plant = null;
    }
}
