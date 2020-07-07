using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlantFactory : MonoBehaviour
{
    private static PlantFactory instance;

    public static PlantFactory Instance()
    {
        if(PlantFactory.instance == null)
        {
            PlantFactory.instance = FindObjectOfType<PlantFactory>();
        }

        return PlantFactory.instance;
    }

    public List<PlantType> plantTypes = new List<PlantType>();
    Dictionary<string, PlantType> plantTypeDict = new Dictionary<string, PlantType>();

    public GameObject[] gemObjects;

    public void Awake()
    {
        //Construct the reference dictionary
        foreach(PlantType type in plantTypes)
        {
            plantTypeDict.Add(type.id, type);
        }
    }

    public PlantType GetPlantType(string id)
    {
        return plantTypeDict[id];
    }

    public string GetName(string id)
    {
        return plantTypeDict[id].plantName;
    }

    public string GetDescription(string id)
    {
        return plantTypeDict[id].description;
    }

    public PlantRarity GetRarity(string id)
    {
        return plantTypeDict[id].rarity;
    }

    public Sprite GetIconSprite(string id)
    {
        return plantTypeDict[id].iconSprite;
    }

    public Sprite GetPortraitSprite(string id)
    {
        return plantTypeDict[id].portraitSprite;
    }

    public Sprite GetGameSprites(string id, int growthStage)
    {
        return plantTypeDict[id].gameSprites[growthStage];
    }

    public TimeSpan GetGrowthTime(string id, int growthStage)
    {
        return TimeSpan.FromSeconds(plantTypeDict[id].growthTimes[growthStage]);
    }

    public int GetGrowthStages(string id)
    {
        return plantTypeDict[id].growthTimes.Length;
    }

    public int GetGemDrop(string id, int growthStage)
    {
        return plantTypeDict[id].gemDrops[growthStage];
    }

    public GameObject GetGemObject(int index)
    {
        return gemObjects[index];
    }

    public int GetGemDropLimit(string id)
    {
        return plantTypeDict[id].gemDropLimit;
    }
}
