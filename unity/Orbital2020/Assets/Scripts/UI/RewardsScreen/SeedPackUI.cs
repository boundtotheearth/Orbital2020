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

    public SeedPack data;

    public void initialize(SeedPack seedPack)
    {
        gameObject.SetActive(true);
        this.data = seedPack;

        icon.sprite = PlantFactory.Instance().GetIconSprite(data.plantType);
        portrait.sprite = PlantFactory.Instance().GetPortraitSprite(data.plantType);
        plantName.text = PlantFactory.Instance().GetName(data.plantType);
        plantRarity.text = PlantFactory.Instance().GetRarity(data.plantType).ToString();
    }

    public void reset()
    {
        gameObject.SetActive(false);
    }
}
