using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class FlutterMessageReceiver : MonoBehaviour
{
    public Counter counter;
    public GameController gameController;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void Increment(string amount)
    {
        counter.Increment(int.Parse(amount));
    }

    public void giveReward(string amount)
    {
        gameController.obtainSeedPack(int.Parse(amount));
    }
}
