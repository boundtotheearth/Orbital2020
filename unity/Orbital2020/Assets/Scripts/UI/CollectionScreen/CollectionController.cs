using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CollectionController : MonoBehaviour, UIScreen
{
    public GameController gameController;
    public UIController uiController;
    public GameObject uiObject;
    public GameObject plantDetailsObject;

    public CollectionItemUI selectedPlant;

    public Image portraitImage;
    public Text nameText;
    public Text descriptionText;

    public CollectionItemUI[] collectionItemUIs;

    public void initialize(List<CollectionItem> collectionItems)
    {
        uiController = GetComponentInParent<UIController>();
        collectionItemUIs = GetComponentsInChildren<CollectionItemUI>(true);

        for(int i = 0; i < collectionItems.Count; i++)
        {
            CollectionItemUI ui = collectionItemUIs[i];
            CollectionItem item = collectionItems[i];
            ui.initialize(item);
        }
    }

    public void onSelectPlant(CollectionItemUI plant)
    {
        if(selectedPlant)
        {
            selectedPlant.UnSelect();
        }
        plant.Select();
        selectedPlant = plant;
        portraitImage.sprite = selectedPlant.plantData.portraitSprite;
        nameText.text = selectedPlant.plantData.plantName;
        descriptionText.text = selectedPlant.plantData.description;
        OpenPlantDetails();
    }

    public void Open()
    {
        uiObject.SetActive(true);
    }

    public void Close()
    {
        foreach (CollectionItemUI ui in collectionItemUIs)
        {
            ui.reset();
        }

        ClosePlantDetails();
        uiObject.SetActive(false);
    }

    public void OpenPlantDetails()
    {
        plantDetailsObject.SetActive(true);
    }

    public void ClosePlantDetails()
    {
        plantDetailsObject.SetActive(false);
    }
}
