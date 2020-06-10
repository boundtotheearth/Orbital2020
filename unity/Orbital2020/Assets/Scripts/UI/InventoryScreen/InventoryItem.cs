using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InventoryItem
{
    public string plantType;
    public string property;

    public InventoryItem(string plantType)
    {
        this.plantType = plantType;
        this.property = "Default Property";
    }

    public InventoryItem(string plantType, string property)
    {
        this.plantType = plantType;
        this.property = property;
    }

    public override bool Equals(object obj)
    {
        return obj is InventoryItem item &&
               plantType == item.plantType &&
               property == item.property;
    }

    public override int GetHashCode()
    {
        int hashCode = 110953082;
        hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(plantType);
        hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(property);
        return hashCode;
    }
}
