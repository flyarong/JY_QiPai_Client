using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;


public class AnimationOptimize
{
    static void AddFileList(List<string> filePaths, string path)
    {
        if (".anim" == Path.GetExtension(path))
        {
            filePaths.Add(path);
        }
    }

    const string AnimationOptimizeTag = "Assets/Animation Tool/裁剪浮点数&&去除多余关键帧";
    [MenuItem(AnimationOptimizeTag, false, 64)]
    public static void Optimize()
    {
        string[] assetGUIDArray = Selection.assetGUIDs;
        if (assetGUIDArray.Length > 0)
        {
            List<string> filePaths = new List<string>();
            for (int i = 0; i < assetGUIDArray.Length; ++i)
            {
                string assetPath = AssetDatabase.GUIDToAssetPath(assetGUIDArray[i]);
                if (Directory.Exists(assetPath))
                {
                    string[] folder = new string[] { assetPath };
                    //将文件夹下所有资源作为选择资源
                    string[] paths = AssetDatabase.FindAssets(null, folder);
                    foreach (var p in paths)
                    {
                        string ppath = AssetDatabase.GUIDToAssetPath(p);
                        if (!Directory.Exists(ppath))
                        {
                            AddFileList(filePaths, ppath);
                        }
                    }
                }
                else
                {
                    AddFileList(filePaths, assetPath);
                }

            }
            var count = 0;
            EditorUtility.DisplayProgressBar("3.Set Anim ", "3.Set Anim ...", 0);
            foreach (string path in filePaths)
            {
                count++;
                EditorUtility.DisplayProgressBar("3.Set Anim " + "(" + count + "/" + filePaths.Count + ")", path, count / (float)filePaths.Count);
                AnimationClip anim = AssetDatabase.LoadAssetAtPath<AnimationClip>(path);
                Optimize(anim);
                AssetDatabase.ImportAsset(path);
            }
            AssetDatabase.SaveAssets();
            EditorUtility.ClearProgressBar();
        }
    }

    static void _OptmizeAnimationFloat(AnimationClip _clip)
    {
        if (_clip != null)
        {
            AnimationClipCurveData[] curves = null;
            curves = AnimationUtility.GetAllCurves(_clip);
            Keyframe key;
            Keyframe[] keyFrames;
            string floatFormat = "f3";//浮点数精度压缩到f3
            if (curves != null && curves.Length > 0)
            {
                for (int ii = 0; ii < curves.Length; ++ii)
                {
                    AnimationClipCurveData curveDate = curves[ii];
                    if (curveDate.curve == null || curveDate.curve.keys == null)
                    {
                        //Debug.LogWarning(string.Format("AnimationClipCurveData {0} don't have curve; Animation name {1} ", curveDate, animationPath));
                        continue;
                    }
                    keyFrames = curveDate.curve.keys;
                    for (int i = 0; i < keyFrames.Length; i++)
                    {
                        key = keyFrames[i];
                        key.value = float.Parse(key.value.ToString(floatFormat));
                        key.inTangent = float.Parse(key.inTangent.ToString(floatFormat));
                        key.outTangent = float.Parse(key.outTangent.ToString(floatFormat));
                        keyFrames[i] = key;
                    }
                    curveDate.curve.keys = keyFrames;
                    _clip.SetCurve(curveDate.path, curveDate.type, curveDate.propertyName, curveDate.curve);
                }
            }
        }
    }
    private static void _OptmizeAnimationReduceKeyFrame(AnimationClip _clip)
    {
        if (_clip != null)
        {
            List<int> delIndexList = new List<int>();
            foreach (EditorCurveBinding theCurveBinding in AnimationUtility.GetCurveBindings(_clip))
            {
                AnimationCurve animation = AnimationUtility.GetEditorCurve(_clip, theCurveBinding);
                for (int i = 1; i < animation.keys.Length - 1; i++)
                {
                    if (animation.keys[i - 1].value == animation.keys[i].value && animation.keys[i].value == animation.keys[i + 1].value)
                    {
                        delIndexList.Add(i);
                    }
                }
                for (int i = delIndexList.Count - 1; i >= 0; i--)
                {
                    animation.RemoveKey(delIndexList[i]);
                }
                delIndexList.Clear();
                AnimationUtility.SetEditorCurve(_clip, theCurveBinding, animation);
            }
        }
    }
    static void Optimize(AnimationClip _clip)
    {
        _OptmizeAnimationReduceKeyFrame(_clip);
        _OptmizeAnimationFloat(_clip);
    }
}