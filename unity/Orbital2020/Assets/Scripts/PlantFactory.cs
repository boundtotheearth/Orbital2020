using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlantFactory : MonoBehaviour
{
    public static PlantFactory instance;

    public static PlantFactory Instance()
    {
        if(PlantFactory.instance == null)
        {
            PlantFactory.instance = FindObjectOfType<PlantFactory>();
        }

        return PlantFactory.instance;
    }

    public PlantType testPlant1;
    public PlantType testPlant2;

    public PlantData TestPlant1()
    {
        return new PlantData(testPlant1);
    }

    public PlantData TestPlant2()
    {
        return new PlantData(testPlant2);
    }
}
