using UnityEngine;
using System;
using System.IO;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Text.RegularExpressions;
using LuaInterface;
using LuaFramework;

#if UNITY_EDITOR
using UnityEditor;
#endif

namespace LuaFramework
{
    public class Util
    {
        private static List<string> luaPaths = new List<string>();

        public static int Int(object o)
        {
            return Convert.ToInt32(o);
        }

        public static float Float(object o)
        {
            return (float)Math.Round(Convert.ToSingle(o), 2);
        }

        public static long Long(object o)
        {
            return Convert.ToInt64(o);
        }

        public static int Random(int min, int max)
        {
            return UnityEngine.Random.Range(min, max);
        }

        public static float Random(float min, float max)
        {
            return UnityEngine.Random.Range(min, max);
        }

        public static string Uid(string uid)
        {
            int position = uid.LastIndexOf('_');
            return uid.Remove(0, position + 1);
        }

        public static long GetTime()
        {
            TimeSpan ts = new TimeSpan(DateTime.UtcNow.Ticks - new DateTime(1970, 1, 1, 0, 0, 0).Ticks);
            return (long)ts.TotalMilliseconds;
        }

        /// <summary>
        /// 搜索子物体组件-GameObject版
        /// </summary>
        public static T Get<T>(GameObject go, string subnode) where T : Component
        {
            if (go != null)
            {
                Transform sub = go.transform.Find(subnode);
                if (sub != null) return sub.GetComponent<T>();
            }
            return null;
        }

        /// <summary>
        /// 搜索子物体组件-Transform版
        /// </summary>
        public static T Get<T>(Transform go, string subnode) where T : Component
        {
            if (go != null)
            {
                Transform sub = go.Find(subnode);
                if (sub != null) return sub.GetComponent<T>();
            }
            return null;
        }

        /// <summary>
        /// 搜索子物体组件-Component版
        /// </summary>
        public static T Get<T>(Component go, string subnode) where T : Component
        {
            return go.transform.Find(subnode).GetComponent<T>();
        }

        /// <summary>
        /// 添加组件
        /// </summary>
        public static T Add<T>(GameObject go) where T : Component
        {
            if (go != null)
            {
                T[] ts = go.GetComponents<T>();
                for (int i = 0; i < ts.Length; i++)
                {
                    if (ts[i] != null) GameObject.Destroy(ts[i]);
                }
                return go.gameObject.AddComponent<T>();
            }
            return null;
        }

        /// <summary>
        /// 添加组件
        /// </summary>
        public static T Add<T>(Transform go) where T : Component
        {
            return Add<T>(go.gameObject);
        }

        /// <summary>
        /// 查找子对象
        /// </summary>
        public static GameObject Child(GameObject go, string subnode)
        {
            return Child(go.transform, subnode);
        }

        /// <summary>
        /// 查找子对象
        /// </summary>
        public static GameObject Child(Transform go, string subnode)
        {
            Transform tran = go.Find(subnode);
            if (tran == null) return null;
            return tran.gameObject;
        }

        /// <summary>
        /// 取平级对象
        /// </summary>
        public static GameObject Peer(GameObject go, string subnode)
        {
            return Peer(go.transform, subnode);
        }

        /// <summary>
        /// 取平级对象
        /// </summary>
        public static GameObject Peer(Transform go, string subnode)
        {
            Transform tran = go.parent.Find(subnode);
            if (tran == null) return null;
            return tran.gameObject;
        }

        /// <summary>
        /// 计算字符串的MD5值
        /// </summary>
        public static string md5(string source)
        {
            MD5CryptoServiceProvider md5 = new MD5CryptoServiceProvider();
            byte[] data = System.Text.Encoding.UTF8.GetBytes(source);
            byte[] md5Data = md5.ComputeHash(data, 0, data.Length);
            md5.Clear();

            string destString = "";
            for (int i = 0; i < md5Data.Length; i++)
            {
                destString += System.Convert.ToString(md5Data[i], 16).PadLeft(2, '0');
            }
            destString = destString.PadLeft(32, '0');
            return destString;
        }

        /// <summary>
        /// 计算文件的MD5值
        /// </summary>
        public static string md5file(string file)
        {
            try
            {
				FileStream fs = new FileStream(file, FileMode.Open);
                System.Security.Cryptography.MD5 md5 = new System.Security.Cryptography.MD5CryptoServiceProvider();
                byte[] retVal = md5.ComputeHash(fs);
                fs.Close();

                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < retVal.Length; i++)
                {
                    sb.Append(retVal[i].ToString("x2"));
                }

                return sb.ToString();
            }
            catch (Exception ex)
            {
                throw new Exception("md5file() fail, error:" + ex.Message);
            }
        }

		public static string HMACSHA1Encrypt(string input, string key)
		{
			HMACSHA1 hmacsha1 = new HMACSHA1 (Encoding.UTF8.GetBytes (key));
			byte[] data = hmacsha1.ComputeHash (Encoding.UTF8.GetBytes (input));
			return Convert.ToBase64String (data);
		}

