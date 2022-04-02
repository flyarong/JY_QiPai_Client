using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.Serialization.Formatters.Binary;
using UnityEditor;
using UnityEngine;
using System.Xml.Serialization;
using UnityEditor.IMGUI.Controls;
using System.Text.RegularExpressions;
using LitJson;

public class AssetsManager : EditorWindow
{
    public class AssetDescriptionInfo : ReferenceFinderData.AssetDescription
    {
        public string guid = "";
        public string name = "";
        public string path = "";
        public Hash128 assetDependencyHash;
        public List<string> dependencies = new List<string>();
        public List<string> references = new List<string>();
        public ReferenceFinderData.AssetState state = ReferenceFinderData.AssetState.NORMAL;
        public List<string> dependenciesRoot = new List<string>();
        public List<string> referencesRoot = new List<string>();
        public List<string> dependenciesAll = new List<string>();
        public List<string> referencesAll = new List<string>();
        public List<string> referencesCode = new List<string>();

        public string type = "";
        public string nameSuffix = "";
        public string suffix = "";
        public string minLocation = "";
        public string maxLocation = "";
        public Location location = new Location();
        public string location1 = "";
        public string location2 = "";
        public string location3 = "";
        public string asset_library = "";
        public string com_library = "";
        public bool is_spine = false;
        public List<Location> locationRealeList = new List<Location>();
        public List<Location> locationLibList = new List<Location>();
        public List<Location> locationAssetList = new List<Location>();
        public List<Location> locationCodeList = new List<Location>();
        public List<Location> referencesCodeLocation = new List<Location>();
    }

    [Serializable]
    public class AssetsManagerStruct
    {
        public Dictionary<string, List<string>> asset_library;
        public List<string> com_library;
        public List<string> normal_common;
        public Dictionary<string, List<string>> game_scene;
        public Dictionary<string, List<string>> depend;
        public List<string> asstes_check;
        public List<string> game_ignore;
        public List<string> lua_ignore;
        public Dictionary<string, List<string>> fix_asset;
        public string vesion;
        public Dictionary<string, bool> activity_config;
        public Dictionary<string, bool> activity_folder;
    }

    public struct Location
    {
        public string location1;
        public string location2;
        public string location3;
    }

    private static string ReadAllText(string path)
    {
        FileStream fs = new FileStream(path, FileMode.OpenOrCreate);
        StreamReader sr = new StreamReader(fs);
        string str = "";
        if (sr != null) str = sr.ReadToEnd();
        if (sr != null) sr.Close();
        if (fs != null) fs.Close();
        return str;
    }

    private static bool WriteAllText(string path, string str)
    {
        if (string.IsNullOrEmpty(str) && string.IsNullOrEmpty(path)) return false;
        if (File.Exists(path)) File.Delete(path);
        FileStream fs = new FileStream(path, FileMode.OpenOrCreate);
        StreamWriter sw = new StreamWriter(fs);
        if (sw != null) sw.Write(str);
        if (sw != null) sw.Close();
        if (fs != null) fs.Close();
        return true;
    }

    public static string DebugToConsole(AssetDescriptionInfo adi, string i)
    {
        string str = i + "> ";
        str += "name:" + adi.name + "    ";
        str += "path:" + adi.path + "    ";
        str += "type:" + adi.type + "\n";
        str += "location1:" + adi.location1 + "  ";
        str += "location2:" + adi.location2 + "  ";
        str += "location3:" + adi.location3 + "\n";
        str += "asset_library: " + adi.asset_library + "  ";
        str += "com_library: " + adi.com_library + "\n";
        for (int k = 0; k < adi.references.Count; k++)
        {
            if (asset_guid.ContainsKey(adi.references[k]))
                str += "references:" + asset_guid[adi.references[k]].path + "\n";
        }
        for (int k = 0; k < adi.referencesAll.Count; k++)
        {
            if (asset_guid.ContainsKey(adi.referencesAll[k]))
                str += "referencesAll:" + asset_guid[adi.referencesAll[k]].path + "\n";
        }
        for (int k = 0; k < adi.referencesRoot.Count; k++)
        {
            if (asset_guid.ContainsKey(adi.referencesRoot[k]))
                str += "referencesRoot:" + asset_guid[adi.referencesRoot[k]].path + "\n";
        }
        for (int k = 0; k < adi.referencesCode.Count; k++)
        {
            if (asset_guid.ContainsKey(adi.referencesCode[k]))
                str += "referencesCode:" + asset_guid[adi.referencesCode[k]].path + "\n";
        }
        for (int k = 0; k < adi.referencesCodeLocation.Count; k++)
        {
            var item = adi.referencesCodeLocation[k];
            str += "referencesCodeLocation: localtion1: " + item.location1 + "| localtion2: " + item.location2 + "| localtion3: " + item.location3 + "\n";
        }
        for (int k = 0; k < adi.dependencies.Count; k++)
        {
            if (asset_guid.ContainsKey(adi.dependencies[k]))
                str += "dependencies:" + asset_guid[adi.dependencies[k]].path + "\n";
        }
        for (int k = 0; k < adi.dependenciesAll.Count; k++)
        {
            if (asset_guid.ContainsKey(adi.dependenciesAll[k]))
                str += "dependenciesAll:" + asset_guid[adi.dependenciesAll[k]].path + "\n";
        }
        for (int k = 0; k < adi.dependenciesRoot.Count; k++)
        {
            if (asset_guid.ContainsKey(adi.dependenciesRoot[k]))
                str += "dependenciesRoot:" + asset_guid[adi.dependenciesRoot[k]].path + "\n";
        }
        var l = adi.location;
        str += "location: localtion1: " + l.location1 + "| localtion2: " + l.location2 + "| localtion3: " + l.location3 + "\n";
        for (int k = 0; k < adi.locationLibList.Count; k++)
        {
            var item = adi.locationLibList[k];
            str += "locationLibList: localtion1: " + item.location1 + "| localtion2: " + item.location2 + "| localtion3: " + item.location3 + "\n";
        }
        for (int k = 0; k < adi.locationAssetList.Count; k++)
        {
            var item = adi.locationAssetList[k];
            str += "locationAssetList: localtion1: " + item.location1 + "| localtion2: " + item.location2 + "| localtion3: " + item.location3 + "\n";
        }
        for (int k = 0; k < adi.locationCodeList.Count; k++)
        {
            var item = adi.locationCodeList[k];
            str += "locationCodeList: localtion1: " + item.location1 + "| localtion2: " + item.location2 + "| localtion3: " + item.location3 + "\n";
        }
        for (int k = 0; k < adi.locationRealeList.Count; k++)
        {
            var item = adi.locationRealeList[k];
            str += "locationRealeList: localtion1: " + item.location1 + "| localtion2: " + item.location2 + "| localtion3: " + item.location3 + "\n";
        }
        Debug.Log(str);
        return str;
    }

    private static void CheckFolder(string path)
    {
        string[] rsArray = path.Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
        string _path = "";
        for (int k = 0; k < rsArray.Length - 1; k++)
        {
            _path = _path + rsArray[k] + "/";
        }
        _path = _path.Substring(0, _path.Length - 1);

        if (!AssetDatabase.IsValidFolder(_path))
        {
            CheckFolder(_path);
        }
        else
        {
            if (!AssetDatabase.IsValidFolder(path))
            {
                AssetDatabase.CreateFolder(_path, rsArray[rsArray.Length - 1]);
            }
        }
    }

    private static void LocationListSort(List<Location> list)
    {
        list.Sort(delegate (Location x, Location y)
        {
            if (string.IsNullOrEmpty(x.location1) && string.IsNullOrEmpty(x.location1)) return 0;
            else if (string.IsNullOrEmpty(x.location1)) return -1;
            else if (string.IsNullOrEmpty(y.location1)) return 1;
            else if (x.location1 == y.location1)
            {
                if (string.IsNullOrEmpty(x.location2) && string.IsNullOrEmpty(x.location2)) return 0;
                else if (string.IsNullOrEmpty(x.location2)) return -1;
                else if (string.IsNullOrEmpty(y.location2)) return 1;
                else if (x.location2 == y.location2)
                {
                    if (string.IsNullOrEmpty(x.location3) && string.IsNullOrEmpty(x.location3)) return 0;
                    else if (string.IsNullOrEmpty(x.location3)) return -1;
                    else if (string.IsNullOrEmpty(y.location3)) return 1;
                    else return x.location3.CompareTo(y.location3);
                }
                else return x.location2.CompareTo(y.location2);
            }
            else return x.location1.CompareTo(y.location1);
        });
        list.Reverse();//这里倒序，以game中为基础，activity中进行copy
    }

    private static void LocationListAdd(List<Location> list, Location l)
    {
        if (!list.Contains(l)) list.Add(l);
    }

