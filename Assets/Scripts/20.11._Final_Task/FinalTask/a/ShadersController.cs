using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShadersController : MonoBehaviour
{
    public ComputeShader CellularAutomataShader;
    public ComputeShader SetPreTextureShader;
    
    public RenderTexture PreResult;
    public RenderTexture Result;
    
    void Start()
    {
        Result = new RenderTexture(512, 512, 24);
        Result.enableRandomWrite = true;
        Result.Create();
        
        PreResult = new RenderTexture(512, 512, 24);
        PreResult.enableRandomWrite = true;
        PreResult.Create();
        
        CellularAutomataShader.SetTexture(0, "PreResult", PreResult);
        CellularAutomataShader.SetTexture(0, "Result", Result);
        
        SetPreTextureShader.SetTexture(0, "PreResult", PreResult);
        SetPreTextureShader.SetTexture(0, "Result", Result);
    }
    
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        CellularAutomataShader.Dispatch(0, Result.width / 8, Result.height / 8, 1);
        SetPreTextureShader.Dispatch(0, PreResult.width / 8, PreResult.height / 8, 1);
        
        Graphics.Blit(Result, destination);
    }
}
