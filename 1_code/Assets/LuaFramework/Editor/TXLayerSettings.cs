using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public static class TXLayerSettings
{

    [MenuItem("Tools/TX/打印")]
    static void ShowTXLayer()
    {
        if (Selection.activeGameObject)
        {
            Debug.Log("activeGameObject=" + Selection.activeGameObject.name);
            GameObject obj = Selection.activeGameObject;
            Renderer[] list = obj.GetComponentsInChildren<Renderer>(true);
            for (int i = 0; i < list.Length; ++i)
            {
                Debug.Log("name:" + list[i].gameObject.name + "  " + list[i].sortingOrder);
            }
        }
    }
    [MenuItem("Tools/TX/加1")]
    static void AddTXLayer()
    {
        if (Selection.activeGameObject)
        {
            Debug.Log("activeGameObject=" + Selection.activeGameObject.name);
            GameObject obj = Selection.activeGameObject;
            Renderer[] list = obj.GetComponentsInChildren<Renderer>(true);
            for (int i = 0; i < list.Length; ++i)
            {
                list[i].sortingOrder = list[i].sortingOrder + 1;
            }
        }
    }
    [MenuItem("Tools/TX/减1")]
    static void DecTXLayer()
    {
        if (Selection.activeGameObject)
        {
            Debug.Log("activeGameObject=" + Selection.activeGameObject.name);
            GameObject obj = Selection.activeGameObject;
            Renderer[] list = obj.GetComponentsInChildren<Renderer>(true);
            for (int i = 0; i < list.Length; ++i)
            {
                list[i].sortingOrder = list[i].sortingOrder - 1;
            }
        }
    }
}