        /// <summary>
        /// 清除所有子节点
        /// </summary>
        public static void ClearChild(Transform go)
        {
            if (go == null) return;
            for (int i = go.childCount - 1; i >= 0; i--)
            {
                GameObject.Destroy(go.GetChild(i).gameObject);
            }
        }

        /// <summary>
        /// 清理内存
        /// </summary>
        public static void ClearMemory()
        {
            //GC.Collect();
			Resources.UnloadUnusedAssets();
            LuaManager mgr = AppFacade.Instance.GetManager<LuaManager>(ManagerName.Lua);
            if (mgr != null) mgr.LuaGC();
        }

        /// <summary>
        /// 取得数据存放目录
        /// </summary>
        public static string DataPath
        {
            get
            {
                string game = AppConst.AppName.ToLower();
                if (Application.isMobilePlatform)
                {
                    return Application.persistentDataPath + "/" + game + "/";
                }
                if (AppConst.DebugMode)
                {
                    return Application.dataPath + "/" + AppConst.AssetDir + "/";
                }
                if (Application.platform == RuntimePlatform.OSXEditor)
                {
                    int i = Application.dataPath.LastIndexOf('/');
                    return Application.dataPath.Substring(0, i + 1) + game + "/";
                }
                return "c:/" + game + "/";
            }
        }

        public static string GetRelativePath()
        {
            if (Application.isEditor)
            {
                if (AppConst.UpdateMode)
                    return "file:///" + DataPath;
                else
                    return "file://" + System.Environment.CurrentDirectory.Replace("\\", "/") + "/Assets/" + AppConst.AssetDir + "/";
            }
            else if (Application.isMobilePlatform || Application.isConsolePlatform)
            {
                return "file:///" + DataPath;
            }
            else // For standalone player.
            {
                return "file://" + Application.streamingAssetsPath + "/";
            }
        }

        /// <summary>
        /// 取得行文本
        /// </summary>
        public static string GetFileText(string path)
        {
            return File.ReadAllText(path);
        }

        /// <summary>
        /// 网络可用
        /// </summary>
        public static bool NetAvailable
        {
            get
            {
                return Application.internetReachability != NetworkReachability.NotReachable;
            }
        }

        /// <summary>
        /// 是否是无线
        /// </summary>
        public static bool IsWifi
        {
            get
            {
                return Application.internetReachability == NetworkReachability.ReachableViaLocalAreaNetwork;
            }
        }

        /// <summary>
        /// 应用程序内容路径
        /// </summary>
        public static string AppContentPath()
        {
            string path = string.Empty;
            switch (Application.platform)
            {
                case RuntimePlatform.Android:
                    path = "jar:file://" + Application.dataPath + "!/assets/";
                    break;
                case RuntimePlatform.IPhonePlayer:
					path = "file://" + Application.dataPath + "/Raw/";
                    break;
                default:
                    path = Application.dataPath + "/" + AppConst.AssetDir + "/";
                    break;
            }
            return path;
        }

        public static void Log(string str)
        {
            Debug.Log(str);
        }

        public static void LogWarning(string str)
        {
            Debug.LogWarning(str);
        }

        public static void LogError(string str)
        {
            Debug.LogError(str);
        }

        /// <summary>
        /// 防止初学者不按步骤来操作
        /// </summary>
        /// <returns></returns>
        public static int CheckRuntimeFile()
        {
            if (!Application.isEditor) return 0;
            string streamDir = Application.dataPath + "/StreamingAssets/";
            if (!AppConst.UpdateMode)
            {
                if (!Directory.Exists(streamDir))
                {
                    return -1;
                }
                else
                {
                    string[] files = Directory.GetFiles(streamDir);
                    if (files.Length == 0)
                        return -1;

                    if (!File.Exists(streamDir + "udf.txt"))
                        return -1;
                }
            }
            string sourceDir = AppConst.FrameworkRoot + "/ToLua/Source/Generate/";
            if (!Directory.Exists(sourceDir))
            {
                return -2;
            }
            else
            {
                string[] files = Directory.GetFiles(sourceDir);
                if (files.Length == 0)
                    return -2;
            }
            return 0;
        }

        /// <summary>
        /// 执行Lua方法
        /// </summary>
        public static object[] CallMethod(string module, string func, params object[] args)
        {
            LuaManager luaMgr = AppFacade.Instance.GetManager<LuaManager>(ManagerName.Lua);
            if (luaMgr == null) return null;
            return luaMgr.CallFunction(module + "." + func, args);
        }

        /// <summary>
        /// 检查运行环境
        /// </summary>
        public static bool CheckEnvironment()
        {
#if UNITY_EDITOR
            int resultId = Util.CheckRuntimeFile();
            if (resultId == -1)
            {
                Debug.LogError("没有找到框架所需要的资源，单击Game菜单下Build xxx Resource生成！！");
                EditorApplication.isPlaying = false;
                return false;
            }
            else if (resultId == -2)
            {
                Debug.LogError("没有找到Wrap脚本缓存，单击Lua菜单下Gen Lua Wrap Files生成脚本！！");
                EditorApplication.isPlaying = false;
                return false;
            }
            if (Application.loadedLevelName == "Test" && !AppConst.DebugMode)
            {
                Debug.LogError("测试场景，必须打开调试模式，AppConst.DebugMode = true！！");
                EditorApplication.isPlaying = false;
                return false;
            }
#endif
            return true;
        }

