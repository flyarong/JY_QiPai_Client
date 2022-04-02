using UnityEditor;
using UnityEngine;
using System;
using System.IO;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using LuaFramework;
using UnityEditor.Callbacks;
using UnityEditor.SceneManagement;
using UnityEngine.SceneManagement;
using System.Text.RegularExpressions;
using System.Runtime.CompilerServices;

public class Packager
{
    public static string platform = string.Empty;
    static List<string> paths = new List<string>();
    static List<string> files = new List<string>();
    static List<AssetBundleBuild> maps = new List<AssetBundleBuild>();
	static Dictionary<string, string> AssetToBundleMap = new Dictionary<string, string>();
    ///-----------------------------------------------------------
    static string[] exts = { ".txt", ".xml", ".lua", ".assetbundle", ".json" };
    static bool CanCopy(string ext)
    {   //能不能复制
        foreach (string e in exts)
        {
            if (ext.Equals(e)) return true; 
        }
        return false;
    }

    /// <summary>
    /// 载入素材
    /// </summary>
    static UnityEngine.Object LoadAsset(string file)
    {
        if (file.EndsWith(".lua")) file += ".txt";
        return AssetDatabase.LoadMainAssetAtPath("Assets/LuaFramework/Examples/Builds/" + file);
    }

    /// <summary>
    /// 生成绑定素材
    /// </summary>
    public static void BuildAssetResource(BuildTarget target)
    {
        if (Directory.Exists(Util.DataPath))
        {
            Directory.Delete(Util.DataPath, true);
        }
        string streamPath = Application.streamingAssetsPath;
        if (Directory.Exists(streamPath))
        {
            Directory.Delete(streamPath, true);
        }
        Directory.CreateDirectory(streamPath);
        AssetDatabase.Refresh();

        maps.Clear();
		AssetToBundleMap.Clear ();
        if (AppConst.LuaBundleMode)
        {
			HandleMainLuaBundle ();
            HandleLuaBundle();
        }
        else
        {
			HandleMainLuaFile ();
            HandleLuaFile();
        }

        HandleBundleDDZ();

		BuildAssetToBundleFile ();

        string resPath = "Assets/" + AppConst.AssetDir;
        BuildPipeline.BuildAssetBundles(resPath, maps.ToArray(), BuildAssetBundleOptions.None, target);
        BuildFileIndex();

        File.WriteAllText(string.Format("{0}/{1}.txt", resPath, target.ToString()), "文件名为当前资源的编译平台");

        string streamDir = Application.dataPath + "/" + AppConst.LuaTempDir;
        //清理临时资源
        if (Directory.Exists(streamDir))
            Directory.Delete(streamDir, true);

        AssetDatabase.Refresh();
    }

	static void AddBuildMap(string bundleName, string pattern, string path, bool isLua = false)
    {
        string[] files = Directory.GetFiles(path, pattern);
        if (files.Length == 0) return;

		string dictKey, dictValue;
        for (int i = 0; i < files.Length; i++)
        {
            files[i] = files[i].Replace('\\', '/');

			//lua做了特殊处理,忽视
			if(isLua) continue;

			dictKey = Path.GetFileName (files[i]);
			if(AssetToBundleMap.TryGetValue(dictKey, out dictValue)) {
				if(string.Compare(dictValue, bundleName) != 0)
					UnityEngine.Debug.LogError(string.Format("[AssetBundle] AddBuildMap conflict: {0} : {1} - {2}", dictKey, dictValue, bundleName));
				continue;
			}
			AssetToBundleMap.Add(dictKey, bundleName);
        }

        AssetBundleBuild build = new AssetBundleBuild();
        build.assetBundleName = bundleName;
        build.assetNames = files;
        maps.Add(build);
    }

    /// <summary>
    /// 处理Lua代码包
    /// </summary>
	static void HandleMainLuaBundle()
	{
		string streamDir = Application.dataPath + "/" + AppConst.LuaTempDir;

		string[] srcDirs = { "Assets/Game/Framework/", "Assets/Game/Common/" };
		for (int idx = 0; idx < srcDirs.Length; ++idx) {
			string luaFileDir = srcDirs [idx];
			if (AppConst.LuaByteMode) {
				string sourceDir = luaFileDir;
				string[] files = Directory.GetFiles(sourceDir, "*.lua", SearchOption.AllDirectories);
				int len = sourceDir.Length;

				if (sourceDir[len - 1] == '/' || sourceDir[len - 1] == '\\')
				{
					--len;
				}

				string tag = "@";
				for (int j = 0; j < files.Length; j++)
				{
					string str = files[j].Remove(0, len);
					if (str.Contains(tag))
						UnityEngine.Debug.LogErrorFormat("{0} 名称中包含了{1}，存在路径解析错误的可能！", str, tag);
					str = str.Replace("\\", "/");
					str = str.Substring(1);
					str = str.Replace("/", tag);

					string dest = streamDir + str + ".bytes";
					string dir = Path.GetDirectoryName(dest);

					UnityEngine.Debug.Log("==>>" + dest);
					Directory.CreateDirectory(dir);
					EncodeLuaFile(files[j], dest);
				}
			} else {
				ToLuaMenu.CopyLuaBytesFiles(luaFileDir, streamDir);
			}

		}

		AddBuildMap("lua" + AppConst.ExtName, "*.bytes", "Assets/" + AppConst.LuaTempDir, true);
		AssetDatabase.Refresh();
	}

    static void HandleLuaBundle()
    {
        string streamDir = Application.dataPath + "/" + AppConst.LuaTempDir;
        if (!Directory.Exists(streamDir))
            Directory.CreateDirectory(streamDir);

        string[] srcDirs = { CustomSettings.luaDir, CustomSettings.FrameworkPath + "/ToLua/Lua" };
        for (int i = 0; i < srcDirs.Length; i++)
        {
            if (AppConst.LuaByteMode)
            {
                string sourceDir = srcDirs[i];
                string[] files = Directory.GetFiles(sourceDir, "*.lua", SearchOption.AllDirectories);
                int len = sourceDir.Length;

                if (sourceDir[len - 1] == '/' || sourceDir[len - 1] == '\\')
                {
                    --len;
                }

                string tag = "@";
                for (int j = 0; j < files.Length; j++)
                {
                    string str = files[j].Remove(0, len);
                    if (str.Contains(tag))
                        UnityEngine.Debug.LogErrorFormat("{0} 名称中包含了{1}，存在路径解析错误的可能！", str, tag);
                    str = str.Replace("\\", "/");
                    str = str.Substring(1);
                    str = str.Replace("/", tag);

                    string dest = streamDir + str + ".bytes";
                    string dir = Path.GetDirectoryName(dest);

                    UnityEngine.Debug.Log("==>>" + dest);
                    Directory.CreateDirectory(dir);
                    EncodeLuaFile(files[j], dest);
                }
            }
            else
            {
                ToLuaMenu.CopyLuaBytesFiles(srcDirs[i], streamDir);
            }
        }

        AddBuildMap("lua" + AppConst.ExtName, "*.bytes", "Assets/" + AppConst.LuaTempDir, true);
        AssetDatabase.Refresh();
    }

    static void HandleBundleDDZ()
    {
        AddBuildMap("sproto" + AppConst.ExtName, "*.txt", "Assets/Game/Sproto");

		AddBuildMap("hall" + AppConst.ExtName, "*.unity", "Assets/Game/game_Hall");
		//AddBuildMap("hall" + AppConst.ExtName, "*.json", "Assets/Game/game_Hall");

		AddBuildMap("Login" + AppConst.ExtName, "*.unity", "Assets/Game/game_Login");
		AddBuildMap("Login_AT" + AppConst.ExtName, "*.json", "Assets/Game/game_Login");

        AddBuildMap("Login_prefab" + AppConst.ExtName, "*.prefab", "Assets/Game/game_Login/Prefab");

		//斗地主比赛场
		AddBuildMap("DdzMatch" + AppConst.ExtName, "*.unity", "Assets/Game/game_DdzMatch");
		AddBuildMap("DdzMatch_AT" + AppConst.ExtName, "*.json", "Assets/Game/game_DdzMatch");
		AddBuildMap("DdzMatch_prefab" + AppConst.ExtName, "*.prefab", "Assets/Game/game_DdzMatch/Prefab");
		AddBuildMap("DdzMatch_ui" + AppConst.ExtName, "*.png", "Assets/Game/game_DdzMatch/Image");


		AddBuildMap("hall_prefab" + AppConst.ExtName, "*.prefab", "Assets/Game/game_Hall/Prefab");
		AddBuildMap("hall_prefab" + AppConst.ExtName, "*.prefab", "Assets/Game/game_Hall/Prefab/Bag");
		AddBuildMap("hall_prefab" + AppConst.ExtName, "*.prefab", "Assets/Game/game_Hall/Prefab/DDZ");
		AddBuildMap("hall_prefab" + AppConst.ExtName, "*.prefab", "Assets/Game/game_Hall/Prefab/DDZ/Cards");
		AddBuildMap("hall_prefab" + AppConst.ExtName, "*.prefab", "Assets/Game/game_Hall/Prefab/DDZ/DZCards");
		AddBuildMap("hall_prefab" + AppConst.ExtName, "*.prefab", "Assets/Game/game_Hall/Prefab/DDZ/DDZAni");
		AddBuildMap("hall_prefab" + AppConst.ExtName, "*.prefab", "Assets/Game/game_Hall/Prefab/FreeTable");
		AddBuildMap("hall_prefab" + AppConst.ExtName, "*.prefab", "Assets/Game/game_Hall/Prefab/PlayerCenter");
		AddBuildMap("hall_prefab" + AppConst.ExtName, "*.prefab", "Assets/Game/game_Hall/Prefab/Notify");

        AddBuildMap("Common_Prefab" + AppConst.ExtName, "*.prefab", "Assets/Game/CommonPrefab/Prefab");

        AddBuildMap("hall_ui" + AppConst.ExtName, "*.png", "Assets/Game/game_Hall/UI");
		AddBuildMap("hall_ui" + AppConst.ExtName, "*.png", "Assets/Game/game_Hall/UI/Common");
		AddBuildMap("hall_ui" + AppConst.ExtName, "*.png", "Assets/Game/game_Hall/UI/DDZ");
		AddBuildMap("hall_ui" + AppConst.ExtName, "*.png", "Assets/Game/game_Hall/UI/DDZ/Head");
		AddBuildMap("hall_ui" + AppConst.ExtName, "*.png", "Assets/Game/game_Hall/UI/DDZ/Fonts");
		AddBuildMap("hall_ui" + AppConst.ExtName, "*.png", "Assets/Game/game_Hall/UI/DDZ/DDZAniBomb");
		AddBuildMap("hall_ui" + AppConst.ExtName, "*.png", "Assets/Game/game_Hall/UI/DDZ/Settlement");
		AddBuildMap("hall_ui" + AppConst.ExtName, "*.png", "Assets/Game/game_Hall/UI/Hall");
		AddBuildMap("hall_ui" + AppConst.ExtName, "*.png", "Assets/Game/game_Hall/UI/Bag");
		AddBuildMap("hall_ui" + AppConst.ExtName, "*.png", "Assets/Game/game_Hall/UI/FreeTable");
		AddBuildMap("hall_ui" + AppConst.ExtName, "*.png", "Assets/Game/game_Hall/UI/PlayerCenter");
		AddBuildMap("hall_ui" + AppConst.ExtName, "*.png", "Assets/Game/game_Hall/UI/Notify");

		AddBuildMap("hall_audio" + AppConst.ExtName, "*.mp3", "Assets/Game/game_Hall/Audio");
		AddBuildMap("hall_audio" + AppConst.ExtName, "*.mp3", "Assets/Game/game_Hall/Audio/effect");
		AddBuildMap("hall_audio" + AppConst.ExtName, "*.mp3", "Assets/Game/game_Hall/Audio/effect/common");
		AddBuildMap("hall_audio" + AppConst.ExtName, "*.mp3", "Assets/Game/game_Hall/Audio/effect/fishing_sound");
		AddBuildMap("hall_audio" + AppConst.ExtName, "*.mp3", "Assets/Game/game_Hall/Audio/effect/hall_background_sound");
		AddBuildMap("hall_audio" + AppConst.ExtName, "*.mp3", "Assets/Game/game_Hall/Audio/effect/match_sound");
		AddBuildMap("hall_audio" + AppConst.ExtName, "*.mp3", "Assets/Game/game_Hall/Audio/effect/room_sound");
		AddBuildMap("hall_audio" + AppConst.ExtName, "*.mp3", "Assets/Game/game_Hall/Audio/effect/table_sound");

		AddBuildMap("hall_audio" + AppConst.ExtName, "*.mp3", "Assets/Game/game_Hall/Audio/music");
		AddBuildMap("hall_audio" + AppConst.ExtName, "*.mp3", "Assets/Game/game_Hall/Audio/music/table_background_music");


		/*AddBuildMap("hall_ui" + AppConst.ExtName, "*.png", "Assets/Game/Hall/UI/ddz_hall");
		AddBuildMap("hall_ui" + AppConst.ExtName, "*.png", "Assets/Game/Hall/UI/ddz_poker_element");
		AddBuildMap("hall_ui" + AppConst.ExtName, "*.png", "Assets/Game/Hall/UI/ddz_scoreboard");
		AddBuildMap("hall_ui" + AppConst.ExtName, "*.png", "Assets/Game/Hall/UI/ddz_table_task");


		//AddBuildMap("hall_ui" + AppConst.ExtName, "*.png", "Assets/Game/Hall/UI/Loading");

		AddBuildMap("hall_ui" + AppConst.ExtName, "*.png", "Assets/Game/Hall/UI/new_match");
		AddBuildMap("hall_ui" + AppConst.ExtName, "*.png", "Assets/Game/Hall/UI/nopack");

		AddBuildMap("hall_ui" + AppConst.ExtName, "*.png", "Assets/Game/Hall/UI/nt_ddz_common");
		AddBuildMap("hall_ui" + AppConst.ExtName, "*.png", "Assets/Game/Hall/UI/nt_ddz_ft_ui");

		AddBuildMap("hall_ui" + AppConst.ExtName, "*.png", "Assets/Game/Hall/UI/tableoperatebtn");
		AddBuildMap("hall_ui" + AppConst.ExtName, "*.png", "Assets/Game/Hall/UI/tableother");*/

		///////////////////////////////////////////////////////////////////////////////////////////////////////////////


        //AddBuildMap("ddz/ddz_prefab" + AppConst.ExtName, "*.prefab", "Assets/LuaFramework/FXResources/Builds/DDZ");
        //AddBuildMap("ddz/ddz_cards_prefab" + AppConst.ExtName, "*.prefab", "Assets/LuaFramework/FXResources/Builds/DDZ/Cards");
        //AddBuildMap("ddz/ddz_dzcards_prefab" + AppConst.ExtName, "*.prefab", "Assets/LuaFramework/FXResources/Builds/DDZ/DZCards");
        //AddBuildMap("ddz/ddz_ddzani_prefab" + AppConst.ExtName, "*.prefab", "Assets/LuaFramework/FXResources/Builds/DDZ/DDZAni");
        //AddBuildMap("ddz/ddz_textture" + AppConst.ExtName, "*.png", "Assets/LuaFramework/FXResources/Textures/DDZ");
        //AddBuildMap("ddz/ddz_textture" + AppConst.ExtName, "*.png", "Assets/LuaFramework/FXResources/Textures/DDZ/Head");
        //AddBuildMap("ddz/ddz_textture" + AppConst.ExtName, "*.png", "Assets/LuaFramework/FXResources/Textures/DDZ/Fonts");
        //AddBuildMap("ddz/ddz_ani_bomb_textture" + AppConst.ExtName, "*.png", "Assets/LuaFramework/FXResources/Textures/DDZ/DDZAniBomb");
        //AddBuildMap("ddz/ddz_settlement_textture" + AppConst.ExtName, "*.png", "Assets/LuaFramework/FXResources/Textures/DDZ/Settlement");

        //登录
        //AddBuildMap("login/login_prefab" + AppConst.ExtName, "*.prefab", "Assets/LuaFramework/FXResources/Builds/Login");
        // AddBuildMap("login/login_textture" + AppConst.ExtName, "*.png", "Assets/LuaFramework/FXResources/Textures/Login");
        //加载
        //AddBuildMap("loading/loading_prefab" + AppConst.ExtName, "*.prefab", "Assets/LuaFramework/FXResources/Builds/Loading");
		//AddBuildMap("loading/loading_textture" + AppConst.ExtName, "*.png", "Assets/LuaFramework/FXResources/Textures/Loading");

        //大厅
        //AddBuildMap("hall/hall_prefab" + AppConst.ExtName, "*.prefab", "Assets/LuaFramework/FXResources/Builds/Hall");
        //AddBuildMap("hall/hall_textture" + AppConst.ExtName, "*.png", "Assets/LuaFramework/FXResources/Textures/Hall");
        //比赛场
        //AddBuildMap("match/match_prefab" + AppConst.ExtName, "*.prefab", "Assets/LuaFramework/FXResources/Builds/Match");
        //AddBuildMap("match/match_textture" + AppConst.ExtName, "*.png", "Assets/LuaFramework/FXResources/Textures/Match");
        //背包
        //AddBuildMap("bag/bag_prefab" + AppConst.ExtName, "*.prefab", "Assets/LuaFramework/FXResources/Builds/Bag");
        //AddBuildMap("bag/bag_textture" + AppConst.ExtName, "*.png", "Assets/LuaFramework/FXResources/Textures/Bag");
        //公共
        //AddBuildMap("common/common_textture" + AppConst.ExtName, "*.png", "Assets/LuaFramework/FXResources/Textures/Common");
        //自由场
        //AddBuildMap("free/free_prefab" + AppConst.ExtName, "*.prefab", "Assets/LuaFramework/FXResources/Builds/FreeTable");
        //AddBuildMap("free/free_textture" + AppConst.ExtName, "*.png", "Assets/LuaFramework/FXResources/Textures/FreeTable");
        //玩家中心
        //AddBuildMap("player_center/player_center_prefab" + AppConst.ExtName, "*.prefab", "Assets/LuaFramework/FXResources/Builds/PlayerCenter");
        //AddBuildMap("player_center/player_center_textture" + AppConst.ExtName, "*.png", "Assets/LuaFramework/FXResources/Textures/PlayerCenter");
        //notify
        //AddBuildMap("notify/notify_prefab" + AppConst.ExtName, "*.prefab", "Assets/LuaFramework/FXResources/Builds/Notify");
        //AddBuildMap("notify/notify_textture" + AppConst.ExtName, "*.png", "Assets/LuaFramework/FXResources/Textures/Notify");
    }

