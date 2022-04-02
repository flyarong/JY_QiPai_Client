using UnityEngine;
using UnityEngine.SceneManagement;
using System.Collections;
using System.Collections.Generic;
using System;
using System.IO;
using System.Text;
using UObject = UnityEngine.Object;
using LuaInterface;
using SG;
using System.Text.RegularExpressions;
using System.Linq;

#if UNITY_EDITOR
using UnityEditor;
#endif

//资源加载分为两种：同步(Sync)、异步(Async)，函数名通过后缀区分

namespace LuaFramework
{
    public enum AssetLife
    {
        AL_TEMP = 0,	//不缓存
        AL_RESIDENT,	//常驻
        AL_SWITCH		//切换场景时关闭
    };

    public class AssetUnit
    {
        public AssetLife lifeType = AssetLife.AL_SWITCH;
        public UnityEngine.Object templete = null;
        public AssetUnit(AssetLife lifeType)
        {
            this.lifeType = lifeType;
        }
    };
	public class AssetBundleInfo
	{
		public AssetBundle m_AssetBundle;
		public int m_ReferencedCount;

		public AssetBundleInfo(AssetBundle assetBundle)
		{
			m_AssetBundle = assetBundle;
			m_ReferencedCount = 1;
		}
	}


	public class ResourceManager : Manager
    {
		private const string LOCAL = "abs/";
		public const string ASSET_TO_BUNDLE = "atb.txt";
		public const string NAME_TO_ASSET = "NTA";
		public const string SCENE_LUA_BUNDLE_NAME = "_lua.unity3d";

		private string[] BASIC_DIR = new string[] {"common", "framework", "sproto", "commonprefab"};

		[Serializable]
		public class AssetUnitConfig
		{
			public string assetName;
			public bool isRegex;
			public int lifeType;
		};
		[Serializable]
		public class AssetTableConfig
		{
			public List<string> preload = new List<string> ();
			public List<AssetUnitConfig> assetConfig = new List<AssetUnitConfig>();
		};

		private string m_BaseDownloadingURL = "";

		private AssetBundleManifest	m_Manifest;
		private string[] m_Variants = {};
	
		private Dictionary<string, AssetBundleInfo> m_LoadedBundles = new Dictionary<string, AssetBundleInfo>();

		private Dictionary<string, string[]> m_Dependencies = new Dictionary<string, string[]>();
		private Dictionary<string, string> m_AssetToBundles = new Dictionary<string, string>();
		private Dictionary<string, string> m_NameToAssets = new Dictionary<string, string>();

		//Asset Catch
		private List<string> m_PreloadAssetList = new List<string> ();
		private Dictionary<string, AssetUnit> m_AssetTable = new Dictionary<string, AssetUnit> ();
		private Dictionary<string, KeyValuePair<int, Regex>> m_RegexList = new Dictionary<string, KeyValuePair<int, Regex>>();


		//debug
		Dictionary<string, int> m_TraceObject = new Dictionary<string, int>();

#if UNITY_EDITOR

		public bool UseAssetBundle()
		{
			return AppConst.LuaBundleMode;
		}

#else

		public bool UseAssetBundle() {
			return true;
		}

#endif
		public string DataPath
		{
			get { return Util.DataPath + LOCAL; }
		}
		static public string StreamingDataPath()
		{
			string path = string.Empty;
			switch (Application.platform)
			{
				case RuntimePlatform.Android:
					path = "jar:file://" + Application.dataPath + "!/assets/";
					break;
				case RuntimePlatform.IPhonePlayer:
					path = Application.dataPath + "/Raw/";
					break;
				default:
					path = Application.dataPath + "/" + AppConst.AssetDir + "/";
					break;
			}
			return path;
		}

		private bool CheckMatchRegex(string value, out int lifeType)
        {
			lifeType = 0;
			foreach (var it in m_RegexList)
            {
				if (it.Value.Value.IsMatch(value))
                {
					lifeType = it.Value.Key;
					return true;
				}
            }
			return false;
        }

		public bool FindAssetPath(string assetName, out string assetPath)
		{
			assetPath = string.Empty;

			if (UseAssetBundle())
				return false;

			return m_NameToAssets.TryGetValue(assetName.ToLower(), out assetPath);
		}

		public bool FindAssetBundle(string assetName, out string bundleName)
		{
			bundleName = string.Empty;
			if (!UseAssetBundle())
				return false;

			return m_AssetToBundles.TryGetValue(assetName.ToLower(), out bundleName);
		}

		private bool ReadAssetTable(string sceneName) {
			m_PreloadAssetList.Clear ();

			string assetTableName = Path.GetFileNameWithoutExtension (sceneName) + "_AT.json";
			TextAsset ta = LoadAssetSync<TextAsset> (assetTableName);
			if (ta == null)
				return false;
			
			AssetTableConfig tableConfig = JsonUtility.FromJson<AssetTableConfig> (ta.text);
			if (tableConfig == null) {
				Debug.LogError(string.Format("[AssetBundle] ReadAssetTable({0}) failed. Parse failed.", assetTableName));
				return false;
			}

			AssetUnit assetUnit;
			KeyValuePair<int, Regex> regexUnit;
			AssetUnitConfig assetUnitCfg;
			for (int idx = 0; idx < tableConfig.assetConfig.Count; ++idx) {
				assetUnitCfg = tableConfig.assetConfig [idx];
				if (assetUnitCfg.lifeType == (int)AssetLife.AL_TEMP) continue;

				if(assetUnitCfg.isRegex)
                {
					if(m_RegexList.TryGetValue(assetUnitCfg.assetName, out regexUnit))
                    {
						if(regexUnit.Key != (int)assetUnitCfg.lifeType)
							Debug.LogError(string.Format("[AssetBundle] ReadAssetTable({0}) exception: asset({1}) lifeType({2} : {3}) conflict.",
								assetTableName, assetUnitCfg.assetName, assetUnitCfg.lifeType, regexUnit.Key));
					}
					else
						m_RegexList.Add(assetUnitCfg.assetName, new KeyValuePair<int, Regex>((int)assetUnitCfg.lifeType, new Regex(assetUnitCfg.assetName)));
                }
				else
                {
					if (m_AssetTable.TryGetValue(assetUnitCfg.assetName, out assetUnit))
                    {
						if((int)assetUnit.lifeType != (int)assetUnitCfg.lifeType)
                        {
							Debug.LogError(string.Format("[AssetBundle] ReadAssetTable({0}) exception: asset({1}) lifeType({2} : {3}) conflict.",
								assetTableName, assetUnitCfg.assetName, assetUnitCfg.lifeType, assetUnit.lifeType));
						}
					}
					else
						m_AssetTable.Add(assetUnitCfg.assetName, new AssetUnit((AssetLife)assetUnitCfg.lifeType));
				}
			}

			string assetName = string.Empty;
			for (int idx = 0; idx < tableConfig.preload.Count; ++idx)
				m_PreloadAssetList.Add(tableConfig.preload[idx]);

			return true;
		}

