using System;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Experimental.Rendering;

public class FinalTask : MonoBehaviour
{
    [SerializeField] private ComputeShader finalTaskShader;
    [SerializeField] private Material finalTaskMaterial;
    
    [SerializeField] private RenderTexture blackUVTexture;
    [SerializeField] private RenderTexture whiteUVTexture;

    
    [SerializeField] private Seed seed = Seed.InitFullTexture; // seed ei ole numero vaan esim open teamsiin laittamat jännät scriptit on seedejä
    [SerializeField] private float updateIntervalSeconds = 2f;
    [SerializeField] private Stage currentStage;

    private enum Seed
    {
        InitFullTexture,
        InitRPentomino,
        InitAcorn,
        InitGun
    }

    private static int _mainKernel;
    private static int _update1Kernel;
    private static int _update2Kernel;
    private static int _forEverySeedKernel;
    private static int _initFullTextureKernel;
    private static int _initRPentominoKernel;
    private static int _initAcornKernel;
    private static int _initGunKernel;

    private static readonly int BaseMap = Shader.PropertyToID("_BaseMap");
    private static readonly int UVMap = Shader.PropertyToID("UVMap");

    public GameObject TileObject;
    private static readonly int Width = 10;
    private static readonly int Height = 10;
    bool[,] grid = new bool[Width, Height];
    GameObject[,] tiles = new GameObject[Width, Height];

    private void Start()
    {
        #region Generate tiles
        for (int x = 0; x < Width; x++)
        {
            for (int y = 0; y < Height; y++)
            {
                // Clear the grid
                grid[x, y] = false;
                // Instantiate the tile
                tiles[x, y] = Instantiate(TileObject,
                    new Vector3(x, 0f, y) * 1.05f,
                    TileObject.transform.rotation);
            }
        }
        #endregion Generate tiles

        int textureWidth = 512;
        int textureHeight = 512;
        // create 2 RenderTextures using default LDR settings, point filter and enableRandomWrite = true.
        #region implementation
        // Create white UV texture
        whiteUVTexture = new RenderTexture(textureWidth, textureHeight, 0, RenderTextureFormat.ARGB32);
        whiteUVTexture.enableRandomWrite = true;
        whiteUVTexture.filterMode = FilterMode.Point;
        whiteUVTexture.Create();
        
        finalTaskShader.SetTexture(0, "White", whiteUVTexture);
        // finalTaskShader.Dispatch(0,
        
        // Create black UV texture
        blackUVTexture = new RenderTexture(textureWidth, textureHeight, 0, RenderTextureFormat.ARGB32);
        blackUVTexture.enableRandomWrite = true;
        blackUVTexture.filterMode = FilterMode.Point;
        blackUVTexture.Create();
        #endregion implementation



        // find all kernels of Compute Shader
        _mainKernel = finalTaskShader.FindKernel("CSMain");
        _update1Kernel = finalTaskShader.FindKernel("Update1");
        _update2Kernel = finalTaskShader.FindKernel("Update2");
        _forEverySeedKernel = finalTaskShader.FindKernel("ForEverySeed");
        _initFullTextureKernel = finalTaskShader.FindKernel("InitFullTextureKernel");
        _initRPentominoKernel = finalTaskShader.FindKernel("InitRPentominoKernel");
        _initAcornKernel = finalTaskShader.FindKernel("InitAcornKernel");
        _initGunKernel = finalTaskShader.FindKernel("InitGunKernel");
        

        // attach all kernels of Compute Shader the required textures and other fields that won't be updated during Update
        finalTaskShader.SetTexture(_mainKernel, BaseMap, finalTaskMaterial.mainTexture);
        finalTaskShader.SetTexture(_mainKernel, UVMap, blackUVTexture);

        // TODO: initialize the simulation using seed variable
        InitializeSimulation(seed);
    }