    private static string LocationToPath(Location l, AssetDescriptionInfo adi)
    {
        string path = "Assets";
        //没有被引用到的资源，需要移动到 _Type 的文件夹中
        if (!string.IsNullOrEmpty(l.location1)) path += "/" + l.location1;
        if (!string.IsNullOrEmpty(l.location2)) path += "/" + l.location2;
        if (!string.IsNullOrEmpty(l.location3)) path += "/" + l.location3;
        path += "/";
        if (adi.locationRealeList.Count == 0) path += "_";//放到_Type目录中
        path += adi.type + "/" + adi.nameSuffix;
        return path;
    }

    private static string LocationToNewPath(Location l, AssetDescriptionInfo adi)
    {
        string newPath = LocationToPath(l, adi);
        string nameSuffix = adi.nameSuffix;
        string newName = adi.name + "_" + l.location2;
        if (l.location2 == "Activity") newName += "_" + l.location3;
        newName = newName.ToLower();
        newPath = newPath.Replace(adi.name, newName);
        return newPath;
    }

    private static string LocationToDirectory(Location l, AssetDescriptionInfo adi)
    {
        string directory = "Assets";
        //没有被引用到的资源，需要移动到 _Type 的文件夹中
        if (!string.IsNullOrEmpty(l.location1)) directory += "/" + l.location1;
        if (!string.IsNullOrEmpty(l.location2)) directory += "/" + l.location2;
        if (!string.IsNullOrEmpty(l.location3)) directory += "/" + l.location3;
        directory += "/";
        if (adi.locationRealeList.Count == 0) directory += "_";//放到_Type目录中
        directory += adi.type;
        return directory;
    }

    private static string LocationToDirectory(Location l)
    {
        string directory = "Assets";
        //没有被引用到的资源，需要移动到 _Type 的文件夹中
        if (!string.IsNullOrEmpty(l.location1)) directory += "/" + l.location1;
        if (!string.IsNullOrEmpty(l.location2)) directory += "/" + l.location2;
        if (!string.IsNullOrEmpty(l.location3)) directory += "/" + l.location3;
        return directory;
    }

    private static bool LocationEquals(Location a, Location b)
    {
        return a.location1 == b.location1 && a.location2 == b.location2 && a.location3 == b.location3;
    }

    private static void SaveLog(Dictionary<string, List<string>> log, string name)
    {
        if (log == null || log.Count == 0) return;
        string json_str = JsonMapper.ToJson(log);
        Debug.Log(name + " " + json_str);
        // System.DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new System.DateTime(1970, 1, 1)); // 当地时区
        // var timeStamp = (long)(DateTime.Now - startTime).TotalMilliseconds; // 相差毫秒数
        // string path =  "Assets/" + name + "_" + timeStamp + ".json";
        string path = "Assets/Editor/AssetsManager/" + name + ".json";
        WriteAllText(path, json_str);
    }

    public static void RemoveSpine()
    {
        int counter = 0;
        int total = asset_guid.Count;
        foreach (var item in asset_guid)
        {
            EditorUtility.DisplayProgressBar("Remove Spine", item.Value.path, ++counter / (float)total);
            bool is_spine = false;
            if (!is_spine)
            {
                if (item.Value.type == "SkeletonDataAsset")
                {
                    is_spine = true;
                }
            }
            if (!is_spine)
                foreach (var guid in item.Value.dependencies)
                {
                    if (asset_guid.ContainsKey(guid) && asset_guid[guid].type == "SkeletonDataAsset")
                    {
                        is_spine = true;
                    }
                }
            if (!is_spine)
                foreach (var guid in item.Value.dependenciesAll)
                {
                    if (asset_guid.ContainsKey(guid) && asset_guid[guid].type == "SkeletonDataAsset")
                    {
                        is_spine = true;
                    }
                }
            if (!is_spine)
                foreach (var guid in item.Value.references)
                {
                    if (asset_guid.ContainsKey(guid) && asset_guid[guid].type == "SkeletonDataAsset")
                    {
                        is_spine = true;
                    }
                }
            if (!is_spine)
                foreach (var guid in item.Value.referencesAll)
                {
                    if (asset_guid.ContainsKey(guid) && asset_guid[guid].type == "SkeletonDataAsset")
                    {
                        is_spine = true;
                    }
                }
            if (!is_spine)
                foreach (var guid in item.Value.referencesRoot)
                {
                    if (asset_guid.ContainsKey(guid) && asset_guid[guid].type == "SkeletonDataAsset")
                    {
                        is_spine = true;
                    }
                }
            if (!is_spine)
                foreach (var guid in item.Value.dependenciesRoot)
                {
                    if (asset_guid.ContainsKey(guid) && asset_guid[guid].type == "SkeletonDataAsset")
                    {
                        is_spine = true;
                    }
                }
            if (is_spine)
            {
                asset_guid[item.Key].locationRealeList.Clear();
                LocationListAdd(asset_guid[item.Key].locationRealeList,asset_guid[item.Key].location);
                asset_guid[item.Key].is_spine = true;
            }
        }
        EditorUtility.ClearProgressBar();
    }

    public static void CollectFbx()
    {
        int counter = 0;
        int total = asset_guid.Count;
        foreach (var item in asset_guid)
        {
            EditorUtility.DisplayProgressBar("Collect Fbx", item.Value.path, ++counter / (float)total);
            if (item.Value.type == "Fbx")
            {
                foreach (var guid in item.Value.dependenciesAll)
                {
                    if (!string.IsNullOrEmpty(asset_guid[guid].asset_library) || !string.IsNullOrEmpty(asset_guid[guid].com_library)) continue;
                    if ((item.Value.type == "MonoScript") || (item.Value.type == "Lua") || (item.Value.type == "SceneAsset")) continue;
                    List<string> _mpl = new List<string>();
                    // foreach (var path in item.Value.movePathList)
                    // {
                    //     string str = path.Replace(item.Value.nameSuffix, asset_guid[guid].nameSuffix);
                    //     str = str.Replace(item.Value.type, asset_guid[guid].type);
                    //     _mpl.Add(str);
                    // }
                    // asset_guid[guid].movePathList = _mpl;
                }
            }
        }
        EditorUtility.ClearProgressBar();
    }

    public static void CollectMaterial()
    {
        int counter = 0;
        int total = asset_guid.Count;
        foreach (var item in asset_guid)
        {
            EditorUtility.DisplayProgressBar("Collect Material", item.Value.path, ++counter / (float)total);
            if (item.Value.type == "Material")
            {
                foreach (var guid in item.Value.dependenciesAll)
                {
                    if (!string.IsNullOrEmpty(asset_guid[guid].asset_library) || !string.IsNullOrEmpty(asset_guid[guid].com_library)) continue;
                    if ((item.Value.type == "MonoScript") || (item.Value.type == "Lua") || (item.Value.type == "SceneAsset")) continue;
                    List<string> _mpl = new List<string>();
                    // foreach (var path in asset_guid[item.Value.guid].movePathList)
                    // {
                    //     string str = path.Replace(item.Value.nameSuffix, asset_guid[guid].nameSuffix);
                    //     str = str.Replace(item.Value.type, asset_guid[guid].type);
                    //     _mpl.Add(str);
                    // }
                    // asset_guid[guid].movePathList = _mpl;
                }
            }
        }
        EditorUtility.ClearProgressBar();
    }

    public static void CollectTexture2DTpsheet()
    {
        int counter = 0;
        int total = asset_guid.Count;
        foreach (var item in asset_guid)
        {
            EditorUtility.DisplayProgressBar("Collect Texture2D Tpsheet", item.Value.path, ++counter / (float)total);
            if (item.Value.type != "Tpsheet") continue;
            foreach (var kv in asset_guid)
            {
                if (!string.IsNullOrEmpty(kv.Value.asset_library) || !string.IsNullOrEmpty(kv.Value.com_library)) continue;
                if ((kv.Value.type == "MonoScript") || (kv.Value.type == "Lua") || (kv.Value.type == "SceneAsset")) continue;
                if (!(kv.Value.name == item.Value.name && kv.Value.type != "Tpsheet")) continue;
                asset_guid[item.Key].locationRealeList = kv.Value.locationRealeList;
            }
        }
        EditorUtility.ClearProgressBar();
    }

    public static void CollectFont()
    {
        int counter = 0;
        int total = asset_guid.Count;
        foreach (var item in asset_guid)
        {
            EditorUtility.DisplayProgressBar("Collect Font", item.Value.path, ++counter / (float)total);
            if (item.Value.type == "Font")
            {
                foreach (var guid in item.Value.dependenciesAll)
                {
                    if (!string.IsNullOrEmpty(asset_guid[guid].asset_library) || !string.IsNullOrEmpty(asset_guid[guid].com_library))
                    {
                        continue;
                    }
                    List<string> _mpl = new List<string>();
                    // foreach (var path in asset_guid[item.Value.guid].movePathList)
                    // {
                    //     string str = path.Replace(item.Value.nameSuffix, asset_guid[guid].nameSuffix);
                    //     str = str.Replace(item.Value.type, asset_guid[guid].type);
                    //     _mpl.Add(str);
                    // }
                    // asset_guid[guid].movePathList = _mpl;
                }
            }
        }
        EditorUtility.ClearProgressBar();
    }

