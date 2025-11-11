using UnityEngine;

public class InjectMouse : MonoBehaviour
{
    void Update()
    {
        Ray r = RectTransformUtility.ScreenPointToRay(Camera.main, Input.mousePosition);
        if (Physics.Raycast(r, out var hitinfo))
        {
            var hitpos = hitinfo.textureCoord;

            var renderer = GetComponent<Renderer>();
            if (renderer == null) return;
            var mat = renderer.sharedMaterial;
            if (mat == null) return;

            mat.SetVector("mouse", new Vector4(hitpos.x, hitpos.y, 0, 0));
        }
    }
}