		public bool IsBasicDir(string dirName) {
			for (int idx = 0; idx < BASIC_DIR.Length; ++idx) {
				if (string.Compare (BASIC_DIR [idx], dirName, true) == 0)
					return true;
			}
			return false;
		}

		private bool IsDependFormat(string value) {
			return value.StartsWith ("normal_") && value.EndsWith ("_common");
		}

		private int FindDependLuaBundles(string sceneIdent, ref List<string> list) {
			string udfFileName = DataPath + sceneIdent + "/" + GameManager.UDF_FILE;
			if (!File.Exists (udfFileName))
				return 0;
			
			UDF localUDF = GameManager.LoadUDF (udfFileName);
			if (localUDF == null)
				return 0;
			
			string dirName, fileName;
			List<string> fileList = new List<string> ();
			for (int idx = 0; idx < localUDF.dirList.Count; ++idx) {
				dirName = localUDF.dirList [idx];
				if (IsBasicDir (dirName))
					continue;

				if (!IsDependFormat (dirName))
					continue;
				
				fileName = dirName + "/" + dirName + SCENE_LUA_BUNDLE_NAME;
				fileName = fileName.Replace ('\\', '/');

				list.Add (fileName);
			}
			return list.Count;
		}

		private string FindDependLuaBundle(string sceneIdent) {
			string udfFileName = DataPath + sceneIdent + "/" + GameManager.UDF_FILE;
			if (!File.Exists (udfFileName)) {
				return string.Empty;
			}

			UDF localUDF = GameManager.LoadUDF (udfFileName);
			if (localUDF == null) {
				return string.Empty;
			}
			
			string dirName, fileName;
			List<string> fileList = new List<string> ();
			for (int idx = 0; idx < localUDF.dirList.Count; ++idx) {
				dirName = localUDF.dirList [idx];
				if (IsBasicDir (dirName))
					continue;

				if (!IsDependFormat (dirName))
					continue;

				fileName = dirName + "/" + dirName + SCENE_LUA_BUNDLE_NAME;
				fileName = fileName.Replace ('\\', '/');

				return fileName;
			}
			return string.Empty;
		}

		public void LoadSceneLuaBundle(string sceneName) {
			if (!UseAssetBundle ())
				return;
			string sceneIdent = Path.GetFileNameWithoutExtension (sceneName).ToLower();
			//find depend bundle
			List<string> dependLuas = new List<string>();
			if (FindDependLuaBundles (sceneIdent, ref dependLuas) > 0) {
				foreach(string it in dependLuas)
					LuaManager.RegisterBundle (it);
			}

			//scene lua bundle
			string luaBundleFile = sceneIdent + "/" + sceneIdent + SCENE_LUA_BUNDLE_NAME;
			LuaManager.RegisterBundle (luaBundleFile);
		}

		public void AddToAssetTable(string assetName, AssetLife lifeType) {
			AssetUnit assetUnit = null;

			if (m_AssetTable.TryGetValue (assetName, out assetUnit)) {
				assetUnit.lifeType = lifeType;
			} else {
				assetUnit = new AssetUnit (lifeType);
				m_AssetTable.Add (assetName, assetUnit);
			}

			if (assetUnit.templete == null)
				assetUnit.templete = LoadAssetSync<UnityEngine.Object> (assetName);
		}

		public bool GetAssetTable(ref List<string> preloadList, ref Dictionary<string, AssetUnit> catchTable) {
			preloadList = m_PreloadAssetList;
			catchTable = m_AssetTable;
			return preloadList.Count > 0 || catchTable.Count > 0;
		}
        public string[] GetAssetTableList()
        {
            return m_PreloadAssetList.ToArray();
        }
        public Dictionary<string, AssetUnit> GetAssetTableDict()
        {
            return m_AssetTable;
        }
        public int GetAssetTableDictLifeType(AssetUnit data)
        {
            return (int)data.lifeType;
        }
        public GameObject GetAssetTableDictTemplete(AssetUnit data)
        {
            return (GameObject)data.templete;
        }
        public void DestroyAssetObject(string objKey)
        {
			//Debug.Log ("[AssetBundle] DestroyAssetObject:" + objKey);
			AssetUnit assetUnit;
			if (m_AssetTable.TryGetValue (objKey, out assetUnit)) {
				assetUnit.templete = null;
				m_AssetTable.Remove (objKey);
			}
        }

        public void Awake() {
			Initialize ();
		}

		public void Initialize()
		{
			if(!Directory.Exists(DataPath))
				Directory.CreateDirectory (DataPath);

			int i = 2;
			int index = 0;
			do {
				byte v = 0;
				for(int j = 2; j < i; ++j) {
					if((i % j) == 0) {
						v = 1;
						break;
					}
				}
				if(v == 0) {
					xtea_key[index++] = (byte)(i ^ AppConst.PubXTEA);
					if(index >= 16)
						break;
				}
				++i;
			} while(true);

			SceneManager.sceneLoaded += (scene, mode) => {
				if(m_LoadSceneCallback != null)
					m_LoadSceneCallback.Call(scene.name);
			};
		}