    public static void ParseAssetsManagerConfig()
    {
        string path_str = "Assets/Editor/AssetsManager/AssetsManagerConfig.json";
        string json_str = ReadAllText(path_str);
        if (json_str.Length <= 0) return;

        JsonData jsonData = JsonMapper.ToObject(json_str);
        asset_manager_struct = new AssetsManagerStruct();
        foreach (KeyValuePair<String, JsonData> keyValue in jsonData)
        {
            // Debug.Log(keyValue.Key + ">>>>>>>>>>>>>>>>>>>>>>>>>");
            Dictionary<string, List<string>> dic = new Dictionary<string, List<string>>();
            List<string> list = new List<string>();
            string str = "";
            int _type = 0;
            if (keyValue.Value.ToString() == "JsonData array")
            {
                if (keyValue.Value[0].ToString() == "JsonData object")
                {
                    _type = 1;
                    // Dictionary<string, List<string>>();
                    for (int i = 0; i < keyValue.Value.Count; i++)
                    {
                        foreach (KeyValuePair<String, JsonData> keyValue1 in keyValue.Value[i])
                        {
                            if (!dic.ContainsKey(keyValue1.Key))
                            {
                                dic.Add(keyValue1.Key, new List<string>());
                            }
                            for (int j = 0; j < keyValue1.Value.Count; j++)
                            {
                                dic[keyValue1.Key].Add(keyValue1.Value[j].ToString());
                            }
                        }
                    }
                }
                else
                {
                    _type = 2;
                    // List<string>();
                    foreach (var keyValue1 in keyValue.Value)
                    {
                        list.Add(keyValue1.ToString());
                    }
                }
            }
            else
            {
                _type = 3;
                //string
                str = keyValue.Value.ToString();
            }

            // if (_type == 1){
            //     foreach (var item in dic)
            //     {
            //         Debug.Log("key : " + item.Key);
            //         foreach (var item1 in item.Value)
            //         {
            //             Debug.Log("key : " + item.Key + "value :" + item1);
            //         }
            //     }
            // }
            // else if (_type == 2){
            //     foreach (var item1 in list)
            //     {
            //         Debug.Log("value :" + item1);
            //     }
            // }
            // else if(_type == 3){
            //     Debug.Log("value :" + str);   
            // }

            if (keyValue.Key == "asset_library")
            {
                asset_manager_struct.asset_library = dic;
            }
            else if (keyValue.Key == "com_library")
            {
                asset_manager_struct.com_library = list;
            }
            else if (keyValue.Key == "normal_common")
            {
                asset_manager_struct.normal_common = list;
            }
            else if (keyValue.Key == "game_scene")
            {
                asset_manager_struct.game_scene = dic;
            }
            else if (keyValue.Key == "depend")
            {
                asset_manager_struct.depend = dic;
            }
            else if (keyValue.Key == "asstes_check")
            {
                asset_manager_struct.asstes_check = list;
            }
            else if (keyValue.Key == "game_ignore")
            {
                asset_manager_struct.game_ignore = list;
            }
            else if (keyValue.Key == "lua_ignore")
            {
                asset_manager_struct.lua_ignore = list;
            }
            else if (keyValue.Key == "fix_asset")
            {
                asset_manager_struct.fix_asset = dic;
            }
            else if (keyValue.Key == "vesion")
            {
                asset_manager_struct.vesion = str;
            }
        }
    }

    private static void SetActivityConfigStruct()
    {
        CreateActivityConfig();
        Dictionary<string, bool> activity_config = new Dictionary<string, bool>();
        Dictionary<string, bool> activity_folder = new Dictionary<string, bool>();
        string path = ActivityConfigPath;//以主版本活动为准
        string json_str = File.ReadAllText(path);
        JsonData jsonData = JsonMapper.ToObject(json_str);
        JsonData activities = jsonData["activities"];
        foreach (JsonData item in activities)
        {
            JsonData name = item["name"]; //通过字符串索引器可以取得键值对的值
            JsonData enable = item["enable"];
            string[] pathArr = name.ToString().Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
            if (!activity_config.ContainsKey(pathArr[1]))
            {
                activity_config.Add(pathArr[1], enable.ToString().ToLower() == "true");
            }
        }

        string[] subFolders = AssetDatabase.GetSubFolders("Assets/Game/Activity");
        foreach (var _path in subFolders)
        {
            string[] strArr = _path.Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
            string str = strArr[3];
            if (activity_config.ContainsKey(str))
            {
                activity_folder.Add(str, activity_config[str]);
            }
            else
            {
                activity_folder.Add(str, false);
            }
        }

        asset_manager_struct.activity_config = activity_config;
        asset_manager_struct.activity_folder = activity_folder;
    }

    public static Dictionary<string, AssetDescriptionInfo> asset_guid;//所有资源信息
    //初始化资源描述信息
    private static void InitAssetDescriptionInfo()
    {
        //刷新游戏中资源引用关系
        ReferenceFinderWindow.RefreshData();
        Dictionary<string, ReferenceFinderData.AssetDescription> assetDict = ReferenceFinderWindow.data.assetDict;
        int counter = 0;
        int total = assetDict.Count;
        asset_guid = new Dictionary<string, AssetDescriptionInfo>();
        foreach (var item in assetDict)
        {
            EditorUtility.DisplayProgressBar("Init Asset Description", item.Value.path, ++counter / (float)total);

            string[] pathArr = item.Value.path.Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
            if (asset_guid.ContainsKey(item.Key)) continue; //已经添加过的不需要再添加
            if (!asset_manager_struct.asstes_check.Contains(pathArr[1])) continue; //Assets目录下不需要检查的直接忽略
            if (pathArr[1] == "Game" && asset_manager_struct.game_ignore.Contains(pathArr[2])) continue; //game目录下需要忽略的直接忽略

            AssetDescriptionInfo adi = new AssetDescriptionInfo();
            adi.guid = item.Key;
            adi.name = item.Value.name;
            adi.path = item.Value.path;
            adi.assetDependencyHash = item.Value.assetDependencyHash;
            adi.state = item.Value.state;
            adi.dependencies = item.Value.dependencies;
            adi.references = item.Value.references;
            adi.dependenciesRoot = new List<string>();
            adi.referencesRoot = new List<string>();
            adi.dependenciesAll = new List<string>();
            adi.referencesAll = new List<string>();
            adi.referencesCode = new List<string>();

            adi.nameSuffix = pathArr[pathArr.Length - 1];
            string[] nameArr = adi.nameSuffix.Split(new string[] { "." }, StringSplitOptions.RemoveEmptyEntries);
            adi.suffix = nameArr[nameArr.Length - 1].Substring(0).ToLower();

            // Debug.Log(item.Value.path);
            string at = AssetDatabase.GetMainAssetTypeAtPath(item.Value.path).ToString();
            string[] atArray = at.Split(new string[] { "." }, StringSplitOptions.RemoveEmptyEntries);
            at = atArray[atArray.Length - 1];
            if (at == "GameObject" || at == "DefaultAsset")
            {
                //不能判定准确类型
                at = adi.suffix.Substring(0, 1).ToUpper() + adi.suffix.Substring(1);
            }
            adi.type = at;

            //忽略特定类型的文件
            if (adi.type == "MonoScript") continue;

            adi.location1 = pathArr[1];
            if (pathArr[1] == "Game")
            {
                adi.location2 = pathArr[2];
                if (pathArr[2] == "Activity")
                {
                    adi.location3 = pathArr[3];
                }
            }
            adi.location.location1 = adi.location1;
            adi.location.location2 = adi.location2;
            adi.location.location3 = adi.location3;
            asset_guid.Add(item.Key, adi);
        }
        EditorUtility.ClearProgressBar();
    }

    //添加资源引用关系
    private static void AddAssetReferences()
    {
        int counter = 0;
        int total = asset_guid.Count;
        foreach (var item in asset_guid)
        {
            EditorUtility.DisplayProgressBar("Add Asset References", item.Value.path, ++counter / (float)total);
            SetDependencies(item.Key, item.Key, item.Key);
            SetReferences(item.Key, item.Key, item.Key);
        }
        EditorUtility.ClearProgressBar();
    }

