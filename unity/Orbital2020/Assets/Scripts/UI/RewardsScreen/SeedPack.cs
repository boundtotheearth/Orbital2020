using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SeedPack
{
    public string plantType;
    public string property;

    public SeedPack(string plantType)
    {
        this.plantType = plantType;
        this.property = "Default Property";
    }

    public SeedPack(string plantType, string property)
    {
        this.plantType = plantType;
        this.property = property;
    }
}