		public void SetupManifest() {
			string[] item = { };
			string[] lines = { };

			if (!UseAssetBundle ()) {

				string ntaFile = Application.dataPath + "/" + NAME_TO_ASSET + ".txt";
				if (!File.Exists (ntaFile)) {
					Debug.LogError ("[AssetBundle] Runing in AssetMode, Press F6 to generate filemap Please");
					return;
				}

				m_NameToAssets.Clear ();
				lines = File.ReadAllLines (ntaFile);
				for (int idx = 0; idx < lines.Length; ++idx) {
						item = lines[idx].Split('|');
						if(item.Length != 2) {
							Debug.LogError ("[AssetBundle] Runing in AssetMode, generate filemap exception: " + lines[idx]);
							continue;
						}
						m_NameToAssets.Add(item[0], item[1]);
				}

				#if UNITY_EDITOR
				Debug.Log("<color=red>XXXXXXXXXXXXXXXXX当前渠道=" + AppDefine.CurQuDao + " 资源路径=" + AppDefine.CurResPath + "</color>");
				if (AppDefine.CurResPath != "main")
				{
					ntaFile = Application.dataPath + "/" + NAME_TO_ASSET + "_" + AppDefine.CurResPath + ".txt";
					if (File.Exists (ntaFile))
					{
						lines = File.ReadAllLines (ntaFile);
						for (int idx = 0; idx < lines.Length; ++idx) {
								item = lines[idx].Split('|');
								if(item.Length != 2) {
									Debug.LogError ("[AssetBundle] Runing in AssetMode, generate filemap exception: " + lines[idx]);
									continue;
								}
								m_NameToAssets[item[0]] = item[1];
						}					
					}
				}
				#endif

				return;
			}
			
			string fileName = DataPath + AppConst.AssetDir;
			//AssetBundle assetBundle = ReadBundle (fileName);
			AssetBundle assetBundle = AssetBundle.LoadFromFile(fileName);
			if (assetBundle == null) {
				Debug.LogError (string.Format ("[AssetBundle] SetupManifest failed: ReadBundle({0}) failed.", fileName));
				return;
			}
			m_Manifest = assetBundle.LoadAsset<AssetBundleManifest> ("AssetBundleManifest");
			assetBundle.Unload (false);

			if (m_Manifest == null)
				Debug.LogError ("[AssetBundle] SetupManifest failed: LoadAsset manifest is null.");

			fileName = DataPath + ASSET_TO_BUNDLE;
			if (!File.Exists (fileName)) {
				Debug.LogError ("[AssetBundle] SetupManifest failed: ATB file invalid.");
				return;
			}

			//Asset To Bundle Map
			m_AssetToBundles.Clear ();

			lines = File.ReadAllLines(fileName);
			foreach (var line in lines)
			{
				item = line.Split('|');
				m_AssetToBundles.Add (item [0], item [1]);
			}
		}


		public string FormatSceneName(string sceneName)
		{
			if (!sceneName.EndsWith(".unity"))
				sceneName += ".unity";
			if (UseAssetBundle())
				return "Assets/Game/" + Path.GetFileNameWithoutExtension(sceneName) + "/" + sceneName;
			else
			{
				string fileName = string.Empty;
				if (FindAssetPath(sceneName.ToLower(), out fileName))
					return fileName;
				else
					Debug.LogError(string.Format("[AssetBundle] FormatSceneName({0}) failed. press F6 to generate file map", sceneName));
				return sceneName;
			}
		}

		private LuaFunction m_LoadSceneCallback;
		public void LoadSceneAsync(string sceneName, LuaFunction luaFunc)
        {
			PrintTraceCreateObject(true);

			m_LoadSceneCallback = luaFunc;

			if (!Path.HasExtension(sceneName))
                sceneName += ".unity";

            ReadAssetTable(sceneName);

#if UNITY_EDITOR

			if (!UseAssetBundle())
            {
                SceneManager.LoadScene(FormatSceneName(sceneName), LoadSceneMode.Single);
                return;
            }

#endif

            string bundleName = string.Empty;
			if(!FindAssetBundle(sceneName.ToLower(), out bundleName))
            {
                Debug.LogError(string.Format("[AssetBundle] LoadSceneAsync({0}) failed. AssetToBundles can't find.", sceneName));
                return;
            }

            StartCoroutine(LoadBundleAsync(bundleName, true, (AssetBundle assetBundle) =>
            {
				SceneManager.LoadScene(FormatSceneName(sceneName), LoadSceneMode.Single);
			}));
        }

		//interface
		public void LoadSceneSync(string sceneName, LuaFunction luaFunc) {
			PrintTraceCreateObject(true);

			m_LoadSceneCallback = luaFunc;

			if (!Path.HasExtension (sceneName))
				sceneName += ".unity";

			ReadAssetTable (sceneName);

#if UNITY_EDITOR

			if (!UseAssetBundle()) {
				SceneManager.LoadScene(FormatSceneName(sceneName), LoadSceneMode.Single);
				return;
			}

			#endif

			string bundleName = string.Empty;
			if (!FindAssetBundle(sceneName.ToLower(), out bundleName)) {
				Debug.LogError (string.Format("[AssetBundle] LoadScene({0}) failed. AssetToBundles can't find.", sceneName));
				return;
			}

			AssetBundle assetBundle = LoadBundleSync(bundleName, true);
			if(assetBundle == null)
            {
				Debug.LogError(string.Format("[AssetBundle] LoadScene({0}) failed. LoadBundle({1}) failed.", sceneName, bundleName));
				return;
            }

			SceneManager.LoadScene(FormatSceneName(sceneName), LoadSceneMode.Single);
		}

		public void CaptureScreen(LuaFunction callback)
        {
			StartCoroutine(CaptureScreenInternal(callback));
        }
		private IEnumerator CaptureScreenInternal(LuaFunction callback)
		{
			yield return new WaitForEndOfFrame();

			Rect rect = new Rect(0, 0, Screen.width, Screen.height);
			Texture2D cs = new Texture2D(Screen.width, Screen.height, TextureFormat.RGB24, false);
			cs.ReadPixels(rect, 0, 0);
			cs.Apply();
			callback.Call((object)cs);
		}

		/// <summary>
		/// 场景加载完成
		/// </summary>
		public void LoadSceneFinish(string sceneName)
        {
			Util.ClearMemory ();
			
            if (!UseAssetBundle())
                return;

            if (!Path.HasExtension(sceneName))
                sceneName += ".unity";
            
			string bundleName = string.Empty;
            if (!FindAssetBundle(sceneName.ToLower(), out bundleName))
            {
                Debug.LogError(string.Format("[AssetBundle] LoadSceneAsync({0}) failed. AssetToBundles can't find.", sceneName));
                return;
            }

            UnloadBundle(bundleName);
        }


