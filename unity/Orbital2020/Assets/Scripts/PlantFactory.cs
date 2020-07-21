using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

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

    public List<PlantType> commonPlantTypes = new List<PlantType>();
    public List<PlantType> uncommonPlantTypes = new List<PlantType>();
    public List<PlantType> rarePlantTypes = new List<PlantType>();

    Dictionary<string, PlantType> plantTypeDict = new Dictionary<string, PlantType>();

    public GameObject[] gemObjects;
    public double uncommonRate;
    public double rareRate;

    public void Awake()
    {
        List<PlantType> allPlantTypes = new List<PlantType>();
        allPlantTypes.AddRange(commonPlantTypes);
        allPlantTypes.AddRange(uncommonPlantTypes);
        allPlantTypes.AddRange(rarePlantTypes);

        //Construct the reference dictionary
        foreach(PlantType type in allPlantTypes)
        {
            plantTypeDict.Add(type.id, type);
        }
    }

    public SeedPack GenerateSeedPack()
    {
        double result = Random.value;
        PlantType chosenType = null;
        if(result < rareRate)
        {
            chosenType = rarePlantTypes[Random.Range(0, rarePlantTypes.Count)];
        }
        else if(result < uncommonRate)
        {
            chosenType = uncommonPlantTypes[Random.Range(0, uncommonPlantTypes.Count)];
        }
        else
        {
            chosenType = commonPlantTypes[Random.Range(0, commonPlantTypes.Count)];
        }
        return new SeedPack(chosenType.id);

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
        return TimeSpan.FromMinutes(plantTypeDict[id].growthTimes[growthStage]);
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
