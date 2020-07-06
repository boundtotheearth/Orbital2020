using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlantType : MonoBehaviour
{
    public string id;
    public string plantName;
    public string description;
    public PlantRarity rarity;
    public Sprite iconSprite;
    public Sprite portraitSprite;
    public Sprite[] gameSprites;
    public double[] growthTimes;
    public int[] gemDrops;
}