    private static void SetDependencies(string k, string key, string val)
    {
        if (asset_guid[k].dependencies != null && asset_guid[k].dependencies.Count > 0)
        {
            foreach (var guid in asset_guid[k].dependencies)
            {
                if (!asset_guid.ContainsKey(guid))
                {
                    continue;
                }
                if (asset_guid[guid].dependencies != null && asset_guid[guid].dependencies.Count > 0)
                {
                    var v = asset_guid[guid];
                    SetDependencies(guid, key, guid);

                    if (key != guid && !asset_guid[key].dependenciesAll.Contains(guid))
                    {
                        asset_guid[key].dependenciesAll.Add(guid);
                    }
                }
                else
                {
                    if (key != guid && !asset_guid[key].dependenciesRoot.Contains(guid))
                    {
                        asset_guid[key].dependenciesRoot.Add(guid);
                    }

                    if (key != guid && !asset_guid[key].dependenciesAll.Contains(guid))
                    {
                        asset_guid[key].dependenciesAll.Add(guid);
                    }
                }
            }
        }
        else
        {
            if (key != val && !asset_guid[key].dependenciesRoot.Contains(val))
            {
                asset_guid[key].dependenciesRoot.Add(val);
            }

            if (key != val && !asset_guid[key].dependenciesAll.Contains(val))
            {
                asset_guid[key].dependenciesAll.Add(val);
            }
        }
    }

    private static void SetReferences(string k, string key, string val)
    {
        if (asset_guid[k].references != null && asset_guid[k].references.Count > 0)
        {
            foreach (var guid in asset_guid[k].references)
            {
                if (!asset_guid.ContainsKey(guid))
                {
                    continue;
                }
                if (asset_guid[guid].references != null && asset_guid[guid].references.Count > 0)
                {
                    var v = asset_guid[guid];
                    SetReferences(guid, key, guid);

                    if (key != guid && !asset_guid[key].referencesAll.Contains(guid))
                    {
                        asset_guid[key].referencesAll.Add(guid);
                    }
                }
                else
                {
                    if (key != guid && !asset_guid[key].referencesRoot.Contains(guid))
                    {
                        asset_guid[key].referencesRoot.Add(guid);
                    }

                    if (key != guid && !asset_guid[key].referencesAll.Contains(guid))
                    {
                        asset_guid[key].referencesAll.Add(guid);
                    }
                }
            }
        }
        else
        {
            if (key != val && !asset_guid[key].referencesRoot.Contains(val))
            {
                asset_guid[key].referencesRoot.Add(val);
            }

            if (key != val && !asset_guid[key].referencesAll.Contains(val))
            {
                asset_guid[key].referencesAll.Add(val);
            }
        }
    }

    //添加代码引用
    public static Dictionary<string, List<string>> asset_name2lua_guid;//一个资源被哪些代码所引用，相同名字的不同类型的资源都会添加引用
    private static void AddLuaCodeReferences()
    {
        SetLuaCodeReferences();
        int counter = 0;
        int total = asset_guid.Count;
        foreach (var item in asset_guid)
        {
            EditorUtility.DisplayProgressBar("Add Lua Code References", item.Value.path, ++counter / (float)total);
            //只考虑对图片的引用
            // if (item.Value.type != "Texture2D") continue;
            //MonoScript，lua文件和场景文件不需要移动
            // if ((item.Value.type == "MonoScript") || (item.Value.type == "Lua") || (item.Value.type == "SceneAsset")) continue;
            //代码中播放动画，用到动画的名字，但是不会直接加载动画资源
            if ((item.Value.type == "AnimatorController") || (item.Value.type == "AnimationClip")) continue;
            if (asset_name2lua_guid.ContainsKey(item.Value.name))
            {
                asset_guid[item.Key].referencesCode = asset_name2lua_guid[item.Value.name];
                foreach (var guid in asset_name2lua_guid[item.Value.name])
                {
                    LocationListAdd(asset_guid[item.Key].referencesCodeLocation, asset_guid[guid].location);
                }
            }
        }
        EditorUtility.ClearProgressBar();
    }

    private static void SetLuaCodeReferences()
    {
        int counter = 0;
        int total = asset_guid.Count;
        Dictionary<string, string> lua_code = new Dictionary<string, string>();
        foreach (var item in asset_guid)
        {
            EditorUtility.DisplayProgressBar("Read Lua Code", item.Value.path, ++counter / (float)total);
            if (!(item.Value.type == "Lua")) continue;
            if (item.Value.name == "GameSceneCfg") continue;
            if (item.Value.name == "game_module_config") continue;
            // if (!item.Value.name.Contains("_config")) continue;//只检查配置文件
            string lua_str = File.ReadAllText(item.Value.path);
            lua_code.Add(item.Key, lua_str);
        }

        counter = 0;
        total = lua_code.Count;
        asset_name2lua_guid = new Dictionary<string, List<string>>();
        foreach (var lua_kv in lua_code)
        {
            EditorUtility.DisplayProgressBar("Set Lua Code References", asset_guid[lua_kv.Key].path, ++counter / (float)total);
            // if (lua_kv.Key != "item_config") continue;
            //匹配多个结果
            string text = lua_kv.Value;
            string pattern = "(?<=\").*?(?=\")";
            if (Regex.IsMatch(text, pattern))
            {
                MatchCollection mc = Regex.Matches(text, pattern);
                foreach (Match m in mc)
                {
                    var name = m.Value;
                    var guid = lua_kv.Key;
                    //res就是匹配得到的结果//
                    // index += 1;
                    // Debug.Log(index + "  " + name);
                    // str += name + "\n";
                    if (!asset_name2lua_guid.ContainsKey(name))
                    {
                        asset_name2lua_guid.Add(name, new List<string>());
                    }
                    if (!asset_name2lua_guid[name].Contains(guid))
                    {
                        asset_name2lua_guid[name].Add(guid);
                    }
                }
            }
            //匹配一个结果
            // string text1 = lua_kv.Value;
            // string pattern1 = "(?<=\")("+ "匹配字符" + ")(?=\")";
            // if(Regex.IsMatch(text1,pattern1))
            // {
            //     var m = Regex.Match(text1,pattern1);
            //     var res = m.Value;
            //     //res就是匹配得到的结果//
            //     index += 1;
            //     Debug.Log(index + "  " + res);
            //     str += res + "\n";
            // }
        }
        EditorUtility.ClearProgressBar();
    }

    //添加资源库
    private static void AddAssetLibrary()
    {
        int counter = 0;
        int total = asset_guid.Count;
        foreach (var item in asset_guid)
        {
            EditorUtility.DisplayProgressBar("Add Asset Library", item.Value.path, ++counter / (float)total);
            if (asset_manager_struct.asset_library.ContainsKey(item.Value.type) && asset_manager_struct.asset_library[item.Value.type].Contains(item.Value.name))
            {
                asset_guid[item.Key].asset_library = item.Value.guid;
            }
        }
        EditorUtility.ClearProgressBar();
    }

    //添加公用库
    private static void AddComLibrary()
    {
        int counter = 0;
        int total = asset_guid.Count;
        foreach (var item in asset_guid)
        {
            EditorUtility.DisplayProgressBar("Add Com Library", item.Value.path, ++counter / (float)total);
            if (asset_name2lua_guid.ContainsKey(item.Value.name))
            {
                foreach (var guid in asset_name2lua_guid[item.Value.name])
                {
                    if (asset_manager_struct.com_library.Contains(asset_guid[guid].name))
                    {
                        asset_guid[item.Key].com_library = guid;
                        break;
                    }
                }
            }
        }
        EditorUtility.ClearProgressBar();
    }

    private static void AddLocationReferences()
    {
        int counter = 0;
        int total = asset_guid.Count;
        foreach (var item in asset_guid)
        {
            EditorUtility.DisplayProgressBar("Add References Location List", item.Value.path, ++counter / (float)total);
            if (!string.IsNullOrEmpty(item.Value.asset_library))
            {
                Location location = new Location();
                location.location1 = "Game";
                location.location2 = "CommonPrefab";
                location.location3 = "";
                LocationListAdd(item.Value.locationLibList, location);
                continue;
            }
            if (!string.IsNullOrEmpty(item.Value.com_library))
            {
                string guid = item.Value.com_library;
                LocationListAdd(item.Value.locationLibList, asset_guid[guid].location);
                continue;
            }
            //最上层资源的引用对象
            foreach (var guid in item.Value.referencesRoot)
            {
                if (asset_guid[guid].referencesCode != null && asset_guid[guid].referencesCode.Count > 0)
                {
                    //上层引用对象被代码引用，这里需要同步添加上
                    //代码引用对象
                    foreach (var code_guid in asset_guid[guid].referencesCode)
                    {
                        LocationListAdd(item.Value.locationCodeList, asset_guid[code_guid].location);
                    }
                }
                else
                {
                    LocationListAdd(item.Value.locationAssetList, asset_guid[guid].location);
                }
            }
            //代码引用对象
            foreach (var guid in item.Value.referencesCode)
            {
                LocationListAdd(item.Value.locationCodeList, asset_guid[guid].location);
            }
        }
        EditorUtility.ClearProgressBar();
    }