    /// <summary>
    /// 处理Lua文件
    /// </summary>
	static void HandleMainLuaFile()
	{
		string resPath = AppDataPath + "/StreamingAssets/";
		string luaPath = resPath + "/lua/";

		//----------复制Lua文件----------------
		if (!Directory.Exists(luaPath))
		{
			Directory.CreateDirectory(luaPath);
		}

		string[] luaPaths = { "Assets/Game/Framework/",
			"Assets/Game/Common/" };
		for (int idx = 0; idx < luaPaths.Length; ++idx) {
			string luaFileDir = luaPaths [idx];
			paths.Clear(); files.Clear();
			string luaDataPath = luaFileDir.ToLower();
			Recursive(luaDataPath);
			int n = 0;
			foreach (string f in files)
			{
				if (f.EndsWith(".meta")) continue;
				string newfile = f.Replace(luaDataPath, "");
				string newpath = luaPath + newfile;
				string path = Path.GetDirectoryName(newpath);
				if (!Directory.Exists(path)) Directory.CreateDirectory(path);

				if (File.Exists(newpath))
				{
					File.Delete(newpath);
				}
				if (AppConst.LuaByteMode)
				{
					EncodeLuaFile(f, newpath);
				}
				else
				{
					File.Copy(f, newpath, true);
				}
				UpdateProgress(n++, files.Count, newpath);
			}
		}

		EditorUtility.ClearProgressBar();
		AssetDatabase.Refresh();
	}
    static void HandleLuaFile()
    {
        string resPath = AppDataPath + "/StreamingAssets/";
        string luaPath = resPath + "/lua/";

        //----------复制Lua文件----------------
        if (!Directory.Exists(luaPath))
        {
            Directory.CreateDirectory(luaPath);
        }
		string[] luaPaths = { AppDataPath + "/LuaFramework/Lua",
                              AppDataPath + "/LuaFramework/Tolua/Lua/" };

        for (int i = 0; i < luaPaths.Length; i++)
        {
            paths.Clear(); files.Clear();
            string luaDataPath = luaPaths[i].ToLower();
            Recursive(luaDataPath);
            int n = 0;
            foreach (string f in files)
            {
                if (f.EndsWith(".meta")) continue;
                string newfile = f.Replace(luaDataPath, "");
                string newpath = luaPath + newfile;
                string path = Path.GetDirectoryName(newpath);
                if (!Directory.Exists(path)) Directory.CreateDirectory(path);

                if (File.Exists(newpath))
                {
                    File.Delete(newpath);
                }
                if (AppConst.LuaByteMode)
                {
                    EncodeLuaFile(f, newpath);
                }
                else
                {
                    File.Copy(f, newpath, true);
                }
                UpdateProgress(n++, files.Count, newpath);
            }
        }
        EditorUtility.ClearProgressBar();
        AssetDatabase.Refresh();
    }

	static void BuildAssetToBundleFile() {
		string resPath = Util.AppContentPath ();
		string newFilePath = resPath + "/ATB";
		if (File.Exists(newFilePath))
			File.Delete(newFilePath);

		FileStream fs = new FileStream (newFilePath, FileMode.CreateNew);
		StreamWriter sw = new StreamWriter(fs);

		foreach (KeyValuePair<string, string> kv in AssetToBundleMap) {
			sw.WriteLine (kv.Key + "|" + kv.Value);
		}

		sw.Close ();
		fs.Close ();
	}

    /// <summary>
    /// 数据目录
    /// </summary>
    static string AppDataPath
    {
        get { return Application.dataPath.ToLower(); }
    }

    /// <summary>
    /// 遍历目录及其子目录
    /// </summary>
    static void Recursive(string path)
    {
        string[] names = Directory.GetFiles(path);
        string[] dirs = Directory.GetDirectories(path);
        foreach (string filename in names)
        {
            string ext = Path.GetExtension(filename);
            if (ext.Equals(".meta")) continue;
            files.Add(filename.Replace('\\', '/'));
        }
        foreach (string dir in dirs)
        {
            paths.Add(dir.Replace('\\', '/'));
            Recursive(dir);
        }
    }

	static void BuildFileIndex()
	{
		string resPath = Util.AppContentPath ();
		if (!Directory.Exists (resPath)) {
			UnityEngine.Debug.LogError ("[AssetBundle] BuildFileIndex empty StreamingAssets");
			return;
		}

		///----------------------创建文件列表-----------------------
		string newFilePath = resPath + "/udf.txt";
		if (File.Exists(newFilePath))
			File.Delete(newFilePath);

		paths.Clear();
		files.Clear();
		Recursive(resPath);

		UDF udf = new UDF ();
		udf.ident = "basic";
		//udf.url = "http://192.168.0.207:6688/files/AppUPD/";
		udf.version = "1";

		for (int idx = 0; idx < files.Count; ++idx) {
			string file = files [idx];

			string ext = Path.GetExtension(file);
			if (file.EndsWith(".meta") || file.Contains(".DS_Store")) continue;

			string md5 = Util.md5file (file);
			string key = file.Replace (resPath, string.Empty);
			udf.dirList.Add (key + "|" + md5);
		}

		File.WriteAllText (newFilePath, JsonUtility.ToJson (udf));
	}

    /// <summary>
    /// 编码lua文件
    /// </summary>
    /// <param name="srcFile"></param>
    /// <param name="outFile"></param>
    public static void EncodeLuaFile(string srcFile, string outFile)
    {
        if (!srcFile.ToLower().EndsWith(".lua"))
        {
            File.Copy(srcFile, outFile, true);
            return;
        }
        bool isWin = true;
        string luaexe = string.Empty;
        string args = string.Empty;
        string exedir = string.Empty;
        string currDir = Directory.GetCurrentDirectory();

		/*if (Application.platform == RuntimePlatform.WindowsEditor) {
			isWin = true;
			luaexe = "luac.exe";
			exedir = AppDataPath.Replace("assets", "") + "LuaEncoder/luajit/";
		} else {
			isWin = false;
			luaexe = "./luac";
			exedir = AppDataPath.Replace("assets", "") + "LuaEncoder/luajit_mac/";
		}
		args = "-o " + outFile + " " + srcFile;*/
        
		if (Application.platform == RuntimePlatform.WindowsEditor)
        {
            isWin = true;
            luaexe = "luajit.exe";
            exedir = AppDataPath.Replace("assets", "") + "LuaEncoder/luajit/";
        }
        else if (Application.platform == RuntimePlatform.OSXEditor)
        {
            isWin = false;
            luaexe = "./luajit";
            exedir = AppDataPath.Replace("assets", "") + "LuaEncoder/luajit_mac/";
        }
		args = "-b " + srcFile + " " + outFile;
		
        Directory.SetCurrentDirectory(exedir);
        ProcessStartInfo info = new ProcessStartInfo();
        info.FileName = luaexe;
        info.Arguments = args;
        info.WindowStyle = ProcessWindowStyle.Hidden;
        info.UseShellExecute = isWin;
        info.ErrorDialog = true;
        Util.Log(info.FileName + " " + info.Arguments);

        Process pro = Process.Start(info);
        pro.WaitForExit();
        Directory.SetCurrentDirectory(currDir);
    }

    //[MenuItem("LuaFramework/Build Protobuf-lua-gen File")]
    //public static void BuildProtobufFile()
    //{
    //    if (!AppConst.ExampleMode)
    //    {
    //        UnityEngine.Debug.LogError("若使用编码Protobuf-lua-gen功能，需要自己配置外部环境！！");
    //        return;
    //    }
    //    string dir = AppDataPath + "/Lua/3rd/pblua";
    //    paths.Clear();
    //    files.Clear();
    //    Recursive(dir);

    //    string protoc = "d:/protobuf-2.4.1/src/protoc.exe";
    //    string protoc_gen_dir = "\"d:/protoc-gen-lua/plugin/protoc-gen-lua.bat\"";

    //    foreach (string f in files)
    //    {
    //        string name = Path.GetFileName(f);
    //        string ext = Path.GetExtension(f);
    //        if (!ext.Equals(".proto")) continue;

    //        ProcessStartInfo info = new ProcessStartInfo();
    //        info.FileName = protoc;
    //        info.Arguments = " --lua_out=./ --plugin=protoc-gen-lua=" + protoc_gen_dir + " " + name;
    //        info.WindowStyle = ProcessWindowStyle.Hidden;
    //        info.UseShellExecute = true;
    //        info.WorkingDirectory = dir;
    //        info.ErrorDialog = true;
    //        Util.Log(info.FileName + " " + info.Arguments);

    //        Process pro = Process.Start(info);
    //        pro.WaitForExit();
    //    }
    //    AssetDatabase.Refresh();
    //}

	private static string exportPath = string.Empty;
	private static string platformType = string.Empty;
	private static bool debugMode = false;
	private static string overrideList = string.Empty;
	private static string overrideData = string.Empty;
	private static string overrideGame = string.Empty;
	private static string overrideServer = string.Empty;
	private static string overrideVersion = string.Empty;
	private static string marketChannel = string.Empty;
	private static string marketPlatform = string.Empty;
	private static string sdkChannel = string.Empty;
	private static string productName = string.Empty;

	private static void ParseCommandLine() {
		Dictionary<string, Action<string>> cmdActions = new Dictionary<string, Action<string>> () {
			{
				"-exportPath", delegate(string arg) { exportPath = arg; }
			},
			{
				"-platformType", delegate(string arg) { platformType = arg; }
			},
			{
				"-debugMode", delegate(string arg) {
					if(string.Compare(arg, "true", true) == 0)
						debugMode = true;
					else
						debugMode = false;
					UnityEngine.Debug.Log("debugMode: " + arg);
				}
			},
			{
				"-overrideList", delegate(string arg) { overrideList = arg; }
			},
			{
				"-overrideData", delegate(string arg) { overrideData = arg; }
			},
			{
				"-overrideGame", delegate(string arg) { overrideGame = arg; }
			},
			{
				"-overrideServer", delegate(string arg) { overrideServer = arg; }
			},
			{
				"-overrideVersion", delegate(string arg) { overrideVersion = arg; }
			},
			{
				"-marketChannel", delegate(string arg) { marketChannel = arg; }
			},
			{
				"-marketPlatform", delegate(string arg) { marketPlatform = arg; }
			},
			{
				"-sdkChannel", delegate(string arg) {
					for(int idx = 0; idx < QUDAO_KEY.Length; ++idx) {
						if(string.Compare(arg, QUDAO_KEY[idx]) == 0) {
							sdkChannel = QUDAO_LIST[idx];
							UnityEngine.Debug.Log("Set SDKChannel:" + sdkChannel);
							break;
						}
					}
				}
			},
			{
				"-productName", delegate(string arg) { productName = arg; }
			}
		};
		Action<string> actionCache;
		string[] cmdArgs = Environment.GetCommandLineArgs ();
		for (int idx = 0; idx < cmdArgs.Length; ++idx) {
			if (cmdActions.ContainsKey (cmdArgs [idx])) {
				actionCache = cmdActions [cmdArgs [idx]];
				if (idx >= (cmdArgs.Length - 1) || cmdArgs [idx + 1].StartsWith ("-")) {
					UnityEngine.Debug.Log ("Single Param:" + cmdArgs [idx]);
					actionCache (string.Empty);
				} else {
					UnityEngine.Debug.Log ("Mutil Param:" + cmdArgs [idx] + "," + cmdArgs[idx + 1]);
					actionCache (cmdArgs [idx + 1]);
				}
			}
		}
	}

	private static bool CheckValidPlatform(string platform, out BuildTarget buildTarget) {
		buildTarget = BuildTarget.NoTarget;

		if(string.IsNullOrEmpty(platform))
			return false;
		
		if (platform == "Android") {
			buildTarget = BuildTarget.Android;
			return true;
		}
		if (platform == "IOS") {
			buildTarget = BuildTarget.iOS;
			return true;
		}
		if(platform == "Windows")
        {
			buildTarget = BuildTarget.StandaloneWindows64;
			return true;
        }

		return false;
	}
	public static void Export() {
		ParseCommandLine ();

		BuildTarget buildTarget;
		if (!CheckValidPlatform (platformType, out buildTarget)) {
			UnityEngine.Debug.LogError ("[Export] exception: invalid platformType: " + platformType);
			return;
		}
		if (string.IsNullOrEmpty (exportPath)) {
			UnityEngine.Debug.LogError ("[Export] exception: invalid exportPath: " + exportPath);
			return;
		}

		if (!string.IsNullOrEmpty (productName))
			PlayerSettings.productName = productName;

		//if (buildTarget == BuildTarget.iOS)
		/*{
			if (string.IsNullOrEmpty(overrideIcon))
				SetAppIcon(AppConst.AppIcon, buildTarget);
			else
				SetAppIcon(overrideIcon, buildTarget);
		}*/

		if (!string.IsNullOrEmpty (sdkChannel))
			AppDefine.CurQuDao = sdkChannel;

		//build bundle
		buildAllBundles (buildTarget);

		BuildOptions buildOptions = BuildOptions.AcceptExternalModificationsToPlayer;
		if (debugMode) {
			buildOptions |= BuildOptions.Development;
			buildOptions |= BuildOptions.ConnectWithProfiler;
		}

		//export project
		if (buildTarget == BuildTarget.Android)
			ExportAndroid (buildOptions);
		else if (buildTarget == BuildTarget.iOS)
			ExportIOS (buildOptions);
		else
			ExportWindows(buildOptions);

		debugMode = false;
		overrideServer = string.Empty;
		overrideVersion = string.Empty;
	}

	static string[] GetBuildScenes() {
		List<string> scenes = new List<string> ();
		foreach (EditorBuildSettingsScene e in EditorBuildSettings.scenes) {
			if (e == null || !e.enabled)
				continue;
			scenes.Add (e.path);
		}
		return scenes.ToArray ();
	}
	[MenuItem("Packager/ExportAndroidProject")]
	public static void ExportAndroidProject() {
		ExportAndroid (BuildOptions.AcceptExternalModificationsToPlayer);
	}

	public static void ExportAndroid(BuildOptions options) {
		string exportDir = exportPath;
		if(string.IsNullOrEmpty(exportDir))
			exportDir = UnityEditor.EditorUtility.OpenFolderPanel ("选择目录", "", "AndroidProject");
		exportDir = exportDir.Replace ('\\', '/');

		if (string.IsNullOrEmpty (exportDir)) {
			UnityEngine.Debug.LogError ("[AssetBundle] ExportAndroid error: exportDir invalid");
			return;
		}

		if (!Directory.Exists (exportDir))
			Directory.CreateDirectory (exportDir);

		string dstSrc = exportDir + "/" + Application.productName;
		if (Directory.Exists (dstSrc))
			Directory.Delete (dstSrc, true);
		
		string dstCpy = exportDir + "/" + "jyddz";
		if (Directory.Exists (dstCpy))
			Directory.Delete (dstCpy, true);

		BuildPipeline.BuildPlayer (GetBuildScenes (), exportDir, BuildTarget.Android, options);

		AssetDatabase.Refresh ();

		UnityEngine.Debug.Log (string.Format("Export AndroidProject: {0} success", exportDir + "/" + Application.productName));

		Directory.Move (exportDir + "/" + Application.productName, exportDir + "/" + "jyddz");

		ClearUnextract (GetBuildConfigFileName(BuildTarget.Android), exportDir + "/jyddz/src/main/assets/");
		//ClearPluginDir ("Android");

		UnityEngine.Debug.Log (string.Format("Export AndroidProject: Please use {0}", exportDir + "/" + "jyddz"));
	}

	[MenuItem("Packager/ExportIOSProject")]
	public static void ExportIOSProject() {
		ExportIOS (BuildOptions.AcceptExternalModificationsToPlayer);
	}

	public static void ExportIOS(BuildOptions options) {
		string exportDir = exportPath;
		if(string.IsNullOrEmpty(exportDir))
			exportDir = UnityEditor.EditorUtility.OpenFolderPanel ("选择目录", "", "IOSProject");
		exportDir = exportDir.Replace ('\\', '/');
		
		BuildPipeline.BuildPlayer (GetBuildScenes (), exportDir, BuildTarget.iOS, options);

		AssetDatabase.Refresh ();

		ClearUnextract (GetBuildConfigFileName(BuildTarget.iOS), exportDir + "/Data/Raw/");
		//ClearPluginDir ("iOS");

		UnityEngine.Debug.Log (string.Format("Export IOSProject: {0} success", exportDir));
	}

	[MenuItem("Packager/ExportWindows")]
	public static void ExportWindows() {
		ExportWindows (BuildOptions.AcceptExternalModificationsToPlayer);
	}
	public static void ExportWindows(BuildOptions options) {
		string exportDir = exportPath;
		if(string.IsNullOrEmpty(exportDir))
			exportDir = UnityEditor.EditorUtility.OpenFolderPanel ("选择目录", "", "Windows");
		exportDir = exportDir.Replace ('\\', '/');
		if(!exportDir.EndsWith("/"))
			exportDir += "/";

		string exeName = exportDir + PlayerSettings.productName + ".exe";
		BuildPipeline.BuildPlayer (GetBuildScenes (), exeName, BuildTarget.StandaloneWindows64, options);

		AssetDatabase.Refresh ();

		ClearUnextract (GetBuildConfigFileName(BuildTarget.StandaloneWindows64), exportDir + PlayerSettings.productName + "_Data/StreamingAssets/");

		UnityEngine.Debug.Log (string.Format("Export Windows: {0} success", exportDir));
	}

	#region new packager
	/*
	 * game_1 = {
	 * 		{ "bundleName", "dataPath", "fileType", recursion, isLua }
	 * 		...
	 * }
	 * game_2 = {
	 * 		{ "bundleName", "dataPath", "fileType", recursion, isLua }
	 * 		...
	 * }
	*/

	static void UpdateProgress(int progress, int progressMax, string desc)
	{
		string title = "Processing...[" + progress + " - " + progressMax + "]";
		float value = (float)progress / (float)progressMax;
		EditorUtility.DisplayProgressBar(title, desc, value);
	}

	static int CompareString(string x, string y)
	{
		if (x.Length > 0 && y.Length > 0)
		{
			if (x[0].CompareTo(y[0]) == 0)
			{
				return -x.CompareTo(y);
			}
		}
		return x.CompareTo(y);
	}
	public static int SearchFiles(string dir, string patternFilter, bool recursion, ref List<string> fileList) {
		if (!Directory.Exists (dir))
			return 0;
		
		string[] files = { };
		if (recursion)
			files = Directory.GetFiles (dir, patternFilter, SearchOption.AllDirectories);
		else
			files = Directory.GetFiles (dir, patternFilter, SearchOption.TopDirectoryOnly);

		for (int idx = 0; idx < files.Length; ++idx) {
			if (files [idx].EndsWith(".meta") ||
				files [idx].Contains(".DS_Store") ||
				files[idx].EndsWith(".cs") ||
				files[idx].EndsWith(".manifest"))
				continue;

			fileList.Add (files [idx].Replace('\\', '/'));
		}

		return fileList.Count;
	}