		//这里通过回调函数区分同步还是异步:同步方式回调函数都必须为null

		public T LoadAsset<T> (string assetName, Action<T> sharpFunc, LuaFunction luaFunc) where T : UObject {
			//Debug.LogWarning("Debug Load:" + assetName);
			if (sharpFunc == null && luaFunc == null)
				return LoadAssetSync<T> (assetName);
			else
				StartCoroutine (LoadAssetAsync<T> (assetName, sharpFunc, luaFunc));
			
			return null;
		}

		AssetUnit MatchAssetUnit(string key)
        {
			AssetUnit assetUnit;
			if (!m_AssetTable.TryGetValue(key, out assetUnit))
			{
				int lifeType = 0;
				if (CheckMatchRegex(key, out lifeType))
				{
					assetUnit = new AssetUnit((AssetLife)lifeType);
					m_AssetTable.Add(key, assetUnit);
				}
			}

			return assetUnit;
		}

		#region Async

		public IEnumerator LoadAssetAsync<T> (string assetName, Action<T> sharpFunc, LuaFunction luaFunc) where T : UObject
		{
			TraceCreateObject(assetName);

			if (string.IsNullOrEmpty (assetName)) {
				Debug.LogError (string.Format ("[AssetBundle] LoadAssetAsync({0}) failed: bundleName or assetName is invalid.", assetName));
				yield break;
			}

			string assetTableKey = Path.GetFileName (assetName);
			AssetUnit assetUnit = MatchAssetUnit(assetTableKey);
			if (assetUnit != null && assetUnit.templete != null)
			{
				//callback
				if (sharpFunc != null)
					sharpFunc.Invoke((T)assetUnit.templete);
				if (luaFunc != null)
				{
					luaFunc.Call((object)assetUnit.templete);
					luaFunc.Dispose();
				}
				yield break;
			}

			T go = null;

			#if UNITY_EDITOR

			if(!UseAssetBundle()) {
				string fileName = string.Empty;
				if (FindAssetPath(assetName.ToLower(), out fileName))
					assetName = fileName;
				else
					Debug.LogError (string.Format("[AssetBundle] LoadAssetAsync({0}) failed. press F6 to generate file map", assetName));
				
				go = (T)(AssetDatabase.LoadAssetAtPath<T>(assetName));
				if(go == null) {
					Debug.LogError (string.Format ("[AssetBundle] LoadAssetAsync({0}) failed: LoadAssetAtPath failed.", assetName));
				} else {
					if(assetUnit != null) {
						assetUnit.templete = go;
						m_AssetTable[assetTableKey] = assetUnit;
					}
						
					//callback
					if(sharpFunc != null)
						sharpFunc.Invoke(go);
					if(luaFunc != null) {
						luaFunc.Call((object)go);
						luaFunc.Dispose();
					}
				}

				yield break;
			}

			#endif

			string bundleName = string.Empty;
			if (!FindAssetBundle(assetName.ToLower(), out bundleName)) {
				Debug.LogWarning (string.Format("[AssetBundle] LoadAssetAsync({0}) failed. AssetToBundles can't find.", assetName));
				yield break;
			}

			AssetBundle assetBundle = null;

			yield return LoadBundleAsync (bundleName, true, (AssetBundle loadAssetBundle) => {
				assetBundle = loadAssetBundle;
			});

			while (assetBundle == null)
            {
				Debug.LogError(string.Format("[AssetBundle] LoadAssetAsync({0}) failed. assetBundle({1}) is null.", assetName, bundleName));
				yield break;
			}

			//T go = assetBundle.LoadAsset<T>(assetName);
			AssetBundleRequest request = assetBundle.LoadAssetAsync<T>(assetName);
			yield return request;

			go = (T)request.asset;
			if(go == null) {
				Debug.LogError (string.Format ("[AssetBundle] LoadAssetAsync({0}) failed: LoadBundleAsync({1})'s LoadAsset failed.", assetName, bundleName));
				yield break;
			}

			if(assetUnit != null) {
				assetUnit.templete = go;
				m_AssetTable[assetTableKey] = assetUnit;
			}

			if(sharpFunc != null)
				sharpFunc.Invoke(go);
			if(luaFunc != null) {
				luaFunc.Call((object)go);
				luaFunc.Dispose();
			}

			if (assetUnit == null)
				UnloadBundle(bundleName);
		}

		private IEnumerator LoadDependenciesAsync(string bundleName, Action<AssetBundle> callback) {
			if (m_Manifest == null) {
				Debug.LogError (string.Format ("[AssetBundle] LoadDependenciesAsync({0}) failed: ManifestFile is null.", bundleName));
				yield break;
			}

			string[] bundleDependencies = null;
			if(!m_Dependencies.TryGetValue(bundleName, out bundleDependencies)) {
				bundleDependencies = m_Manifest.GetAllDependencies (bundleName);
				for (int idx = 0; idx < bundleDependencies.Length; ++idx)
					bundleDependencies [idx] = RemapVariantName (bundleDependencies [idx]);
				m_Dependencies.Add (bundleName, bundleDependencies);
			}

			for (int idx = 0; idx < bundleDependencies.Length; ++idx)
				yield return LoadBundleAsync(bundleDependencies [idx], false, callback);
		}

		private IEnumerator LoadBundleAsync(string bundleName, bool loadDependencies, Action<AssetBundle> callback)
		{
			if(!Path.HasExtension(bundleName))
				bundleName += AppConst.ExtName;

			bundleName = bundleName.ToLower ();
	
			if (loadDependencies)
				yield return LoadDependenciesAsync (bundleName, null);

			AssetBundleInfo assetBundleInfo = null;
			if(m_LoadedBundles.TryGetValue(bundleName, out assetBundleInfo)) {
				++assetBundleInfo.m_ReferencedCount;
			} else {
				string fileName = DataPath + bundleName;
				AssetBundle assetBundle = ReadBundle (fileName);
				if (assetBundle == null) {
					Debug.LogError (string.Format ("[AssetBundle] LoadBundleAsync({0}) failed: ReadBundle({1}) failed.", bundleName, fileName));
					yield break;
				} else {
					assetBundleInfo = new AssetBundleInfo (assetBundle);
					m_LoadedBundles.Add (bundleName, assetBundleInfo);
				}
			}
			if (callback != null)
				callback.Invoke (assetBundleInfo.m_AssetBundle);
		}

