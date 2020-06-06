using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class SeedPackUI : MonoBehaviour
{
    public Image icon;
    public Image portrait;
    public Text plantName;
    public Text plantRarity;

    public Sprite defaultIcon;
    public Sprite defaultPortrait;

    public void initialize(PlantData plantData)
    {
        gameObject.SetActive(true);
        icon.sprite = plantData.iconSprite ?? defaultIcon;
        portrait.sprite = plantData.portraitSprite ?? defaultPortrait;
        plantName.text = plantData.plantName;
        plantRarity.text = plantData.rarity.ToString();
    }

    public void reset()
    {
        gameObject.SetActive(false);
    }
}
