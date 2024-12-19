using UnityEngine;
using UnityEditor;

[ExecuteInEditMode]
public class RenderToTexture : MonoBehaviour 
{
	public Material material;
	RenderTexture buffer;
	
	void OnEnable()
	{
		SceneView.onSceneGUIDelegate += SceneGUI;
		
	}
	void OnDisable()
	{
		SceneView.onSceneGUIDelegate -= SceneGUI;
	}
	void SceneGUI(SceneView sceneView)
	{
		if(!Application.isPlaying)
		{
			Update();
		}
	}


	void Update () 
	{
		if(material == null) return;
		if(buffer == null)
		{
			buffer = new RenderTexture(Screen.width, 
                               Screen.height, 
                               0,                            // No depth/stencil buffer
                               RenderTextureFormat.ARGB32,   // Standard colour format
                               RenderTextureReadWrite.Linear // No sRGB conversions
                           );
		}
		RenderTexture buffer2 = new RenderTexture(Screen.width, 
                               Screen.height, 
                               0,                            // No depth/stencil buffer
                               RenderTextureFormat.ARGB32,   // Standard colour format
                               RenderTextureReadWrite.Linear // No sRGB conversions
                           );
		
		Graphics.Blit(buffer, buffer2, material, -1);
		//RenderTexture.active = buffer;           // If not using a scene camera
		//Texture2D tex = new Texture2D(Screen.width,Screen.height);
		//tex.ReadPixels(
        //new Rect(0, 0, Screen.width, Screen.height), // Capture the whole texture
        // 0, 0,                          // Write starting at the top-left texel
        //  false                          // No mipmaps
		//);

		//System.IO.File.WriteAllBytes(Application.dataPath + "/"+"test.png", tex.EncodeToPNG());    //app path n1!

		GetComponent<Renderer>().sharedMaterial.SetTexture("backbuffer", buffer2);
		
	}
}