		#endregion Async

		#region Sync
	
		private T LoadAssetSync<T> (string assetName) where T : UObject
		{
			TraceCreateObject(assetName);
			
			if (string.IsNullOrEmpty (assetName)) {
				Debug.LogError (string.Format ("[AssetBundle] LoadAssetSync({0}) failed: bundleName or assetName is invalid.", assetName));
				return null;
			}

			string assetTableKey = Path.GetFileName(assetName);
			AssetUnit assetUnit = MatchAssetUnit(assetTableKey);
			if (assetUnit != null && assetUnit.templete != null)
				return (T)assetUnit.templete;

			T go = null;

			#if UNITY_EDITOR

			if(!UseAssetBundle()) {
				string fileName = string.Empty;
				if (FindAssetPath(assetName.ToLower(), out fileName))
					assetName = fileName;
				else
					Debug.LogError (string.Format("[AssetBundle] LoadAssetSync({0}) failed. press F6 to generate file map", assetName));
				
				go = (T)(AssetDatabase.LoadAssetAtPath<T>(assetName));
				if(go == null)
					Debug.LogError (string.Format ("[AssetBundle] LoadAssetSync({0}) failed: LoadAssetAtPath failed.", assetName));
				else {
					if(assetUnit != null) {
						assetUnit.templete = go;
						m_AssetTable[assetTableKey] = assetUnit;
					}
				}
				return go;
			}

			#endif

			string bundleName = string.Empty;
			if (!FindAssetBundle(assetName.ToLower(), out bundleName)) {
				Debug.LogWarning (string.Format("[AssetBundle] LoadAssetSync({0}) failed. AssetToBundles can't find.", assetName));
				return null;
			}

			AssetBundle assetBundle = LoadBundleSync (bundleName, true);
			if (assetBundle == null) {
				Debug.LogError (string.Format ("[AssetBundle] LoadAssetSync({0}) failed: LoadBundleSync({1}) failed.", assetName, bundleName));
				return null;
			}

			go = assetBundle.LoadAsset<T> (assetName);
			if (go == null)
				Debug.LogError (string.Format ("[AssetBundle] LoadAssetSync({0}) failed: LoadBundleSync({1})'s LoadAsset failed.", assetName, bundleName));
			else {
				if(assetUnit != null) {
					assetUnit.templete = go;
					m_AssetTable[assetTableKey] = assetUnit;
				}
			}

			if(assetUnit == null)
				UnloadBundle(bundleName);

			return go;
		}

		private void LoadDependenciesSync(string bundleName) {
			if (m_Manifest == null) {
				Debug.LogError (string.Format ("[AssetBundle] LoadDependenciesSync({0}) failed: ManifestFile is null.", bundleName));
				return;
			}

			string[] bundleDependencies = null;
			if(!m_Dependencies.TryGetValue(bundleName, out bundleDependencies)) {
				bundleDependencies = m_Manifest.GetAllDependencies (bundleName);
				for (int idx = 0; idx < bundleDependencies.Length; ++idx)
					bundleDependencies [idx] = RemapVariantName (bundleDependencies [idx]);
				m_Dependencies.Add (bundleName, bundleDependencies);
			}

			for (int idx = 0; idx < bundleDependencies.Length; ++idx)
				LoadBundleSync(bundleDependencies [idx], false);
		}

		public AssetBundle LoadBundleSync(string bundleName, bool loadDependencies)
		{
			if(!Path.HasExtension(bundleName))
				bundleName += AppConst.ExtName;

			bundleName = bundleName.ToLower ();
			
			if (loadDependencies)
				LoadDependenciesSync (bundleName);

			AssetBundleInfo assetBundleInfo = null;
			if(m_LoadedBundles.TryGetValue(bundleName, out assetBundleInfo)) {
				++assetBundleInfo.m_ReferencedCount;
			} else {
				string fileName = DataPath + bundleName;
				AssetBundle assetBundle = ReadBundle (fileName);
				if (assetBundle == null) {
					Debug.LogError (string.Format ("[AssetBundle] LoadBundle({0}) failed: ReadBundle({1}) failed.", bundleName, fileName));
					return null;
				} else {
					assetBundleInfo = new AssetBundleInfo (assetBundle);
					m_LoadedBundles.Add (bundleName, assetBundleInfo);
				}
			}

			return assetBundleInfo.m_AssetBundle;
		}

		public AssetBundle ReloadBundle(string bundleName, bool loadDependencies) {
			if(!Path.HasExtension(bundleName))
				bundleName += AppConst.ExtName;

			bundleName = bundleName.ToLower ();

			if (loadDependencies)
				LoadDependenciesSync (bundleName);

			AssetBundleInfo assetBundleInfo = null;
			if (m_LoadedBundles.TryGetValue (bundleName, out assetBundleInfo)) {
				m_LoadedBundles.Remove (bundleName);
				assetBundleInfo.m_AssetBundle.Unload (false);
				assetBundleInfo.m_AssetBundle = null;

				//Debug.LogError ("[UPDATE] ReloadBundle: " + bundleName);
			}

			string fileName = DataPath + bundleName;
			AssetBundle assetBundle = ReadBundle (fileName);
			if (assetBundle == null) {
				Debug.LogError (string.Format ("[AssetBundle] ReloadBundle({0}) failed: ReadBundle({1}) failed.", bundleName, fileName));
				return null;
			} else {
				assetBundleInfo = new AssetBundleInfo (assetBundle);
				m_LoadedBundles.Add (bundleName, assetBundleInfo);
			}

			return assetBundleInfo.m_AssetBundle;
		}

		#endregion Sync

		private IEnumerator UnloadBundleCoroutine(string bundleName) {
			yield return null;

			AssetBundleInfo assetBundleInfo = null;
			if (m_LoadedBundles.TryGetValue (bundleName, out assetBundleInfo)) {
				//if (--assetBundleInfo.m_ReferencedCount <= 0) {
				//	m_LoadedBundles.Remove (bundleName);
				//	assetBundleInfo.m_AssetBundle.Unload (false);
				//}
				--assetBundleInfo.m_ReferencedCount;
			}

			string[] bundleDependencies = null;
			if (m_Dependencies.TryGetValue (bundleName, out bundleDependencies)) {
				for (int idx = 0; idx < bundleDependencies.Length; ++idx) {
					if (m_LoadedBundles.TryGetValue (bundleDependencies[idx], out assetBundleInfo)) {
						//if (--assetBundleInfo.m_ReferencedCount <= 0) {
						//	m_LoadedBundles.Remove (bundleDependencies[idx]);
						//	assetBundleInfo.m_AssetBundle.Unload (false);
						//}
						--assetBundleInfo.m_ReferencedCount;
					}
				}
			}
		}

