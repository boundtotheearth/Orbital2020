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

    public Sprite[] GetGameSprites(string id)
    {
        return plantTypeDict[id].gameSprites;
    }
}