        [NoToLua]
        /// <summary>
        /// 字节数组转16进制字符串
        /// </summary>
        /// <param name="bytes"></param>
        /// <returns></returns>
        public static string byteToHexStr(byte[] bytes)
        {
            DateTime dt = DateTime.Now;
            // Debug.LogFormat("<color=pink>字节数组转AAA :{0}:{1}</color>",
            //                     dt.ToLongTimeString().ToString(),
            //                     dt.Millisecond.ToString());

            StringBuilder str = new StringBuilder();
            string returnStr = "";
            if (bytes != null)
            {
                for (int i = 0; i < bytes.Length; i++)
                {
                    str.Append(bytes[i].ToString("X2"));
                }
            }
            returnStr = str.ToString();
            dt = DateTime.Now;
            // Debug.LogFormat("<color=pink>字节数组转BBB :{0}:{1}</color>",
            //                     dt.ToLongTimeString().ToString(),
            //                     dt.Millisecond.ToString());
            return returnStr;
        }

        public static string[] getDeviceInfo()
        {
            string[] array = new string[3];
            array[0] = SystemInfo.deviceUniqueIdentifier;
            array[1] = SystemInfo.operatingSystem;
			array[2] = SystemInfo.deviceModel;

            return array;
        }

		public static void CopyFile(string srcFile, string dstFile) {
			string dir = Path.GetDirectoryName (dstFile);
			if (!Directory.Exists (dir))
				Directory.CreateDirectory (dir);
			File.Copy (srcFile, dstFile, true);
		}

        public static void MoveFile(string srcFile, string dstFile)
        {
            string dir = Path.GetDirectoryName(dstFile);
            if (!Directory.Exists(dir))
                Directory.CreateDirectory(dir);
            File.Move(srcFile, dstFile);
        }

		private static string FormatDir(string dir) {
			string newDir = dir.Replace ('\\', '/');
			if (!newDir.EndsWith ("/"))
				newDir += "/";
			return newDir;
		}

		public static void CopyDir(string srcDir, string dstDir) {
			if (!Directory.Exists (srcDir))
				return;
			srcDir = FormatDir (srcDir);
			dstDir = FormatDir (dstDir);
			string srcFile = string.Empty, dstFile = string.Empty;
			string[] files = Directory.GetFiles (srcDir, "*.*", SearchOption.AllDirectories);
			foreach (string file in files) {
				if (file.EndsWith (".meta"))
					continue;
				srcFile = file.Replace ('\\', '/');
				dstFile = dstDir + srcFile.Substring (srcDir.Length);
				CopyFile (srcFile, dstFile);
			}
		}

		public static void ClearPluginDir(string rootDir, string tagName, string channel) {
			string pluginDir = "/Plugins/" + tagName + "/";
			string srcDir = rootDir + "Channel/" + channel + pluginDir;
			string dstDir = Application.dataPath + pluginDir;
			if (!Directory.Exists (srcDir))
				return;

			string srcFile = string.Empty, dstFile = string.Empty;
			string[] files = Directory.GetFiles (srcDir, "*.*", SearchOption.AllDirectories);
			foreach (string file in files) {
				srcFile = file.Replace ('\\', '/');
				dstFile = dstDir + srcFile.Substring (srcDir.Length);
				File.Delete (dstFile);
			}
		}

		public class JsonHelper {
			//Usage:
			//YouObject[] objects = JsonHelper.getJsonArray<YouObject> (jsonString);
			public static T[] FromJson<T>(string json)
			{
				string newJson = "{ \"array\": " + json + "}";
				Wrapper<T> wrapper = JsonUtility.FromJson<Wrapper<T>> (newJson);
				return wrapper.array;
			}
			//Usage:
			//string jsonString = JsonHelper.arrayToJson<YouObject>(objects);
			public static string ToJson<T>(T[] array)
			{
				Wrapper<T> wrapper = new Wrapper<T> { array = array };
				string json = JsonUtility.ToJson(wrapper, true);
				var pos = json.IndexOf(":");
				json = json.Substring(pos+1); // cut away "{ \"array\":"
				pos = json.LastIndexOf('}');
				json = json.Substring(0, pos-1); // cut away "}" at the end
				return json;
			}

			public static bool LoadJson<T>(string fileName, out T t) {
				t = default(T);
				try {
					if(!File.Exists(fileName))
						return false;
					string txt = File.ReadAllText(fileName);
					if(string.IsNullOrEmpty(txt)) {
						Debug.LogWarning (string.Format ("[JSON] LoadJson failed. ReadFile({0}) is empty.", fileName));
						return false;
					}
					t = JsonUtility.FromJson<T>(txt);
					return true;
				} catch(Exception e) {
					Debug.LogError (string.Format ("[JSON] LoadJson failed. ReadFile({0}) message({1}).", fileName, e.Message));
					return false;
				}
			}

			[Serializable]
			private class Wrapper<T>
			{
				public T[] array;
			}
		}

    }
}