	[Serializable]
	internal class BundleContent {
		public string bundleName = string.Empty;
		public string dataPath = string.Empty;
		public string patternFilter = string.Empty;
		public bool recursionSearch = true;
		public bool autoSplitBundle = false;
		public bool isLua = false;

		public bool isVaild() {
			if (string.IsNullOrEmpty (bundleName) ||
				string.IsNullOrEmpty (dataPath) ||
				string.IsNullOrEmpty (patternFilter) ||
				(isLua && autoSplitBundle))
				return false;
			return true;
		}
	}

	[Serializable]
	internal class BundleGroup {
		public string groupName = string.Empty;
		public bool isExtract = false;
		public bool useBasicVersion = false;
		public List<string> dirList = new List<string> ();
		public List<BundleContent> bundleContents = new List<BundleContent>();
	}

	static string[] filePattern = new string[] {
		"*.tga", "*.png", "*.jpg", "*.prefab", "*.unity", "*.mp3","*.wav","*.ogg", "*.txt", "*.json" , "*.mat", "*.fontsettings", "*.lua", "*.controller","*.asset","*.anim","*.ttf"
	};
	private static void BuildAssetMapCore(string channelPath, ref Dictionary<string, string> map) {
		string dataPath = Application.dataPath + "/";
		string fileName = string.Empty;
		string key = string.Empty, value = string.Empty;
		List<string> fileList = new List<string> ();

		string path = dataPath + channelPath;
		for (int i = 0; i < filePattern.Length; ++i) {
			if (SearchFiles (path, filePattern [i], true, ref fileList) > 0) {
				for (int j = 0; j < fileList.Count; ++j) {
					fileName = fileList [j].Substring (dataPath.Length - "Assets/".Length);
					if (fileName.EndsWith ("udf.txt") || fileName.EndsWith ("file_list.txt"))
						continue;
					if (fileName.EndsWith ("readme.txt") || fileName.EndsWith ("BuildVersionConfig.json"))
						continue;
					//Assets/xxx/xxx.xxx
					key = Path.GetFileName (fileName).ToLower ();
					if (map.TryGetValue (key, out value)) {
						UnityEngine.Debug.LogError (string.Format ("[AssetBundle] BuildAssetMap exception: key({0}) conflict({1}, {2})", key, value, fileName));
						continue;
					}
					map.Add (key, fileName);
				}
			}
			fileList.Clear ();
		}
	}

	private static void SaveAssetMap(string fileName, Dictionary<string, string> map) {
		FileStream fs = new FileStream (fileName, FileMode.Create);
		StreamWriter sw = new StreamWriter(fs);
		foreach (KeyValuePair<string, string> kv in map)
			sw.WriteLine (kv.Key + "|" + kv.Value); 
		sw.Close ();
		fs.Close ();
	}
	private static void BuildAssetMapCore(string channel, ref Dictionary<string, string> mainMap, ref Dictionary<string, string> channelMap) {
		string dataPath = Application.dataPath + "/";

		mainMap.Clear ();
		BuildAssetMapCore ("Game", ref mainMap);
		SaveAssetMap (dataPath + ResourceManager.NAME_TO_ASSET + ".txt", mainMap);

		int idx = 0;
		if (string.IsNullOrEmpty (channel)) {
			for (idx = 0; idx < QUDAO_LIST.Length; ++idx) {
				channelMap.Clear ();
				BuildAssetMapCore (QUDAO_PATH [idx], ref channelMap);
				SaveAssetMap (dataPath + ResourceManager.NAME_TO_ASSET + "_" + QUDAO_LIST[idx] + ".txt", channelMap);
			}
		} else {
			for (idx = 0; idx < QUDAO_LIST.Length; ++idx) {
				if (string.Compare (QUDAO_LIST [idx], channel) == 0) {
					channelMap.Clear ();
					BuildAssetMapCore (QUDAO_PATH [idx], ref channelMap);
					SaveAssetMap (dataPath + ResourceManager.NAME_TO_ASSET + "_" + QUDAO_LIST[idx] + ".txt", channelMap);
					break;
				}
			}
		}

		AssetDatabase.Refresh ();
	}

	[MenuItem("Packager/BuildAssetMap _F6")]
	public static void BuildAssetMap() {
		Dictionary<string, string> mainMap = new Dictionary<string, string> ();
		Dictionary<string, string> channelMap = new Dictionary<string, string> ();
		BuildAssetMapCore (string.Empty, ref mainMap, ref channelMap);
		UnityEngine.Debug.Log ("BuildAssetMap finish!");
	}
	
	public class GameInfoEquality : IEqualityComparer<GameInfo>
    {
        public bool Equals(GameInfo x, GameInfo y)
        {
            return string.Compare(x.Name, y.Name, true) == 0;
        }

        public int GetHashCode(GameInfo obj)
        {
            if (obj == null)
            {
                return 0;
            }
            else
            {
                return obj.ToString().GetHashCode();
            }
        }
    }

	public class GuideFileEquality : IEqualityComparer<GuideFile>
    {
        public bool Equals(GuideFile x, GuideFile y)
        {
            return string.Compare(x.Name, y.Name, true) == 0;
        }

        public int GetHashCode(GuideFile obj)
        {
            if (obj == null)
            {
                return 0;
            }
            else
            {
                return obj.ToString().GetHashCode();
            }
        }
    }

	[MenuItem("Packager/MergeVersionMap")]
	public static void MergeVersionMap()
    {
		string newVersionFile = UnityEditor.EditorUtility.OpenFilePanelWithFilters("Select New VersionMap", "", new string[]{ "txt", "txt" });
		string rawVersionFile = UnityEditor.EditorUtility.OpenFilePanelWithFilters("Select Raw VersionMap", "", new string[]{ "txt", "txt" });
		
		VersionMap newVM = new VersionMap();
		if (!Util.JsonHelper.LoadJson<VersionMap>(newVersionFile, out newVM))
		{
			UnityEngine.Debug.LogError("MergeVersionMap exception: load new versionmap failed:" + newVersionFile);
			return;
		}

		VersionMap rawVM = new VersionMap();
		if (!Util.JsonHelper.LoadJson<VersionMap>(rawVersionFile, out rawVM))
		{
			UnityEngine.Debug.LogError("MergeVersionMap exception: load raw versionmap failed:" + rawVersionFile);
			return;
		}

		var mergeGames = newVM.games.Except(rawVM.games, new GameInfoEquality());
		if(mergeGames.Count() > 0)
			rawVM.games.AddRange(mergeGames);

		var mergemd5s = newVM.md5s.Except(rawVM.md5s, new GuideFileEquality());
		if(mergemd5s.Count() > 0)
			rawVM.md5s.AddRange(mergemd5s);

		File.WriteAllText (rawVersionFile + ".new", JsonUtility.ToJson (rawVM, true));
    }

	[MenuItem("Packager/ResetParticleMaterial")]
	public static void ResetParticleMaterial() {
		string dataPath = Application.dataPath + "/";

		List<string> fileList = new List<string> ();
		if (SearchFiles (dataPath, "*.mat", true, ref fileList) > 0) {
			foreach (string file in fileList) {
				string fileName = "Assets/" + file.Replace (dataPath, string.Empty);

				Material material = AssetDatabase.LoadAssetAtPath<Material> (fileName);
				if (material == null) {
					UnityEngine.Debug.LogError ("[AssetBundle] ResetParticleMaterial failed. can't load material: " + fileName);
					continue;
				}
				if (material.name == "ParticleMask")
					continue;

				if (material.shader.name == "ParticleMask") {
					material.shader = Shader.Find ("Particles/Additive");
					UnityEngine.Debug.Log ("Reset: " + material.name);
				}
			}
		}
		AssetDatabase.SaveAssets ();
		AssetDatabase.Refresh ();
	}

	[Serializable]
	internal class BundleOption {
		public string rootDir = string.Empty;
		public bool useBasicVersion = false;
		public bool isExtract = false;
		public List<string> dependList = new List<string> ();
	}
	[Serializable]
	internal class BuildConfig {
		public List<string> svr_list = new List<string>();
		public List<string> svr_data = new List<string>();
		public List<string> svr_game = new List<string>();

		public string Version = "1.1.1";
		public List<BundleOption> options = new List<BundleOption>();
	}

	[Serializable]
	internal class ActivityContent {
		public string name = string.Empty;
		public bool enable = false;
	}
	[Serializable]
	internal class ActivityConfig {
		public List<ActivityContent> activities = new List<ActivityContent> ();
	}

	[Serializable]
	internal class VersionContent {
		public string dirName = string.Empty;
		public List<string> fileList = new List<string> ();
		public VersionContent(string dirName) {
			this.dirName = dirName;
		}
	}
		
	static bool FindBundleOption(BuildConfig buildCfg, string dirIdent, ref BundleOption bundleOption) {
		bundleOption = null;

		if (buildCfg == null)
			return false;

		string dirName = string.Empty;
		string[] item = { };
		foreach (BundleOption bo in buildCfg.options) {
			dirName = bo.rootDir.ToLower ();
			if (string.Compare (dirName, dirIdent, true) == 0) {
				bundleOption = bo;
				return true;
			}
		}
		return false;
	}

	static bool ParseSegments(string value, char split, ref List<string> result) {
		result.Clear ();

		string[] items = value.Split (split);
		if (items == null || items.Length <= 0) {
			UnityEngine.Debug.LogError (string.Format ("[AssetBundle] ParseSegments({0}, {1}) failed.", value, split));
			return false;
		}

		for (int idx = 0; idx < items.Length; ++idx) {
			if (string.IsNullOrEmpty (items [idx]))
				continue;
			result.Add (items [idx]);
		}

		return result.Count > 0;
	}

	const string BuildConfigFile = "VersionConfig/BuildVersionConfig";
	const string BuildConfigFileAndroid = "VersionConfig/Android/BuildVersionConfig";
	const string BuildConfigFileIOS = "VersionConfig/IOS/BuildVersionConfig";
	const string BuildActivityConfig = "VersionConfig/ActivityConfig";

	static string GetBuildConfigFileName(BuildTarget buildTarget) {
		string configFile = string.Empty;
		if (buildTarget == BuildTarget.Android)
			configFile = BuildConfigFileAndroid;
		else if (buildTarget == BuildTarget.iOS)
			configFile = BuildConfigFileIOS;
		else
			configFile = BuildConfigFile;
		
		string channelName = AppDefine.CurQuDao;
		string dataPath = Application.dataPath + "/";

		if (!string.IsNullOrEmpty (channelName) && string.Compare (channelName, "main", true) != 0) {
			string fullName = dataPath + configFile + "_" + channelName + ".json";
			if (File.Exists (fullName))
				return fullName;
		}
		return dataPath + configFile + ".json";
	}

	const string BASIC_BUNDLE = GameManager.BASIC_IDENT;
	const string LUA_TMP_DIR = "_LUA_";

	static List<AssetBundleBuild> buildBundleMaps = new List<AssetBundleBuild>();
	static Dictionary<string, string> buildAssetMaps = new Dictionary<string, string>();
	static Dictionary<string, VersionContent> versionDirs = new Dictionary<string, VersionContent> ();
	static HashSet<string> activityMaps = new HashSet<string> ();

	static string updVersion = string.Empty;
	static string netAddress = string.Empty;

	static string[] BASIC_DIR = new string[] {"common", "framework", "sproto", "loadingpanel"};
	static string EntrySceneName = "Entry.unity";

	public static ChannelConfig ChannelConfig = new ChannelConfig();

	static string[] QUDAO_LIST = {
		"main",
        "Local1",
        "Local2",
        "Local3",
		"caiyunmj_cpls",
		"caiyunmj_yyb",
		"caiyunmj_hw",
		"caiyunmj_yyb_main",
		"caiyunmj_hw_main",
		"wqpddz_ios_ts",
		"wqpddz_hw",
        "wqpddz_hw_main",
		"wqp",
		"wqpddz_yyb",
		"wqpddz_pad",
		"caiyunmj_trial",
		"wqpddz_pdd",
		"caiyunmj_hw_noupdate",
		"aibianxian",
		"wuziqi",
		"vivo_cymj",
		"vivo_wuziqi",
        "caiyunmj_ts",
	};
	static string[] QUDAO_PATH = {
		"Channel/main/Assets",
		"Channel/Local1/Assets",
        "Channel/Local2/Assets",
        "Channel/Local3/Assets",
		"Channel/caiyunmj_cpls/Assets",
		"Channel/caiyunmj_yyb/Assets",
		"Channel/caiyunmj_hw/Assets",
		"Channel/caiyunmj_yyb_main/Assets",
		"Channel/caiyunmj_hw_main/Assets",
		"Channel/wqpddz_ios_ts/Assets",
		"Channel/wqpddz_hw/Assets",
        "Channel/wqpddz_hw_main/Assets",
		"Channel/wqp/Assets",
		"Channel/wqpddz_yyb/Assets",
		"Channel/wqpddz_pad/Assets",
		"Channel/caiyunmj_trial/Assets",
		"Channel/wqpddz_pdd/Assets",
		"Channel/caiyunmj_hw_noupdate/Assets",
		"Channel/aibianxian/Assets",
		"Channel/wuziqi/Assets",
		"Channel/vivo_cymj/Assets",
		"Channel/vivo_wuziqi/Assets",
        "Channel/caiyunmj_ts/Assets",
	};
	static string[] QUDAO_KEY = {
		"自营渠道",
        "Local1",
        "Local2",
        "Local3",
		"彩云麻将CPL",
		"彩云麻将(应用宝)",
		"彩云麻将(华为提审)",
		"彩云麻将(应用宝正式)",
		"彩云麻将(华为正式)",
		"玩棋牌斗地主(IOS提审)",
		"玩棋牌斗地主(华为提审)",
        "玩棋牌斗地主(华为正式)",
		"玩棋牌斗地主(部分CPL渠道)",
		"玩棋牌斗地主(应用宝)",
		"玩棋牌斗地主(白包)",
		"彩云麻将(审核包)",
		"玩棋牌斗地主(拼多多)",
		"彩云麻将(华为不更新)",
		"鲸鱼斗地主(爱变现)",
		"高手五子棋",
		"彩云麻将(vivo)",
		"高手五子棋(vivo)",
        "彩云麻将(提审ts)",
	};
	//static string[] QUDAO_SHARE_MAIN = {"caiyunmj_cpls", "aibianxian" };
	

	//主渠道根据平台来区分，目前有彩云麻将、玩棋牌、五子棋
	static string[] CYMJ_SHARE_MAIN = { };
	static string[] WQP_SHARE_MAIN = { };
	static string[] WZQ_SHARE_MAIN = { };
	static string[] NONE_SHARE_MAIN = { };
	private static string[] getQuDaoShareMain(string channelName)
    {
		if (string.Compare(channelName, "main", true) == 0)
			return CYMJ_SHARE_MAIN;
		else if (string.Compare(channelName, "wqp", true) == 0)
			return WQP_SHARE_MAIN;
		else if (string.Compare(channelName, "wuziqi", true) == 0)
			return WZQ_SHARE_MAIN;
		return NONE_SHARE_MAIN;
	}
	private static bool IsMainChannel(string channelName)
    {
		if (string.IsNullOrEmpty(channelName) || string.Compare(channelName, "main", true) == 0)
			return true;
		else if (string.Compare(channelName, "wqp", true) == 0)
			return true;
		else if (string.Compare(channelName, "wuziqi", true) == 0)
			return true;
		else
			return false;
    }

	private static bool SyncShareMainChannels(string channelName, ref BuildConfig buildCfg, ref Dictionary<string, string> revertFiles, ref List<string> deleteFiles) {
		if (!IsMainChannel(channelName))
			return false;

		string[] QuDaoShares = getQuDaoShareMain(channelName);
		for (int idx = 0; idx < QuDaoShares.Length; ++idx)
		{
			UnityEngine.Debug.Log("[AssetBundle] SyncShareMainChannels:" + QuDaoShares[idx]);
			SyncShareMainChannelFiles (QuDaoShares[idx], ref buildCfg, ref revertFiles, ref deleteFiles);
		}

		return true;
	}

	private static bool SyncShareMainChannelFiles(string channelName, ref BuildConfig buildCfg, ref Dictionary<string, string> revertFiles, ref List<string> deleteFiles) {
		int revertCnt = revertFiles.Count;
		if (!SyncChannelFiles (channelName, ref buildCfg, ref revertFiles, ref deleteFiles))
		{
			UnityEngine.Debug.Log("[AssetBundle] SyncShareMainChannelFiles's SyncChannelFiles failed:" + channelName);
			return false;
		}

		return true;
	}

	private static bool SyncChannelFiles(string channelName, ref BuildConfig buildCfg, ref Dictionary<string, string> revertFiles, ref List<string> deleteFiles) {
		if (string.IsNullOrEmpty (channelName))
			return false;

		string rootPath = Application.dataPath.Substring (0, Application.dataPath.Length - 6);
		string gamePath = Application.dataPath + "/" + "Game/";
		string channelPath = gamePath + channelName + "/";
		if (Directory.Exists (channelPath))
			Directory.Delete (channelPath, true);
		Directory.CreateDirectory (channelPath);
		AssetDatabase.Refresh();

		Dictionary<string, string> mainMap = new Dictionary<string, string> ();
		Dictionary<string, string> channelMap = new Dictionary<string, string> ();
		BuildAssetMapCore (channelName, ref mainMap, ref channelMap);
		if (channelMap.Count <= 0)
			return true;

		string tmpDir = rootPath + "_TMP_/";
		var replaceKeys = channelMap.Keys.Intersect (mainMap.Keys);
		var copyKeys = channelMap.Keys.Except (mainMap.Keys);
		string srcFile, dstFile, tmpFile;

		foreach (var key in replaceKeys) {
			srcFile = rootPath + channelMap [key];
			dstFile = rootPath + mainMap [key];

			tmpFile = tmpDir + mainMap [key];
			Util.CopyFile (dstFile, tmpFile);
			revertFiles.Add (tmpFile, dstFile);

			Util.CopyFile (srcFile, dstFile);

			if (dstFile.EndsWith(".prefab"))
			{
				AssetDatabase.ImportAsset(mainMap[key]);
			}

			UnityEngine.Debug.Log ("[Replace]:" + srcFile + " --> " + dstFile);
		}

		string sdkPath = "Assets/Channel/" + channelName + "/Assets/";
		string name = string.Empty;
		foreach (var key in copyKeys) {
			name = channelMap [key];
			srcFile = rootPath + name;
			dstFile = channelPath + name.Substring (sdkPath.Length);

			Util.MoveFile(srcFile, dstFile);
			revertFiles.Add(dstFile, srcFile);
			UnityEngine.Debug.Log("[Move]:" + srcFile + " --> " + dstFile);

			srcFile = srcFile + ".meta";
			dstFile = dstFile + ".meta";
			Util.MoveFile(srcFile, dstFile);
			revertFiles.Add(dstFile, srcFile);

			if (dstFile.EndsWith(".prefab"))
			{
				AssetDatabase.ImportAsset(mainMap[key]);
			}
		}

		BundleOption option = new BundleOption ();
		option.useBasicVersion = true;
		option.isExtract = true;
		option.rootDir = channelName;
		buildCfg.options.Add (option);

		return true;
	}