    private void Update()
    {
        // maintain the time interval used to update the simulation (how fast a new generation happens)
        updateIntervalSeconds += Time.deltaTime;

        // TODO: keep account on whether the simulation is at Stage1 or Stage2 stage and choose the according stage to execute

        // TODO: keep track of which Stage of the simulation we are and use the current stage to decide the stage to complete

        // TODO: update the textures of the finalTaskMaterial based on the current stage (flipbook).
        

        // use the time interval to do the checks 
        if (updateIntervalSeconds > 2.0f)
        {
            // RULES:
            // 1. Fewer than 2 live neighbours --> die
            // 2. 2 or 3 live neighbours -> live on
            // 3. more than 3 live neighbours -> die
            // 4. dead cell with 3 live neighbours -> rebirth 
            for (int x = 0; x < Width; x++)
            {
                for (int y = 0; y < Height; y++)
                {
                    int live = GetLiveNeighbours(x, y);
                    if (live < 2)
                    {
                        grid[x, y] = false;
                    }
                    else if (live < 4 && grid[x, y] == true)
                    {
                        // live on... do nothing
                    }
                    else if (live > 3 && grid[x, y] == true)
                    {
                        grid[x, y] = false;
                    }
                    else if (live == 3 && grid[x, y] == false)
                    {
                        grid[x, y] = true;
                    }
                }
            }

            // Update the tiles
            for (int x = 0; x < Width; x++)
            {
                for (int y = 0; y < Height; y++)
                {
                    if (grid[x, y] == true)
                    {
                        tiles[x, y].GetComponent<MeshRenderer>().material.color = Color.red;
                    }
                    else
                    {
                        tiles[x, y].GetComponent<MeshRenderer>().material.color = Color.black;
                    }
                }
            }
            updateIntervalSeconds = 0.0f;
        }
    }
    
    private int GetLiveNeighbours(int x, int y)
    {
        int liveneighbours = 0;
        for (int i = x - 1; i <= x + 1; i++)
        {
            for (int j = y - 1; j <= y + 1; j++)
            {
                if (!(i == x & j == y) && i >= 0 && j >= 0 && i < Width && j < Height)
                {
                    // current i,j is not x,y
                    if (grid[i, j] == true)
                    {
                        liveneighbours++;
                    }
                }
            }
        }
        return liveneighbours;
    }

    // TODO: initialize the simulation using seed variable 
    void InitializeSimulation(Seed seed)
    {
        switch (seed)
        {
            case Seed.InitFullTexture:
                
                break;
            case Seed.InitRPentomino:
                
                break;
            case Seed.InitAcorn:

                break;
            case Seed.InitGun:

                break;
            
            default:
                break;
        }
        
        #region previous try
        // grid[5, 5] = true;
        // tiles[5, 5].GetComponent<MeshRenderer>().material.color = Color.red;
        // grid[3, 5] = true;
        // tiles[3, 5].GetComponent<MeshRenderer>().material.color = Color.red;
        // grid[4, 4] = true;
        // tiles[4, 4].GetComponent<MeshRenderer>().material.color = Color.red;
        // grid[1, 4] = true;
        // tiles[1, 4].GetComponent<MeshRenderer>().material.color = Color.red;
        // grid[2, 3] = true;
        // tiles[2, 3].GetComponent<MeshRenderer>().material.color = Color.red;
        // grid[1, 3] = true;
        // tiles[1, 3].GetComponent<MeshRenderer>().material.color = Color.red;
        // grid[2, 2] = true;
        // tiles[2, 2].GetComponent<MeshRenderer>().material.color = Color.red;
        #endregion previous try
    }
    
    // DONE:
    #region when the script is destroyed or disabled, release render texture variables from memory

    void OnDisable()
    {
        blackUVTexture.Release();
        whiteUVTexture.Release();
    }

    void OnDestroy()
    {
        blackUVTexture.Release();
        whiteUVTexture.Release();
    }

    #endregion when the script is destroyed or disabled, release render texture variables from memory
}