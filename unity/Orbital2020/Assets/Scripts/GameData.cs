using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public class GameData
{
    public List<InventoryItem> inventory = new List<InventoryItem>();
    public HashSet<CollectionItem> collection = new HashSet<CollectionItem>();
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

    public GameData(string json)
    {
        //Load game data from json
    }

    public string ToJson()
    {
        StringBuilder data = new StringBuilder();

        data.Append("{");

        data.Append("\"Inventory\":[");
        foreach (InventoryItem inventoryItem in inventory)
        {
            data.Append(JsonUtility.ToJson(inventoryItem));
            data.Append(",");
        }
        data.Remove(data.Length - 1, 1);
        data.Append("],");

        data.Append("\"Collection\":[");
        foreach (CollectionItem collectionItem in collection)
        {
            data.Append(JsonUtility.ToJson(collectionItem));
            data.Append(",");
        }
        data.Remove(data.Length - 1, 1);
        data.Append("],");

        data.Append("\"Plants\":[");
        foreach (GamePlant plant in plants)
        {
            data.Append(JsonUtility.ToJson(plant));
            data.Append(",");
        }
        data.Remove(data.Length - 1, 1);
        data.Append("]");

        data.Append("}");

        return data.ToString();
    }
}
