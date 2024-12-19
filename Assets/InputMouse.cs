using UnityEngine;
using UnityEditor;

[ExecuteInEditMode]
public class InputMouse : MonoBehaviour 
{
	public void Update () 
	{
		GetComponent<Renderer>().sharedMaterial.SetVector("mouse", new Vector4(Input.mousePosition.x/Screen.width,Input.mousePosition.y/Screen.height,0,0));
	}
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
        if (!Application.isPlaying)
        {
            Vector3 mousePosition = Event.current.mousePosition;
            //mousePosition.x -= Screen.width;
            mousePosition.y -= Screen.height;
            mousePosition.y = -mousePosition.y;
            //Update () ;
            GetComponent<Renderer>().sharedMaterial.SetVector("mouse", new Vector4(mousePosition.x / Screen.width, mousePosition.y / Screen.height, 0, 0));
        }
	}
}