    private static List<Location> GetADILocationList(AssetDescriptionInfo adi)
    {
        List<Location> location_list = new List<Location>();
        if (adi.locationLibList != null && adi.locationLibList.Count > 0)
        {
            var location = adi.locationLibList[0];
            LocationListAdd(location_list, location);
            return location_list;//有库引用的时候只需要库引用
        }
        //代码引用优先
        foreach (var location in adi.locationCodeList)
        {
            LocationListAdd(location_list, location);
        }
        foreach (var location in adi.locationAssetList)
        {
            LocationListAdd(location_list, location);
        }
        return location_list;
    }

    private static void CalculateGameNormalDepend(ref List<Location> game_location, ref List<Location> normal_location, AssetDescriptionInfo adi)
    {
        for (int i = game_location.Count - 1; i >= 0; i--)
        {
            var location = game_location[i];
            foreach (var normal in asset_manager_struct.game_scene[location.location2])
            {
                Location l = new Location();
                l.location1 = "Game";
                l.location2 = normal;
                l.location3 = "";
                //移动到normal中也相当于移动到了game中了
                if (normal_location.Contains(l))
                {
                    game_location.RemoveAt(i);
                    //代码引用的同步
                    if (adi.locationCodeList.Contains(location))
                    {
                        adi.locationCodeList.Remove(location);
                        LocationListAdd(adi.locationCodeList, l);
                    }
                    break;
                }
            }
        }
    }

    private static void CalculateGameDepend(ref List<Location> game_location, ref List<Location> normal_location, AssetDescriptionInfo adi)
    {
        CalculateGameNormalDepend(ref game_location, ref normal_location, adi);

        //尝试移动到normal中
        Dictionary<Location, int> normal_count = new Dictionary<Location, int>();
        if (game_location.Count > 1)
        {
            foreach (var l in game_location)
            {
                if (asset_manager_struct.game_scene[l.location2].Count == 0) continue;
                string normal = asset_manager_struct.game_scene[l.location2][0];
                Location location = new Location();
                location.location1 = "Game";
                location.location2 = normal;
                location.location3 = "";
                if (!normal_count.ContainsKey(location))
                    normal_count.Add(location, 1);
                else
                    normal_count[location]++;
            }
        }

        foreach (var keyValue in normal_count)
        {
            Location location = keyValue.Key;
            if (keyValue.Value > 1)
                LocationListAdd(normal_location, location);
        }

        CalculateGameNormalDepend(ref game_location, ref normal_location, adi);
    }

    private static void CalculateDepend(ref List<Location> location_list, ref List<Location> game_location, ref List<Location> normal_location, ref List<Location> activity_location, AssetDescriptionInfo adi)
    {
        location_list.Clear();
        foreach (var location in game_location) LocationListAdd(location_list, location);
        foreach (var location in normal_location) LocationListAdd(location_list, location);
        foreach (var location in activity_location) LocationListAdd(location_list, location);

        //如果所有的引用都依赖于当前location，这种情况不需要移动
        List<string> depend_list = new List<string>();
        for (int i = 0; i < location_list.Count; i++)
        {
            var location = location_list[i];
            string orig = location.location2;
            if (orig == "Activity") orig = location.location3;
            if (asset_manager_struct.depend.ContainsKey(orig))
            {
                List<string> depends = asset_manager_struct.depend[orig];
                if (depend_list.Count == 0) depend_list = depends;
                List<string> dl = new List<string>();
                foreach (var depend in depends)
                {
                    if (depend_list.Contains(depend))
                    {
                        if (!dl.Contains(depend)) dl.Add(depend);
                    }
                }
                depend_list = dl;
                if (depend_list.Count == 0)
                {
                    break;
                }
            }
        }

        bool all_depend_cur = false;
        foreach (var depend in depend_list)
        {
            Location depend_location = new Location();
            depend_location.location1 = "Game";
            depend_location.location2 = depend;
            depend_location.location3 = "";
            if (asset_manager_struct.activity_config.ContainsKey(depend))
            {
                depend_location.location2 = "Activity";
                depend_location.location3 = depend;
            }
            //所有location都依赖本地这时候不移动了
            if (LocationEquals(adi.location, depend_location))
            {
                all_depend_cur = true;
                break;
            }
        }

        List<int> remove_index = new List<int>();
        if (all_depend_cur)
        {
            for (int i = location_list.Count - 1; i >= 0; i--)
            {
                if (!LocationEquals(location_list[i],adi.location)){
                    if (!remove_index.Contains(i)) remove_index.Add(i);
                }
            }
        }
        else
        {
            for (int i = location_list.Count - 1; i >= 0; i--)
            {
                var location = location_list[i];
                string orig = location.location2;
                if (orig == "Activity") orig = location.location3;
                if (asset_manager_struct.depend.ContainsKey(orig))
                {
                    List<string> depends = asset_manager_struct.depend[orig];
                    bool is_depend = false;
                    foreach (var depend in depends)
                    {
                        for (int j = location_list.Count - 1; j >= 0; j--)
                        {
                            if (location_list.Count != 1 && i == j) continue;
                            Location check_location = location_list[j];
                            //location == 1的时候，可能是没有收集到引用关系，不一定保证该资源没有用，这个时候需要看依赖和资源当前位置的关系
                            if (location_list.Count == 1) check_location = adi.location;
                            string m_location = check_location.location2;
                            if (m_location == "Activity") m_location = check_location.location3;
                            //在依赖的地方，是依赖关系，不用移动
                            if (m_location == depend)
                            {
                                if (!remove_index.Contains(i)) remove_index.Add(i);
                                is_depend = true;
                                break;
                            }
                            //是game_scene时需要检查其 normal_common
                            if (asset_manager_struct.game_scene.ContainsKey(depend))
                            {
                                List<string> normals = asset_manager_struct.game_scene[depend];
                                foreach (var normal in normals)
                                {
                                    if (m_location == normal)
                                    {
                                        if (!remove_index.Contains(i)) remove_index.Add(i);
                                        is_depend = true;
                                        break;
                                    }
                                }
                                if (is_depend) break;
                            }
                        }
                        if (is_depend) break;
                    }
                }
            }
        }

        for (int i = location_list.Count - 1; i >= 0; i--)
        {
            if (!remove_index.Contains(i)) continue;
            var location = location_list[i];
            location_list.RemoveAt(i);
            //代码引用的同步
            if (adi.locationCodeList.Contains(location))
            {
                adi.locationCodeList.Remove(location);
            }
        }
    }

    private static void CallculateLocationListSort(ref List<Location> location_list, AssetDescriptionInfo adi)
    {
        LocationListSort(location_list);
        Location l = new Location();
        int index = -1;
        //code
        for (int i = 0; i < location_list.Count; i++)
        {
            if (adi.locationCodeList.Contains(location_list[i]))
            {
                l = location_list[i];
                index = i;
                break;
            }
        }
        if (index > 0)
        {
            location_list.RemoveAt(index);
            location_list.Insert(0, l);
        }
        //self
        index = location_list.IndexOf(adi.location);
        if (index > 0)
        {
            location_list.RemoveAt(index);
            location_list.Insert(0, adi.location);
        }
    }

    private static void CalculateLocationReferences()
    {
        int counter = 0;
        int total = asset_guid.Count;
        foreach (var item in asset_guid)
        {
            EditorUtility.DisplayProgressBar("Calculate Location References", item.Value.path, ++counter / (float)total);
            //根据locationRealeList 计算结果,添加真正引用的 location
            List<Location> location_list = GetADILocationList(item.Value);
            //game_scene 依赖处理 + depend 依赖处理
            List<Location> game_location = new List<Location>();
            List<Location> normal_location = new List<Location>();
            List<Location> activity_location = new List<Location>();
            //depend 依赖处理
            foreach (var location in location_list)
            {
                if (location.location1 == "Game" && asset_manager_struct.game_scene.ContainsKey(location.location2))
                    LocationListAdd(game_location, location);
                else if (location.location1 == "Game" && asset_manager_struct.normal_common.Contains(location.location2))
                    LocationListAdd(normal_location, location);
                else if (location.location1 == "Game" && location.location2 == "Activity" && asset_manager_struct.activity_config.ContainsKey(location.location3))
                    LocationListAdd(activity_location, location);
            }
            //不需要移动
            if (location_list.Count == 0)
            {
                continue;
            }
            //只要移动到一个地方
            if (location_list.Count == 1)
            {
                // var location = location_list[0];
                // LocationListAdd(item.Value.locationRealeList, location);

                //depend 依赖处理
                CalculateDepend(ref location_list, ref game_location, ref normal_location, ref activity_location, item.Value);
                //处理完后，先排序
                CallculateLocationListSort(ref location_list, item.Value);
                item.Value.locationRealeList = location_list;
                continue;
            }
            //要移动到多个地方
            bool b = false;
            //要移动到 CommonPrefab
            foreach (var location in location_list)
            {
                if (location.location1 == "Game" && location.location2 == "CommonPrefab")
                {
                    LocationListAdd(item.Value.locationRealeList, location);
                    b = true;
                    break;
                }
            }
            if (b) continue;

            //game_scene 依赖处理
            CalculateGameDepend(ref game_location, ref normal_location, item.Value);
            //depend 依赖处理
            CalculateDepend(ref location_list, ref game_location, ref normal_location, ref activity_location, item.Value);
            //处理完后，先排序
            CallculateLocationListSort(ref location_list, item.Value);

            item.Value.locationRealeList = location_list;
        }
        EditorUtility.ClearProgressBar();
    }

