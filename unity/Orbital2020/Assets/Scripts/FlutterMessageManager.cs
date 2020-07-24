using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class FlutterMessageManager : MonoBehaviour
{
    private static FlutterMessageManager instance;
    public static FlutterMessageManager Instance()
    {
        if(FlutterMessageManager.instance == null)
        {
            FlutterMessageManager.instance = FindObjectOfType<FlutterMessageManager>();
        }

        return FlutterMessageManager.instance;
    }

    public GameController gameController;

    //Receiving
    public void giveReward(string amount)
    {
        gameController.obtainSeedPack(int.Parse(amount));
    }

    public void setGameData(string json)
    {
        gameController.SetGameData(json);
    }

    public void handleFocusTime(string focusTime)
    {
        gameController.GrowAndDrop(focusTime);
    }

    public void resetGame(string args)
    {
        gameController.ResetGame();
    }

    //Sending
    public void sendGameData(string data)
    {
        UnityMessageManager.Instance.SendMessageToFlutter(data);
    }
}