	private static void SetEntryScene(string sceneName) {
		List<EditorBuildSettingsScene> editorBuildSettingsScenes = new List<EditorBuildSettingsScene> (EditorBuildSettings.scenes);
		List<int> remList = new List<int> ();
		for (int i = 0; i < editorBuildSettingsScenes.Count; i++) {
			if (editorBuildSettingsScenes [i].path.EndsWith (EntrySceneName))
				remList.Add (i);
		}
		for (int idx = remList.Count - 1; idx >= 0; --idx)
			editorBuildSettingsScenes.RemoveAt (idx);

		editorBuildSettingsScenes.Insert (0, new EditorBuildSettingsScene (sceneName, true));
		EditorBuildSettings.scenes = editorBuildSettingsScenes.ToArray ();

		UnityEngine.Debug.Log ("SetEntryScene:" + sceneName);
	}

	private static void ChangeChannelScene(string channelName) {
		string sceneName = Application.dataPath + "/Entry/" + EntrySceneName;
		if(!string.IsNullOrEmpty(channelName) && string.Compare(channelName, "main", true) != 0)
			sceneName = Application.dataPath + "/Channel/" + channelName + "/" + EntrySceneName;
		
		if (File.Exists (sceneName)) {
			sceneName = sceneName.Substring (Application.dataPath.Length - 6);
			SetEntryScene (sceneName);
		} else {
			sceneName = "Assets/Entry/" + EntrySceneName;
			SetEntryScene (sceneName);
		}
	}
	private static void ResetEntryScene(string channelName) {
		string sceneName = Application.dataPath + "/Channel/" + channelName + "/" + EntrySceneName;
		if (File.Exists (sceneName)) {
			sceneName = sceneName.Substring (Application.dataPath.Length - 6);

			List<EditorBuildSettingsScene> editorBuildSettingsScenes = new List<EditorBuildSettingsScene>(EditorBuildSettings.scenes);
			int index = -1;
			for (int i = 0; i < editorBuildSettingsScenes.Count; i++) {
				if (editorBuildSettingsScenes [i].path == sceneName) {
					index = i;
					break;
				}
			}
			if(index >= 0)
				editorBuildSettingsScenes.RemoveAt (index);
			EditorBuildSettings.scenes = editorBuildSettingsScenes.ToArray();

			//SceneAsset theScene = AssetDatabase.LoadAssetAtPath<SceneAsset>(EditorBuildSettings.scenes[0].path);
			//EditorSceneManager.playModeStartScene = theScene;
		}
	}

	private static void buildAllBundles(BuildTarget buildTarget) {
		string dataPath = Application.dataPath + "/";
		string rootDir = dataPath + "Game/";
		string channelName = AppDefine.CurQuDao;

		ClearEmptyFolder.IsLock = true;

		//change channel scene
		ChangeChannelScene(channelName);

		do {
			string streamingPath = Application.streamingAssetsPath;
			if (Directory.Exists (streamingPath))
				Directory.Delete (streamingPath, true);
			Directory.CreateDirectory (streamingPath);
			AssetDatabase.Refresh();
			AssetDatabase.SaveAssets();

			string configFile = GetBuildConfigFileName(buildTarget);
			UnityEngine.Debug.Log ("[AssetBundle] BuildBundles with " + configFile);

			if (!File.Exists (configFile)) {
				UnityEngine.Debug.LogError ("[AssetBundle] BuildBundles failed. ConfigFile not exist");
				break;
			}

			string content = File.ReadAllText (configFile);
			if (string.IsNullOrEmpty (content)) {
				UnityEngine.Debug.LogError ("[AssetBundle] BuildBundles failed. ConfigFile invalid.");
				break;
			}

			BuildConfig buildCfg = JsonUtility.FromJson<BuildConfig> (content);
			if (buildCfg == null) {
				UnityEngine.Debug.LogError ("[AssetBundle] BuildBundles failed. ParseJson failed.");
				break;
			}

			if (!string.IsNullOrEmpty (overrideList)){
				UnityEngine.Debug.Log (string.Format("[AssetBundle] BuildBundles overrideList({0})", overrideList));

				List<string> urls = new List<string> ();
				if (ParseSegments (overrideList, ';', ref urls))
					buildCfg.svr_list = urls;
			}
			if (!string.IsNullOrEmpty (overrideData)) {
				UnityEngine.Debug.Log (string.Format("[AssetBundle] BuildBundles overrideData({0})", overrideData));

				List<string> urls = new List<string> ();
				if (ParseSegments (overrideData, ';', ref urls))
					buildCfg.svr_data = urls;
			}
			if (!string.IsNullOrEmpty (overrideGame)) {
				UnityEngine.Debug.Log (string.Format("[AssetBundle] BuildBundles overrideGame({0})", overrideGame));

				List<string> urls = new List<string> ();
				if (ParseSegments (overrideGame, ';', ref urls))
					buildCfg.svr_game = urls;
			}

			if (!string.IsNullOrEmpty (overrideVersion)) {
				UnityEngine.Debug.Log (string.Format("[AssetBundle] BuildBundles overrideVersion({0}) to ({1})", buildCfg.Version, overrideVersion));

				buildCfg.Version = overrideVersion;
			}
			updVersion = buildCfg.Version;

			//activity filter
			configFile = dataPath + BuildActivityConfig + "_" + channelName + ".json";
			if (!File.Exists(configFile))
				configFile = dataPath + BuildActivityConfig + ".json";
			UnityEngine.Debug.Log("[AssetBundle] BuildBundles activity config:" + configFile);

			if (File.Exists (configFile)) {
				ActivityConfig activityConfig = JsonUtility.FromJson<ActivityConfig> (File.ReadAllText (configFile));
				activityMaps.Clear ();
				foreach (ActivityContent it in activityConfig.activities) {
					if(!it.enable) continue;
					activityMaps.Add(it.name.ToLower());
				}
			}

			UnityEngine.Debug.Log ("BuildBundles Start...");

			string luaTmpDir = dataPath + LUA_TMP_DIR;
			if (Directory.Exists(luaTmpDir))
				Directory.Delete(luaTmpDir, true);
			Directory.CreateDirectory(luaTmpDir);
			AssetDatabase.Refresh ();

			buildBundleMaps.Clear ();
			buildAssetMaps.Clear ();
			versionDirs.Clear ();

			string tmpDir = Application.dataPath + "/_TMP_";
			if (Directory.Exists(tmpDir))
				Directory.Delete(tmpDir, true);
			Directory.CreateDirectory (tmpDir);

			Dictionary<string, string> revertFiles = new Dictionary<string, string>();
			List<string> deleteFiles = new List<string>();
			SyncChannelFiles (channelName, ref buildCfg, ref revertFiles, ref deleteFiles);
			SyncShareMainChannels(channelName, ref buildCfg, ref revertFiles, ref deleteFiles);

			AssetDatabase.Refresh ();
			AssetDatabase.SaveAssets();
			AssetDatabase.Refresh ();

			//special dir
			//tolua framework
			if(!BuildBundleLua("lua", dataPath + "LuaFramework/ToLua/Lua/", dataPath + "LuaFramework/ToLua/Lua/")) {
				UnityEngine.Debug.LogError ("[AssetBundle] BuildBundles failed. BuildToLua failed.");
				break;
			}

			//project share
			string[,] ShareLuaDir = new string[2,2] {
				{"common/common", "Common"},
				{"framework/framework", "Framework"}
			};
			for (int idx = 0; idx < ShareLuaDir.GetLength(0); ++idx) {
				if(!BuildBundleLua(ShareLuaDir[idx,0], rootDir + ShareLuaDir[idx,1], dataPath)) {
					UnityEngine.Debug.LogError (string.Format("[AssetBundle] BuildBundles failed. BuildShareLua({0},{1}) failed.", ShareLuaDir[idx,0], ShareLuaDir[idx,1]));
					break;
				}
			}

			AssetDatabase.Refresh ();

			//netconfig
			string netConfigFile = luaTmpDir + "/" + "framework/framework/Game@Framework@NetConfig.lua.bytes";
			if (!string.IsNullOrEmpty (overrideServer)) {
				content = string.Format ("NetConfig = {{}}\n\nfunction NetConfig.NetConfigInit()\n\tAppConst.SocketAddress = \"{0}\"\nend\n", overrideServer);
				File.WriteAllText (netConfigFile, content);

				netAddress = overrideServer;
			} else {
				if(File.Exists(netConfigFile))
				{
					foreach (string line in File.ReadAllLines (netConfigFile)) {
						content = line.Trim();
						if (string.IsNullOrEmpty (content))
							continue;
						if (content.StartsWith ("AppConst.SocketAddress")) {
							netAddress = content;
							break;
						}
					}
				}
			}
			/*if(File.Exists(netConfigFile)) {
				if (string.IsNullOrEmpty (overrideServer)) {
					foreach (string line in File.ReadAllLines (netConfigFile)) {
						content = line.Trim();
						if (string.IsNullOrEmpty (content))
							continue;
						if (content.StartsWith ("AppConst.SocketAddress")) {
							netAddress = content;
							break;
						}
					}
				} else {
					content = string.Format ("NetConfig = {{}}\n\nfunction NetConfig.NetConfigInit()\n\tAppConst.SocketAddress = \"{0}\"\nend\n", overrideServer);
					File.WriteAllText (netConfigFile, content);

					netAddress = overrideServer;
				}
				UnityEngine.Debug.Log ("[AssetBundle] Use NetConfig:" + netAddress);
			}*/

			string dirIdent = string.Empty;

			bool skipDir = false;
			string[] dirs = Directory.GetDirectories (rootDir);
			foreach (string dir in dirs) {
				dirIdent = dir.Substring (rootDir.Length).ToLower();
				versionDirs.Add (dirIdent, new VersionContent(dirIdent));
				if(dirIdent.StartsWith("activity"))
					continue;

				skipDir = false;
				for (int idx = 0; idx < ShareLuaDir.GetLength(0); ++idx) {
					if (dir.EndsWith (ShareLuaDir [idx,1])) {
						skipDir = true;
						break;
					}
				}
				if (skipDir)
					continue;

				//UnityEngine.Debug.Log ("Build for " + dir);

				if (!BuildBundleDir (dirIdent.ToLower(), dir)) {
					UnityEngine.Debug.LogError (string.Format("[AssetBundle] BuildBundles failed. BuildBundleDir({0}) failed.", dir));
					break;
				}
			}

			//activity
			foreach(string it in activityMaps) {
				if (!BuildBundleDir ("activity", rootDir + it)) {
					UnityEngine.Debug.LogError (string.Format("[AssetBundle] BuildBundles failed. BuildBundleDir({0}) failed.", rootDir + it));
					break;
				}
			}

			AssetDatabase.Refresh ();

			if (true) {

				BuildPipeline.BuildAssetBundles(Application.streamingAssetsPath,
					buildBundleMaps.ToArray(),
					BuildAssetBundleOptions.None,
					buildTarget);
				AssetDatabase.Refresh ();

				if (AppConst.UseXTEA) {
					if (!EncryptAssetBundles ()) {
						UnityEngine.Debug.LogError ("[AssetBundle] EncryptAssetBundles failed.");
						break;
					}
				}
			}

			//atb
			BuildATB ();

			//cinematic
			List<string> mp4List = new List<string>();

			if (SearchFiles(dataPath + "Entry/LogoAnimation", "*.mp4", false, ref mp4List) > 0)
            {
				foreach (var mp4File in mp4List)
					Util.CopyFile(mp4File, Application.streamingAssetsPath + "/" + Path.GetFileName(mp4File));
			}

			//try replace main's mp4
			{
				mp4List.Clear();
				if (SearchFiles(dataPath + "Channel/" + AppDefine.CurQuDao + "/LogoAnimation", "*.mp4", false, ref mp4List) > 0)
                {
					foreach(var mp4File in mp4List)
						Util.CopyFile(mp4File, Application.streamingAssetsPath + "/" + Path.GetFileName(mp4File));
                }
			}
			
			//share channel's mp4
			string channelVideoName = string.Empty;
			string[] QuDaoShares = getQuDaoShareMain(AppDefine.CurQuDao);
			for (int idx = 0; idx < QuDaoShares.Length; ++idx)
			{
				mp4List.Clear();
				if(SearchFiles(dataPath + "Channel/" + QuDaoShares[idx] + "/LogoAnimation", "*.mp4", false, ref mp4List) > 0)
                {
					foreach (var mp4File in mp4List)
						Util.CopyFile(mp4File, Application.streamingAssetsPath + "/" + Path.GetFileName(mp4File));
				}
			}

			//icon
			File.Copy(dataPath + "AppIcons/" + AppConst.AppIcon, Application.streamingAssetsPath + "/" + "AppIcon.png", true);

			//channel file
			{
				ChannelConfig.platform = marketPlatform;
				ChannelConfig.channel = marketChannel;
				File.WriteAllText(Application.streamingAssetsPath + "/" + GameManager.CHANNEL_FILE, JsonUtility.ToJson(ChannelConfig));
			}

			AssetDatabase.Refresh ();

			//filelist & udf
			if (!BuildVersions (buildCfg)) {
				UnityEngine.Debug.LogError ("[AssetBundle] BuildBundles failed. BuildVersions failed.");
				break;
			}

			//extract
			BuildExtract(buildCfg);

			//VersionMap
			BuildVersionMap(buildCfg, buildTarget);

			//MainVersion
			string[] items = buildCfg.Version.Split('.');
			if (string.Compare (MainVersion.Version, items [0], true) != 0) {
				UnityEngine.Debug.Log (string.Format("[AssetBundle] Attention: MainVersion Upgrade({0} --> {1})", MainVersion.Version, items[0]));

				MainVersion.Version = items [0];

				string mainVersionFile = dataPath + "LuaFramework/Scripts/ConstDefine/MainVersion.cs";
				string mainVersionText = string.Format ("public class MainVersion\n{{\n\tstatic public string Version = \"{0}\";\n\n\tstatic public string baseVersion = \"{1}\";}}", MainVersion.Version, updVersion);
				File.WriteAllText (mainVersionFile, mainVersionText);
			}

			AssetDatabase.Refresh ();

			UnityEngine.Debug.Log (string.Format("Use NetConfig({0}), UpdateVersion({1})", netAddress, updVersion));

			//CheckAssetBundles ();

			foreach(KeyValuePair<string, string> kv in revertFiles) {
				Util.CopyFile(kv.Key, kv.Value);
				File.Delete(kv.Key);
			}
			revertFiles.Clear();
			foreach(string deleteFile in deleteFiles) {
				if(File.Exists(deleteFile))
					File.Delete(deleteFile);
				else
					UnityEngine.Debug.Log("[AssetBundle] clear file, but file not exist:" + deleteFile);
			}
			deleteFiles.Clear();

			if(Directory.Exists(tmpDir))
				Directory.Delete(tmpDir, true);

			string channelDir = Application.dataPath + "/Game/" + channelName;
			if(Directory.Exists(channelDir))
				Directory.Delete (channelDir, true);

			AssetDatabase.Refresh ();
			AssetDatabase.SaveAssets();
			AssetDatabase.Refresh ();

			UnityEngine.Debug.Log ("BuildBundles Success!");

		} while(false);

		ClearEmptyFolder.IsLock = false;
	}

	[MenuItem("Packager/BuildBundles _F9")]
	public static void BuildAllBundles() {
		buildAllBundles (EditorUserBuildSettings.activeBuildTarget);
	}

	static bool BuildBundleLua(string bundleName, string dirName, string cutoff) {
		string tmp_dir = Application.dataPath + "/" + LUA_TMP_DIR + "/";
		string bundleDir = tmp_dir + bundleName + "/";

		if (!Directory.Exists (bundleDir))
			Directory.CreateDirectory (bundleDir);

		List<string> fileList = new List<string> ();
		if (SearchFiles (dirName, "*.lua", true, ref fileList) <= 0) {
			UnityEngine.Debug.LogWarning (string.Format("BuildBundleLua({0}, {1}) is empty.", bundleName, dirName));
			return true;
		}

		List<string> newList = new List<string> ();
		string srcFile, dstFile, fileName;
		for (int idx = 0; idx < fileList.Count; ++idx) {
			srcFile = fileList [idx];
			fileName = srcFile.Substring (cutoff.Length);
			fileName = fileName.Replace ('/', '@');

			dstFile = bundleDir + fileName + ".bytes";

			if (AppConst.LuaByteMode)
				EncodeLuaFile (srcFile, dstFile);
			else
				File.Copy (srcFile, dstFile, true);

			UnityEngine.Debug.Log(string.Format("[AssetBundle] Debug lua copy({0}, {1}).", srcFile, dstFile));

			dstFile = dstFile.Substring (Application.dataPath.Length - 6);
			newList.Add (dstFile);

			string dictKey = Path.GetFileName (dstFile).ToLower();
			string dictValue = string.Empty;
			if (buildAssetMaps.TryGetValue (dictKey, out dictValue)) {
				if (string.Compare (dictValue, bundleName) != 0)
					UnityEngine.Debug.LogError(string.Format("[AssetBundle] BuildBundleLua conflict: {0} : {1} - {2}", fileList [idx], dictValue, bundleName));
				else
					UnityEngine.Debug.LogError(string.Format("[AssetBundle] BuildBundleLua conflict: {0} : {1}", fileList [idx], dictValue));
				//return false;
			}
			buildAssetMaps.Add (dictKey, bundleName);
		}

		AssetDatabase.Refresh();

		AssetBundleBuild bundleBuild = new AssetBundleBuild ();
		bundleBuild.assetBundleName = bundleName + AppConst.ExtName;
		bundleBuild.assetNames = newList.ToArray();
		buildBundleMaps.Add (bundleBuild);

		return true;
	}