    public static void AddMoveLog(AssetDescriptionInfo adi, Location newLocation, ref int count)
    {
        string newPath = LocationToPath(newLocation, adi);
        string nameSuffix = adi.nameSuffix;
        if (!asset_move.ContainsKey(nameSuffix)) asset_move.Add(nameSuffix, new List<string>());
        asset_move[nameSuffix].Add(newPath);
        DebugToConsole(adi, string.Format("<color=blue>{0}</color>", count++));
    }

    public static void SaveMoveLog()
    {
        SaveLog(asset_move, "asset_move");
    }

    //移动游戏资源
    public static Dictionary<string, List<string>> asset_move;//拷贝的资源
    public static void MoveGameAsset()
    {
        bool on_off = true;//移动开关
        int count = 0;//移动资源计数
        int counter = 0;
        int total = asset_guid.Count;
        asset_move = new Dictionary<string, List<string>>();
        foreach (var item in asset_guid)
        {
            EditorUtility.DisplayProgressBar("Move Game Asset", item.Value.path, ++counter / (float)total);
            //排除不需要处理的文件
            if ((item.Value.type == "MonoScript") || (item.Value.type == "Lua") || (item.Value.type == "SceneAsset")) continue;
            //spine文件不处理
            if (item.Value.is_spine) continue;
            //不需要移动的不处理 //需要移动到两个位置的要进行 copy 这里先不处理
            if (is_move){
                Location newLocation = new Location();
                if (item.Value.locationRealeList.Count == 0)newLocation = item.Value.location;
                else newLocation = item.Value.locationRealeList[0];
                bool move = IsMove(item.Value, newLocation);
                if (!move) continue;

                AddMoveLog(item.Value, newLocation, ref count);
                if (!on_off) continue;//移动开关，只打印不做移动操作
                MoveAsset(item.Value, newLocation);
            }
            else{
                if (item.Value.locationRealeList.Count == 0) continue;
                Location newLocation = item.Value.locationRealeList[0];
                bool move = IsMove(item.Value, newLocation);
                if (!move) continue;

                AddMoveLog(item.Value, newLocation, ref count);
                if (!on_off) continue;//移动开关，只打印不做移动操作
                MoveAsset(item.Value, newLocation);
            }
            
        }
        EditorUtility.ClearProgressBar();
        SaveMoveLog();
        Debug.Log(count + " 资源移动完成!!!");
        AssetDatabase.Refresh();
        AssetDatabase.SaveAssets();
    }

    public static bool IsMove(AssetDescriptionInfo adi, Location newLocation)
    {
        //移动规则 1，location相同的不移动，2，path相同不移动， 另外：废弃的资源一定移动到 _Type中
        bool pe = adi.path.ToLower() == LocationToPath(newLocation, adi).ToLower();
        if (pe) return false; //path相同不移动

        bool is_del = adi.locationRealeList.Count == 0;
        if (is_del) return true; //废弃的资源一定移动到 _Type中

        bool location_rule = true; //location相同的不移动
        if (is_move) location_rule = false;
        bool le = LocationEquals(adi.location, newLocation);
        if (location_rule && le) return false;

        return true;
    }

    public static string MoveAsset(AssetDescriptionInfo adi, Location newLocation, int recursion_count = 10)
    {
        bool on_off = true;//开关
        if (is_show) on_off = false;
        if (!on_off) return "";
        //要移动的地方和自己的位置相同的不需要处理
        string newPath = LocationToPath(newLocation, adi);
        if (adi.path == newPath) return "";
        //Unity中没有区分大小写目录，这里需要处理
        if (adi.path.ToLower() == newPath.ToLower()) return "";
        recursion_count--;
        string folder = LocationToDirectory(newLocation, adi);
        CheckFolder(folder);
        string result = AssetDatabase.MoveAsset(adi.path, newPath);
        if (string.IsNullOrEmpty(result))
        {
            // Debug.Log("<color=green>移动资产结果成功：</color>" + newPath);
            adi.path = newPath;//更新位置
        }
        else
        {
            //移动失败从新移动
            if (recursion_count > 0)
                MoveAsset(adi, newLocation, recursion_count);
            else
                Debug.LogError("<color=red>移动资产结果失败：</color>" + result);

        }

        return result;
    }

    private static void AddCopyLog(AssetDescriptionInfo adi, Location newLocation, ref int count)
    {
        string newPath = LocationToNewPath(newLocation, adi);
        string nameSuffix = adi.nameSuffix;
        if (adi.locationCodeList.Contains(newLocation))
        {
            bool is_rc = false;
            if (adi.referencesCodeLocation.Contains(newLocation))
            {
                is_rc = true;
            }
            else
            {
                string location_str = newLocation.location2;
                if (location_str == "Activity") location_str = newLocation.location3;
                if (asset_manager_struct.normal_common.Contains(location_str))
                {
                    //normal处理
                    foreach (var location_code in adi.referencesCodeLocation)
                    {
                        if (asset_manager_struct.game_scene.ContainsKey(location_code.location2))
                        {
                            foreach (var normal_common in asset_manager_struct.game_scene[location_code.location2])
                            {
                                if (location_str == normal_common)
                                {
                                    is_rc = true;
                                    break;
                                }
                            }
                        }
                        if (is_rc) break;
                    }
                }
                else
                {
                    foreach (var item in asset_manager_struct.depend)
                    {
                        foreach (var dep in item.Value)
                        {
                            if (dep == location_str)
                            {
                                Location l = new Location();
                                l.location1 = "Game";
                                if (asset_manager_struct.activity_config.ContainsKey(item.Key))
                                {
                                    //活动
                                    l.location2 = "Activity";
                                    l.location3 = item.Key;
                                }
                                else
                                {
                                    l.location2 = item.Key;
                                    l.location3 = "";
                                }
                                if (adi.referencesCodeLocation.Contains(l))
                                {
                                    is_rc = true;
                                    break;
                                }
                            }
                        }
                        if (is_rc) break;
                    }
                }
            }

            if (is_rc)
            {
                // Debug.Log("<color=green>拷贝资产结果成功：</color>" + newPath);
                if (!asset_copy_by_code.ContainsKey(nameSuffix)) asset_copy_by_code.Add(nameSuffix, new List<string>());
                asset_copy_by_code[nameSuffix].Add(newPath);
                DebugToConsole(adi, string.Format("<color=red>！！！代码中引用Copy的资源 {0} </color>", newPath));
            }
        }

        if (!asset_copy.ContainsKey(nameSuffix)) asset_copy.Add(nameSuffix, new List<string>());
        asset_copy[nameSuffix].Add(newPath);

        DebugToConsole(adi, string.Format("<color=yellow>{0} -> newPath:{1} -- </color>", count++, newPath));
    }

    private static void SaveCopyLog()
    {
        //保存多代码引用数据
        SaveLog(asset_copy_by_code, "asset_copy_by_code");
        //保存copy的数据
        SaveLog(asset_copy, "asset_copy");
    }

