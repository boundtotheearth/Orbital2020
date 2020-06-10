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

    public void initialize(HashSet<CollectionItem> collectionItems)
    {
        uiController = GetComponentInParent<UIController>();
        collectionItemUIs = GetComponentsInChildren<CollectionItemUI>(true);

        int count = 0;
        foreach(CollectionItem item in collectionItems)
        {
            CollectionItemUI ui = collectionItemUIs[count];
            ui.initialize(item);
            count++;
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

        CollectionItem plantData = selectedPlant.data;
        portraitImage.sprite = PlantFactory.Instance().GetPortraitSprite(plantData.plantType);
        nameText.text = PlantFactory.Instance().GetName(plantData.plantType);
        descriptionText.text = PlantFactory.Instance().GetDescription(plantData.plantType);
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
        uiController.closeScreen();
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
