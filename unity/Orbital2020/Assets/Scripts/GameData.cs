using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

[Serializable]
public class GameData
{
    public List<InventoryItem> inventory = new List<InventoryItem>();
    public List<CollectionItem> collection = new List<CollectionItem>();
    public List<GamePlant> plants = new List<GamePlant>();
    public int gemTotal;
    public int idleCount;

    public GameData()
    {
        //Mock Inventory

        //Mock Collection

        //Mock Gem Total
        gemTotal = 0;

        //Mock Idle Count
        idleCount = 0;
    }

    public static GameData From(string json)
    {
        if(string.IsNullOrEmpty(json))
        {
            return new GameData();
        }

        return JsonUtility.FromJson<GameData>(json);
    }

    public string ToJson()
    {
        return JsonUtility.ToJson(this);
    }
}