    private static void SaveReplaceGuid(AssetDescriptionInfo adi, Location newLocation, string newPath)
    {
        string oldGuid = adi.guid;
        string newGuid = AssetDatabase.AssetPathToGUID(newPath);
        if (string.IsNullOrEmpty(oldGuid) || string.IsNullOrEmpty(newGuid)) return;
        string movePath = LocationToDirectory(newLocation);
        if (path_old2new_guid == null) path_old2new_guid = new Dictionary<string, Dictionary<string, string>>();
        if (!path_old2new_guid.ContainsKey(movePath)) path_old2new_guid.Add(movePath, new Dictionary<string, string>());
        if (!path_old2new_guid[movePath].ContainsKey(oldGuid)) path_old2new_guid[movePath].Add(oldGuid, newGuid);

        //normal_common处理
        string normal_common = newLocation.location2;
        if (asset_manager_struct.normal_common.Contains(normal_common))
        {
            foreach (var guid in adi.referencesRoot)
            {
                Location location = asset_guid[guid].location;
                if (location.location1 == "Game" && asset_manager_struct.game_scene.ContainsKey(location.location2)
                    && asset_manager_struct.game_scene[location.location2].Count > 0)
                {
                    bool is_nor = false;
                    foreach (var normal in asset_manager_struct.game_scene[location.location2])
                    {
                        if (normal == normal_common)
                        {
                            is_nor = true;
                            break;
                        }
                    }
                    if (!is_nor) continue;
                    string originPath = LocationToDirectory(location);
                    if (path_old2new_guid == null) path_old2new_guid = new Dictionary<string, Dictionary<string, string>>();
                    if (!path_old2new_guid.ContainsKey(originPath)) path_old2new_guid.Add(originPath, new Dictionary<string, string>());
                    if (!path_old2new_guid[originPath].ContainsKey(oldGuid)) path_old2new_guid[originPath].Add(oldGuid, newGuid);
                }
            }
        }
        //depend处理
        string depend = newLocation.location2;
        if (depend == "Activity") depend = newLocation.location3;
        List<Location> re_list = new List<Location>();
        foreach (var item in asset_manager_struct.depend)
        {
            foreach (var dep in item.Value)
            {
                if (dep == depend)
                {
                    Location l = new Location();
                    l.location1 = "Game";
                    if (asset_manager_struct.activity_config.ContainsKey(item.Key))
                    {
                        //活动
                        l.location2 = "Activity";
                        l.location3 = item.Key;
                    }
                    else
                    {
                        l.location2 = item.Key;
                        l.location3 = "";
                    }
                    if (!re_list.Contains(l)) re_list.Add(l);
                    break;
                }
            }
        }
        foreach (var guid in adi.referencesRoot)
        {
            Location location = asset_guid[guid].location;
            if (re_list.Contains(location))
            {
                string originPath = LocationToDirectory(location);
                if (path_old2new_guid == null) path_old2new_guid = new Dictionary<string, Dictionary<string, string>>();
                if (!path_old2new_guid.ContainsKey(originPath)) path_old2new_guid.Add(originPath, new Dictionary<string, string>());
                if (!path_old2new_guid[originPath].ContainsKey(oldGuid)) path_old2new_guid[originPath].Add(oldGuid, newGuid);
            }
        }
        //code引用处理
        if (adi.locationCodeList != null && adi.locationCodeList.Count > 0)
        {
            foreach (var guid in adi.referencesRoot)
            {
                var referencesCodeLocation = asset_guid[guid].referencesCodeLocation;
                if (referencesCodeLocation.Contains(newLocation))
                {
                    Location location = asset_guid[guid].location;
                    string originPath = LocationToDirectory(location);
                    if (path_old2new_guid == null) path_old2new_guid = new Dictionary<string, Dictionary<string, string>>();
                    if (!path_old2new_guid.ContainsKey(originPath)) path_old2new_guid.Add(originPath, new Dictionary<string, string>());
                    if (!path_old2new_guid[originPath].ContainsKey(oldGuid)) path_old2new_guid[originPath].Add(oldGuid, newGuid);
                }
            }
        }
    }

    public static void ReplaceGuid()
    {
        if (path_old2new_guid.Count == 0) return;
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        //将游戏中对旧资源的引用重新指向对新copy的资源的引用
        foreach (var item in path_old2new_guid)
        {
            string path = item.Key;
            path = path.Replace("Assets/", "");
            path = path.Replace("/", "\\");
            string newFoldrPath = Application.dataPath + "/" + path;
            UtilGuids.RegenerateGuids(newFoldrPath, null, item.Value);
        }
    }

    //拷贝游戏资源
    public static Dictionary<string, Dictionary<string, string>> path_old2new_guid;//需要替换为新 guid 的文件
    public static Dictionary<string, List<string>> asset_copy_by_code;//代码中用到的被copy的资源
    public static Dictionary<string, List<string>> asset_copy;//拷贝的资源
    public static void CopyGameAsset()
    {
        bool on_off = true;//开关
        int count = 0;//计数
        int counter = 0;
        int total = asset_guid.Count;
        path_old2new_guid = new Dictionary<string, Dictionary<string, string>>();
        asset_copy_by_code = new Dictionary<string, List<string>>();
        asset_copy = new Dictionary<string, List<string>>();
        foreach (var item in asset_guid)
        {
            EditorUtility.DisplayProgressBar("Copy Game Asset", item.Value.path, ++counter / (float)total);
            //排除不需要处理的文件
            if ((item.Value.type == "MonoScript") || (item.Value.type == "Lua") || (item.Value.type == "SceneAsset")) continue;
            //spine文件不处理
            if (item.Value.is_spine) continue;
            //不需要copy的不处理
            if (item.Value.locationRealeList.Count < 2) continue;
            for (int i = 1; i < item.Value.locationRealeList.Count; i++)
            {
                Location newLocation = item.Value.locationRealeList[i];
                AddCopyLog(item.Value, newLocation, ref count);
                if (!on_off) continue;//只打印不做操作
                CopyAsset(item.Value, newLocation);
            }
        }
        EditorUtility.ClearProgressBar();

        ReplaceGuid();

        SaveCopyLog();

        Debug.Log(count + " 资源拷贝完成!!!");
        AssetDatabase.Refresh();
        AssetDatabase.SaveAssets();
    }

    public static bool CopyAsset(AssetDescriptionInfo adi, Location newLocation, int recursion_count = 10)
    {
        bool on_off = true;//开关
        if (is_show) on_off = false;
        if (!on_off) return true;
        recursion_count--;
        string folder = LocationToDirectory(newLocation, adi);
        CheckFolder(folder);

        string oldPath = adi.path;
        string newPath = LocationToNewPath(newLocation, adi);
        bool b = AssetDatabase.CopyAsset(oldPath, newPath);
        if (b)
        {
            // Debug.Log("<color=green>拷贝资产结果成功：</color>" + newPath);
            SaveReplaceGuid(adi, newLocation, newPath);
        }
        else
        {
            if (recursion_count > 0)
                CopyAsset(adi, newLocation, recursion_count);
            else
                Debug.LogError("<color=red>拷贝资产结果失败：</color>" + newPath);
        }
        return b;
    }

    public static AssetsManagerStruct asset_manager_struct;//资源管理的配置文件转换的结构体

    [MenuItem("Assets/Util/资源整理", false, 1)]
    [MenuItem("Util/资源整理", false, 1)]
    public static void MoveAndCopyGameAsset()
    {
        ClearEmptyFolder.IsLock = true;
        is_move = false;
        is_show = false;
        ParseAssetsManagerConfig();
        SetActivityConfigStruct();
        InitAssetDescriptionInfo();
        AddAssetReferences();
        AddLuaCodeReferences();
        AddAssetLibrary();
        AddComLibrary();
        AddLocationReferences();
        CalculateLocationReferences();

        CollectTexture2DTpsheet();
        RemoveSpine();//不移动spine相关文件，导入的时候需要确认会导致引用丢失

        foreach (var item in asset_guid)
        {
            // if (item.Value.name.Contains("wave3d")) DebugToConsole(item.Value,"XXXXXXXXXXXX");
        }

        MoveGameAsset();
        CopyGameAsset();

        AssetDatabase.Refresh();
        AssetDatabase.SaveAssets();
        ClearEmptyFolder.IsLock = false;
        // Packager.BuildAssetMap();//删除空余目录
    }

    public static bool is_show = true;
    [MenuItem("Assets/Util/资源整理（预览）", false, 0)]
    [MenuItem("Util/资源整理（预览）", false, 0)]
    public static void MoveAndCopyGameAssetShow()
    {
        ClearEmptyFolder.IsLock = true;
        is_move = false;
        is_show = true;
        ParseAssetsManagerConfig();
        SetActivityConfigStruct();
        InitAssetDescriptionInfo();
        AddAssetReferences();
        AddLuaCodeReferences();
        AddAssetLibrary();
        AddComLibrary();
        AddLocationReferences();
        CalculateLocationReferences();

        CollectTexture2DTpsheet();
        RemoveSpine();//不移动spine相关文件，导入的时候需要确认会导致引用丢失

        foreach (var item in asset_guid)
        {
            if (item.Value.name.Contains("ddz_settlement_icon_fd_normal_ddz_common")) DebugToConsole(item.Value,"XXXXXXXXXXXX");
        }

        MoveGameAsset();
        CopyGameAsset();

        AssetDatabase.Refresh();
        AssetDatabase.SaveAssets();
        ClearEmptyFolder.IsLock = false;
        // Packager.BuildAssetMap();//删除空余目录
    }

    public static bool is_move = false;
    [MenuItem("Assets/Util/收集废弃资源", false, 3)]
    [MenuItem("Util/收集废弃资源", false, 3)]
    public static void MoveUnusedGameAsset()
    {
        ClearEmptyFolder.IsLock = true;
        is_move = true;
        is_show = false;
        ParseAssetsManagerConfig();
        SetActivityConfigStruct();
        InitAssetDescriptionInfo();
        AddAssetReferences();
        AddLuaCodeReferences();
        AddAssetLibrary();
        AddComLibrary();
        AddLocationReferences();
        CalculateLocationReferences();

        CollectTexture2DTpsheet();
        RemoveSpine();//不移动spine相关文件，导入的时候需要确认会导致引用丢失

        foreach (var item in asset_guid)
        {
            // if (item.Value.name.Contains("wave3d")) DebugToConsole(item.Value,"XXXXXXXXXXXX");
        }

        MoveGameAsset();
        CopyGameAsset();

        AssetDatabase.Refresh();
        AssetDatabase.SaveAssets();
        ClearEmptyFolder.IsLock = false;
        // Packager.BuildAssetMap();//删除空余目录
    }

