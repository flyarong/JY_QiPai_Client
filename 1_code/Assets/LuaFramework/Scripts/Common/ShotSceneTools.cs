using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.UI;

public class ShotSceneTools : MonoBehaviour
{
    public static void MakeCameraImgAsync(Camera mCam, int x, int y, int width, int height, string path, bool isRotate = false)
    {
        //StartCoroutine(getScreenTexture(x, y, width, height));
    }
    
    public static void MakeCameraImg(Camera mCam, int width, int height, string path, bool isRotate = false)
    {
        Rect CutRect = new Rect(0, 0, 1, 1);
        //Image mImage;
        RenderTexture rt = new RenderTexture(width, height, 2);
        mCam.pixelRect = new Rect(0, 0, Screen.width, Screen.height);
        mCam.targetTexture = rt;
        Texture2D screenShot = new Texture2D((int)(width * CutRect.width), (int)(height * CutRect.height), TextureFormat.RGBA32, false);
        mCam.Render();
        RenderTexture.active = rt;
        screenShot.ReadPixels(new Rect(width * CutRect.x, width * CutRect.y, width * CutRect.width, height * CutRect.height), 0, 0);
        mCam.targetTexture = null;
        RenderTexture.active = null;
        UnityEngine.Object.Destroy(rt);

        Color32[] pixels = screenShot.GetPixels32();
        if (isRotate)
        {
            screenShot = rotateTexture(screenShot, true);
        }

        byte[] bytes = screenShot.EncodeToPNG();
        System.IO.File.WriteAllBytes(path, bytes);

        //mImage = Image.GetInstance(bytes);
        //return mImage;
    }

    static Texture2D rotateTexture(Texture2D originalTexture, bool clockwise)
    {
        Color32[] original = originalTexture.GetPixels32();
        Color32[] rotated = new Color32[original.Length];
        int w = originalTexture.width;
        int h = originalTexture.height;

        int iRotated, iOriginal;

        for (int j = 0; j < h; ++j)
        {
            for (int i = 0; i < w; ++i)
            {
                iRotated = (i + 1) * h - j - 1;
                iOriginal = clockwise ? original.Length - 1 - (j * w + i) : j * w + i;
                rotated[iRotated] = original[iOriginal];
            }
        }

        Texture2D rotatedTexture = new Texture2D(h, w);
        rotatedTexture.SetPixels32(rotated);
        rotatedTexture.Apply();
        return rotatedTexture;
    }
}