	static bool BuildBundleDir(string ident, string dir) {
		dir = dir.Replace ('\\', '/');

		string dataPath = Application.dataPath + "/";
		string rootPath = dataPath.Replace ("Assets/", string.Empty);
			
		string rootDir = dataPath + "Game/";
		string relateDir = dir.Substring (rootDir.Length).ToLower();

		string bundleName = string.Empty;
		if (string.Compare (ident, relateDir, true) == 0)
			bundleName = ident + "/" + ident;
		else
			bundleName = ident + "/" + relateDir.Replace ('/', '_');
		bundleName = bundleName.ToLower ();

		if (dir.EndsWith ("/Lua"))
			return BuildBundleLua (bundleName, dir, dataPath);
		else {
			foreach (string subdir in Directory.GetDirectories (dir)) {
				if (!BuildBundleDir (ident, subdir)) {
					UnityEngine.Debug.LogError(string.Format("[AssetBundle] BuildBundleDir({0}, {1}) failed: build subDir({2}) failed.", ident, dir, subdir));
					return false;
				}
			}

			//split unity & others
			string sceneBundleName = bundleName + "_scene";
			List<string> sceneFiles = new List<string>();

			List<string> fileList = new List<string> ();
			if (SearchFiles (dir, "*.*", false, ref fileList) <= 0) {
				UnityEngine.Debug.LogWarning (string.Format("[AssetBundle] BuildBundleDir({0}, {1}) is empty.", ident, dir));
				return true;
			}

			string dictKey, dictValue;
			for (int idx = 0; idx < fileList.Count; ++idx) {
				fileList [idx] = fileList [idx].Replace (rootPath, string.Empty);
				dictKey = Path.GetFileName (fileList [idx]).ToLower();

				//skip unity
				if (dictKey.EndsWith (".unity")) {
					sceneFiles.Add (fileList [idx]);
					continue;
				}

				if (buildAssetMaps.TryGetValue (dictKey, out dictValue)) {
					if (string.Compare (dictValue, bundleName) != 0)
						UnityEngine.Debug.LogError (string.Format ("[AssetBundle] BuildBundleDir conflict: {0} : {1} - {2}", fileList [idx], dictValue, bundleName));
					else
						UnityEngine.Debug.LogError (string.Format ("[AssetBundle] BuildBundleDir conflict: {0} : {1}", fileList [idx], dictValue));
					//return false;
				}
				buildAssetMaps.Add (dictKey, bundleName);
			}

			if (sceneFiles.Count > 0) {
				for (int idx = 0; idx < sceneFiles.Count; ++idx) {
					fileList.Remove (sceneFiles [idx]);

					dictKey = Path.GetFileName (sceneFiles [idx]).ToLower();
					if (buildAssetMaps.TryGetValue (dictKey, out dictValue)) {
						if (string.Compare (dictValue, sceneBundleName) != 0)
							UnityEngine.Debug.LogError (string.Format ("[AssetBundle] BuildBundleDir conflict: {0} : {1} - {2}", fileList [idx], dictValue, sceneBundleName));
						else
							UnityEngine.Debug.LogError (string.Format ("[AssetBundle] BuildBundleDir conflict: {0} : {1}", fileList [idx], dictValue));
						//return false;
					}
					buildAssetMaps.Add (dictKey, sceneBundleName);
				}

				AssetBundleBuild sceneBundleBuild = new AssetBundleBuild ();
				sceneBundleBuild.assetBundleName = sceneBundleName + AppConst.ExtName;
				sceneBundleBuild.assetNames = sceneFiles.ToArray();
				buildBundleMaps.Add (sceneBundleBuild);
			}

			AssetBundleBuild bundleBuild = new AssetBundleBuild ();
			bundleBuild.assetBundleName = bundleName + AppConst.ExtName;
			bundleBuild.assetNames = fileList.ToArray();
			buildBundleMaps.Add (bundleBuild);
		}

		return true;
	}

	//map
	static void BuildATB() {
		string streamingPath = Application.streamingAssetsPath;
		string fileName = streamingPath + "/" + ResourceManager.ASSET_TO_BUNDLE;
		if (File.Exists (fileName))
			File.Delete (fileName);

		FileStream fs = new FileStream (fileName, FileMode.CreateNew);
		StreamWriter sw = new StreamWriter(fs);

		foreach (KeyValuePair<string, string> kv in buildAssetMaps) {
			sw.WriteLine (kv.Key + "|" + kv.Value);
		}

		sw.Close ();
		fs.Close ();
	}


	/*static bool BuildVersions(BuildConfig buildCfg) {
		string streamingRoot = Application.streamingAssetsPath + "/";
		List<string> fileList = new List<string> ();
		versionDirs.Add (BASIC_BUNDLE, new VersionContent (BASIC_BUNDLE));

		//udf
		UDF udf;
		foreach (KeyValuePair<string, VersionContent> kv in versionDirs) {
			fileList.Clear ();
			if (kv.Key == BASIC_BUNDLE)
				SearchFiles (streamingRoot, "*.*", false, ref fileList);
			else
				SearchFiles (streamingRoot + kv.Key, "*.*", false, ref fileList);
			if (fileList.Count <= 0)
				continue;
			
			udf = new UDF ();
			udf.ident = kv.Key;
			//udf.url = buildCfg.URL;
			if(debugMode)
				udf.url = buildCfg.DebugURL;
			else
				udf.url = buildCfg.URL;
			udf.version = buildCfg.Version;
			if (!BASIC_DIR.Contains (kv.Key))
				udf.dirList.AddRange (BASIC_DIR);

			BundleOption bundleOption = null;
			if (FindBundleOption (buildCfg, kv.Key, ref bundleOption)) {
				for (int idx = 0; idx < bundleOption.dependList.Count; ++idx) {
					if (udf.dirList.Contains (bundleOption.dependList [idx].ToLower()))
						continue;
					udf.dirList.Add (bundleOption.dependList [idx].ToLower ());
				}
			}

			if (kv.Key == BASIC_BUNDLE) {
				udf.dirList.Add ("game_loding");
				udf.dirList.Add ("game_login");
				udf.dirList.Add ("game_hall");
				File.WriteAllText (streamingRoot + GameManager.UDF_FILE, JsonUtility.ToJson (udf));
			} else
				File.WriteAllText (streamingRoot + kv.Key + "/" + GameManager.UDF_FILE, JsonUtility.ToJson (udf));
		}
			
		string fileName, fileMD5, fileSize;
		FileInfo fileInfo;
		foreach (KeyValuePair<string, VersionContent> kv in versionDirs) {
			fileList.Clear ();
			if (kv.Key == BASIC_BUNDLE)
				SearchFiles (streamingRoot, "*.*", false, ref fileList);
			else
				SearchFiles (streamingRoot + kv.Key, "*.*", false, ref fileList);

			if (fileList.Count <= 0) {
				UnityEngine.Debug.LogWarning (string.Format ("[AssetBundle] BuildVersions warning: {0} is empty", kv.Key));
				continue;
			}

			string udfInfo = string.Empty;
			for (int idx = 0; idx < fileList.Count; ++idx) {
				fileName = fileList [idx];
				fileInfo = new FileInfo(fileName);
				fileMD5 = Util.md5file (fileName);
				fileName = fileName.Replace (streamingRoot, string.Empty).ToLower();
				if (fileName.EndsWith (GameManager.UDF_FILE)) {
					udfInfo = fileName + "|" + fileMD5 + "|" + fileInfo.Length.ToString ();
					continue;
				}
				kv.Value.fileList.Add (fileName + "|" + fileMD5 + "|" + fileInfo.Length.ToString());
			}
			kv.Value.fileList.Add (udfInfo);
		}

		//save filelist
		FileStream fs;
		StreamWriter sw;
		foreach (KeyValuePair<string, VersionContent> kv in versionDirs) {
			if (kv.Value.fileList.Count <= 0)
				continue;
			
			if (string.Compare (kv.Key, BASIC_BUNDLE) == 0)
				fs = new FileStream(streamingRoot + GameManager.FILE_LIST, FileMode.Create);
			else
				fs = new FileStream(streamingRoot + kv.Key + "/" + GameManager.FILE_LIST, FileMode.Create);

			sw = new StreamWriter(fs);

			for (int idx = 0; idx < kv.Value.fileList.Count; ++idx)
				sw.WriteLine (kv.Value.fileList [idx]);

			sw.Close ();
			fs.Close ();
		}

		return true;
	}*/
	static bool BuildVersions(BuildConfig buildCfg) {
		string streamingRoot = Application.streamingAssetsPath + "/";
		List<string> fileList = new List<string> ();

		//List<string> svr_list = buildCfg.svr_list;
		//List<string> svr_data = buildCfg.svr_data;
		//List<string> svr_game = buildCfg.svr_game;
		//updList = svr_list;
		//updData = svr_data;
		//updGame = svr_game;
		
		//udf
		UDF udf;
		List<string> basicDependList = new List<string> ();
		basicDependList.AddRange (BASIC_DIR);
		basicDependList.Add("game_loding");
		basicDependList.Add("game_login");

		foreach (KeyValuePair<string, VersionContent> kv in versionDirs) {
			fileList.Clear ();
			SearchFiles (streamingRoot + kv.Key, "*.*", false, ref fileList);
			if (fileList.Count <= 0)
				continue;

			udf = new UDF ();
			udf.ident = kv.Key;
			udf.version = buildCfg.Version;
			if (!BASIC_DIR.Contains (kv.Key))
				udf.dirList.AddRange (BASIC_DIR);
			
			BundleOption bundleOption = null;
			if (FindBundleOption (buildCfg, kv.Key, ref bundleOption)) {
				for (int idx = 0; idx < bundleOption.dependList.Count; ++idx) {
					if (udf.dirList.Contains (bundleOption.dependList [idx].ToLower()))
						continue;
					udf.dirList.Add (bundleOption.dependList [idx].ToLower ());
				}

				if (bundleOption.useBasicVersion)
				{
					if (!basicDependList.Contains(kv.Key.ToLower()))
						basicDependList.Add(kv.Key.ToLower());
					for (int idx = 0; idx < bundleOption.dependList.Count; ++idx) {
						if (basicDependList.Contains (bundleOption.dependList [idx].ToLower ()))
							continue;
						basicDependList.Add(bundleOption.dependList [idx].ToLower ());
					}
				}
			}

			File.WriteAllText (streamingRoot + kv.Key + "/" + GameManager.UDF_FILE, JsonUtility.ToJson (udf));
		}

		//channel & qudao & activity
		{
			string[] dependList = new string[] {
				"channel", AppDefine.CurQuDao.ToLower (), "activity"
			};

			string dependName = string.Empty;
			for (int idx = 0; idx < dependList.Length; ++idx) {
				dependName = dependList [idx];
				fileList.Clear ();
				if (SearchFiles(streamingRoot + dependName, "*.unity3d", false, ref fileList) > 0) {
					if (!basicDependList.Contains (dependName))
						basicDependList.Add(dependName);
				}
			}
		}


		//basic udf
		versionDirs.Add (BASIC_BUNDLE, new VersionContent (BASIC_BUNDLE));

		fileList.Clear ();
		SearchFiles (streamingRoot, "*.*", false, ref fileList);
		if (fileList.Count <= 0) {
			UnityEngine.Debug.LogError ("[AssetBundle] BuildVersions failed: BasicUDF fileList is Empty");
			return false;
		}

		udf = new UDF ();
		udf.ident = BASIC_BUNDLE;
		udf.svr_list = buildCfg.svr_list;
		udf.svr_data = buildCfg.svr_data;
		udf.svr_game = buildCfg.svr_game;
		udf.version = buildCfg.Version;
		udf.dirList.AddRange (basicDependList);
		File.WriteAllText (streamingRoot + GameManager.UDF_FILE, JsonUtility.ToJson (udf));

		BundleOption option = new BundleOption ();
		option.useBasicVersion = true;
		option.isExtract = true;
		option.rootDir = BASIC_BUNDLE;
		option.dependList.AddRange (basicDependList);
		buildCfg.options.Add (option);

		string manifestFile = Application.streamingAssetsPath + "/" + "StreamingAssets";
		AssetBundle assetBundle = AssetBundle.LoadFromFile(manifestFile);
		if (assetBundle == null)
		{
			UnityEngine.Debug.LogError("[AssetBundle] BuildVersions failed: load StreamingAssets failed");
			return false;
		}
		AssetBundleManifest manifest = assetBundle.LoadAsset<AssetBundleManifest>("AssetBundleManifest");
		assetBundle.Unload(false);

		//filelist
		string fileName, fileMD5, fileSize;
		FileInfo fileInfo;
		foreach (KeyValuePair<string, VersionContent> kv in versionDirs) {
			fileList.Clear ();
			if (kv.Key == BASIC_BUNDLE)
            {
				SearchFiles(streamingRoot, "*.*", false, ref fileList);
				//remove channel config
				RemoveChannelFileFromList(ref fileList);
			}
			else
				SearchFiles (streamingRoot + kv.Key, "*.*", false, ref fileList);

			if (fileList.Count <= 0) {
				UnityEngine.Debug.LogWarning (string.Format ("[AssetBundle] BuildVersions warning: {0} is empty", kv.Key));
				continue;
			}

			for (int idx = 0; idx < fileList.Count; ++idx) {
				fileName = fileList [idx];
				fileInfo = new FileInfo(fileName);
				fileMD5 = Util.md5file (fileName);
				fileName = fileName.Replace (streamingRoot, string.Empty);
				if (fileName.EndsWith(GameManager.UDF_FILE))
					continue;
				
				if(fileName.EndsWith(AppConst.ExtName))
					kv.Value.fileList.Add(fileName + "|" + fileMD5 + "|" + manifest.GetAssetBundleHash(fileName) + "|" + fileInfo.Length.ToString());
				else
					kv.Value.fileList.Add(fileName + "|" + fileMD5 + "|" + "#" + "|" + fileInfo.Length.ToString());
			}
		}

		//save filelist
		FileStream fs;
		StreamWriter sw;
		foreach (KeyValuePair<string, VersionContent> kv in versionDirs) {
			if (kv.Value.fileList.Count <= 0)
				continue;

			if (string.Compare (kv.Key, BASIC_BUNDLE) == 0)
				fs = new FileStream(streamingRoot + GameManager.FILE_LIST, FileMode.Create);
			else
				fs = new FileStream(streamingRoot + kv.Key + "/" + GameManager.FILE_LIST, FileMode.Create);

			sw = new StreamWriter(fs);

			for (int idx = 0; idx < kv.Value.fileList.Count; ++idx)
				sw.WriteLine (kv.Value.fileList [idx]);

			sw.Close ();
			fs.Close ();
		}

		return true;
	}

	static void RemoveChannelFileFromList(ref List<string> list)
    {
		foreach (string it in list)
		{
			if (it.EndsWith(GameManager.CHANNEL_FILE))
			{
				list.Remove(it);
				break;
			}
		}
	}

	static void BuildExtract(BuildConfig buildCfg) {
		string streamingRoot = Application.streamingAssetsPath + "/";

		BundleOption bundleOption = null;

		Dictionary<string, bool> extractFilter = new Dictionary<string, bool> ();
		string dictKey = string.Empty;
		bool dictValue = false;
		for (int idx = 0; idx < buildCfg.options.Count; ++idx) {
			bundleOption = buildCfg.options [idx];

			dictKey = bundleOption.rootDir.ToLower ();
			if (extractFilter.TryGetValue (dictKey, out dictValue)) {
				if (dictValue)
					continue;
				extractFilter [dictKey] = bundleOption.isExtract;
			} else
				extractFilter.Add (dictKey, bundleOption.isExtract);

			foreach (string depend in bundleOption.dependList) {
				dictKey = depend.ToLower ();
				if (extractFilter.TryGetValue (dictKey, out dictValue)) {
					if (dictValue)
						continue;
					extractFilter [dictKey] = bundleOption.isExtract;
				} else
					extractFilter.Add (dictKey, bundleOption.isExtract);
			}
		}

		List<string> fileList = new List<string> ();

		List<string> dirList = new List<string> ();
		dirList.AddRange (BASIC_DIR);
		foreach (KeyValuePair<string, bool> kv in extractFilter) {
			if (kv.Value && !dirList.Contains (kv.Key))
				dirList.Add (kv.Key);
		}
		for (int idx = 0; idx < dirList.Count; ++idx) {
			dictKey = dirList [idx];
			if(dictKey == BASIC_BUNDLE)
            {
				SearchFiles(streamingRoot, "*.*", false, ref fileList);
				//remove channel config
				RemoveChannelFileFromList(ref fileList);
			}
			else
				SearchFiles (streamingRoot + dictKey, "*.*", false, ref fileList);
		}

		/*
		foreach (KeyValuePair<string, VersionContent> kv in versionDirs) {
			if (FindBundleOption (buildCfg, kv.Key, ref bundleOption)) {
				if (!bundleOption.isExtract)
					continue;
			}

			dictKey = kv.Key;
			if (extractFilter.TryGetValue (dictKey, out dictValue)) {
				if (!dictValue) {
					UnityEngine.Debug.Log ("Make Extract: - " + dictKey);
					continue;
				}
			}

			if (kv.Key == BASIC_BUNDLE)
				SearchFiles (streamingRoot, "*.*", false, ref fileList);
			else
				SearchFiles (streamingRoot + kv.Key, "*.*", false, ref fileList);
		}
		*/

		FileStream fs = new FileStream (Application.streamingAssetsPath + "/" + GameManager.EXTRACT_FILE, FileMode.Create);
		StreamWriter sw = new StreamWriter(fs);

		for (int idx = 0; idx < fileList.Count; ++idx)
			sw.WriteLine (fileList [idx].Substring(streamingRoot.Length));

		sw.Close ();
		fs.Close ();
	}

