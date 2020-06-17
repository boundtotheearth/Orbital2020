using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class PlantDeleteButton : MonoBehaviour, IPointerClickHandler
{
    public GamePlantObject plant;

    public void OnPointerClick(PointerEventData eventData)
    {
        plant.deletePlant();
    }
}