		private void UnloadBundle(string bundleName) {
			if (!Path.HasExtension(bundleName))
				bundleName += AppConst.ExtName;

			if (!m_LoadedBundles.ContainsKey (bundleName))
				return;

			StartCoroutine (UnloadBundleCoroutine (bundleName));
		}

		public void TryUnloadAllBundles(bool onlyUnref)
        {
			if (!UseAssetBundle())
				return;

			if (onlyUnref)
            {
				List<string> removeList = new List<string>();
				foreach(var it in m_LoadedBundles)
                {
					if (it.Value.m_ReferencedCount <= 0)
                    {
						if(it.Value.m_AssetBundle)
							it.Value.m_AssetBundle.Unload(false);
						removeList.Add(it.Key);
					}
                }

				for (int idx = 0; idx < removeList.Count; ++idx)
					m_LoadedBundles.Remove(removeList[idx]);

				Debug.Log("TryUnloadAllBundles free bundle:" + removeList.Count);
            }
			else
            {
				foreach (var it in m_LoadedBundles)
                {
					if (it.Value.m_AssetBundle)
						it.Value.m_AssetBundle.Unload(false);
				}
				m_LoadedBundles.Clear();
			}
		}

		// Remaps the asset bundle name to the best fitting asset bundle variant.
		private string RemapVariantName(string bundleName)
		{
			string[] bundlesWithVariant = m_Manifest.GetAllAssetBundlesWithVariant();

			// If the asset bundle doesn't have variant, simply return.
			if (System.Array.IndexOf(bundlesWithVariant, bundleName) < 0)
				return bundleName;

			string[] split = bundleName.Split('.');

			int bestFit = int.MaxValue;
			int bestFitIndex = -1;
			// Loop all the assetBundles with variant to find the best fit variant assetBundle.
			for (int i = 0; i < bundlesWithVariant.Length; i++)
			{
				string[] curSplit = bundlesWithVariant[i].Split('.');
				if (curSplit[0] != split[0])
					continue;

				int found = System.Array.IndexOf(m_Variants, curSplit[1]);
				if (found != -1 && found < bestFit)
				{
					bestFit = found;
					bestFitIndex = i;
				}
			}
			if (bestFitIndex != -1)
				return bundlesWithVariant[bestFitIndex];
			else
				return bundleName;
		}

		private static byte[] xtea_key = new byte[16];
		//format: "number1,number2,number3,number4"
		[NoToLua]
		static public void SetXTEAKey(string key, byte v)
		{
			string[] items = { };
			items = key.Split(',');
			if (items.Length != 16)
			{
				Debug.LogError("[AssetBundle] SetXTEAKey error: invalid key:" + key);
				return;
			}
			int[] ikeys = new int[items.Length];
			for (int idx = 0; idx < items.Length; ++idx)
			{
				if (!int.TryParse(items[idx], out ikeys[idx]))
				{
					Debug.LogError("[AssetBundle] SetXTEAKey error: invalid key:" + key + ", idx:" + idx);
					return;
				}
			}
			for (int idx = 0; idx < ikeys.Length; ++idx)
				xtea_key[idx] = (byte)(ikeys[idx] ^ v);
		}
		[NoToLua]
		static public byte[] GetXTEAKey()
		{
			return xtea_key;
		}
		public AssetBundle ReadBundle(string fileName)
		{
			byte[] datas;

			if (AppConst.UseXTEA)
			{
				if (File.Exists(fileName))
					datas = File.ReadAllBytes(fileName);
				else
				{
					string rawFileName = fileName.Substring(DataPath.Length);
					datas = SDKManager.LoadFile(rawFileName);
				}

				if (datas == null || datas.Length <= 0)
				{
					Debug.LogError(string.Format("[AssetBundle] ReadBundle({0}) failed: data is invalid.", fileName));
					return null;
				}
				LuaDLL.xtea_decrypt(datas, datas.Length, xtea_key);

				return AssetBundle.LoadFromMemory(datas);
			}
			else
			{
				if (File.Exists(fileName))
				{
					datas = File.ReadAllBytes(fileName);
					if (datas == null || datas.Length <= 0)
					{
						Debug.LogError(string.Format("[AssetBundle] ReadBundle({0}) failed: data is invalid.", fileName));
						return null;
					}
					return AssetBundle.LoadFromMemory(datas);
				}

				string rawFileName = fileName.Substring(DataPath.Length);
				return AssetBundle.LoadFromFile(StreamingDataPath() + rawFileName);
			}
		}

		public IEnumerator ReadFile(string fileName, Action<bool, byte[], string> callback) {
			WWW www = new WWW (fileName);
			yield return www;

			if (!string.IsNullOrEmpty (www.error)) {
				Debug.LogError (string.Format ("[AssetBundle] ReadFile {0} failed: {1}", fileName, www.error));

				callback.Invoke (false, null, www.error);
				yield break;
			}
			while (!www.isDone)
				yield return null;

			callback.Invoke (true, www.bytes, string.Empty);

			www.Dispose ();
		}

		public void WriteFile(string fileName, byte[] data, int offset, int length) {
			string dir = Path.GetDirectoryName (fileName);
			if (!Directory.Exists (dir))
				Directory.CreateDirectory (dir);

			FileStream writer = new FileStream (fileName, FileMode.Create);
			writer.Write (data, offset, length);
			writer.Close ();
		}


		//[todo]
		public void LoadPrefab(string assetName, Action<UObject[]> func)
		{
			if (!Path.HasExtension (assetName))
				assetName += ".prefab";
				
			List<GameObject> result = new List<GameObject> ();
			result.Add(LoadAsset<GameObject>(assetName, null, null));
			if (func != null)
				func.Invoke (result.ToArray());
		}