    [MenuItem("Assets/Util/收集废弃资源（预览）", false, 2)]
    [MenuItem("Util/收集废弃资源（预览）", false, 2)]
    public static void ShowMoveUnusedGameAsset()
    {
        ClearEmptyFolder.IsLock = true;
        is_move = true;
        is_show = true;
        ParseAssetsManagerConfig();
        SetActivityConfigStruct();
        InitAssetDescriptionInfo();
        AddAssetReferences();
        AddLuaCodeReferences();
        AddAssetLibrary();
        AddComLibrary();
        AddLocationReferences();
        CalculateLocationReferences();

        CollectTexture2DTpsheet();
        RemoveSpine();//不移动spine相关文件，导入的时候需要确认会导致引用丢失

        foreach (var item in asset_guid)
        {
            if (item.Value.name == "HD666") DebugToConsole(item.Value,"XXXXXXXXXXXX");
        }

        MoveGameAsset();
        CopyGameAsset();

        AssetDatabase.Refresh();
        AssetDatabase.SaveAssets();
        ClearEmptyFolder.IsLock = false;
        // Packager.BuildAssetMap();//删除空余目录
    }

    [MenuItem("Assets/Util/生成资源引用配置", false, 1000)]
    [MenuItem("Util/生成资源引用配置", false, 1000)]
    private static void UpdateSwjlIconConfig()
    {
        string[] objects = Selection.assetGUIDs;
        string oldFolderPath = AssetDatabase.GUIDToAssetPath(objects[0]);
        string[] s = oldFolderPath.Split('/');
        string folderName = s[s.Length - 1];
        if (folderName.Contains("."))
        {
            // Debug.LogError("该索引不是文件夹名字");
            return;
        }
        string folderPath = Path.GetFullPath(".") + Path.DirectorySeparatorChar + oldFolderPath;
        folderPath = folderPath.Replace("\\", "/");
        Debug.Log("folderPath" + folderPath);
        List<string> asset_name = new List<string>();
        GetDirectory(folderPath, asset_name);
        string json_str = JsonMapper.ToJson(asset_name);
        Debug.Log("asset_config json " + json_str);
        string lua_str = json_str.Replace("[", "{");
        lua_str = lua_str.Replace("]", "}");
        Debug.Log("asset_config lua " + lua_str);
        lua_str = "return " + lua_str;

        s = folderPath.Split('/');
        string name = s[s.Length - 1] + "_asset_config.lua";
        string path = folderPath.Substring(folderPath.IndexOf("Assets"));
        path = path + "/Lua/" + name;
        Debug.Log("path " + path);
        WriteAllText(path, lua_str);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }

    public static void GetDirectory(string sourceDirectory, List<string> asset_name)
    {
        //判断源目录和目标目录是否存在，如果不存在，则创建一个目录
        if (!Directory.Exists(sourceDirectory))
        {
            Debug.Log("没有目录？？？");
            return;
        }
        GetFile(sourceDirectory, asset_name);
        string[] directionName = Directory.GetDirectories(sourceDirectory);
        foreach (string directionPath in directionName)
        {
            GetDirectory(directionPath, asset_name);
        }
    }
    public static void GetFile(string sourceDirectory, List<string> asset_name)
    {
        //获取所有文件名称
        string[] fileName = Directory.GetFiles(sourceDirectory);
        foreach (string filePath in fileName)
        {
            Debug.Log("filePath " + filePath);
            if (!filePath.Contains("."))
            {
                // Debug.Log("该索引不是文件名字");
                continue;
            }
            if (filePath.Contains(".meta"))
            {
                // Debug.Log("该索引是meat文件");
                continue;
            }
            string fp = filePath;
            fp = fp.Replace("\\", "/");
            string[] s = fp.Split('/');
            string folderName = s[s.Length - 1];
            s = folderName.Split('.');
            folderName = s[0];
            if (!asset_name.Contains(folderName)) asset_name.Add(folderName);
        }
    }

    //活动配置相关
    public struct act_struct
    {
        public string name;
        public bool enable;
    }
    public static string ActivityConfigPath = "Assets/VersionConfig/ActivityConfig.json";
    public static string ActConfigPath = "Assets/act_config.txt";
    public static string GameModuleConfig = "Assets/Game/CommonPrefab/Lua/game_module_config.lua";
    [MenuItem("Assets/Util/生成活动配置", false, 10)]
    [MenuItem("Util/生成活动配置", false, 10)]
    public static void CreateActivityConfig()
    {
        string ActivityConfigPath = "Assets/VersionConfig/ActivityConfig.json";
        string ActConfigPath = "Assets/act_config.txt";
        string GameModuleConfig = "Assets/Game/CommonPrefab/Lua/game_module_config.lua";
        Debug.Log(AppDefine.CurQuDao);
        if (AppDefine.CurQuDao != "main")
        {
            ActivityConfigPath = "Assets/VersionConfig/ActivityConfig_" + AppDefine.CurQuDao + ".json";
            ActConfigPath = "Assets/act_config_" + AppDefine.CurQuDao + ".txt";
            string gmc = "Assets/Channel/" + AppDefine.CurQuDao + "/Assets/Lua/game_module_config.lua";
            if (File.Exists(gmc))
                GameModuleConfig = gmc;
        }
        Debug.Log(GameModuleConfig);
        Dictionary<string, Dictionary<string, string>> dic = new Dictionary<string, Dictionary<string, string>>();
        string[] luatable = File.ReadAllLines(GameModuleConfig); ;
        string id = "";
        for (int i = 0; i < luatable.Length; i++)
        {
            // Debug.Log(luatable[i]);
            string str = luatable[i];
            if (str.Contains("			id = "))
            {
                string[] sArray = str.Split(new string[] { "			id = ", "," }, StringSplitOptions.RemoveEmptyEntries);
                id = sArray[0];
                dic.Add(id, new Dictionary<string, string>());
                dic[id].Add("id", id);
            }
            if (str.Contains("			key = "))
            {
                string[] sArray = str.Split(new string[] { "			key = \"", "\"," }, StringSplitOptions.RemoveEmptyEntries);
                dic[id].Add("key", sArray[0]);
            }
            if (str.Contains("			desc = "))
            {
                string[] sArray = str.Split(new string[] { "			desc = \"", "\"," }, StringSplitOptions.RemoveEmptyEntries);
                dic[id].Add("desc", sArray[0]);
            }
            if (str.Contains("			lua = "))
            {
                string[] sArray = str.Split(new string[] { "			lua = \"", "\"," }, StringSplitOptions.RemoveEmptyEntries);
                dic[id].Add("lua", sArray[0]);
            }
            if (str.Contains("			is_on_off = "))
            {
                string[] sArray = str.Split(new string[] { "			is_on_off = ", "," }, StringSplitOptions.RemoveEmptyEntries);
                dic[id].Add("is_on_off", sArray[0]);
            }
            if (str.Contains("			enable = "))
            {
                string[] sArray = str.Split(new string[] { "			enable = ", "," }, StringSplitOptions.RemoveEmptyEntries);
                dic[id].Add("enable", sArray[0]);
            }
            if (str.Contains("			state = "))
            {
                string[] sArray = str.Split(new string[] { "			state = ", "," }, StringSplitOptions.RemoveEmptyEntries);
                dic[id].Add("state", sArray[0]);
            }
        }
        //生成ActivityConfig
        Dictionary<string, List<act_struct>> _dic = new Dictionary<string, List<act_struct>>();
        _dic.Add("activities", new List<act_struct>());
        foreach (var item in dic)
        {
            bool is_enable = item.Value["enable"] == "1" ? true : false;
            act_struct act_st = new act_struct()
            {
                name = "Activity/" + item.Value["key"],
                enable = is_enable,
            };

            _dic["activities"].Add(act_st);
        }
        string json_str = JsonMapper.ToJson(_dic);
        Debug.Log("ActivityConfig " + json_str);
        WriteAllText(ActivityConfigPath, json_str);
        //生成act_config
        string txt_str = "";
        foreach (var item in dic)
        {
            txt_str += item.Value["key"] + "|" + item.Value["desc"] + "|" + item.Value["state"] + "\n";
        }
        Debug.Log("act_config " + txt_str);
        WriteAllText(ActConfigPath, txt_str);
        Debug.Log("生成活动配置完成");
    }

}
