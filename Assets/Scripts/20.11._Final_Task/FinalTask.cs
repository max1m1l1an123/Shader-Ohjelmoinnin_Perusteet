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
    
    [SerializeField] private int seed = 10;
    [SerializeField] private float updateIntervalSeconds = 2f;
    [SerializeField] private Stage currentStage;
    private enum Stage
    {
        Stage1,
        Stage2
    }
    
    private static int _mainKernel;
    private static readonly int BaseMap = Shader.PropertyToID("_BaseMap");
    private static readonly int UVMap = Shader.PropertyToID("UVMap");
    
    private void Start()
    {
        // create 2 RenderTextures using default LDR settings, point filter and enableRandomWrite = true.
        
        // find all kernels of Compute Shader
        
        // attach all kernels of Compute Shader the required textures and other fields that won't be updated during Update
        
        // initialize the simulation using seed variable
    }

    private void Update()
    {
        // maintain the time interval used to update the simulation (how fast a new generation happens)
        updateIntervalSeconds += Time.deltaTime;

        // keep account on whether the simulation is at Stage1 or Stage2 stage and choose the according stage to execute
        
        // Scriptin tulisi pitää kirjaa, kummassa vaiheessa simulaatiota ollaan, ja päättää sen mukaan, kumpi vaihe suorittaa.

        // Scriptin kuuluisi päivittää esitykseen käytetyn materiaalin tekstuuria vaiheen mukaan (flipbook).
    }

    // TEHTY:
    #region Kun scripti tuhotaan tai disabloidaan, sen kuuluisi vapauttaa render texture muuttujat muistista.
    private void OnDisable()
    {
        blackUVTexture.Release();
        whiteUVTexture.Release();
    }
    private void OnDestroy()
    {
        blackUVTexture.Release();
        whiteUVTexture.Release();
    }
    #endregion Kun scripti tuhotaan tai disabloidaan, sen kuuluisi vapauttaa render texture muuttujat muistista.
    
}