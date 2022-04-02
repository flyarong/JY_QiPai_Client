// 自动检测并移动资源

using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using UnityEngine.UI;
using System.Linq;
using UnityEditor.SceneManagement;
using UnityEngine.SceneManagement;
using System.IO;
using System;
using System.Text.RegularExpressions;

public class ImgDependcyClearer : EditorWindow
{
    //忽略项
    static List<string> igNoreList = new List<string>();
    static Dictionary<string, string> AssetPath = new Dictionary<string, string>();
    static void Init() {
        igNoreList.Clear();
        igNoreList.Add("Channel");
        igNoreList.Add("CommonPrefab");
    }

    [MenuItem("Assets/拷贝他处图片(选择一个文件夹，不要选择预制体)")]
    static void ClearDependency()
    {
        ClearEmptyFolder.IsLock = true;
        Init();
        string[] objects = Selection.assetGUIDs;
        Dictionary<string, string> Re = new Dictionary<string, string>();
        Debug.Log("开始处理");
        if (AssetPath.Count == 0)
        {
            ForceGetPngPath();
        }
        for (int ii = 0; ii < objects.Length; ii++)
        {
            string BasePath = AssetDatabase.GUIDToAssetPath(objects[ii]);
            if (Directory.Exists(BasePath + "/Texture2D") == false)
            {
                AssetDatabase.CreateFolder(BasePath, "Texture2D");
            }
            List<string> Need = new List<string>();
            List<string> NeedCopy = new List<string>();
            Dictionary<string, string> Old2New = new Dictionary<string, string>();
            Need.Add(".prefab");
            GetAllAsset(Need, BasePath, ref Re);
            foreach (var item in Re)
            {
                GameObject ReObj;
                Dictionary<Image, string> Map = FindObjTextrue2D(item.Value, out ReObj);
                foreach (var s_item in Map)
                {
                    if (AssetPath.ContainsKey(s_item.Value))
                    {
                        if (!IsInDic(BasePath, s_item.Value))
                        {
                            if (!NeedCopy.Contains(s_item.Value))
                            {
                                NeedCopy.Add(s_item.Value);
                                string NewPngPath = CopyToDic(s_item.Value, BasePath);
                                Old2New.Add(s_item.Value, NewPngPath);
                            }
                        }
                    }
                }
                foreach (var on_item in Old2New)
                {
                    foreach (var ss_item in Map)
                    {
                        if (ss_item.Value == on_item.Key)
                        {
                           
                            ss_item.Key.sprite = AssetDatabase.LoadAssetAtPath(on_item.Value, typeof(Sprite)) as Sprite;
                        }
                    }
                }
                EditorUtility.SetDirty(ReObj);
            }
        }
        AssetDatabase.Refresh();
        AssetDatabase.SaveAssets();
        ClearEmptyFolder.IsLock = false;
    }

    [MenuItem("Assets/相同资源重命名(选择文件夹模式,优先修改文件夹中的名字)")]
    static void ReNameByPath() {
        Dictionary<string, string> Dic = new Dictionary<string, string>();
        string[] objects = Selection.assetGUIDs;
        for (int i = 0; i < objects.Length; i++)
        {
            string BasePath = AssetDatabase.GUIDToAssetPath(objects[i]);
            Debug.Log(BasePath);
            List<string> Re = GetSameNameAssetPath(BasePath);
            Debug.Log(Re.Count);
            for (int j = 0; j < Re.Count; j++)
            {
                Debug.Log("<color=red>修改了</color>" + Re[j]);
                string name = Path.GetFileName(Re[j]);
                name = FixPngName(name);
                name = GetNewName(name, Re[j]);
                AssetDatabase.RenameAsset(Re[j], name);
            }
        }
        AssetDatabase.SaveAssets();
    }
    [MenuItem("Assets/相同资源重命名(全局修改,重命名的文件随机)")]
    static void ReName()
    {
        Dictionary<string, string> Dic = new Dictionary<string, string>();
        List<string> Re = GetSameNameAssetPathForAll("Assets/Game");
        for (int i = 0; i < Re.Count; i++)
        {
            Debug.Log("<color=red>复制了</color>" + Re[i]);
            string name = Path.GetFileName(Re[i]);
            name = FixPngName(name);
            name = GetNewName(name, Re[i]);
            AssetDatabase.RenameAsset(Re[i], name);
        }
        AssetDatabase.SaveAssets();
    }

    [MenuItem("Assets/强制刷新图片路径")]
    static void ForceGetPngPath() {
        AssetPath.Clear();
        List<string> Need = new List<string>();
        Need.Add(".png");
        GetAllAsset(Need, "Assets/Game",ref AssetPath);
        Debug.Log("<color=red>刷新完成</color>");
    }

