using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class PlantDeleteButton : MonoBehaviour, IPointerClickHandler
{
    public GamePlant plant;

    public void OnPointerClick(PointerEventData eventData)
    {
        plant.deletePlant();
    }
}
