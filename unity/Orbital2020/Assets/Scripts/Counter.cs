using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Counter : MonoBehaviour
{
    Text text;
    int counter = 0;

    // Start is called before the first frame update
    void Start()
    {
        text = GetComponent<Text>();
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetKeyDown(KeyCode.Space))
        {
            Increment(1);
        }
    }

    public void Increment(int amount)
    {
        counter += amount;
        text.text = "Counter: " + counter;
    }
}
