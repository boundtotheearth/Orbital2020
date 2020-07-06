using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GemDisplayController : MonoBehaviour
{
    public Text displayText;

    public void UpdateDisplay(int amount)
    {
        displayText.text = amount.ToString();
    }
}
