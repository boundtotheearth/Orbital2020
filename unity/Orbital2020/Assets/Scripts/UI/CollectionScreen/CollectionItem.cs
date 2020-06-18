using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class CollectionItem
{
    public string plantType;

    public CollectionItem(string plantType)
    {
        this.plantType = plantType;
    }

    public override string ToString()
    {
        return plantType;
    }

    public override bool Equals(object obj)
    {
        return obj is CollectionItem item &&
               plantType == item.plantType;
    }

    public override int GetHashCode()
    {
        return 803864498 + EqualityComparer<string>.Default.GetHashCode(plantType);
    }
}