		public void LoadPrefab(string[] assetNames, Action<UObject[]> func)
		{
			List<GameObject> result = new List<GameObject> ();
			for (int idx = 0; idx < assetNames.Length; ++idx) {
				if (!Path.HasExtension (assetNames[idx]))
					assetNames[idx] += ".prefab";
				
				result.Add(LoadAsset<GameObject>(assetNames[idx], null, null));
			}
			if(func != null)
				func.Invoke (result.ToArray());
		}

		public void LoadPrefab(string[] assetNames, LuaFunction func)
		{
			List<GameObject> result = new List<GameObject> ();
			for (int idx = 0; idx < assetNames.Length; ++idx) {
				if (!Path.HasExtension (assetNames[idx]))
					assetNames[idx] += ".prefab";
				
				result.Add(LoadAsset<GameObject>(assetNames[idx], null, null));
			}
			if (func != null) {
				func.Call ((object)result.ToArray ());
				func.Dispose ();
			}
		}


		#region tolua interface

		public List<GameObject> GetPrefabsSync(string[] assetNames) {
			int Count = assetNames.Length;
			List<GameObject> result = new List<GameObject> ();
			string assetName = string.Empty;
			for (int idx = 0; idx < Count; ++idx) {
				assetName = assetNames [idx];
				if (!Path.HasExtension (assetName))
					assetName += ".prefab";
				result.Add(LoadAssetSync<GameObject> (assetName));
			}
			return result;
		}

		public GameObject GetPrefabSync(string assetName) {
			if (!Path.HasExtension (assetName))
				assetName += ".prefab";
			return LoadAssetSync<GameObject> (assetName);
		}

		public List<Sprite> GetTexturesSync(string[] assetNames) {
			int Count = assetNames.Length;
			List<Sprite> result = new List<Sprite> ();
			string assetName = string.Empty;
			for (int idx = 0; idx < Count; ++idx) {
				assetName = assetNames [idx];
				if (!Path.HasExtension (assetName))
					assetName += ".png";
				result.Add(LoadAssetSync<Sprite> (assetName));
			}
			return result;
		}

		public Sprite GetTextureSync(string assetName) {
			if (!Path.HasExtension (assetName))
				assetName += ".png";

			return LoadAssetSync<Sprite> (assetName);
		}

		public Texture2D CreateTexture2D(int width, int height, int format) {
			TextureFormat tf = (TextureFormat)format;
			return new Texture2D (width, height, tf, false);
		}

		public List<Texture> Get3DTexturesSync(string[] assetNames) {
			int Count = assetNames.Length;
			List<Texture> result = new List<Texture> ();
			string assetName = string.Empty;
			for (int idx = 0; idx < Count; ++idx) {
				assetName = assetNames [idx];
				if (!Path.HasExtension (assetName))
					assetName += ".png";
				result.Add(LoadAssetSync<Texture> (assetName));
			}
			return result;
		}

		public Texture Get3DTextureSync(string assetName) {
			if (!Path.HasExtension (assetName))
				assetName += ".png";
			return LoadAssetSync<Texture> (assetName);
		}

		public bool ExtractSprite(string spriteName, string saveName) {
			Sprite sprite = LoadAsset<Sprite> (spriteName, null, null);
			if (sprite == null) {
				Debug.LogError ("[AssetBundle] ExtractSprite load sprite failed: " + spriteName);
				return false;
			}

			//Texture2D texture = new Texture2D ((int)sprite.rect.width, (int)sprite.rect.height, TextureFormat.RGB24, false);
			Texture2D texture = new Texture2D ((int)sprite.rect.width, (int)sprite.rect.height, sprite.texture.format, false);
			texture.SetPixels (sprite.texture.GetPixels ((int)sprite.rect.xMin, (int)sprite.rect.yMin, texture.width, texture.height));

			byte[] datas = texture.EncodeToPNG ();
			if (datas == null || datas.Length <= 0) {
				Debug.LogError ("[AssetBundle] ExtractSprite encode texture failed: " + spriteName);
				return false;
			}
			ResManager.WriteFile (saveName, datas, 0, datas.Length);

			return true;
		}
		public bool ExtractTexture(string textureName, string saveName) {
			Texture2D texture = LoadAsset<Texture2D>(textureName, null, null);
			if (texture == null) {
				Debug.LogError ("[AssetBundle] ExtractTexture load texture failed: " + textureName);
				return false;
			}
			byte[] datas = texture.EncodeToPNG ();
			if (datas == null || datas.Length <= 0) {
				Debug.LogError ("[AssetBundle] ExtractTexture encode texture failed: " + textureName);
				return false;
			}
			ResManager.WriteFile (saveName, datas, 0, datas.Length);

			return true;
		}

		public Material GetMaterial(string assetName) {
			if (!Path.HasExtension (assetName))
				assetName += ".mat";
			return LoadAsset<Material> (assetName, null, null);
		}

		public List<AudioClip> GetAudiosSync(string[] assetNames) {
			int Count = assetNames.Length;
			List<AudioClip> result = new List<AudioClip> ();
			string assetName = string.Empty;
			for (int idx = 0; idx < Count; ++idx) {
				assetName = assetNames [idx];
				if (!Path.HasExtension (assetName))
					assetName += ".mp3";
				result.Add(LoadAssetSync<AudioClip> (assetName));
			}
			return result;
		}

		public AudioClip GetAudioSync(string assetName) {
			if (!Path.HasExtension (assetName))
				assetName += ".mp3";
			return LoadAssetSync<AudioClip> (assetName);
		}

		public List<Font> GetFontsSync(string[] assetNames) {
			int Count = assetNames.Length;
			List<Font> result = new List<Font> ();
			string assetName = string.Empty;
			for (int idx = 0; idx < Count; ++idx) {
				assetName = assetNames [idx];
				if (!Path.HasExtension (assetName))
					assetName += ".fontsettings";
				result.Add(LoadAssetSync<Font> (assetName));
			}
			return result;
		}

		public Font GetFontSync(string assetName) {
			if (!Path.HasExtension (assetName))
				assetName += ".fontsettings";
			return LoadAssetSync<Font> (assetName);
		}

		#endregion