    static void GetAllAsset(List<string> Need,string BasePath,ref Dictionary<string,string> Dic) {
        Dictionary<string, string> Re = new Dictionary<string, string>();
        GetAllFiles(BasePath, ref Re);
        foreach (var item in Re)
        {
            for (int i = 0; i < Need.Count; i++)
            {
                if (item.Key.Contains(Need[i]) && !item.Key.Contains(".meta"))
                {
                    Dic.Add(item.Key, item.Value);
                }
            }
        }
    }
    //文件名做key
    static void GetAllFiles(object p,ref Dictionary<string,string> FileDic)
    {
        string path = p as string;
        DirectoryInfo root = new DirectoryInfo(path);
        foreach (FileInfo f in root.GetFiles())
        {
            if (!FileDic.ContainsKey(f.Name))
            {
                FileDic.Add(f.Name, JD2XDPath(f.FullName));
            }
        }
        foreach (DirectoryInfo f in root.GetDirectories())
        {

            bool isIgnore = false;
            for (int i = 0; i < igNoreList.Count; i++)
            {
                if (f.FullName.Contains(igNoreList[i]))
                {
                    isIgnore = true;
                }
            }
            if (!isIgnore)
            {
                GetAllFiles(f.FullName,ref FileDic);
            }
        }

    }
    //路径作为key
    static void GetAllPath(object p, ref Dictionary<string, string> FileDic)
    {
        string path = p as string;
        DirectoryInfo root = new DirectoryInfo(path);
        foreach (FileInfo f in root.GetFiles())
        {
            if (!FileDic.ContainsKey(f.FullName))
            {
                FileDic.Add(JD2XDPath(f.FullName), f.Name);
            }
        }
        foreach (DirectoryInfo f in root.GetDirectories())
        {

            bool isIgnore = false;
            for (int i = 0; i < igNoreList.Count; i++)
            {
                if (f.FullName.Contains(igNoreList[i]))
                {
                    isIgnore = true;
                }
            }
            if (!isIgnore)
            {
                GetAllPath(f.FullName, ref FileDic);
            }
        }

    }

    //获取当前文件夹下重复的资源路径
    static List<string> GetSameNameAssetPath(string currPath) {
        Dictionary<string, string> Currt = new Dictionary<string, string>();
        Dictionary<string, string> BaseAll = new Dictionary<string, string>();
        GetAllPath(currPath,ref Currt);
        GetAllPath("Assets/Game", ref BaseAll);
        Debug.Log(Currt.Count);
        Debug.Log(BaseAll.Count);
        List<string> Re = new List<string>();
        foreach (var base_item in BaseAll)
        {
            foreach (var curr_item in Currt)
            {
                if (curr_item.Value == base_item.Value && curr_item.Key != base_item.Key && !curr_item.Value.Contains(".meta"))
                {
                    Re.Add(curr_item.Key);
                }
            }
        }
        return Re;
    }
    static List<string> GetSameNameAssetPathForAll(string currPath)
    {
        List<string> Re = new List<string>();
        Dictionary<string, string> BaseAll = new Dictionary<string, string>();
        GetAllPath("Assets/Game", ref BaseAll);
        Dictionary<string, string> Dic = new Dictionary<string, string>();
        foreach (var base_item in BaseAll) {
            if (!Dic.ContainsKey(base_item.Value))
            {
                Dic.Add(base_item.Value, base_item.Key);
            }
            else {
                if (!base_item.Key.Contains(".meta")) {
                    Re.Add(base_item.Key);
                }
            }
        }
        return Re;
    }
    //检查是否满足限制条件
    static bool IsLimit(string curr, List<string> Limit) {
    for (int i = 0; i < Limit.Count; i++)
    {
        if (curr.Contains(Limit[i])) {
            return true;
        }
    }
    return false;
    }

    //获取图片与组件之间对应的关系
    static Dictionary<Image, string> FindObjTextrue2D(string path,out GameObject ReObj){
        GameObject Obj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
        Image[] T = Obj.GetComponentsInChildren<Image>(true);
        //string[] Re = new string[T.Length];
        
        Dictionary<Image, string> Re = new Dictionary<Image, string>();
        for (int i = 0; i < T.Length; i++)
        {
            if (T[i].sprite != null) {
                Re.Add(T[i],T[i].sprite.name + ".png");
            }
        }
        ReObj = Obj;
        Debug.Log(Obj.name);
        return Re;
    }

    //绝对路径变相对路径
    static string JD2XDPath(string path) {
        string mp = path;
        mp = mp.Substring(mp.IndexOf("Assets"));
        mp = mp.Replace('\\', '/');
        return mp;
    }
    //相对路径变绝对路径
    static string XD2JDPath(string path)
    {
        string ap = @"Assets\";
        DirectoryInfo direction = new DirectoryInfo(ap);
        FileInfo[] files = direction.GetFiles(path, SearchOption.TopDirectoryOnly);
        return files[0].FullName.ToString();
    }
    //是不是在某文件夹的图片 selfDicPath文件夹地址，Name图片名字
    static bool IsInDic(string selfDicPath, string Name) {
        Dictionary<string, string> Re = new Dictionary<string, string>();
        GetAllFiles(selfDicPath,ref Re);
        foreach (var item in Re)
        {
            if (item.Key == Name) {
                Re.Clear();
                return true;
            }
        }
        Re.Clear();
        return false;
    }

    static string CopyToDic(string img,string dicpath) {
        img = FixPngName(img);
        Debug.Log("<color=red>拷贝了： </color>" + img);
        string newPngPath = dicpath + "/Texture2D/" + GetPngGUIDName(img);
        bool b = AssetDatabase.CopyAsset(AssetPath[img], newPngPath);
        return newPngPath;
    }

    static string FixPngName(string str) {
        if (str.Contains("_BYCOPY_"))
        {
            string new_name = System.Text.RegularExpressions.Regex.Split(str, "_BYCOPY_", RegexOptions.IgnoreCase)[0] + ".png";
            Debug.Log("命名修正为：" + new_name + "源命名是：" + str);
            str = new_name;
        }
        return str;
    }

    static string GetPngGUIDName(string Name) {
        return Name.Replace(".png", "") + "_BYCOPY_" + Guid.NewGuid().ToString() + ".png";
    }

    static string GetNewName(string name,string path) {
        string ex_type = Path.GetExtension(name);
        string[] s = path.Split('/');
        string _name = name.Replace(ex_type,"");
        _name = _name + "_" + s[2];
        if (s[2] == "Activity") _name = _name + "_" + s[3] + ex_type;
        _name = _name.ToLower();
        return _name;
    }
}