	static int GetSizeByFileList(string root) {
		string fileName = root + "/" + GameManager.FILE_LIST;
		if (!File.Exists (fileName))
			return 0;
		string[] lines = File.ReadAllLines (fileName);
		if (lines == null || lines.Length <= 0) {
			UnityEngine.Debug.LogError (string.Format ("[AssetBundle] GetSizeByFileList({0}) failed: filelist is empty.", root));
			return 0;
		}

		int totalSize = 0;

		string[] item = { };
		foreach (string line in lines) {
			item = line.Split ('|');
			if (item == null || item.Length != 4) {
				UnityEngine.Debug.LogError (string.Format ("[AssetBundle] GetSizeByFileList({0}) failed: filelist line({1}) invalid.", root, line));
				return 0;
			}
			totalSize += int.Parse (item [3]);
		}

		return totalSize;
	}
	static void BuildVersionMap(BuildConfig buildCfg, BuildTarget buildTarget) {
		VersionMap versionMap = new VersionMap ();
		versionMap.svr_list = buildCfg.svr_list;
		versionMap.svr_data = buildCfg.svr_data;
		versionMap.svr_game = buildCfg.svr_game;
		versionMap.last_version = buildCfg.Version;
		//versionMap.config_version = buildCfg.Version;

		string dictKey = string.Empty;
		GameInfo gameInfo;
		BundleOption bundleOption = null;
		for (int idx = 0; idx < buildCfg.options.Count; ++idx) {
			bundleOption = buildCfg.options [idx];

			if (string.Compare (bundleOption.rootDir, BASIC_BUNDLE, true) == 0)
				continue;
			
			dictKey = bundleOption.rootDir.ToLower ();
			gameInfo = new GameInfo ();
			gameInfo.Name = bundleOption.rootDir;
			gameInfo.Size = GetSizeByFileList (Application.streamingAssetsPath + "/" + dictKey);
			if (gameInfo.Size == 0)
				UnityEngine.Debug.LogError ("[AssetBundle] BuildVersionMap Find empty dir:" + dictKey);

			/*
			foreach (string depend in bundleOption.dependList) {
				gameInfo.Size += GetSizeByFileList (Application.streamingAssetsPath + "/" + depend);
			}
			*/

			versionMap.games.Add (gameInfo);
		}

		//file list md5
		string streamingRoot = Application.streamingAssetsPath + "/";
		List<string> fileList = new List<string> ();
		SearchFiles(streamingRoot, GameManager.UDF_FILE, true, ref fileList);
		SearchFiles(streamingRoot, GameManager.FILE_LIST, true, ref fileList);

		if (fileList.Count > 0) {
			string fileName = string.Empty;
			FileInfo fileInfo;
			string fileMD5;
			for (int idx = 0; idx < fileList.Count; ++idx) {
				fileName = fileList [idx];
				fileInfo = new FileInfo(fileName);
				fileMD5 = Util.md5file (fileName);
				versionMap.md5s.Add (new GuideFile (fileName.Substring (streamingRoot.Length), fileMD5, (int)fileInfo.Length));
			}
		}

		string saveDir = string.Empty;
		if (buildTarget == BuildTarget.Android)
			saveDir = Application.dataPath + "/VersionConfig/Android";
		else if (buildTarget == BuildTarget.iOS)
			saveDir = Application.dataPath + "/VersionConfig/IOS";
		else
			saveDir = Application.dataPath + "/VersionConfig";

		//saveDir += "/" + buildCfg.Version;
		//if(Directory.Exists(saveDir))
		//	Directory.Delete (saveDir, true);
		//Directory.CreateDirectory (saveDir);

		File.WriteAllText (saveDir + "/version_map.txt", JsonUtility.ToJson (versionMap, true));
		Util.CopyFile(saveDir + "/version_map.txt", Application.streamingAssetsPath + "/version_map.txt");
	}

	static bool EncryptAssetBundles() {
		List<string> fileList = new List<string> ();
		if (SearchFiles (Application.streamingAssetsPath, "*.unity3d", true, ref fileList) <= 0) {
			UnityEngine.Debug.LogError ("EncryptAssetBundles assetbundle is empty.");
			return false;
		}

		string xtea = "2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53";
		ResourceManager.SetXTEAKey(xtea, AppConst.PubXTEA);
		byte[] xtea_key = ResourceManager.GetXTEAKey ();
		if (xtea_key == null || xtea_key.Length != 16) {
			UnityEngine.Debug.LogError ("EncryptAssetBundles xtea_key invalid:" + System.Text.Encoding.Default.GetString(xtea_key));
			return false;
		}

		byte[] datas = null;
		foreach (string file in fileList) {
			datas = File.ReadAllBytes (file);
			if (datas == null || datas.Length <= 0) {
				UnityEngine.Debug.LogError ("EncryptAssetBundles file data is empty:" + file);
				return false;
			}
			LuaInterface.LuaDLL.xtea_encrypt (datas, datas.Length, xtea_key);
			File.WriteAllBytes (file, datas);
		}
		return true;
	}

	static void ClearPluginDir(string tagName) {
		string rootDir = Application.dataPath.Substring (0, Application.dataPath.Length - 6);
		string pluginDir = "/Plugins/" + tagName + "/";
		string srcDir = rootDir + "Channel/" + AppDefine.CurQuDao + pluginDir;
		string dstDir = Application.dataPath + pluginDir;

		string srcFile = string.Empty, dstFile = string.Empty;
		string[] files = Directory.GetFiles (srcDir, "*.*", SearchOption.AllDirectories);
		foreach (string file in files) {
			srcFile = file.Replace ('\\', '/');
			dstFile = dstDir + srcFile.Substring (srcDir.Length);
			File.Delete (dstFile);
		}
		AssetDatabase.Refresh ();
	}

	static void ClearUnextract(string cfgFile, string assetRoot) {
		string configFile = cfgFile;
		if (!File.Exists (configFile)) {
			UnityEngine.Debug.LogError ("[AssetBundle] ClearUnextract failed. cfgFile not exist");
			return;
		}

		string content = File.ReadAllText (configFile);
		if (string.IsNullOrEmpty (content)) {
			UnityEngine.Debug.LogError ("[AssetBundle] ClearUnextract failed. ConfigFile invalid.");
			return;
		}

		BuildConfig buildCfg = JsonUtility.FromJson<BuildConfig> (content);
		if (buildCfg == null) {
			UnityEngine.Debug.LogError ("[AssetBundle] ClearUnextract failed. ParseJson failed.");
			return;
		}

		string[] dependList = new string[] {
			"channel", AppDefine.CurQuDao.ToLower (), "activity"
		};

		string dictKey = string.Empty;
		bool dictValue = false;
		Dictionary<string, bool> extractFilter = new Dictionary<string, bool> ();

		BundleOption bundleOption = null;
		for (int idx = 0; idx < buildCfg.options.Count; ++idx) {
			bundleOption = buildCfg.options [idx];

			dictKey = bundleOption.rootDir.ToLower ();
			if (extractFilter.TryGetValue (dictKey, out dictValue)) {
				if (dictValue)
					continue;
				extractFilter [dictKey] = bundleOption.isExtract;
			} else
				extractFilter.Add (dictKey, bundleOption.isExtract);

			foreach (string depend in bundleOption.dependList) {
				dictKey = depend.ToLower ();
				if (extractFilter.TryGetValue (dictKey, out dictValue)) {
					if (dictValue)
						continue;
					extractFilter [dictKey] = bundleOption.isExtract;
				} else
					extractFilter.Add (dictKey, bundleOption.isExtract);
			}
		}

		List<string> remDirs = new List<string> ();

		string channelName = AppDefine.CurQuDao.ToLower ();
		bool activityEnable = false;

		string rootDir = Application.dataPath + "/" + "Game/";
		string[] dirs = Directory.GetDirectories (rootDir);
		foreach (string dir in dirs) {
			dictKey = dir.Substring (rootDir.Length).ToLower ();

			if (BASIC_DIR.Contains (dictKey))
				continue;
			
			if (dictKey == "game_loding" || dictKey == "game_login")
				continue;

			if (dependList.Contains (dictKey))
				continue;

			if (extractFilter.TryGetValue (dictKey, out dictValue)) {
				if (dictValue)
					continue;
			}

			remDirs.Add (dictKey);

			UnityEngine.Debug.Log ("Clear " + dictKey);
		}

		dirs = Directory.GetDirectories (assetRoot);
		foreach (string dir in dirs) {
			dictKey = dir.Substring (assetRoot.Length).ToLower ();
			if (remDirs.Contains (dictKey)) {
				Directory.Delete (dir, true);
				UnityEngine.Debug.Log ("rootDir : " + dir);
			}
			else
				UnityEngine.Debug.Log ("rootDir : " + dictKey);
		}
	}

	/*[MenuItem("Packager/CheckDepends")]
	public static void CheckDepends() {
		string dataPath = Application.dataPath.Substring (0, Application.dataPath.Length - 6);
		string rootDir = Application.dataPath + "/Game/";
		string dirName = string.Empty, fileName = string.Empty;

		BuildConfig buildCfg = null;
		BundleOption bundleOption = null;

		string configFile = Application.dataPath + "/" + BuildConfigFile;
		if (File.Exists (configFile))
			buildCfg = JsonUtility.FromJson<BuildConfig> (File.ReadAllText (configFile));
		if (buildCfg == null)
			UnityEngine.Debug.LogWarning ("[AssetBundle] CheckDepends exception: no BuildConfig file.");

		Dictionary<string, List<string>> filterMap = new Dictionary<string, List<string>> ();

		List<string> fileList = new List<string> ();
		List<string> filterList = new List<string> ();
		string[] dirs = Directory.GetDirectories (rootDir);

		string[] checkFiles = new string[] { "*.prefab", "*.mp3", "*.png" };
		foreach (string checkFile in checkFiles) {
			foreach (string dir in dirs) {
				fileList.Clear ();
				if (SearchFiles (dir, "*.prefab", true, ref fileList) <= 0)
					continue;

				dirName = dir.Replace(dataPath, string.Empty);
				string dirIdent = dirName.Replace ("Assets/Game/", string.Empty).ToLower ();
				FindBundleOption (buildCfg, dirIdent, ref bundleOption);

				UnityEngine.Debug.Log ("[AssetBundle] CheckDepends dir: " + dirName);

				for (int idx = 0; idx < fileList.Count; ++idx) {
					fileName = fileList [idx].Replace (dataPath, string.Empty);

					GameObject go = AssetDatabase.LoadAssetAtPath<GameObject> (fileName);
					if (go == null) {
						UnityEngine.Debug.LogError ("[AssetBundle] CheckDepends failed. can't load prefab: " + fileName);
						continue;
					}

					filterList.Clear ();
					UnityEngine.Object[] depends = EditorUtility.CollectDependencies(new UnityEngine.Object[]{go});
					foreach (UnityEngine.Object depend in depends) {
						string dependDir = AssetDatabase.GetAssetPath (depend);
						dependDir = dependDir.Replace (dataPath, string.Empty);
						if (string.IsNullOrEmpty (dependDir))
							continue;
						if (dependDir.EndsWith (".dll") || dependDir.EndsWith (".cs"))
							continue;
						if (dependDir.StartsWith ("Library") || dependDir.StartsWith("Resources"))
							continue;

						if (dependDir.StartsWith (dirName))
							continue;

						dirIdent = dependDir.Replace ("Assets/Game/", string.Empty).ToLower ();
						string[] items = dirIdent.Split ('/');
						if(items.Length > 0)
							dirIdent = items [0];
						if (bundleOption != null) {
							if (bundleOption.dependList.Contains (dirIdent))
								continue;
						}
						if (BASIC_DIR.Contains (dirIdent))
							continue;

						if (!filterList.Contains(dependDir))
							filterList.Add (dependDir);
					}

					if (filterList.Count > 0) {
						string content = "\t" + fileName + ":\n";
						foreach (string line in filterList) {
							content += "\t\t" + line + "\n";
						}

						List<string> contents;
						if (!filterMap.TryGetValue (dirName, out contents)) {
							contents = new List<string> ();
							filterMap.Add (dirName, contents);
						}
						contents.Add (content);

						UnityEngine.Debug.LogError (content);
					}
				}
			}
		}

		string saveFileName = Application.dataPath + "/DependException.txt";
		FileStream fs = new FileStream (saveFileName, FileMode.Create);
		StreamWriter sw = new StreamWriter(fs);

		foreach (KeyValuePair<string, List<string>> kv in filterMap) {
			sw.WriteLine (kv.Key + ":");
			foreach(string content in kv.Value)
				sw.Write (content);
			sw.WriteLine ("");
		}

		sw.Close ();
		fs.Close ();
	}*/


	[MenuItem("Packager/CheckMissing")]
	public static void CheckMissing() {
		string dataPath = Application.dataPath.Substring (0, Application.dataPath.Length - 6);

		List<string> fileList = new List<string> ();
		if (SearchFiles (Application.dataPath + "/Game", "*.prefab", true, ref fileList) <= 0)
			return;

		UnityEngine.Debug.Log ("CheckPrefabCount:" + fileList.Count);

		string fileName = string.Empty;
		for (int idx = 0; idx < fileList.Count; ++idx) {
			fileName = fileList [idx].Replace (dataPath, string.Empty);
			GameObject go = AssetDatabase.LoadAssetAtPath<GameObject> (fileName);
			if (go == null) {
				UnityEngine.Debug.LogError ("[AssetBundle] CheckMissing failed. can't load prefab: " + fileName);
				continue;
			}

			Component[] components = go.GetComponents<Component> ();
			foreach (Component component in components) {
				if (component == null)
					UnityEngine.Debug.LogError ("Missing Component:" + FullObjectPath (go));
				else {
					SerializedObject so = new SerializedObject (component);
					SerializedProperty sp = so.GetIterator ();
					while (sp.NextVisible (true)) {
						if (sp.propertyType != SerializedPropertyType.ObjectReference)
							continue;
						if (sp.objectReferenceValue == null && sp.objectReferenceInstanceIDValue != 0)
							ShowError(FullObjectPath(go), sp.name);
					}
				}
			}

		}
	}
	private static void ShowError(string objectName, string propertyName)
	{
		UnityEngine.Debug.LogError("Missing reference found in: " + objectName + ", Property : " + propertyName);
	}
	private static string FullObjectPath(GameObject go)
	{
		return go.transform.parent == null ? go.name : FullObjectPath(go.transform.parent.gameObject) + "/" + go.name;
	}

	[MenuItem("Packager/FindReference _F4")]
	public static void FindReference() {
		string dataPath = Application.dataPath.Substring (0, Application.dataPath.Length - 6);
		string rootDir = Application.dataPath + "/Game/";
		string dirName = string.Empty, fileName = string.Empty;

		if (Selection.activeObject == null)
			return;
		
		string findIdent = AssetDatabase.GetAssetPath (Selection.activeObject).ToLower();
		findIdent = Path.GetFileName (findIdent);

		List<string> fileList = new List<string> ();
		if (SearchFiles (rootDir, "*.prefab", true, ref fileList) <= 0)
			return;
		
		for (int idx = 0; idx < fileList.Count; ++idx) {
			fileName = fileList [idx].Replace (dataPath, string.Empty);

			GameObject go = AssetDatabase.LoadAssetAtPath<GameObject> (fileName);
			if (go == null) {
				UnityEngine.Debug.LogError ("[AssetBundle] FindReference failed. can't load prefab: " + fileName);
				continue;
			}

			UnityEngine.Object[] depends = EditorUtility.CollectDependencies(new UnityEngine.Object[]{go});
			foreach (UnityEngine.Object depend in depends) {
				string fullName = AssetDatabase.GetAssetPath (depend).ToLower ();
				if (fullName.EndsWith (findIdent)) {
					UnityEngine.Debug.Log (depend.name + ":" + fileName);
				}
			}
		}
	}



	static string[] ISOLATE_TBL = new string[] {"loadingpanel/"};
	private static bool AdaptIsolate(string key, out string value) {
		value = string.Empty;
		for (int idx = 0; idx < ISOLATE_TBL.Length; ++idx) {
			if (key.StartsWith (ISOLATE_TBL [idx])) {
				value = ISOLATE_TBL [idx];
				return true;
			}
		}
		return false;
	}

	static string[] SHARE_TBL = new string[] {"common/", "framework/", "sproto/", "loadingpanel/", "commonprefab/", "game_hall/"};
	private static bool AdaptShare(string key, out string value) {
		value = string.Empty;
		for (int idx = 0; idx < SHARE_TBL.Length; ++idx) {
			if (key.StartsWith (SHARE_TBL [idx])) {
				value = SHARE_TBL [idx];
				return true;
			}
		}

		string channelTag = AppDefine.CurQuDao + "/";
		if (key.StartsWith (channelTag)) {
			value = channelTag;
			return true;
		}

		return false;
	}

	static string[] PAIR_TBL = new string[] {"game_ddz", "normal_ddz_common/", "game_mj", "normal_mj_common/", "game_fishing", "normal_fishing_common/", "game_eliminate", "normal_xxl_common/"};
	private static bool AdaptPair(string key, string value) {
		int index = 0;
		for (int idx = 0; idx < PAIR_TBL.Length / 2; ++idx) {
			index = idx * 2;
			if (!key.StartsWith (PAIR_TBL [index]))
				continue;
			if (value.StartsWith (PAIR_TBL [index + 1]))
				return true;
		}

		return false;
	}

	private static bool IsStartWith(string[] tbl, string key)
	{
		foreach(string it in tbl)
		{
			if (key.StartsWith(it))
				return true;
		}
		return false;
	}

	private static void CheckAssetBundle(AssetBundleManifest manifest, string bundleName, ref List<string> dependList) {
		dependList.Clear ();

		string[] dependencies = manifest.GetAllDependencies(bundleName);
		if (dependencies.Length <= 0)
			return;

		string adapt_value = string.Empty;
		string share_value = string.Empty;

		if (AdaptIsolate (bundleName, out adapt_value)) {
			foreach (string dependency in dependencies) {
				if (dependency.StartsWith (adapt_value))
					continue;
				
				if (AdaptShare (dependency, out share_value))
					continue;

				dependList.Add (dependency);
				//UnityEngine.Debug.Log ("[ISOLATE] " + bundleName + " -- outrange --> " + dependency);
			}

			return;
		}

		if (AdaptShare (bundleName, out share_value)) {
			foreach (string dependency in dependencies) {
				if (AdaptShare (dependency, out adapt_value))
					continue;

				dependList.Add (dependency);
				//UnityEngine.Debug.Log ("[SHARE] " + bundleName + " -- outrange --> " + dependency);
			}

			return;
		}

		{
			int idx = bundleName.IndexOf ('/');
			if (idx <= 0)
				adapt_value = Path.GetFileNameWithoutExtension (bundleName);
			else
				adapt_value = bundleName.Substring (0, idx + 1);
			foreach (string dependency in dependencies) {
				if (AdaptShare (dependency, out share_value))
					continue;

				if (dependency.StartsWith (adapt_value))
					continue;

				if (AdaptPair (adapt_value, dependency))
					continue;

				dependList.Add (dependency);
				//UnityEngine.Debug.Log ("[NORMAL] " + bundleName + " -- outrange --> " + dependency);
			}
		}
	}

	private static void ParseManifestValue(string[] lines, int offset, ref List<string> values) {
		int idx = offset;
		string line = string.Empty;
		while (idx < lines.Length) {
			line = lines [idx++];
			if (line.StartsWith ("- "))
				values.Add (line.Substring(2));
			else
				break;
		}
	}
	private static void ParseManifestKey(string[] lines, string key, ref List<string> values, bool revert) {
		if (revert) {
			for (int idx = lines.Length - 1; idx >= 0; --idx) {
				if (lines [idx].StartsWith (key)) {
					ParseManifestValue (lines, idx + 1, ref values);
					break;
				}
			}
		} else {
			for (int idx = 0; idx < lines.Length; ++idx) {
				if (lines [idx].StartsWith (key)) {
					ParseManifestValue (lines, idx + 1, ref values);
					break;
				}
			}
		}
	}
	const string GUID_KEY = "guid: ";
	private static void CollectGUID(string[] lines, ref HashSet<string> values) {
		int index = 0;
		for (int idx = 0; idx < lines.Length; ++idx) {
			index = lines [idx].IndexOf (GUID_KEY);
			if (index >= 0)
				values.Add (lines [idx].Substring (index + GUID_KEY.Length, 32));
		}
	}

