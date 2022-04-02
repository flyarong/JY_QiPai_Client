using UnityEngine;
using System.Collections;
using UnityEditor;

/*
 * 1.%X : ctrl + X; 
 * 2.#X : shift + X;
 * 3.&X : alt + X; 
 * 4._X ：X
 * 5.%&X: ctrl  + alt + X
 */
public class NMGComEditor : Editor
{

    [MenuItem("Tools/Com/切换物体显隐状态 &q")]
    public static void SetObjActive()
    {
        GameObject[] selectObjs = Selection.gameObjects;
        int objCtn = selectObjs.Length;
        for (int i = 0; i < objCtn; i++)
        {
            bool isAcitve = selectObjs[i].activeSelf;
            selectObjs[i].SetActive(!isAcitve);
        }
    }
}
