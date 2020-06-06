using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameController : MonoBehaviour
{
    public PlantData selectedPlant;
    public GameObject plantableField;
    public bool planting = false;
    public GameObject testPlantPrefab;
    public UIController uiController;
    public Grid grid;
    public Vector2 fieldSize;
    public GameObject tilePrefab;

    public List<InventoryItem> inventory;

    [SerializeField]
    public List<CollectionItem> collection;

    List<PlantableTile> plantableTiles = new List<PlantableTile>();

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
        for(int x = 0; x < fieldSize.x; x++)
        {
            for(int y = 0; y < fieldSize.y; y++)
            {
                GameObject tileObject = Instantiate(tilePrefab, transform);
                tileObject.transform.position = grid.GetCellCenterWorld(new Vector3Int(x, y, 0));
                plantableTiles.Add(tileObject.GetComponent<PlantableTile>());
            }
        }

        //Mock Inventory
        for (int i = 0; i < 10; i++)
        {
            inventory.Add(new InventoryItem("Plant " + i.ToString()));
        }

        //Mock Collection
        for (int i = 0; i < 10; i++)
        {
            collection.Add(new CollectionItem("Plant " + i.ToString()));
        }
    }

    // Update is called once per frame
    void Update()
    {

    }

    public void OnTileClick(PlantableTile tile)
    {
        if (planting)
        {
            Instantiate(testPlantPrefab, tile.transform.position, Quaternion.identity);
            tile.isOccupied = true;
            endPlant();
        }
    }

    public void startPlant(PlantData plantData)
    {
        planting = true;
        selectedPlant = plantData;
        foreach(PlantableTile tile in plantableTiles)
        {
            tile.displayAvailability();
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

    public void obtainSeedPack(int amount)
    {
        //Generate
        List<SeedPack> seedPacks = new List<SeedPack>();
        for(int i = 0; i < amount; i++)
        {
            seedPacks.Add(generateSeedPack());
        }

        //Activate UI
        uiController.OpenRewardsScreen(seedPacks);

        //Edit Collections
        //Edit inventory
    }

    SeedPack generateSeedPack()
    {
        return new SeedPack("Test Pack", PlantRarity.rare);
    }

    public void showCollection()
    {
        uiController.OpenCollectionScreen(collection);
    }

    public void showInventory()
    {
        uiController.OpenInventoryScreen(inventory);
    }
}
