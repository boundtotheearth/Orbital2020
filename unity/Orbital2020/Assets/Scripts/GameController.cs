using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameController : MonoBehaviour
{
    public Plant selectedPlant;
    public GameObject plantableField;
    public bool planting = false;
    public GameObject testPlantPrefab;
    GameObject plant;

    List<PlantableTile> plantableTiles;

    // Start is called before the first frame update
    void Start()
    {
        plantableTiles = new List<PlantableTile>();
        for(int i = 0; i < plantableField.transform.childCount; i++)
        {
            plantableTiles.Add(plantableField.transform.GetChild(i).GetComponent<PlantableTile>());
        }
    }

    // Update is called once per frame
    void Update()
    {
        if(planting)
        {
            if(Input.touchCount > 0)
            {
                Touch touch = Input.GetTouch(0);
                Vector3 touchPoint = Camera.main.ScreenToWorldPoint(touch.position);
                touchPoint.z = 0;

                if(touch.phase == TouchPhase.Began)
                {
                    plant = Instantiate(testPlantPrefab, touchPoint, Quaternion.identity);
                }
                else if(touch.phase == TouchPhase.Ended && plant)
                {
                    Collider2D detected = Physics2D.OverlapPoint(touchPoint);
                    if (detected)
                    {
                        PlantableTile plantableTile = detected.GetComponentInParent<PlantableTile>();
                        if(!plantableTile.isOccupied)
                        {
                            plant.transform.position = detected.transform.position;
                            plantableTile.isOccupied = true;
                        }
                        else
                        {
                            GameObject.Destroy(plant.gameObject);
                        }
                    }
                    else
                    {
                        GameObject.Destroy(plant.gameObject);
                    }

                    endPlant();
                }
                else if(touch.phase == TouchPhase.Moved)
                {
                    if (plant)
                    {
                        plant.transform.position = touchPoint;
                    }
                }
            }
        }
    }

    public void selectPlant(Plant plant)
    {
        selectedPlant = plant;
    }

    public void startPlant()
    {
        planting = true;
        foreach(PlantableTile tile in plantableTiles)
        {
            tile.displayAvailability();
        }
    }

    public void endPlant()
    {
        planting = false;
        plant = null;
        foreach (PlantableTile tile in plantableTiles)
        {
            tile.stopDisplayAvailability();
        }
    }
}
