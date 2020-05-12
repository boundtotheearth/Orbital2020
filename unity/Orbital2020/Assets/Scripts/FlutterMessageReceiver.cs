using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class FlutterMessageReceiver : MonoBehaviour
{
    public Counter counter;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void Increment(string amount)
    {
        counter.Increment(int.Parse(amount));
    }
}
