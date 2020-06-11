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

    public GameData()
    {
        //Mock Inventory
        inventory.Add(new InventoryItem("testplant1"));
        inventory.Add(new InventoryItem("testplant2"));

        //Mock Collection
        collection.Add(new CollectionItem("testplant1"));
        collection.Add(new CollectionItem("testplant2"));
    }

    public static GameData From(string json)
    {
        return JsonUtility.FromJson<GameData>(json);
    }

    public string ToJson()
    {
        return JsonUtility.ToJson(this);
    }
}