	const string MANIFEST_SUFFIX = ".manifest";
	private static void BatchConvertGUID(string[] bundles, ref Dictionary<string, HashSet<string>> guidsMap, ref HashSet<string> guids) {
		string streamingDir = Application.streamingAssetsPath + "/";
		string fileName = string.Empty;
		List<string> assets = new List<string> ();
		HashSet<string> guidSet;

		for (int idx = 0; idx < bundles.Length; ++idx) {
			if (!guidsMap.TryGetValue (bundles [idx], out guidSet)) {
				fileName = streamingDir + bundles [idx] + MANIFEST_SUFFIX;

				assets.Clear ();
				ParseManifestKey (File.ReadAllLines (fileName), "Assets:", ref assets, true);

				guidSet = new HashSet<string> ();
				for (int jdx = 0; jdx < assets.Count; ++jdx)
					guidSet.Add (AssetDatabase.AssetPathToGUID (assets [jdx]));
				guidsMap.Add (bundles [idx], guidSet);
			}

			guids.UnionWith (guidSet);
		}
	}

	private static void AnalyseAssetBundle(string key, string[] values, ref Dictionary<string, HashSet<string>> guidsMap, ref Dictionary<string, string[]> traceMap) {
		string dataDir = Application.dataPath.Substring (0, Application.dataPath.Length - 6);
		string streamingDir = Application.streamingAssetsPath + "/";

		string manifestFile = streamingDir + key + MANIFEST_SUFFIX;
		string[] lines = File.ReadAllLines (manifestFile);
		if (lines == null || lines.Length <= 0)
			return;

		List<string> assets = new List<string> ();
		ParseManifestKey (lines, "Assets:", ref assets, true);

		List<string> objects = new List<string> ();
		for (int idx = 0; idx < assets.Count; ++idx) {
			if (assets [idx].EndsWith (".prefab") || assets [idx].EndsWith (".mat") || assets [idx].EndsWith (".unity"))
				objects.Add (assets [idx]);
		}
		if (objects.Count <= 0)
			return;

		HashSet<string> dependGuids = new HashSet<string> ();
		BatchConvertGUID (values, ref guidsMap, ref dependGuids);

		HashSet<string> guidTbl = new HashSet<string> ();
		for (int idx = 0; idx < objects.Count; ++idx) {
			guidTbl.Clear ();
			CollectGUID (File.ReadAllLines (dataDir + objects [idx]), ref guidTbl);
			guidTbl.IntersectWith (dependGuids);

			if (guidTbl.Count > 0) {
				/*UnityEngine.Debug.Log ("\t" + objects [idx] + ":");
				foreach(string it in guidTbl)
					UnityEngine.Debug.Log ("\t\t" + AssetDatabase.GUIDToAssetPath(it));*/
				
				traceMap.Add (objects [idx], guidTbl.ToArray());
			}
		}
	}

	private static void AutoAdjustAssets(Dictionary<string, string[]> traceMap) {
		if (traceMap.Count <= 0)
			return;
		
		Dictionary<string, int> levelMap = new Dictionary<string, int> ();

		string fileName = string.Empty;
		string memberName = string.Empty;
		int memberLevel = 0;
		foreach (KeyValuePair<string, string[]> kv in traceMap) {
			fileName = kv.Key;
			for (int idx = 0; idx < kv.Value.Length; ++idx) {
				memberName = kv.Value [idx];
				memberLevel = 0;

				if (AdaptPair (fileName, memberName)) {
				}

			}


		}
	}

	[MenuItem("Packager/CheckAssetBundles")]
	public static void CheckAssetBundles() {
		string manifestFile = Application.streamingAssetsPath + "/" + "StreamingAssets";

		AssetBundle assetBundle = AssetBundle.LoadFromFile(manifestFile);
		if (assetBundle == null) {
			UnityEngine.Debug.LogError ("[AssetBundle] CheckAssetBundle failed: load StreamingAssets failed");
			return;
		}
		AssetBundleManifest manifest = assetBundle.LoadAsset<AssetBundleManifest> ("AssetBundleManifest");
		assetBundle.Unload (false);

		string configFile = GetBuildConfigFileName(BuildTarget.Android);
		if (!File.Exists(configFile))
		{
			UnityEngine.Debug.LogError("[AssetBundle] CheckAssetBundle failed. ConfigFile not exist");
			return;
		}

		string content = File.ReadAllText(configFile);
		if (string.IsNullOrEmpty(content))
		{
			UnityEngine.Debug.LogError("[AssetBundle] CheckAssetBundle failed. ConfigFile is empty.");
			return;
		}

		BuildConfig buildCfg = JsonUtility.FromJson<BuildConfig>(content);
		if (buildCfg == null)
		{
			UnityEngine.Debug.LogError("[AssetBundle] CheckAssetBundle failed. ParseJson failed.");
			return;
		}

		Dictionary<string, string[]> exceptionMap = new Dictionary<string, string[]>();
		StringBuilder sb = new StringBuilder();
		for (int idx = 0; idx < buildCfg.options.Count; ++idx)
		{
			CheckAssetBundle(manifest, buildCfg.options[idx], ref exceptionMap);
			if (exceptionMap.Count <= 0)
				continue;

			UnityEngine.Debug.Log("<============================================================>");

			sb.Clear();
			sb.AppendLine("\t" + buildCfg.options[idx].rootDir + ":");
			foreach (KeyValuePair<string, string[]> kv in exceptionMap)
			{
				sb.AppendLine("\t\t" + kv.Key + ":");
				foreach(string it in kv.Value)
					sb.AppendLine("\t\t\t" + it);
			}
			UnityEngine.Debug.Log(sb.ToString());
		}

		/*Dictionary<string, string[]> traceMap = new Dictionary<string, string[]> ();
		Dictionary<string, HashSet<string>> guidsMap = new Dictionary<string, HashSet<string>> ();
		foreach (KeyValuePair<string, string[]> kv in dependMap)
			AnalyseAssetBundle (kv.Key, kv.Value, ref guidsMap, ref traceMap);

		UnityEngine.Debug.Log ("<============================================================>");
		StringBuilder sb = new StringBuilder ();
		foreach (KeyValuePair<string, string[]> kv in traceMap) {
			sb.Length = 0;
			sb.AppendLine (kv.Key + ":");
			foreach (string it in kv.Value)
				sb.AppendLine ("\t" + AssetDatabase.GUIDToAssetPath (it));
			UnityEngine.Debug.Log (sb.ToString());
		}
		UnityEngine.Debug.Log ("<============================================================>");
		UnityEngine.Debug.Log ("Check Exception Total:" + traceMap.Count);*/
	}

	private static void CheckAssetBundle(AssetBundleManifest manifest, BundleOption option, ref Dictionary<string, string[]> exceptionMap)
	{
		exceptionMap.Clear();

		List<string> rootDirs = new List<string>();
		rootDirs.Add(option.rootDir.ToLower());
		foreach (string depend in option.dependList)
			rootDirs.Add(depend.ToLower());
		string[] rootDirArray = rootDirs.ToArray();

		string baseDir = Application.streamingAssetsPath + "/";
		string baseName = string.Empty;
		string baseValue = string.Empty;
		List<string> fileList = new List<string>();
		foreach (string dir in rootDirs)
		{
			if (SearchFiles(baseDir + dir, "*" + AppConst.ExtName, true, ref fileList) <= 0)
				continue;

			foreach(string bundleName in fileList)
			{
				baseName = bundleName.Substring(baseDir.Length);
				string[] dependList = manifest.GetAllDependencies(baseName);
				if (dependList.Length <= 0) continue;

				List<string> newList = new List<string>();
				foreach(string depend in dependList)
				{
					if (depend.StartsWith("activity/"))
						continue;

					if (IsStartWith(SHARE_TBL, depend))
						continue;

					if (IsStartWith(rootDirArray, depend))
						continue;

					newList.Add(depend);
				}
				if (newList.Count > 0)
					exceptionMap.Add(baseName, newList.ToArray());
			}

			fileList.Clear();
		}
	}

	[MenuItem("Packager/ListAssetBundle")]
	public static void ListAssetBundle() {
		string fileName = UnityEditor.EditorUtility.OpenFilePanelWithFilters ("Select AssetBundle", Application.streamingAssetsPath, new string[]{"unity3d", "unity3d"});
		string manifestFile = Application.streamingAssetsPath + "/" + "StreamingAssets";

		AssetBundle assetBundle = AssetBundle.LoadFromFile(manifestFile);
		if (assetBundle == null) {
			UnityEngine.Debug.LogError ("[AssetBundle] ListAssetBundle failed: load StreamingAssets failed");
			return;
		}
		AssetBundleManifest manifest = assetBundle.LoadAsset<AssetBundleManifest> ("AssetBundleManifest");
		assetBundle.Unload (false);

		assetBundle = AssetBundle.LoadFromFile (fileName);
		if (assetBundle == null) {
			UnityEngine.Debug.LogError ("[AssetBundle] ListAssetBundle failed: load assetbundle failed " + fileName);
			return;
		}

		UnityEngine.Debug.Log ("Count:" + assetBundle.GetAllAssetNames().Length);
		foreach (string item in assetBundle.GetAllAssetNames())
			UnityEngine.Debug.Log ("\t" + item);

		assetBundle.Unload (true);
	}

	private static bool InsertGCCode(string fileName)
	{
		if (!File.Exists (fileName)) {
			UnityEngine.Debug.Log (string.Format ("InsertGCCode({0}) failed. file not exit!", fileName));
			return false;
		}

		string context = File.ReadAllText (fileName);
		if (string.IsNullOrEmpty (context)) {
			UnityEngine.Debug.Log (string.Format ("InsertGCCode({0}) failed. file is empty!", fileName));
			return false;
		}

		Regex headRgx = new Regex ("function [ A-Za-z0-9]+:MyExit()");
		MatchCollection headMC = headRgx.Matches (context);
		if (headMC.Count != 1) {
			UnityEngine.Debug.Log (string.Format ("InsertGCCode({0}) failed. mc count = {1}!", fileName, headMC.Count));
			return false;
		}

		Regex tailRgx = new Regex ("\\nend");
		Match tailMC = tailRgx.Match (context, headMC [0].Index);

		int startIdx = headMC [0].Index;
		int endIdx = tailMC.Index + tailMC.Length;

		int insertIdx = tailMC.Index;
		string headContext = context.Substring (0, insertIdx);
		string endContext = context.Substring (insertIdx);
		File.WriteAllText (fileName, headContext + "\n\n\tUtil.ClearMemory()" + endContext, new UTF8Encoding(false));

		return true;
	}

	//[MenuItem("Packager/CheckLuaPrefabPanel")]
	public static void CheckLuaPrefabPanel() {
		string dataPath = Application.dataPath.Substring(0, Application.dataPath.Length - 6);

		List<string> fileList = new List<string>();
		SearchFiles(Application.dataPath + "/Game", "*.prefab", true, ref fileList);
		SearchFiles(Application.dataPath + "/Channel", "*.prefab", true, ref fileList);

		string fileName = string.Empty;
		for (int idx = 0; idx < fileList.Count; ++idx) {
			fileName = fileList [idx].Replace (dataPath, string.Empty);
			if (!fileName.EndsWith ("panel.prefab", StringComparison.OrdinalIgnoreCase))
				continue;
			
			GameObject go = AssetDatabase.LoadAssetAtPath<GameObject>(fileName);
			if (go == null)
			{
				UnityEngine.Debug.LogError("[AssetBundle] CheckLuaPrefabPanel failed. can't load prefab: " + fileName);
				continue;
			}

			if (go.GetComponent<LuaBehaviour> ())
				continue;

			//LuaBehaviour behaviour = go.AddComponent<LuaBehaviour> ();
			//behaviour.luaTableName = go.name;

			//fileName = fileName.Replace ("/Prefab/", "/Lua/");
			//fileName = fileName.Replace (".prefab", ".lua");
			//InsertGCCode (dataPath + fileName);
		}
        AssetDatabase.SaveAssets();
	}

	public static void SetAppIcon(string iconName, BuildTarget buildTarget) {
		if (buildTarget == BuildTarget.iOS) {
			SetIcons (iconName, BuildTargetGroup.iOS, UnityEditor.iOS.iOSPlatformIconKind.Application);
			SetIcons (iconName, BuildTargetGroup.iOS, UnityEditor.iOS.iOSPlatformIconKind.Spotlight);
			SetIcons (iconName, BuildTargetGroup.iOS, UnityEditor.iOS.iOSPlatformIconKind.Settings);
			SetIcons (iconName, BuildTargetGroup.iOS, UnityEditor.iOS.iOSPlatformIconKind.Notification);
			SetIcons (iconName, BuildTargetGroup.iOS, UnityEditor.iOS.iOSPlatformIconKind.Marketing);
		} else if (buildTarget == BuildTarget.Android) {
			SetIcons (iconName, BuildTargetGroup.Android, UnityEditor.Android.AndroidPlatformIconKind.Adaptive, 0);
			SetIcons (iconName, BuildTargetGroup.Android, UnityEditor.Android.AndroidPlatformIconKind.Adaptive, 1);
			SetIcons (iconName, BuildTargetGroup.Android, UnityEditor.Android.AndroidPlatformIconKind.Round);
			SetIcons (iconName, BuildTargetGroup.Android, UnityEditor.Android.AndroidPlatformIconKind.Legacy);
		}


		/*Texture2D texture = AssetDatabase.LoadAssetAtPath<Texture2D> ("Assets/AppIcons/" + iconName);
		if (texture == null) {
			UnityEngine.Debug.LogError ("SetAppIcon failed:" + iconName);
			return;
		}

		BuildTargetGroup buildTG = BuildTargetGroup.Standalone;
		if (buildTarget == BuildTarget.iOS)
			buildTG = BuildTargetGroup.iOS;
		else if (buildTarget == BuildTarget.Android)
			buildTG = BuildTargetGroup.Android;

		int[] iconSize = PlayerSettings.GetIconSizesForTargetGroup (buildTG);
		Texture2D[] textures = new Texture2D[iconSize.Length];
		for (int idx = 0; idx < iconSize.Length; ++idx)
			textures [idx] = texture;
		PlayerSettings.SetIconsForTargetGroup (buildTG, textures);

		if (buildTarget == BuildTarget.Android) {
			PlatformIconKind iconKind = UnityEditor.Android.AndroidPlatformIconKind.Round;
			PlatformIcon[] icons = PlayerSettings.GetPlatformIcons (buildTG, iconKind);
			for (int idx = 0; idx < icons.Length; ++idx) {
				icons [idx].SetTexture (textures [idx]);
			}
			PlayerSettings.SetPlatformIcons (buildTG, iconKind, icons);
		}*/
	}

	private static Texture2D[] GetIcons(string iconName, BuildTargetGroup target, PlatformIconKind iconKind, PlatformIcon[] icons, int layer) {
		if (Path.HasExtension(iconName))
			iconName = Path.GetFileNameWithoutExtension(iconName);

		Texture2D[] textures = new Texture2D[icons.Length];
		string folder = iconKind.ToString ().Split (' ') [0];
		string filename;
		for (int idx = 0; idx < textures.Length; ++idx) {
			int iconSize = icons [idx].width;
			filename = string.Format("Assets/AppIcons/{0}_{1}_{2}.png", iconName, iconSize, layer);
			textures [idx] = AssetDatabase.LoadAssetAtPath<Texture2D> (filename);
		}
		return textures;
	}
	private static void SetIcons(string iconName, BuildTargetGroup target, PlatformIconKind iconKind, int layer = 0) {
		string defaultIconName = iconName;
		if (!Path.HasExtension(defaultIconName))
			defaultIconName += ".png";
		Texture2D defaultTexture = AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/AppIcons/" + defaultIconName);

		PlatformIcon[] icons = PlayerSettings.GetPlatformIcons(target, iconKind);
		Texture2D[] textures = GetIcons(iconName, target, iconKind, icons, layer);

		for (int idx = 0; idx < icons.Length; ++idx)
		{
			if (textures[idx] == null)
				icons[idx].SetTexture(defaultTexture, layer);
			else
				icons[idx].SetTexture(textures[idx], layer);
		}

		PlayerSettings.SetPlatformIcons (target, iconKind, icons);
	}

	/*public static void BuildBundles()
	{
		string dataPath = Application.dataPath;

		string streamingPath = Application.streamingAssetsPath;
		if (Directory.Exists (streamingPath))
			Directory.Delete (streamingPath, true);

		Directory.CreateDirectory (streamingPath);
		AssetDatabase.Refresh ();

		string configFile = dataPath + "/" + BundleConfigFile;
		if (!File.Exists (configFile)) {
			UnityEngine.Debug.LogError ("[AssetBundle] BuildBundles failed. ConfigFile not exist");
			return;
		}
		string content = File.ReadAllText (configFile);
		if (string.IsNullOrEmpty (content)) {
			UnityEngine.Debug.LogError ("[AssetBundle] BuildBundles failed. ConfigFile invalid.");
			return;
		}

		UnityEngine.Debug.Log ("BuildBundles Start...");

		string luaTmpDir = Application.dataPath + "/" + LUA_TMP_DIR;
		if (Directory.Exists (luaTmpDir))
			Directory.Delete (luaTmpDir, true);
		AssetDatabase.Refresh ();

		traceBuildBundle.Clear ();
		buildBundleMaps.Clear ();
		buildAssetMaps.Clear ();
		versionDirs.Clear ();

		//special tolua lib
		if (!BuildToLua ()) {
			UnityEngine.Debug.LogError ("[AssetBundle] BuildToLua failed.");
			return;
		}

		BundleGroup[] bundleGroups = Util.JsonHelper.FromJson<BundleGroup> (content);
		for (int idx = 0; idx < bundleGroups.Length; ++idx) {
			if (!BuildBundleGroup (bundleGroups [idx])) {
				UnityEngine.Debug.LogError (string.Format("[AssetBundle] BuildBundles failed. BuildBundleGroup({0}) invalid.", idx));
				return;
			}
		}

		BuildPipeline.BuildAssetBundles (Application.streamingAssetsPath,
			buildBundleMaps.ToArray(),
			BuildAssetBundleOptions.DeterministicAssetBundle | BuildAssetBundleOptions.ChunkBasedCompression | BuildAssetBundleOptions.StrictMode,
			EditorUserBuildSettings.activeBuildTarget);
		AssetDatabase.Refresh ();

		//write atb
		BuildATB();

		//write version
		if (!BuildVersions (bundleGroups)) {
			UnityEngine.Debug.LogError ("[AssetBundle] BuildVersions failed.");
			return;
		}

		if (!BuildExtract (bundleGroups)) {
			UnityEngine.Debug.LogError ("[AssetBundle] BuildExtract failed.");
			return;
		}

		Directory.Delete (luaTmpDir, true);
		AssetDatabase.Refresh ();

		UnityEngine.Debug.Log ("BuildBundles Success!");
	}*/
	/*
	private static bool BuildBundleGroup(BundleGroup bundleGroup) {
		foreach (string dirName in bundleGroup.dirList) {
			if (versionDirs.ContainsKey (dirName))
				continue;
			versionDirs.Add (dirName, new VersionContent(dirName));
		}

		for (int idx = 0; idx < bundleGroup.bundleContents.Count; ++idx) {
			if (!BuildBundleContent(bundleGroup.bundleContents[idx])) {
				UnityEngine.Debug.LogError (string.Format("[AssetBundle] BuildBundleGroup failed. BuildBundleContent({0}) failed.", idx));
				return false;
			}
		}
		return true;
	}
	*/

