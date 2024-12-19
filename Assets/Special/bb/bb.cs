using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class bb : MonoBehaviour
{
    Material _material;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_material == null)
        {
            _material = new Material(Shader.Find("GLSL/ FlappyBird"));
            _material.hideFlags = HideFlags.HideAndDontSave;
        }

        RenderTexture rt1 = RenderTexture.GetTemporary(source.width, source.height);
        Graphics.Blit(source, rt1, _material);
        Graphics.Blit(source, destination, _material);
        _material.SetTexture("backbuffer", rt1);

        RenderTexture.ReleaseTemporary(rt1);
    }
}