		public void LoadTextture(string[] assetNames, LuaFunction func)
		{
			List<Sprite> result = new List<Sprite> ();
			for (int idx = 0; idx < assetNames.Length; ++idx) {
				if (!Path.HasExtension (assetNames[idx]))
					assetNames[idx] += ".png";
				
				result.Add(LoadAsset<Sprite>(assetNames[idx], null, null));
			}
			if (func != null) {
				func.Call ((object)result.ToArray ());
				func.Dispose ();
			}
		}

		public string LoadText(string assetName, LuaFunction func) {

            TextAsset obj = LoadAsset<TextAsset>(assetName, null, null);
            if (obj)
                return obj.text;
            else
                return null;

        }
        public void LoadSProtoStr2(LuaFunction func)
        {
            string[] assetNames =
            {
                "whole_proto_c2s.txt",
                "whole_proto_s2c.txt",
            };

            List<TextAsset> result = new List<TextAsset>();
            for (int idx = 0; idx < assetNames.Length; ++idx)
            {
                result.Add(LoadAsset<TextAsset>(assetNames[idx], null, null));
            }

            TextAsset proto_c2s, proto_s2c;
            proto_c2s = proto_s2c = null;

            TextAsset obj;
            for (int idx = 0; idx < result.Count; ++idx)
            {
                obj = result[idx];
                if (obj.name == "whole_proto_c2s")
                    proto_c2s = obj as TextAsset;
                else if (obj.name == "whole_proto_s2c")
                    proto_s2c = obj as TextAsset;
            }

            if (func != null)
                func.Call(proto_s2c.text, proto_c2s.text);
        }

        public void LoadSProtoStr(LuaFunction func)
        {
            string[] assetNames =
            {
                "proto_both.txt",
                "proto_c2s.txt",
                "proto_s2c.txt",
            };

            List<TextAsset> result = new List<TextAsset>();
            for (int idx = 0; idx < assetNames.Length; ++idx)
            {
                result.Add(LoadAsset<TextAsset>(assetNames[idx], null, null));
            }

            TextAsset proto_both, proto_c2s, proto_s2c;
            proto_both = proto_c2s = proto_s2c = null;

            TextAsset obj;
            for (int idx = 0; idx < result.Count; ++idx)
            {
                obj = result[idx];
                if (obj.name == "proto_both")
                    proto_both = obj as TextAsset;
                else if (obj.name == "proto_c2s")
                    proto_c2s = obj as TextAsset;
                else if (obj.name == "proto_s2c")
                    proto_s2c = obj as TextAsset;
            }

            string s2c = proto_both.text + proto_s2c.text;
            string c2s = proto_both.text + proto_c2s.text;
            if (func != null)
                func.Call(s2c, c2s);
        }

		private void TraceCreateObject(string assetName)
        {
			if(!AppConst.TraceCreateObject)
				return;

            int Total = 0;
            if (m_TraceObject.TryGetValue(assetName, out Total))
                m_TraceObject[assetName] = Total + 1;
            else
                m_TraceObject.Add(assetName, 1);

        }
		public void PrintTraceCreateObject(bool clear)
        {
			if(!AppConst.TraceCreateObject)
				return;

			Dictionary<string, int> result = m_TraceObject.OrderBy(o=> o.Value).ToDictionary(p=>p.Key, o=>o.Value);

			Debug.Log("[Debug] TraceCreateObject(" + result.Count + ")");

			foreach(KeyValuePair<string, int> it in result)
				Debug.Log(string.Format("\t{0} : {1}", it.Key, it.Value));

			if(clear)
				m_TraceObject.Clear();
        }

        //obj pool
        private Dictionary<string, Pool> poolDict = new Dictionary<string, Pool>();
        
        public void InitPool(string poolName, int size, PoolInflationType type = PoolInflationType.DOUBLE)
        {
            if (poolDict.ContainsKey(poolName))
            {
                return;
            }
            else
            {
                GameObject pb = GetPrefabSync(poolName);//Resources.Load<GameObject>(poolName);
                if (pb == null)
                {
                    Debug.LogError("[ResourceManager] Invalide prefab name for pooling :" + poolName);
                    return;
                }
                poolDict[poolName] = new Pool(poolName, pb, gameObject, size, type);
            }
        }

        /// <summary>
        /// Returns an available object from the pool 
        /// OR null in case the pool does not have any object available & can grow size is false.
        /// </summary>
        /// <param name="poolName"></param>
        /// <returns></returns>
        public GameObject GetObjectFromPool(string poolName, bool autoActive = true, int autoCreate = 0)
        {
            GameObject result = null;

            if (!poolDict.ContainsKey(poolName) && autoCreate > 0)
            {
                InitPool(poolName, autoCreate, PoolInflationType.INCREMENT);
            }

            if (poolDict.ContainsKey(poolName))
            {
                Pool pool = poolDict[poolName];
                result = pool.NextAvailableObject(autoActive);
                //scenario when no available object is found in pool
#if UNITY_EDITOR
                if (result == null)
                {
                    Debug.LogWarning("[ResourceManager]:No object available in " + poolName);
                }
#endif
            }
#if UNITY_EDITOR
            else
            {
                Debug.LogError("[ResourceManager]:Invalid pool name specified: " + poolName);
            }
#endif
            return result;
        }

        /// <summary>
        /// Return obj to the pool
        /// </summary>
        /// <param name="go"></param>
        public void ReturnObjectToPool(GameObject go)
        {
            PoolObject po = go.GetComponent<PoolObject>();
            if (po == null)
            {
#if UNITY_EDITOR
                Debug.LogWarning("Specified object is not a pooled instance: " + go.name);
#endif
            }
            else
            {
                Pool pool = null;
                if (poolDict.TryGetValue(po.poolName, out pool))
                {
                    pool.ReturnObjectToPool(po);
                }
#if UNITY_EDITOR
                else
                {
                    Debug.LogWarning("No pool available with name: " + po.poolName);
                }
#endif
            }
        }

        /// <summary>
        /// Return obj to the pool
        /// </summary>
        /// <param name="t"></param>
        public void ReturnTransformToPool(Transform t)
        {
            if (t == null)
            {
#if UNITY_EDITOR
                Debug.LogError("[ResourceManager] try to return a null transform to pool!");
#endif
                return;
            }
            //set gameobject active flase to avoid a onEnable call when set parent
            t.gameObject.SetActive(false);
            t.SetParent(null, false);
            ReturnObjectToPool(t.gameObject);
        }
    }
}
