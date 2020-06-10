using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public class GameController : MonoBehaviour
{
    public InventoryItem selectedPlant;
    public GameObject plantableField;
    
    public GameObject gamePlantPrefab;
    public UIController uiController;
    public Grid grid;
    public Vector2Int fieldSize;
    public GameObject tilePrefab;

    public List<InventoryItem> inventory = new List<InventoryItem>();
    public HashSet<CollectionItem> collection = new HashSet<CollectionItem>();
    public List<GamePlantObject> plants = new List<GamePlantObject>();

    public bool planting = false;
    public bool moveDeleting = false;

    //List<PlantableTile> plantableTiles = new List<PlantableTile>();
    PlantableTile[,] plantableTiles;

    // Start is called before the first frame update
    void Start()
    {
        //Find all plantable tiles
        //plantableTiles = new List<PlantableTile>();
        //for(int i = 0; i < plantableField.transform.childCount; i++)
        //{
        //    plantableTiles.Add(plantableField.transform.GetChild(i).GetComponent<PlantableTile>());
        //}

        //Initialize plantable tiles
        plantableTiles = new PlantableTile[fieldSize.x,fieldSize.y];
        for(int x = 0; x < fieldSize.x; x++)
        {
            for(int y = 0; y < fieldSize.y; y++)
            {
                GameObject tileObject = Instantiate(tilePrefab, transform);
                tileObject.transform.position = grid.GetCellCenterWorld(new Vector3Int(x, y, 0));
                tileObject.name = "(" + x.ToString() + ", " + y.ToString() + ")";
                PlantableTile tileScript = tileObject.GetComponent<PlantableTile>();
                tileScript.gridPosition = new Vector2Int(x, y);
                //plantableTiles.Add(tileObject.GetComponent<PlantableTile>());
                plantableTiles[x,y] = tileScript;
            }
        }

        //Mock Inventory
        inventory.Add(new InventoryItem("testplant1"));
        inventory.Add(new InventoryItem("testplant2"));

        //Mock Collection
        collection.Add(new CollectionItem("testplant1"));
        collection.Add(new CollectionItem("testplant2"));
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void OnTileClick(PlantableTile tile)
    {
        if (planting && !selectedPlant.Equals(null))
        {
            addPlant(tile);

            endPlant();
        }
    }

    public void addPlant(PlantableTile tile)
    {
        GameObject newPlant = Instantiate(gamePlantPrefab, tile.transform.position, Quaternion.identity, tile.transform);
        GamePlantObject plantScript = newPlant.GetComponent<GamePlantObject>();
        plantScript.initialize(new GamePlant(selectedPlant, tile), tile);
        plantScript.setDeleteCallback(() => removePlant(plantScript));
        tile.setPlant(plantScript);
        plants.Add(plantScript);
    }

    public void startPlant(InventoryItem plantData)
    {
        bool isFull = true;
        foreach(PlantableTile tile in plantableTiles)
        {
            if (!tile.isOccupied)
            {
                isFull = false;
                tile.displayAvailability();
            }
        }

        if (!isFull)
        {
            if (moveDeleting)
            {
                endMoveDelete();
            }
            planting = true;
            selectedPlant = plantData;
        }
        else
        {
            Debug.Log("Field is full!");
        }
    }

    public void endPlant()
    {
        planting = false;
        selectedPlant = null;
        foreach (PlantableTile tile in plantableTiles)
        {
            tile.stopDisplayAvailability();
        }
    }

    public void toggleMoveDelete()
    {
        if (moveDeleting)
        {
            endMoveDelete();
        }
        else
        {
            startMoveDelete();
        }
    }

    public void startMoveDelete()
    {
        bool isEmpty = true;
        foreach(GamePlantObject plant in plants)
        {
            isEmpty = false;
            plant.startMoveDelete();
        }

        if (!isEmpty)
        {
            if (planting)
            {
                endPlant();
            }
            moveDeleting = true;
        }
        else
        {
            Debug.Log("No Plants, nothing to move/delete");
        }
    }

    public void endMoveDelete()
    {
        moveDeleting = false;

        foreach (GamePlantObject plant in plants)
        {
            plant.endMoveDelete();
        }
    }

    public void obtainSeedPack(int amount)
    {
        //Generate
        List<SeedPack> seedPacks = new List<SeedPack>();
        for(int i = 0; i < amount; i++)
        {
            seedPacks.Add(new SeedPack("testplant1"));
        }

        //Activate UI
        uiController.OpenRewardsScreen(seedPacks);

        //Edit Collections
        foreach(SeedPack pack in seedPacks)
        {
            collection.Add(new CollectionItem(pack.plantType));
        }

        //Edit inventory
        foreach (SeedPack pack in seedPacks)
        {
            inventory.Add(new InventoryItem(pack.plantType));
        }
    }

    public void showCollection()
    {
        uiController.OpenCollectionScreen(collection);
    }

    public void showInventory()
    {
        uiController.OpenInventoryScreen(inventory);
    }

    public void removePlant(GamePlantObject plant)
    {
        plants.Remove(plant);
        endMoveDelete();
    }

    public void SaveGame()
    {
        StringBuilder data = new StringBuilder();
        foreach(InventoryItem inventoryItem in inventory)
        {
            data.Append(inventoryItem.ToString());
            data.Append(",");
        }

        foreach(CollectionItem collectionItem in collection)
        {
            data.Append(collectionItem.ToString());
            data.Append(",");
        }

        foreach (PlantableTile tile in plantableTiles)
        {
            if (tile.plant)
            {
                data.Append(tile.plant.data.ToString());
                data.Append(",");
            }
        }

        FlutterMessageManager.Instance().sendGameData(data.ToString());
    }
}