	private static string MakeBundleName(string bundleName, string[] childs) {
		for (int idx = 0; idx < childs.Length - 1; ++idx)
			bundleName += "_" + childs [idx];
		return bundleName;
	}

	/*private static bool BuildBundleContent(BundleContent bundleContent) {
		if (!bundleContent.isVaild ())
			return false;

		//check repeat
		for (int idx = 0; idx < traceBuildBundle.Count; ++idx) {
			if (string.Compare (traceBuildBundle [idx].bundleName, bundleContent.bundleName, true) == 0 &&
			    string.Compare (traceBuildBundle [idx].dataPath, bundleContent.dataPath, true) == 0 &&
			    string.Compare (traceBuildBundle [idx].patternFilter, bundleContent.patternFilter, true) == 0)
				return true;
		}

		List<string> fileList = new List<string> ();
		if (SearchFiles (bundleContent.dataPath, bundleContent.patternFilter, bundleContent.recursionSearch, ref fileList) <= 0) {
			UnityEngine.Debug.LogWarning (string.Format("[AssetBundle] BuildBundleContent failed. fileList({0}, {1}) is empty.", bundleContent.dataPath, bundleContent.patternFilter));
			return true;
		}

		if (bundleContent.isLua) {
			for (int idx = 0; idx < fileList.Count; ++idx)
				fileList [idx] = fileList [idx].Replace ('\\', '/');
			BuildBundleLua (bundleContent, ref fileList);
		}

		string bundleName = bundleContent.bundleName.ToLower();
		string dictKey, dictValue;

		if (bundleContent.recursionSearch && bundleContent.autoSplitBundle) {
			Dictionary<string, List<string>> splitMap = new Dictionary<string, List<string>> ();
			string childBundleName = string.Empty;
			string relateFile = string.Empty;
			string[] item = { };
			List<string> list;
			for (int idx = 0; idx < fileList.Count; ++idx) {
				fileList [idx] = fileList [idx].Replace ('\\', '/');

				relateFile = fileList [idx].Substring (bundleContent.dataPath.Length + 1);
				item = relateFile.Split ('/');
				childBundleName = MakeBundleName (bundleName, item).ToLower();
				if (!splitMap.TryGetValue (childBundleName, out list)) {
					list = new List<string> ();
					splitMap.Add (childBundleName, list);
				}
				list.Add (fileList [idx]);

				dictKey = Path.GetFileName (fileList [idx]).ToLower();
				if (buildAssetMaps.TryGetValue (dictKey, out dictValue)) {
					if (string.Compare (dictValue, childBundleName) != 0)
						UnityEngine.Debug.LogError(string.Format("[AssetBundle] BuildBundleContent conflict: {0} : {1} - {2}", fileList [idx], dictValue, childBundleName));
					else
						UnityEngine.Debug.LogError(string.Format("[AssetBundle] BuildBundleContent conflict: {0} : {1}", fileList [idx], dictValue));
					//return false;
				}
				buildAssetMaps.Add (dictKey, childBundleName);
			}

			foreach (KeyValuePair<string, List<string>> kv in splitMap) {
				AssetBundleBuild bundleBuild = new AssetBundleBuild ();
				bundleBuild.assetBundleName = kv.Key + AppConst.ExtName;
				bundleBuild.assetNames = kv.Value.ToArray();
				buildBundleMaps.Add (bundleBuild);
			}
		} else {
			for (int idx = 0; idx < fileList.Count; ++idx) {
				fileList [idx] = fileList [idx].Replace ('\\', '/');

				dictKey = Path.GetFileName (fileList [idx]).ToLower();
				if (buildAssetMaps.TryGetValue (dictKey, out dictValue)) {
					if (string.Compare (dictValue, bundleName) != 0)
						UnityEngine.Debug.LogError(string.Format("[AssetBundle] BuildBundleContent conflict: {0} : {1} - {2}", fileList [idx], dictValue, bundleName));
					else
						UnityEngine.Debug.LogError(string.Format("[AssetBundle] BuildBundleContent conflict: {0} : {1}", fileList [idx], dictValue));
					//return false;
				}
				buildAssetMaps.Add (dictKey, bundleName);
			}



			AssetBundleBuild bundleBuild = new AssetBundleBuild ();
			bundleBuild.assetBundleName = bundleName + AppConst.ExtName;
			bundleBuild.assetNames = fileList.ToArray();
			buildBundleMaps.Add (bundleBuild);
		}

		traceBuildBundle.Add (bundleContent);

		return true;
	}*/


	/*static bool BuildToLua() {
		string toluaDir = "Assets/LuaFramework/ToLua/Lua";
		string tmp_dir = Application.dataPath + "/" + LUA_TMP_DIR + "/";
		string bundleDir = tmp_dir;

		if (!Directory.Exists (bundleDir))
			Directory.CreateDirectory (bundleDir);

		List<string> fileList = new List<string> ();
		if (SearchFiles (toluaDir, "*.lua", true, ref fileList) <= 0) {
			UnityEngine.Debug.LogError ("[AssetBundle] BuildToLua failed. SearchFile is empty.");
			return false;
		}

		List<string> newList = new List<string> ();
		string srcFile, dstFile, fileName;
		for (int idx = 0; idx < fileList.Count; ++idx) {
			srcFile = fileList [idx];
			fileName = srcFile.Substring (toluaDir.Length + 1);
			fileName = fileName.Replace ('/', '@');

			dstFile = bundleDir + fileName + ".bytes";

			if (AppConst.LuaByteMode)
				EncodeLuaFile (srcFile, dstFile);
			else
				File.Copy (srcFile, dstFile, true);

			dstFile = dstFile.Substring (Application.dataPath.Length - 6);
			newList.Add (dstFile);
		}

		AssetBundleBuild bundleBuild = new AssetBundleBuild ();
		bundleBuild.assetBundleName = "lua" + AppConst.ExtName;
		bundleBuild.assetNames = newList.ToArray();
		buildBundleMaps.Add (bundleBuild);

		return true;
	}

	static bool BuildBundleLua(BundleContent bundleContent, ref List<string> fileList) {
		string tmp_dir = Application.dataPath + "/" + LUA_TMP_DIR + "/";
		string bundleDir = tmp_dir + bundleContent.bundleName + "/";

		if (!Directory.Exists (bundleDir))
			Directory.CreateDirectory (bundleDir);

		List<string> newList = new List<string> ();
		string srcFile, dstFile, fileName;
		for (int idx = 0; idx < fileList.Count; ++idx) {
			srcFile = fileList [idx];
			fileName = srcFile.Substring (6 + 1);
			fileName = fileName.Replace ('/', '@');

			dstFile = bundleDir + fileName + ".bytes";

			if (AppConst.LuaByteMode)
				EncodeLuaFile (srcFile, dstFile);
			else
				File.Copy (srcFile, dstFile, true);

			dstFile = dstFile.Substring (Application.dataPath.Length - 6);
			newList.Add (dstFile);
		}
		fileList = newList;

		AssetDatabase.Refresh ();

		return true;
	}*/

	

	/*static bool BuildVersions(BundleGroup[] bundleGroups) {
		//version|[filename|md5|size]
		string streamingRoot = Application.streamingAssetsPath + "/";
		string versionListFile = Application.dataPath + "/" + VERSION_LIST;

		string versionListDir = Path.GetDirectoryName (versionListFile);
		if (!Directory.Exists (versionListDir))
			Directory.CreateDirectory (versionListDir);

		//add streamingRoot file to basic
		versionDirs.Add (BASIC_BUNDLE, new VersionContent (BASIC_BUNDLE));

		List<string> fileList = new List<string>();
		string fileName, fileMD5, fileSize;
		FileInfo fileInfo;
		foreach (KeyValuePair<string, VersionContent> kv in versionDirs) {
			fileList.Clear();

			if (string.Compare (kv.Key, BASIC_BUNDLE) == 0) {
				if (SearchFiles (streamingRoot, "*.*", false, ref fileList) <= 0) {
					UnityEngine.Debug.LogError ("[AssetBundle] BuildVersions failed: BasicBundle is empty");
					return false;
				}
			} else {
				if (SearchFiles (streamingRoot + kv.Key, "*.*", true, ref fileList) <= 0) {
					UnityEngine.Debug.LogError (string.Format ("[AssetBundle] BuildVersions failed: {0} is empty", streamingRoot + kv.Key));
					return false;
				}
			}

			for (int idx = 0; idx < fileList.Count; ++idx) {
				fileName = fileList [idx];
				fileInfo = new FileInfo(fileName);
				fileMD5 = Util.md5file (fileName);
				fileName = fileName.Replace (streamingRoot, string.Empty).ToLower();

				kv.Value.fileList.Add (fileName + "|" + fileMD5 + "|" + fileInfo.Length.ToString());
			}
		}

		//save filelist
		FileStream fs;
		StreamWriter sw;
		foreach (KeyValuePair<string, VersionContent> kv in versionDirs) {
			if (string.Compare (kv.Key, BASIC_BUNDLE) == 0)
				fs = new FileStream(streamingRoot + GameManager.FILE_LIST, FileMode.Create);
			else
				fs = new FileStream(streamingRoot + kv.Key + "/" + GameManager.FILE_LIST, FileMode.Create);
			
			sw = new StreamWriter(fs);

			for (int idx = 0; idx < kv.Value.fileList.Count; ++idx)
				sw.WriteLine (kv.Value.fileList [idx]);

			sw.Close ();
			fs.Close ();
		}

		//udf
		UDF udf;
		foreach (BundleGroup bundleGroup in bundleGroups) {
			udf = new UDF ();
			udf.ident = bundleGroup.groupName.ToLower ();
			udf.url = URL;
			udf.version = VERSION;
			udf.dirList = bundleGroup.dirList;

			File.WriteAllText (streamingRoot + bundleGroup.groupName + "/" + GameManager.UDF_FILE, JsonUtility.ToJson (udf));
		}
		//basic
		udf = new UDF();
		udf.ident = GameManager.BASIC_IDENT;
		udf.url = URL;
		udf.version = VERSION;
		foreach (BundleGroup bundleGroup in bundleGroups) {
			if (!bundleGroup.useBasicVersion)
				continue;
			//udf.dirList.AddRange (bundleGroup.dirList);
			foreach (string dir in bundleGroup.dirList) {
				if (udf.dirList.Contains (dir))
					continue;
				udf.dirList.Add (dir);
			}
		}
		File.WriteAllText (streamingRoot + GameManager.UDF_FILE, JsonUtility.ToJson (udf));

		//save 
		{
			if (File.Exists (versionListFile)) {
				string historyVersionListFile = versionListDir + "/" + Path.GetFileNameWithoutExtension (versionListFile) + "_" + DateTime.Now.ToString("yyyy-MM-dd HH：mm：ss：ffff") + ".json";
				File.Copy (versionListFile, historyVersionListFile);
			}

			VersionContent[] versionContents = new VersionContent[versionDirs.Count];
			int idx = 0;
			foreach (KeyValuePair<string, VersionContent> kv in versionDirs)
				versionContents [idx++] = kv.Value;
			File.WriteAllText(versionListFile, Util.JsonHelper.ToJson<VersionContent> (versionContents));
		}

		return true;
	}*/
/*
	static bool BuildExtract(BundleGroup[] bundleGroups) {
		List<string> fileList = new List<string> ();

		VersionContent versionContent;

		//basic
		if (!versionDirs.TryGetValue (BASIC_BUNDLE, out versionContent)) {
			UnityEngine.Debug.LogError ("[AssetBundle] BuildExtract failed: BasicBundle invalid.");
			return false;
		}

		fileList.Add (GameManager.UDF_FILE);
		fileList.Add (GameManager.FILE_LIST);

		string[] item = { };
		for (int idx = 0; idx < versionContent.fileList.Count; ++idx) {
			item = versionContent.fileList [idx].Split ('|');
			if (item.Length != 3) {
				UnityEngine.Debug.LogError (string.Format("[AssetBundle] BuildExtract failed: BasicBundle file list({0} : {1}) invalid.",
					idx, versionContent.fileList [idx]));
				return false;
			}
			if (string.Compare (item [0], "StreamingAssets", true) == 0)
				fileList.Add ("StreamingAssets");
			else
				fileList.Add (item [0]);
		}

		foreach(BundleGroup bundleGroup in bundleGroups) {
			if (!bundleGroup.isExtract)
				continue;

			fileList.Add (bundleGroup.groupName.ToLower() + "/" + GameManager.UDF_FILE);
			fileList.Add (bundleGroup.groupName.ToLower() + "/" + GameManager.FILE_LIST);

			foreach (string versionDir in bundleGroup.dirList) {
				if (!versionDirs.TryGetValue (versionDir, out versionContent)) {
					UnityEngine.Debug.LogError (string.Format("[AssetBundle] BuildExtract failed: ExtractBundle({0}) invalid.", versionDir));
					return false;
				}
				for (int idx = 0; idx < versionContent.fileList.Count; ++idx) {
					item = versionContent.fileList [idx].Split ('|');
					if (item.Length != 3) {
						UnityEngine.Debug.LogError (string.Format("[AssetBundle] BuildExtract failed: ExtractBundle file list({0} : {1}) invalid.",
							idx, versionContent.fileList [idx]));
						return false;
					}
					fileList.Add (item [0]);
				}
			}
		}

		FileStream fs = new FileStream (Application.streamingAssetsPath + "/" + GameManager.EXTRACT_FILE, FileMode.Create);
		StreamWriter sw = new StreamWriter(fs);

		for (int idx = 0; idx < fileList.Count; ++idx)
			sw.WriteLine (fileList [idx]);

		sw.Close ();
		fs.Close ();

		return true;
	}
*/

	/*[MenuItem("Packager/BuildAssetTable")]
	public static void BuildAssetTable() {
		ResourceManager.AssetTableConfig cfg = new ResourceManager.AssetTableConfig ();
		cfg.preload.Add ("preload1");
		cfg.preload.Add ("preload2");
		cfg.assetConfig.Add (new ResourceManager.AssetUnitConfig ());
		cfg.assetConfig.Add (new ResourceManager.AssetUnitConfig ());

		File.WriteAllText (Application.dataPath + "/" + "AT.tmpl", JsonUtility.ToJson (cfg, true));

		cfg = JsonUtility.FromJson<ResourceManager.AssetTableConfig> (File.ReadAllText (Application.dataPath + "/" + "AT.tmpl"));


		//File.WriteAllText (Application.dataPath + "/" + "AT.tmpl", Util.JsonHelper.ToJson (configs));

		//configs = Util.JsonHelper.FromJson<AssetTableConfig> (File.ReadAllText (Application.dataPath + "/" + "AT.tmpl"));

		ResourceManager.AssetTableConfig cfg;
		cfg = JsonUtility.FromJson<ResourceManager.AssetTableConfig> (File.ReadAllText (Application.dataPath + "/Game/game_Login/game_Login_AT.json"));
	}*/

	/*[MenuItem("Packager/BuildTemplete")]
	public static void BuildTemplete() {
		BuildConfig buildCfg = new BuildConfig ();
		buildCfg.urls.Add ("http://url1/");
		buildCfg.urls.Add ("http://url2/");
		buildCfg.cdns.Add ("http://cdn1/");
		buildCfg.cdns.Add ("http://cdn2/");
		buildCfg.Version = "1.1.1";

		BundleOption bo = new BundleOption ();
		bo.rootDir = "game_SceneRoot1";
		bo.useBasicVersion = true;
		bo.isExtract = true;
		bo.dependList.Add ("normal_ddz_common");
		buildCfg.options.Add (bo);

		bo = new BundleOption ();
		bo.rootDir = "game_SceneRoot2";
		bo.useBasicVersion = true;
		bo.isExtract = true;
		buildCfg.options.Add (bo);

		UnityEngine.Debug.Log (JsonUtility.ToJson (buildCfg));

		File.WriteAllText (Application.dataPath + "/" + "BuildVersion" + ".tmpl", JsonUtility.ToJson (buildCfg));
	}*/

	/*[MenuItem("Packager/BuildVersionMap")]
	public static void BuildVersionMap() {
		string streamingPath = Application.streamingAssetsPath;
		string fileName = streamingPath + "/" + GameManager.VERSION_MAP;
		if (File.Exists (fileName))
			File.Delete (fileName);

		VersionMap[] versionMaps = new VersionMap[3] { new VersionMap(), new VersionMap(), new VersionMap() };
		for (int idx = 0; idx < versionMaps.Length; ++idx) {
			versionMaps [idx].history.Add ("1.1|1.2");
			versionMaps [idx].history.Add ("1.2|1.3");
		}

		File.WriteAllText (fileName, Util.JsonHelper.ToJson<VersionMap> (versionMaps));
	}*/

	/*static bool BuildVersionMap(BundleConfig bundleConfig) {
		string streamingPath = Application.streamingAssetsPath;
		if (!string.IsNullOrEmpty (bundleConfig.streamingPath))
			streamingPath += "/" + bundleConfig.streamingPath;

		if (!Directory.Exists (streamingPath)) {
			UnityEngine.Debug.LogError (string.Format("[AssetBundle] BuildVersionMap streamingPath({0}) is invalid.", streamingPath));
			return false;
		}

		string fileName = streamingPath + "/" + GameManager.VERSION_MAP;
		if (File.Exists (fileName))
			File.Delete (fileName);

		VersionMap versionMap = new VersionMap ();
		versionMap.ident = bundleConfig.ident;
		versionMap.last_version = bundleConfig.version;
		versionMap.svr_games.Add (new string[]{ "abc", "def", "hij" });
		//versionMap.history = {}

		File.WriteAllText (fileName, JsonUtility.ToJson (versionMap));

		return true;
	}*/


	#endregion
}
