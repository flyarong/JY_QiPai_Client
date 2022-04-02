using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Linq;
using UnityEngine;
using UnityEngine.Video;
using LuaInterface;
using System.Reflection;

namespace LuaFramework
{
	/*
 * 1.检测是否第一次运行
 * 2.如果第一次运行，释放包资源
 * 3.检测基础更新
 * 4.通知Lua层
 * 
 * .登陆XXX
 * .进入大厅
 * .检测子项更新
*/

	enum GameErrorCode {
		NONE = 0,
		NEED_CLEAR_RESTART = -1,	//需要清空缓存重新启动
		NEED_RESTART = -2,			//需要重新启动
		NEED_REINSTALL = -3,		//需要重新安装

		EXP_DL_VERSION_MAP = -4,	//下载版本信息文件失败
		EXP_DL_UDF = -5,			//下载游戏配置失败
		EXP_DL_FILELIST = -6,		//获取数据列表失败
		EXP_DL_DATA = -7,			//获取数据失败

		ERR_VERSION_ID = -8,		//版本中没有包含的游戏
		ERR_VERSION_NO = -9			//版本号有误
	};

	enum GameState
	{
		EXCEPTION = 0,
		WAITING,
		PLAY_CINEMATIC,		//播放cg
		EXTRACT_LIST,		//解压列表
		EXTRACT_BUNDLES,	//解压文件
		REQUEST_VERSION,	//bundle版本
		CHECK_VERSION,		//游戏版本
		ENTER_GAME,			//开始游戏
		ENTER_SCENE,		//进入场景
		RUNNING,
	};

	[Serializable]
	public class GameInfo {
		public string Name;
		public int Size;
	};

	[Serializable]
	public class GuideFile
	{
		public string Name;
		public string MD5;
		public int Size;

		public GuideFile(string name)
		{
			Name = name;
			MD5 = string.Empty;
			Size = 0;
		}
		public GuideFile(string name, string md5, int size)
		{
			Name = name;
			MD5 = md5;
			Size = size;
		}
	};

	[Serializable]
	public class VersionFile
	{
		public string Name;
		public string MD5;
		public string Code;
		public int Size;

		public VersionFile(string name) {
			Name = name;
			MD5 = string.Empty;
			Code = string.Empty;
			Size = 0;
		}
		public VersionFile(string name, string md5, string code, int size) {
			Name = name;
			MD5 = md5;
			Code = code;
			Size = size;
		}
	};
	[Serializable]
	public class SVRVipPassage {
		public List<string> svr_list = new List<string> ();
		public List<string> svr_data = new List<string> ();
		public List<string> svr_game = new List<string> ();
	};

	[Serializable]
	public class VersionMap
	{
		public string ident = "";
		public string last_version = "";
		public string config_version = "";
		public string config_md5 = "";
		//默认官网地址
		public string website = "";
		//链接下载信息ip列表
		public List<string> svr_list = new List<string> ();
		//链接下载数据ip列表
		public List<string> svr_data = new List<string> ();
		//链接游戏中的ip列表
		public List<string> svr_game = new List<string>();
		public bool restart = false;
		public bool check_md5 = true;
		public bool update_tiny = false;
		public string server_status = "";
		public int download_timeout = GameManager.DOWNLOAD_TIMEOUT;
		public List<string> history = new List<string> ();
		public List<GameInfo> games = new List<GameInfo>();
		public List<GuideFile> md5s = new List<GuideFile> ();
	};

	public class ChannelConfig
    {
		public string platform = string.Empty;
		public string channel = string.Empty;
    };

	[Serializable]
	public class UDF
	{
		public string ident = "";
		public string version = "";
		//链接下载信息ip列表
		public List<string> svr_list = new List<string> ();
		//链接下载数据ip列表
		public List<string> svr_data = new List<string> ();
		//链接游戏中的ip列表
		public List<string> svr_game = new List<string>();
		public List<string> dirList = new List<string> ();
	};

	public class GameManager : Manager
	{
		private ResourceManager ResManager;
		private DownloadManager DldManager;
		private EventManager EvtManager;

		private const string TMP_SUFFIX = ".tc";
		public const string VERSION_MAP = "version_map.txt";
		public const string REMOTE_VERSION_MAP = "remote_version_map.txt";

		public const string BASIC_IDENT = "basic";
		public const string EXTRACT_FILE = "extract.txt";
		public const string TMP_EXTRACT_FILE = "tmp_extract.txt";

		public const string FILE_LIST = "file_list.txt";
		public const string TMP_FILE_LIST = "tmp_filelist.txt";

		public const string UDF_FILE = "udf.txt";
		private const string TMP_UDF_FILE = "tmp_udf.txt";

		public const string CHANNEL_FILE = "channel.txt";

		public const string CINEMATIC_FILE = "LogoAnimation.mp4";
		public const string CINEMATIC_CHANNEL = "LogoAnimation_";

		private const string CHEAT_FORCE_VERSION = "_Cheat_Force_Version_";
		private const string CHEAT_FORCE_CONFIG = "_Cheat_Force_Config_";
		private const string SVR_VIP_PASSAGE = "svr_vip_passage.txt";

		private const float NET_BREAKTIME_INTERVAL = 60.0f;
		public const int DOWNLOAD_TIMEOUT = 30;

		private VideoPlayer m_VideoPlayer;
		private AudioSource m_AudioSource;
		private Color m_BackgroundColor;

		private int m_GameState = (int)GameState.WAITING;

		private bool m_FirstRun = true;
		public bool IsFirstRun () { return m_FirstRun; }

		private string m_LocalPath = string.Empty;
		private string m_StreamingPath = string.Empty;

		private string m_VersionIdent = string.Empty;
		private string m_VersionNumber = string.Empty;
		public string GetVersionNumber() {
			return m_VersionNumber;
		}

		private string m_ConfigVersion = string.Empty;
		public string GetConfigVersion() {
			return m_ConfigVersion;
		}

		//ip列表
		private List<string> svr_lists = new List<string> ();
		private List<string> svr_datas = new List<string> ();
		private List<string> svr_games = new List<string> ();
		private List<string> override_svr_games = new List<string> ();
		private List<string> svr_vip_lists = new List<string> ();
		private List<string> svr_vip_datas = new List<string> ();
		private List<string> svr_vip_games = new List<string> ();
		private SVRVipPassage svr_vip_passage;

		private VersionMap m_RemoteVersionMap;
		private ChannelConfig m_ChannelConfig;

		//生成游戏状态列表:{ 游戏id, 需要更新/需要下载/正常启动 }
		private Dictionary<string, string> m_GameStatus = new Dictionary<string, string>();

		private GameErrorCode m_ErrorCode;
		public bool ReinstallApp() {
			return m_ErrorCode == GameErrorCode.NEED_REINSTALL;
		}
		public bool HasException() {
			return (m_GameState & 0X0000FFFF) == (int)GameState.EXCEPTION;
		}

		//大厅是否有更新(更新完标记)
		private bool m_HasUpdated = false;
		public bool HasUpdated() {
			return m_HasUpdated;
		}
		public bool NeedRestart() {
			if (m_RemoteVersionMap == null)
				return false;
			return m_RemoteVersionMap.restart;
		}

		public bool CheckMD5() {
			if (m_RemoteVersionMap == null)
				return false;
			return m_RemoteVersionMap.check_md5;
		}
		public bool UseUpdateTiny()
		{
			if (m_RemoteVersionMap == null)
				return false;
			return m_RemoteVersionMap.update_tiny;
		}
		public string GetRootURL() {
			if (DldManager.urlList == null)
				return string.Empty;
			else
				return DldManager.urlList [DldManager.urlIndex];
		}
		public string[] GetAllRootURL() {
			if (DldManager.urlList == null)
				return null;
			else
				return DldManager.urlList.ToArray ();
		}

		public string[] getOverrideServerList() {
			return override_svr_games.ToArray ();
		}

		public string[] getServerList() {
			return svr_games.ToArray();
		}

		public string getServerStatus() {
			if (m_RemoteVersionMap == null)
				return string.Empty;
			return m_RemoteVersionMap.server_status;
		}

		public int GetDownloadTimeOut()
		{
			if (m_RemoteVersionMap == null)
				return DOWNLOAD_TIMEOUT;
			else
				return m_RemoteVersionMap.download_timeout;
		}

		public string getLocalPath(string name) {
			return m_LocalPath + name;
		}
		public string getConfigVersion() {
			if (m_RemoteVersionMap == null)
				return string.Empty;
			return m_RemoteVersionMap.config_version;
		}

		public bool getRemoteGuideFileInfo(string fileName, ref string md5, ref int size) {
			if (m_RemoteVersionMap == null)
				return false;
			
			GuideFile gf;
			for (int idx = 0; idx < m_RemoteVersionMap.md5s.Count; ++idx) {
				gf = m_RemoteVersionMap.md5s [idx];
				if (string.Compare(gf.Name, fileName, true) == 0) {
					md5 = gf.MD5;
					size = gf.Size;
					return true;
				}
			}

			return false;
		}
			
		static string[,] ChannelTal = new string[23, 3] {
			//标志,      渠道,     平台
			{"main",   "normal", "normal"},					//彩云麻将
			{"wqp",    "wqp",    "wqp"},					//玩棋牌斗地主
			{"wuziqi", "wuziqi", "wuziqi"},					//五子棋

			{"Local1", "normal", "normal"},
			{"Local2", "normal", "normal"},
			{"Local3", "normal", "normal"},
			{"caiyunmj_yyb", "yyb_cymj", "yyb_cymj"},
			{"caiyunmj_hw", "hw_cymj", "hw_cymj"},
			{"caiyunmj_yyb_main", "yyb_cymj", "yyb_cymj"},
			{"chaoliubuyu", "xw_clby", "xw_clby"},
			{"caiyunmj_hw_main", "hw_cymj", "hw_cymj"},
			{"wqpddz_ios_ts", "normal", "normal"},
			{"wqpddz_hw", "hw_wqp", "hw_wqp"},
			{"wqpddz_yyb", "yyb_wqp", "yyb_wqp"},
			{"wqpddz_pad", "wqp", "wqp"},
			{"caiyunmj_trial", "normal", "normal"},
			{"wqpddz_pdd", "wqp", "wqp"},
			{"caiyunmj_cpls", "cymj", "cymj_xw"},
			{"caiyunmj_hw_noupdate", "hw_cymj_noupdate", "hw_cymj_noupdate"},
			{"aibianxian", "normal", "aibianxian"},
			{ "vivo_cymj","vivo_cymj","vivo_cymj"},
			{ "vivo_wuziqi","vivo_wuziqi","vivo_wuziqi"},
			{ "caiyunmj_ts","ts","normal"},
		};

		public string getMarketChannel() {
			#if UNITY_EDITOR
			if(m_ChannelConfig == null || string.IsNullOrEmpty(m_ChannelConfig.channel)) {
				for(int idx = 0; idx < ChannelTal.Length; ++idx) {
					if(string.Compare(AppDefine.CurQuDao, ChannelTal[idx, 0]) == 0)
						return ChannelTal[idx, 1];
				}
			}
#endif
			if (m_ChannelConfig != null)
				return m_ChannelConfig.channel;
			else
				return string.Empty;
		}
		public string getMarketPlatform() {
			#if UNITY_EDITOR
			if(m_ChannelConfig == null || string.IsNullOrEmpty(m_ChannelConfig.platform)) {
				for(int idx = 0; idx < ChannelTal.Length; ++idx) {
					if(string.Compare(AppDefine.CurQuDao, ChannelTal[idx, 0]) == 0)
						return ChannelTal[idx, 2];
				}
			}
#endif
			if (m_ChannelConfig != null)
				return m_ChannelConfig.platform;
			else
				return string.Empty;
		}

		public bool IsAndroid() {
			return Application.platform == RuntimePlatform.Android;
		}
		public bool IsIOS() {
			return Application.platform == RuntimePlatform.IPhonePlayer;
		}

		private bool m_SetupManifest = true;

		private LuaFunction m_VersionUpdateLuaCallback = null;
		private LuaFunction m_VersionStateLuaCallback = null;
		private void SendDownloadProgress(float percent) {
			if (m_VersionUpdateLuaCallback != null)
				m_VersionUpdateLuaCallback.Call ((object)percent);
		}
		private void SendDownloadState(string state) {
			if (m_VersionStateLuaCallback != null)
				m_VersionStateLuaCallback.Call ((object)state);
		}

		//ui
		private const string LOADING_TITLE_EXTRACT = "初始化数据中...";
		private const string LOADING_TITLE_COMPARE = "加载数据中...";
		private const string LOADING_TITLE_DOWNLOAD = "更新加载数据({0}%)";
		private const string LOADING_TITLE_ENTERING = "读取数据中";
		private LoadingPanel m_LoadingPanel = null;

		private GameObject FindGameObjectInCanvas(string name) {
			GameObject canvas = GameObject.Find ("Canvas");
			if (canvas == null)
				return null;
			Transform node = canvas.transform.Find (name);
			if (node)
				return node.gameObject;
			else
				return null;
		}

		private T SetupPanel<T>(string assetName, bool findCanvas) where T : MonoBehaviour {
			T result = null;
			GameObject go = null;

			if (findCanvas) {
				go = FindGameObjectInCanvas (assetName);
				if (go == null) {
					Debug.LogError ("[GameManager] SetupPanel failed. Can't find Canvas/" + assetName);
					return null;
				}
				if (m_FirstRun) {
					result = go.GetComponent<T> ();
					if (result == null) {
						Debug.LogError ("[GameManager] SetupPanel failed. Can't component:" + assetName);
						return null;
					}
					result.gameObject.SetActive (false);
					return result;
				} else
					go.SetActive (false);
			}

			GameObject tmpl = ResManager.LoadAsset<GameObject> (assetName + ".prefab", null, null);
			if (tmpl == null) {
				Debug.LogError ("[GameManager] SetupPanel failed. Can't Load prefab:" + assetName);
				return null;
			}
			go = GameObject.Instantiate (tmpl, GameObject.Find("Canvas").transform);
			if (go == null) {
				Debug.LogError ("[GameManager] SetupPanel failed. Can't Instantiate " + assetName);
				return null;
			}

			result = go.GetComponent<T> ();
			if (result == null) {
				Debug.LogError ("[GameManager] SetupPanel failed. Can't component:" + assetName);
				return null;
			}
			result.gameObject.SetActive (false);

			return result;
		}

		private bool m_InternetCarrierHintInteractive = false;
		private InternetCarrierHint m_InternetCarrierHint = null;
		private void ShowInternetCarrierDlg(long value) {
			if (m_InternetCarrierHint) {
				m_InternetCarrierHint.SetActive (true);
				m_InternetCarrierHint.SetDetail (value);
				m_InternetCarrierHint.transform.SetAsLastSibling ();
			}
		}
		private IEnumerator CheckInternetCarrierHint(long downloadSize) {
			if (m_InternetCarrierHint == null || !m_InternetCarrierHint.IsOverLimit (downloadSize))
				yield break;

			m_InternetCarrierHintInteractive = true;
			ShowInternetCarrierDlg (downloadSize);
			while (m_InternetCarrierHintInteractive)
				yield return new WaitForSeconds (0.1f);
		}

		public void HandleBtnInternetCarrierDlgOK() {
			Debug.Log ("[AssetBundle] HandleBtnInternetCarrierDlgOK");

			m_InternetCarrierHintInteractive = false;
			m_InternetCarrierHint.transform.SetParent (null);
			GameObject.Destroy (m_InternetCarrierHint.gameObject);
		}
		public void HandleBtnInternetCarrierDlgCancel() {
			Debug.Log ("[AssetBundle] HandleBtnInternetCarrierDlgCancel");

			m_InternetCarrierHint.transform.SetParent (null);
			GameObject.Destroy (m_InternetCarrierHint.gameObject);

			QuitAll ();
		}

		private HintNoticePanel m_HintNoticePanel = null;
		private void ShowHintNoticePanel(string value, Action callback = null) {
			if (m_HintNoticePanel) {
				string detail = string.Empty;
				UDF udf = LoadUDF (m_LocalPath + UDF_FILE);
				if (udf != null) {
					detail = "Ver: " + udf.version;
					if (m_RemoteVersionMap != null)
						detail += " / " + m_RemoteVersionMap.last_version;
					else
						detail += " / " + "?";
					detail += " / " + MainVersion.Version + ":";
				}

				string url = GetRootURL ();
				if (!string.IsNullOrEmpty (url)) {
					url = url.Substring (0, url.Length - 1);

					int idx = url.LastIndexOf ('/');
					if (idx >= 0) {
						string uri = url.Substring (idx + 1);
						if (!string.IsNullOrEmpty (uri))
							detail = detail + " " + uri;
					}
				}

				if (!string.IsNullOrEmpty (detail)) {
					value += "\n\n";
					value = value + "<color=#ff0000><size=30>" + detail + "</size></color>";
				}

				m_HintNoticePanel.SetActive (true);
				m_HintNoticePanel.SetText (value);
				m_HintNoticePanel.SetCallback (callback);
				m_HintNoticePanel.transform.SetAsLastSibling ();
			}
		}
		public void HandleBtnHintNoticeDlgOK() {
			QuitAll ();
		}

		public bool IsCheckVersion() {
			return AppConst.CheckVersionMode;
		}

		public void QuitAll() {
			SDKManager mgr = AppFacade.Instance.GetManager<SDKManager> (ManagerName.SDK);
			if (mgr != null)
				mgr.ForceQuit ();
			Application.Quit ();
		}

		void Awake() {
			if (!IsCheckVersion ())
				Debug.LogWarning ("[GameManager] Notice that the current running no CheckVersion!");
		}

		// Use this for initialization
		IEnumerator Start ()
		{
			Debug.Log ("MainVersion: " + MainVersion.Version);

			while ((ResManager = GetComponent<ResourceManager> ()) == null) {
				Debug.LogWarning ("[AssetBundle] Wait ResourceManager");
				yield return null;
			}
			while ((DldManager = GetComponent<DownloadManager> ()) == null) {
				Debug.LogWarning ("[AssetBundle] Wait DownloadManager");
				yield return null;
			}
			while ((EvtManager = GetComponent<EventManager> ()) == null) {
				Debug.LogWarning ("[AssetBundle] Wait EventManager");
				yield return null;
			}

			if (ResManager.UseAssetBundle ()) {
				while (PlatformFile ("") == "Nonsupport RuntimePlatform") {
					Debug.LogError ("[AssetBundle] Nonsupport RuntimePlatform");
					yield return null;
				}
			}

			m_LocalPath = ResManager.DataPath;
			m_StreamingPath = Util.AppContentPath ();

			m_VersionIdent = BASIC_IDENT;
			m_VersionNumber = string.Empty;

			if (ResManager.UseAssetBundle ()) {
				m_BackgroundColor = Camera.main.backgroundColor;
				Camera.main.backgroundColor = Color.black;

				string extractFile = m_LocalPath + EXTRACT_FILE;
				string registerVersion = PlayerPrefs.GetString("_MAIN_VERSION_", string.Empty);
				if (string.Compare(registerVersion, MainVersion.Version) != 0 ||
					!File.Exists(extractFile))
					m_FirstRun = true;
				else
					m_FirstRun = false;

				if(m_FirstRun)
                {
					PlayerPrefs.SetString("_MAIN_VERSION_", MainVersion.Version);
					PlayerPrefs.SetString("_BASE_VERSION_", MainVersion.baseVersion);
					if (Directory.Exists(m_LocalPath))
						Directory.Delete(m_LocalPath, true);
					Directory.CreateDirectory(m_LocalPath);

					yield return StartCoroutine(ResManager.ReadFile(m_StreamingPath + CHANNEL_FILE, ((bool isOK, byte[] datas, string errMsg) => {
						if (isOK)
							ResManager.WriteFile(m_LocalPath + CHANNEL_FILE, datas, 0, datas.Length);
						else
							Debug.LogError(string.Format("[AssetBundle] Start exception: extract Channel File failed({0}).", errMsg));
					})));

					Debug.Log("[GameManager] It's first run. MainVersion:" + MainVersion.Version);
				}
				else
					ResManager.SetupManifest();

				if (!Util.JsonHelper.LoadJson<ChannelConfig>(m_LocalPath + CHANNEL_FILE, out m_ChannelConfig))
					Debug.LogError("[AssetBundle] Start load ChannelFile failed.");

				m_GameState = (int)GameState.PLAY_CINEMATIC;

				{
					string marketChannel = getMarketChannel();
					if(!string.IsNullOrEmpty(marketChannel))
						m_LoadingPanel = SetupPanel<LoadingPanel>("LoadingPanel_" + marketChannel, true);
					if (m_LoadingPanel == null) {
						m_LoadingPanel = SetupPanel<LoadingPanel> ("LoadingPanel", true);

						{
							//debug
							GameObject canvas = GameObject.Find ("Canvas");
							if (canvas != null) {
								Debug.Log ("-------------------setuppanel--------------------------------");
								for (int idx = 0; idx < canvas.transform.childCount; ++idx) {
									Debug.Log (string.Format("{0}:{1}", idx, canvas.transform.GetChild(idx).name));
								}
							}
						}


					} else
						Debug.Log ("[GameManager] SetupPanel use marketChannel:" + marketChannel);
				}

				PlayCinematic ();
			} else {
				m_FirstRun = false;
				m_GameState = (int)GameState.ENTER_GAME;
			}

			//clear Unuse
			//ClearUnuseFile();
		}

		// Update is called once per frame
		private float m_NetBreakTimeCount = NET_BREAKTIME_INTERVAL;
		void Update ()
		{
			if (IsHangUp ()) {
				Debug.Log ("[GameManager] update Application is HangUp");
				return;
			}

			if (m_GameState == (int)GameState.RUNNING)
				return;

			if (IsCheckVersion () && (m_GameState & 0X0000FFFF) >= (int)GameState.REQUEST_VERSION) {
				if (DldManager.CheckNetValid())
				{
					m_NetBreakTimeCount = NET_BREAKTIME_INTERVAL;
				}
				else
				{
					if (DldManager.IsNetBreakeTimeOut(m_NetBreakTimeCount))
					{
						m_NetBreakTimeCount += NET_BREAKTIME_INTERVAL;

						Debug.LogError("[GameManager] Update NetWork is Break");

						if (IsBasicIdent())
							ShowHintNoticePanel("网络无法连接，不能完成下载");
						else
							Util.CallMethod("HallPanel", "HandleDownloadNetworkError");
					}
					return;
				}
			}

			switch ((GameState)(m_GameState & 0X0000FFFF)) {
			case GameState.EXTRACT_LIST:
				{
					ExtractList ();
				}
				break;
			case GameState.EXTRACT_BUNDLES:
				{
					ExtractBundles ();
				}
				break;
			case GameState.REQUEST_VERSION:
				{
					RequestVersion ();
				}
				break;
			case GameState.CHECK_VERSION:
				{
					CheckVersion ();
				}
				break;
			case GameState.ENTER_GAME:
				{
					EnterGame ();
				}
				break;
			case GameState.ENTER_SCENE:
				{
					EnterScene ();
				}
				break;
			case GameState.EXCEPTION:
				{
				}
				break;
			default:
				break;
			}
		}

		private void SendLoadingProgress(string title, float value) {
			if (m_LoadingPanel == null)
				return;
			m_LoadingPanel.SetLoadingTitle (title);
			m_LoadingPanel.SetLoadingProgress(value);
		}
		private void SendLoadingVersion(string value)
		{
			if (m_LoadingPanel == null)
				return;
			m_LoadingPanel.SetVersion(value);
		}
		private void SendLoadingError(string value)
		{
			if (m_LoadingPanel == null)
				return;
			m_LoadingPanel.SetError(value);
		}

		private void PlayCinematic() {
			Debug.Log ("[Debug] PlayCinematic");

			StartCoroutine (PlayingCinematic ((bool isOK) => {
				if (m_FirstRun)
					m_GameState = (int)GameState.EXTRACT_LIST;
				else
					m_GameState = (int)GameState.REQUEST_VERSION;

				if (m_LoadingPanel != null)
					m_LoadingPanel.SetActive (true);

				Camera.main.backgroundColor = m_BackgroundColor;
			}));
		}

		/*private IEnumerator PlayingCinematic(Action<bool> callback) {
			m_GameState = ((int)GameState.PLAY_CINEMATIC << 16) | (int)GameState.WAITING;

			string localVideoFile = m_LocalPath + CINEMATIC_FILE;

			if (m_FirstRun || !File.Exists (localVideoFile)) {
				StartCoroutine (ResManager.ReadFile (m_StreamingPath + CINEMATIC_FILE, ((bool isOK, byte[] datas) => {
					if (isOK)
						ResManager.WriteFile (localVideoFile, datas, 0, datas.Length);
					else {
						m_GameState = ((int)GameState.PLAY_CINEMATIC << 16) | (int)GameState.EXCEPTION;
						Debug.LogError (string.Format ("[AssetBundle] PlayingCinematic failed: Read Cinematic File({0}) failed.", m_StreamingPath + CINEMATIC_FILE));
					}
				})));
			}

			while ((m_GameState == (((int)GameState.PLAY_CINEMATIC << 16) | (int)GameState.WAITING)) && !File.Exists (localVideoFile))
				yield return new WaitForEndOfFrame ();

			if (m_GameState == (((int)GameState.PLAY_CINEMATIC << 16) | (int)GameState.EXCEPTION)) {
				callback (false);
				yield break;
			}

			GameObject go = GameObject.Find ("Cinematic");
			if (go == null) {
				m_GameState = ((int)GameState.PLAY_CINEMATIC << 16) | (int)GameState.EXCEPTION;
				Debug.LogError ("[AssetBundle] PlayingCinematic failed: Can't find Cinematic Node.");
				yield break;
			}

			m_VideoPlayer = go.GetComponent<VideoPlayer> ();
			if (m_VideoPlayer == null) {
				m_GameState = ((int)GameState.PLAY_CINEMATIC << 16) | (int)GameState.EXCEPTION;
				Debug.LogError ("[AssetBundle] PlayingCinematic failed: Can't find VideoPlayer.");
				yield break;
			}
			m_AudioSource = go.GetComponent<AudioSource> ();
			if (m_AudioSource == null) {
				m_GameState = ((int)GameState.PLAY_CINEMATIC << 16) | (int)GameState.EXCEPTION;
				Debug.LogError ("[AssetBundle] PlayingCinematic failed: Can't find AudioSource.");
				yield break;
			}
				
			m_AudioSource.playOnAwake = false;
			m_VideoPlayer.playOnAwake = false;
			m_VideoPlayer.audioOutputMode = VideoAudioOutputMode.AudioSource;
			m_VideoPlayer.EnableAudioTrack (0, true);
			m_VideoPlayer.SetTargetAudioSource (0, m_AudioSource);

			m_VideoPlayer.url = localVideoFile;
			m_VideoPlayer.Prepare ();

			while (!m_VideoPlayer.isPrepared)
				yield return new WaitForEndOfFrame ();

			m_VideoPlayer.Play ();
			while (m_VideoPlayer.isPlaying)
				yield return null;
			m_VideoPlayer.Stop ();

			callback.Invoke (true);
		}*/

		/*private IEnumerator PlayingCinematic(Action<bool> callback) {
			m_GameState = ((int)GameState.PLAY_CINEMATIC << 16) | (int)GameState.WAITING;

			string localVideoFile = m_LocalPath + CINEMATIC_FILE;

			if (m_FirstRun || !File.Exists (localVideoFile)) {
				StartCoroutine (ResManager.ReadFile (m_StreamingPath + CINEMATIC_FILE, ((bool isOK, byte[] datas) => {
					if (isOK)
						ResManager.WriteFile (localVideoFile, datas, 0, datas.Length);
					else {
						m_GameState = ((int)GameState.PLAY_CINEMATIC << 16) | (int)GameState.EXCEPTION;
						Debug.LogError (string.Format ("[AssetBundle] PlayingCinematic failed: Read Cinematic File({0}) failed.", m_StreamingPath + CINEMATIC_FILE));
					}
				})));
			}

			while ((m_GameState == (((int)GameState.PLAY_CINEMATIC << 16) | (int)GameState.WAITING)) && !File.Exists (localVideoFile))
				yield return new WaitForEndOfFrame ();

			do {
				if (m_GameState == (((int)GameState.PLAY_CINEMATIC << 16) | (int)GameState.EXCEPTION))
					break;

				GameObject go = GameObject.Find ("Cinematic");
				if (go == null) {
					m_GameState = ((int)GameState.PLAY_CINEMATIC << 16) | (int)GameState.EXCEPTION;
					Debug.LogError ("[AssetBundle] PlayingCinematic failed: Can't find Cinematic Node.");
					break;
				}

				m_VideoPlayer = go.GetComponent<VideoPlayer> ();
				if (m_VideoPlayer == null) {
					m_GameState = ((int)GameState.PLAY_CINEMATIC << 16) | (int)GameState.EXCEPTION;
					Debug.LogError ("[AssetBundle] PlayingCinematic failed: Can't find VideoPlayer.");
					break;
				}
				m_AudioSource = go.GetComponent<AudioSource> ();
				if (m_AudioSource == null) {
					m_GameState = ((int)GameState.PLAY_CINEMATIC << 16) | (int)GameState.EXCEPTION;
					Debug.LogError ("[AssetBundle] PlayingCinematic failed: Can't find AudioSource.");
					break;
				}

				m_AudioSource.playOnAwake = false;
				m_VideoPlayer.playOnAwake = false;
				m_VideoPlayer.audioOutputMode = VideoAudioOutputMode.AudioSource;
				m_VideoPlayer.EnableAudioTrack (0, true);
				m_VideoPlayer.SetTargetAudioSource (0, m_AudioSource);

				m_VideoPlayer.url = localVideoFile;
				m_VideoPlayer.Prepare ();

				int waitCount = 45;
				while (!m_VideoPlayer.isPrepared && --waitCount > 0)
					yield return new WaitForEndOfFrame ();

				m_VideoPlayer.Play ();
				while (m_VideoPlayer.isPlaying)
					yield return null;
				m_VideoPlayer.Stop ();

			} while(false);

			callback.Invoke (true);
		}*/

		private IEnumerator PlayingCinematic(Action<bool> callback) {
			m_GameState = ((int)GameState.PLAY_CINEMATIC << 16) | (int)GameState.WAITING;

			string marketChannel = getMarketChannel();

			//priority
			List<string> videoFiles = new List<string>();
			videoFiles.Add(CINEMATIC_FILE);

			if (!string.IsNullOrEmpty(marketChannel))
				videoFiles.Add(CINEMATIC_CHANNEL + marketChannel + ".mp4");

			int extractVideoCount = 0;
			if (m_FirstRun || (!File.Exists(m_LocalPath + videoFiles[0]))) {
				extractVideoCount = videoFiles.Count;
				for(int idx = 0; idx < videoFiles.Count; ++idx)
                {
					string mp4File = videoFiles[idx];
					StartCoroutine(ResManager.ReadFile(m_StreamingPath + mp4File, ((bool isOK, byte[] datas, string errMsg) => {
						--extractVideoCount;
						if (isOK)
							ResManager.WriteFile(m_LocalPath + mp4File, datas, 0, datas.Length);
						else
							Debug.LogWarning(string.Format("[AssetBundle] PlayingCinematic Read Cinematic File({0}) failed.", m_StreamingPath + mp4File));
					})));
				}
			}

			while(extractVideoCount > 0)
				yield return new WaitForEndOfFrame ();

			//priority
			string localVideoFile = m_LocalPath + videoFiles[0];
			if (File.Exists(m_LocalPath + videoFiles[videoFiles.Count - 1]))
				localVideoFile = m_LocalPath + videoFiles[videoFiles.Count - 1];

			Debug.Log("[AssetBundle] PlayingCinematic file:" + localVideoFile);

			do {
				if (m_GameState == (((int)GameState.PLAY_CINEMATIC << 16) | (int)GameState.EXCEPTION))
					break;

				GameObject go = GameObject.Find ("Cinematic");
				if (go == null) {
					m_GameState = ((int)GameState.PLAY_CINEMATIC << 16) | (int)GameState.EXCEPTION;
					Debug.LogError ("[AssetBundle] PlayingCinematic failed: Can't find Cinematic Node.");
					break;
				}

				m_VideoPlayer = go.GetComponent<VideoPlayer> ();
				if (m_VideoPlayer == null) {
					m_GameState = ((int)GameState.PLAY_CINEMATIC << 16) | (int)GameState.EXCEPTION;
					Debug.LogError ("[AssetBundle] PlayingCinematic failed: Can't find VideoPlayer.");
					break;
				}
				m_AudioSource = go.GetComponent<AudioSource> ();
				if (m_AudioSource == null) {
					m_GameState = ((int)GameState.PLAY_CINEMATIC << 16) | (int)GameState.EXCEPTION;
					Debug.LogError ("[AssetBundle] PlayingCinematic failed: Can't find AudioSource.");
					break;
				}

				m_AudioSource.playOnAwake = false;
				m_VideoPlayer.playOnAwake = false;
				m_VideoPlayer.audioOutputMode = VideoAudioOutputMode.AudioSource;
				m_VideoPlayer.EnableAudioTrack (0, true);
				m_VideoPlayer.SetTargetAudioSource (0, m_AudioSource);

				m_VideoPlayer.url = localVideoFile;
				m_VideoPlayer.Prepare ();

				int waitCount = 45;
				while (!m_VideoPlayer.isPrepared && --waitCount > 0)
					yield return new WaitForEndOfFrame ();

				Debug.Log("[Debug] play video:" + waitCount);
				m_VideoPlayer.Play ();

				yield return null;

				waitCount = 0;
				while (m_VideoPlayer.isPlaying)
                {
					if (++waitCount >= 45)
						break;

					yield return new WaitForSeconds(0.1f);
				}
					
				Debug.Log("[Debug] play over:" + waitCount);
				m_VideoPlayer.Stop ();

			} while(false);

			callback.Invoke (true);
		}


		private void ExtractList ()
		{
			Debug.Log ("[Debug] ExtractList");

			m_GameState = ((int)GameState.EXTRACT_LIST << 16) | (int)GameState.WAITING;

			StartCoroutine (ResManager.ReadFile (m_StreamingPath + EXTRACT_FILE, ((bool isOK, byte[] datas, string errMsg) => {
				if (isOK) {
					ResManager.WriteFile (m_LocalPath + TMP_EXTRACT_FILE, datas, 0, datas.Length);

					m_GameState = (int)GameState.EXTRACT_BUNDLES;
				} else {
					m_GameState = ((int)GameState.EXTRACT_LIST << 16) | (int)GameState.EXCEPTION;
					Debug.LogError (string.Format ("[AssetBundle] ExtractList failed: Read Extract File({0}) failed({1}).", m_StreamingPath + EXTRACT_FILE, errMsg));
					SendLoadingError("请重启应用,加载文件列表异常:" + errMsg);
				}
			})));
		}

		private IEnumerator ExtractBundle (string srcFile, string dstFile, Action<string> callback)
		{
			yield return ResManager.ReadFile (srcFile, ((bool isOK, byte[] datas, string errMsg) => {
				if (isOK) {
					ResManager.WriteFile (dstFile, datas, 0, datas.Length);
					if (callback != null)
						callback.Invoke (dstFile);
				} else {
					m_GameState = ((int)GameState.EXTRACT_BUNDLES << 16) | (int)GameState.EXCEPTION;
					Debug.LogError (string.Format ("[AssetBundle] ExtractBundle failed: ReadFile({0}) failed({1}).", srcFile, errMsg));
					SendLoadingError("请重启应用,加载文件数据异常:" + errMsg);
				}
			}));
		}

		private void ExtractBundles ()
		{
			Debug.Log ("[Debug] ExtractBundles");

			m_GameState = ((int)GameState.EXTRACT_BUNDLES << 16) | (int)GameState.WAITING;

			string extractFile = m_LocalPath + TMP_EXTRACT_FILE;
			if (!File.Exists (extractFile)) {
				m_GameState = ((int)GameState.EXTRACT_BUNDLES << 16) | (int)GameState.EXCEPTION;
				Debug.LogError (string.Format ("[AssetBundle] ExtractBundles failed: ExtractFile({0}) not exist.", extractFile));
				SendLoadingError("请重启应用,文件列表不存在");
				return;
			}

			string[] lines = File.ReadAllLines (extractFile);
			if (lines == null || lines.Length <= 0) {
				m_GameState = ((int)GameState.EXTRACT_BUNDLES << 16) | (int)GameState.EXCEPTION;
				Debug.LogError (string.Format ("[AssetBundle] ExtractBundles failed: ExtractFile({0}) is empty.", extractFile));
				return;
			}

			string srcFile = string.Empty, dstFile = string.Empty;
			Dictionary<string, string> fileMap = new Dictionary<string, string> ();
			for (int idx = 0; idx < lines.Length; ++idx) {
				if (!lines [idx].EndsWith (".txt") && !lines[idx].Equals("StreamingAssets"))
					continue;
				srcFile = m_StreamingPath + lines [idx];
				dstFile = m_LocalPath + lines [idx];

				if (fileMap.ContainsKey (dstFile)) {
					Debug.LogWarning (string.Format ("[AssetBundle] ExtractBundles exception: Parse fileList({0}) {1} repeat.", idx, lines [idx]));
					continue;
				}
				fileMap.Add (dstFile, srcFile);
			}

			if (fileMap.Count <= 0) {
				m_GameState = ((int)GameState.EXTRACT_BUNDLES << 16) | (int)GameState.EXCEPTION;
				Debug.LogError ("[AssetBundle] ExtractBundles failed: fileList is Empty.");
				return;
			}
	
			StartCoroutine (ExtractBundles (fileMap));
		}

		private IEnumerator ExtractBundles (Dictionary<string,string> fileMap) {
			string srcFile = string.Empty, dstFile = string.Empty;

			int Count = 0;
			//string extractTitle = string.Format ("{0} ({1} / {2})", LOADING_TITLE_EXTRACT, Count, fileMap.Count);
			string extractTitle = LOADING_TITLE_EXTRACT;
			//SendLoadingProgress (extractTitle, 0.0f);

			string dir = string.Empty;
			foreach (KeyValuePair<string, string> kv in fileMap) {
				dstFile = kv.Key;
				srcFile = kv.Value;

				//message notice
				//Debug.Log ("[Todo] SendMessage: Extract " + dstFile);

				dir = Path.GetDirectoryName (dstFile);
				if (!Directory.Exists (dir))
					Directory.CreateDirectory (dir);

				yield return ExtractBundle (srcFile, dstFile, (string bundleName) => {
					if (fileMap.ContainsKey (bundleName)) {
						++Count;
						//extractTitle = string.Format ("{0} ({1} / {2})", LOADING_TITLE_EXTRACT, Count, fileMap.Count);
						extractTitle = LOADING_TITLE_EXTRACT;
						//SendLoadingProgress (extractTitle, (float)Count / fileMap.Count);

						if (Count >= fileMap.Count) {
							File.Copy (m_LocalPath + TMP_EXTRACT_FILE, m_LocalPath + EXTRACT_FILE, true);
							File.Delete (m_LocalPath + TMP_EXTRACT_FILE);

							m_GameState = (int)GameState.REQUEST_VERSION;

							Debug.Log ("[Debug] ExtractBundles Finish." + Count);
						}
					}
				});
			}
		}

		private bool IsBasicIdent() {
			return string.Compare (m_VersionIdent, BASIC_IDENT, true) == 0;
		}
		private string GetRelateName(string fileName) {
			if (IsBasicIdent ())
				return fileName;
			else
				return m_VersionIdent + "/" + fileName;
		}

		private void ClearUnuseFile() {
			string remoteVersionFile = m_LocalPath + REMOTE_VERSION_MAP;
			if (File.Exists (remoteVersionFile))
				File.Delete (remoteVersionFile);
		}

		/*
		 * 0:normal
		 * -1:install
		 * 1:update
		*/
		private int CheckUDFVersion(string versionNumber, string dirName, ref UDF udf) {
			udf = LoadUDF (m_LocalPath + dirName + "/" + UDF_FILE);
			if (udf == null)
				return -1;
			if (string.Compare (versionNumber, udf.version, true) == 0)
				return 0;
			return 1;
		}

		public int GetRemoteGameSize(string gameKey) {
			if (!ResManager.UseAssetBundle () || !IsCheckVersion ())
				return 0;
			
			GameInfo gi = FindRemoteGameInfo (gameKey);
			if (gi == null)
				return 0;

			return gi.Size;
		}

		public int GetLocalGameSize(string gameKey) {
			string fileName = m_LocalPath + gameKey + "/" + FILE_LIST;

			string[] lines = File.ReadAllLines (fileName);
			if (lines == null || lines.Length <= 0) {
				UnityEngine.Debug.LogError (string.Format ("[AssetBundle] GetLocalGameSize({0}) failed: filelist is empty.", gameKey));
				return 0;
			}

			int totalSize = 0;

			string[] item = { };
			foreach (string line in lines) {
				item = line.Split ('|');
				if (item == null || item.Length != 3) {
					UnityEngine.Debug.LogError (string.Format ("[AssetBundle] GetLocalGameSize({0}) failed: filelist line({1}) invalid.", gameKey, line));
					return 0;
				}
				totalSize += int.Parse (item [2]);
			}

			return totalSize;
		}

		public string CheckUpdate(string gameKey) {
			if (!ResManager.UseAssetBundle() || !IsCheckVersion ())
				return "Normal";

			if (string.IsNullOrEmpty (m_VersionNumber)) {
				Debug.LogError (string.Format("[AssetBundle] CheckUpdate({0}) exception: versionNumber is invalid.", gameKey));
				return "Normal";
			}

			if (FindVersionMap (gameKey) == null) {
				Debug.LogWarning (string.Format("[AssetBundle] CheckUpdate({0}) exception: Not in verisonList.", gameKey));
				return "Normal";
			}

			UDF udf = null;
			int result = CheckUDFVersion (m_VersionNumber, gameKey.ToLower (), ref udf);
			if (result != 0) {
				Debug.Log (string.Format("[AssetBundle] CheckUpdate({0}) result({1}) need update.", gameKey, result));

				if (result < 0)
					return "Install";
				if (result > 0)
					return "Update";
			}

			//check depend
			UDF pad = null;
			for (int idx = 0; idx < udf.dirList.Count; ++idx) {
				if (CheckUDFVersion (m_VersionNumber, udf.dirList [idx], ref pad) != 0) {
					Debug.Log (string.Format("[AssetBundle] CheckUpdate({0}) dependDir({1}) need update.", gameKey, udf.dirList [idx]));

					return "Update";
				}
			}

			return "Normal";
		}

		/*
		 * gameID, "Normal"/"Error"/"Install"/"Update" 
		*/
		public Dictionary<string, string> GetGameStatus() {
			return m_GameStatus;
		}
		/*
		 * luaStateCallback(string)
		 *     Error: reason
		 *     gameID.tolower()
		 * luaUpdateCallback(float percent)
		 *     [0,1]
		*/
		public void DownloadUpdate(string gameID, LuaFunction luaStateCallback, LuaFunction luaUpdateCallback) {
			string gameStatus = string.Empty;
			if (!m_GameStatus.TryGetValue (gameID, out gameStatus)) {
				if (luaStateCallback != null)
					luaStateCallback.Call((object)("Error:Not find gameStatus:" + gameID));

				Debug.LogError (string.Format ("[AssetBundle] DownloadUpdate({0}) failed: Not find gameStatus.", gameID));
				return;
			}
			if (gameStatus != "Install" && gameStatus != "Update") {
				if (luaStateCallback != null)
					luaStateCallback.Call((object)(string.Format("Error:gameStatus({0}) invalid:{1}", gameStatus, gameID)));

				Debug.LogError (string.Format ("[AssetBundle] DownloadUpdate({0}) failed: gameStatus({1}) invalid.", gameID, gameStatus));
				return;
			}

			m_VersionIdent = gameID.ToLower();

			if (m_VersionStateLuaCallback != null)
				m_VersionStateLuaCallback.Dispose ();
			m_VersionStateLuaCallback = luaStateCallback;

			if (m_VersionUpdateLuaCallback != null)
				m_VersionUpdateLuaCallback.Dispose ();
			m_VersionUpdateLuaCallback = luaUpdateCallback;

			m_GameState = (int)GameState.CHECK_VERSION;
		}

		private void UpdateGameVersionStatus() {
			if (m_RemoteVersionMap == null)
				return;
	
			m_GameStatus.Clear ();

			string gameName = string.Empty;
			for (int idx = 0; idx < m_RemoteVersionMap.games.Count; ++idx) {
				gameName = m_RemoteVersionMap.games [idx].Name;
				if (string.Compare (gameName, BASIC_IDENT, true) == 0)
					continue;

				m_GameStatus.Add (gameName, CheckUpdate (gameName));
			}
	
			//debug
			{
				Debug.Log ("GameStatus:");
				foreach (KeyValuePair<string, string> kv in m_GameStatus) {
					if (kv.Value == "Install" || kv.Value == "Update")
						Debug.Log ("\t" + kv.Key + ": " + kv.Value + ": " + m_VersionNumber);
					else
						Debug.Log ("\t" + kv.Key + ": " + kv.Value);
				}
			}
		}

		/*
		 * 1:	upgrade
		 * 0:	keep
		 * -1:	clear & jump restart
		 * -2:	restart
		 * -3:	reinstall
		*/
		private int CompareVersion(string remoteVersion, string localVersion)
		{
			string[] rv = remoteVersion.Split('.');
			string[] lv = localVersion.Split('.');
			if (rv.Length != lv.Length)
				return -2;

			if (string.Compare(MainVersion.Version, rv[0], true) == 0)
			{
				//cache
				if (string.Compare(rv[0], lv[0], true) != 0)
					return -1;

				if (string.Compare(remoteVersion, localVersion, true) == 0)
					return 0;

				return 1;
			}
			else
				return -3;			
		}

		private IEnumerator CheckVersionMap(string rvmFile, List<string> svrList, Action<VersionMap> callback) {
			int step = 0;
			VersionMap vm = null;

			DldManager.urlList = svrList;
			yield return DldManager.Downloading (PlatformFile (VERSION_MAP), string.Empty, (isOK, datas) => {
				if(isOK) {
					ResManager.WriteFile (rvmFile, datas, 0, datas.Length);
					if(Util.JsonHelper.LoadJson<VersionMap>(rvmFile, out vm))
						step = 1;
					else {
						Debug.LogError("[AssetBundle] CheckVersionMap Load VersionMap failed");
						step = -1;
					}
				} else {
					Debug.LogError("[AssetBundle] CheckVersionMap Download VersionMap failed");
					step = -1;
				}
			});

			while (step == 0)
				yield return null;

			if (step <= 0 || vm == null) {
				callback (null);
				yield break;
			}

			List<string> override_svr_list = new List<string>();
			OverrideSvr(vm.svr_list, null, ref override_svr_list);
			List<string> result = override_svr_list.Except(svrList).ToList();
			if (result.Count <= 0) {
				callback(vm);
				yield break;
			}
			Debug.Log ("override url:" + result[0]);

			yield return CheckVersionMap (rvmFile, override_svr_list, callback);
		}

		private void RequestVersion() {
			Debug.Log ("[Debug] RequestVersion");

			if (!IsCheckVersion ()) {
				m_GameState = (int)GameState.ENTER_GAME;
				return;
			}

			m_ErrorCode = GameErrorCode.NONE;

			if (m_FirstRun)
				ResManager.SetupManifest ();
			m_InternetCarrierHint = SetupPanel<InternetCarrierHint>("InternetCarrierHint", false);
			m_HintNoticePanel = SetupPanel<HintNoticePanel> ("HintNoticePanel", false);

			SendLoadingProgress (LOADING_TITLE_COMPARE, 0.0f);

			string udfFile = m_LocalPath + GetRelateName(UDF_FILE);
			UDF udf = LoadUDF (udfFile);
			if (udf == null) {
				m_GameState = ((int)GameState.REQUEST_VERSION << 16) | (int)GameState.EXCEPTION;
				Debug.LogError (string.Format ("[AssetBundle] RequestVersion({0}) failed: LoadUDF failed.", udfFile));
				SendLoadingError("请重启应用,文件数据不存在");
				return;
			}
			SendLoadingVersion("Ver:" + udf.version + " " + getMarketChannel());

			if (string.Compare (udf.ident, m_VersionIdent, true) != 0) {
				m_GameState = ((int)GameState.REQUEST_VERSION << 16) | (int)GameState.EXCEPTION;
				Debug.LogError (string.Format ("[AssetBundle] RequestVersion({0}) failed: UDF's ident({1} : {2}) not adapt.", udfFile, udf.ident, m_VersionIdent));
				return;
			}

			if (udf.svr_list.Count <= 0) {
				m_GameState = ((int)GameState.REQUEST_VERSION << 16) | (int)GameState.EXCEPTION;
				Debug.LogError (string.Format ("[AssetBundle] RequestVersion({0}) failed: UDF's svr_list empty.", udfFile));
				return;
			}

			string rvmFile = m_LocalPath + REMOTE_VERSION_MAP;

			LoadSvrVipPassage ();
			//override svr_list
			{
				VersionMap vm;
				if(Util.JsonHelper.LoadJson<VersionMap>(rvmFile, out vm))
					OverrideSvrAll (vm, udf);
				else
					OverrideSvrAll (null, udf);
			}
			DldManager.urlList = svr_lists;

			m_GameState = ((int)GameState.REQUEST_VERSION << 16) | (int)GameState.WAITING;
			SendLoadingProgress (LOADING_TITLE_COMPARE, 0.5f);

			m_RemoteVersionMap = null;
			m_VersionNumber = string.Empty;

			StartCoroutine(CheckVersionMap(rvmFile, svr_lists, (vm) => {
				SendLoadingProgress (LOADING_TITLE_COMPARE, 1.0f);
				m_GameState = (int)GameState.ENTER_GAME;

				if(vm != null) {
					m_RemoteVersionMap = vm;

					string remoteVersion = AdaptVersion (m_RemoteVersionMap, udf.version);
					int result = CompareVersion(remoteVersion, udf.version);
					if(result < 0) {
						if(result == -1 || result == -2) {
							//清除本地缓存重新进行解压
							if (Directory.Exists (m_LocalPath))
								Directory.Delete (m_LocalPath, true);
							Directory.CreateDirectory (m_LocalPath);

							m_FirstRun = true;
							m_GameState = (int)GameState.EXTRACT_LIST;

							Debug.Log (string.Format ("[AssetBundle] RequestVersion({0}) failed: CompareVersion({1}, {2}) --> {3} MainVersion({4}) ReExtract",
								udfFile, remoteVersion, udf.version, result, MainVersion.Version));

							return;
						}

						//精简版本资源不完整,添加资源判断；如果资源不完整,直接进行
						string commonprefab = getLocalPath("commonprefab/commonprefab_prefab.unity3d");
						if(result == -3 && !File.Exists(commonprefab)) {
							ShowHintNoticePanel("下载最新版本，全新体验升级", ()=>{
								Debug.Log("[AssetBundle] check version failed for first run. so jump website:" + vm.website);
								if(!string.IsNullOrEmpty(vm.website))
									Application.OpenURL(vm.website);
							});

							m_GameState = ((int)GameState.REQUEST_VERSION << 16) | (int)GameState.EXCEPTION;
							return;
						}

						m_ErrorCode = (GameErrorCode)result;
						Debug.LogError (string.Format ("[AssetBundle] RequestVersion({0}) failed: CompareVersion({1}, {2}) failed:{3}.", udfFile, remoteVersion, udf.version, result));

						EvtManager.StartUp(string.Empty, string.Empty);
					} else {
						m_VersionNumber = remoteVersion;

						Debug.Log (string.Format ("[AssetBundle] RequestVersion({0}) version {1} to {2}.", udfFile, udf.version, remoteVersion));

						if(result > 0)
							m_GameState = (int)GameState.CHECK_VERSION;
						else {
							UDF pad = null;
							for (int idx = 0; idx < udf.dirList.Count; ++idx) {
								if (CheckUDFVersion (remoteVersion, udf.dirList[idx], ref pad) != 0) {
									m_GameState = (int)GameState.CHECK_VERSION;
									break;
									//Debug.Log (string.Format ("[AssetBundle] RequestVersion({0}) update {1} to {2} dependVersion({3}) not adapt.", udfFile, udf.version, remoteVersion, udf.dirList[idx]));
								}
							}
						}

						UpdateGameVersionStatus();
						if(m_GameState == (int)GameState.CHECK_VERSION)
							m_HasUpdated = true;

						if(m_RemoteVersionMap.svr_data.Count > 0) {
							svr_datas.Clear();
							OverrideSvr(m_RemoteVersionMap.svr_data, udf.svr_data, ref svr_datas);
							svr_datas.AddRange(svr_vip_datas);

							DebugList("override svr data", svr_datas);
						}
						DldManager.urlList = svr_datas;

						if(m_RemoteVersionMap.svr_game.Count > 0) {
							svr_games.Clear();
							OverrideSvr(m_RemoteVersionMap.svr_game, udf.svr_game, ref svr_games);

							override_svr_games.Clear();
							override_svr_games.AddRange(svr_games);

							svr_games.AddRange(svr_vip_games);

							DebugList("override svr game", svr_games);
						}

						string configVersion = m_RemoteVersionMap.config_version;
						string md5 = m_RemoteVersionMap.config_md5;
						if(PlayerPrefs.HasKey(CHEAT_FORCE_CONFIG)) {
							configVersion = PlayerPrefs.GetString(CHEAT_FORCE_CONFIG);
							md5 = string.Empty;
							//PlayerPrefs.DeleteKey(CHEAT_FORCE_CONFIG);
						}
						EvtManager.StartUp(configVersion, md5);
					}

				} else {
					m_ErrorCode = GameErrorCode.EXP_DL_VERSION_MAP;
					Debug.LogError (string.Format ("[AssetBundle] RequestVersion({0}) failed: download version_map failed.", udfFile));
					ShowHintNoticePanel("获取游戏版本信息失败,请重新运行游戏!");
				}
			}));
		}

		private void CheckVersion() {
			Debug.Log ("[Debug] CheckVersion");

			if (string.IsNullOrEmpty (m_VersionIdent) || string.IsNullOrEmpty (m_VersionNumber)) {
				m_GameState = ((int)GameState.CHECK_VERSION << 16) | (int)GameState.EXCEPTION;
				SendDownloadState(string.Format("Error:CheckVersion({0}, {1}) params invalid", m_VersionIdent, m_VersionNumber));
				Debug.LogError (string.Format("[AssetBundle] CheckVersion({0}, {1}) failed: versionIdent or versionNumber invalid.", m_VersionIdent, m_VersionNumber));
				return;
			}

			m_GameState = ((int)GameState.CHECK_VERSION << 16) | (int)GameState.WAITING;
			StartCoroutine (CheckingVersion ());
		}

		private bool CompareFileMD5(string fileName, string md5)
		{
			if (!File.Exists(fileName))
				return false;

			if (!CheckMD5())
				return false;

			return string.Compare(Util.md5file(fileName), md5, true) == 0;
		}

		private IEnumerator CheckingVersion() {
			SendLoadingProgress (string.Format(LOADING_TITLE_DOWNLOAD, 0), 0.0f);

			DldManager.Reset (true);
			while (!DldManager.IsIdle ()) {
				Debug.Log("[AssetBundle] CheckingVersion wait downloadMgr idle. Downloading count:" + DldManager.GetDownloadingCount());
				yield return new WaitForEndOfFrame();
			}
			DldManager.Reset (false);

			//platform/version/
			string remotePath = PlatformFile(m_VersionNumber + "/");
			string remoteUDFFile = remotePath + GetRelateName (UDF_FILE);
			string localRemoteUDFFile = m_LocalPath + GetRelateName (TMP_UDF_FILE);

			string remoteFile, localFile;
			string md5 = string.Empty;
			int size = 0;

			remoteFile = GetRelateName(UDF_FILE);
			if(!getRemoteGuideFileInfo(remoteFile, ref md5, ref size))
			{
				m_GameState = ((int)GameState.CHECK_VERSION << 16) | (int)GameState.EXCEPTION;
				Debug.LogError(string.Format("[AssetBundle] CheckingVersion({0}) failed: getRemoteGuideFileInfo({1}) failed.", localRemoteUDFFile, remoteFile));
				SendLoadingError("更新文件数据不存在:" + GetRelateName(UDF_FILE));
				SendDownloadState(string.Format("Error:CheckVersion({0}, {1}) udf({2}) invalid", m_VersionIdent, m_VersionNumber, GetRelateName(UDF_FILE)));

				yield break;
			}

			yield return DldManager.Downloading (remoteUDFFile, md5, (bool isOK, byte[] datas) => {
				if (isOK) {
					ResManager.WriteFile (localRemoteUDFFile, datas, 0, datas.Length);
				} else {
					m_GameState = ((int)GameState.CHECK_VERSION << 16) | (int)GameState.EXCEPTION;
					m_ErrorCode = GameErrorCode.EXP_DL_UDF;

					if(IsBasicIdent())
						ShowHintNoticePanel("获取游戏配置失败,请重新运行游戏!");
					else
						SendDownloadState ("Error:" + m_ErrorCode.ToString());

					Debug.LogError (string.Format ("[AssetBundle] CheckingVersion({0}) failed: Download UDF failed.", remoteUDFFile));
				}
			});

			if (HasException ())
				yield break;
			
			Debug.Log ("[Download Debug] CheckingVersion: download remote version OK:" + remoteUDFFile);

			UDF remoteUDF = LoadUDF (localRemoteUDFFile);
			if (remoteUDF == null) {
				m_GameState = ((int)GameState.CHECK_VERSION << 16) | (int)GameState.EXCEPTION;
				Debug.LogError (string.Format ("[AssetBundle] CheckingVersion({0}) failed: Read remoteUDF failed.", localRemoteUDFFile));
				SendLoadingError("读取版本数据失败:" + GetRelateName(UDF_FILE));
				SendDownloadState(string.Format("Error:CheckVersion({0}, {1}) load udf({2}) failed", m_VersionIdent, m_VersionNumber, GetRelateName(UDF_FILE)));

				yield break;
			}

			//depend_udf
			Dictionary<string, VersionFile> dependUDFMap = new Dictionary<string, VersionFile>();
			//file_list
			Dictionary<string, VersionFile> fileListMap = new Dictionary<string, VersionFile> ();

			remoteFile = GetRelateName(FILE_LIST);
			localFile = GetRelateName (TMP_FILE_LIST);
			if (getRemoteGuideFileInfo(remoteFile, ref md5, ref size))
			{
				if(!CompareFileMD5(m_LocalPath + remoteFile, md5))
					fileListMap.Add(localFile, new VersionFile(remoteFile, md5, "#", size));
			}
			else
			{
				m_GameState = ((int)GameState.CHECK_VERSION << 16) | (int)GameState.EXCEPTION;
				Debug.LogError(string.Format("[AssetBundle] CheckingVersion({0}) failed: getRemoteGuideFileInfo({1}) failed.", localRemoteUDFFile, remoteFile));
				SendLoadingError("更新文件列表不存在:" + GetRelateName(FILE_LIST));
				SendDownloadState(string.Format("Error:CheckVersion({0}, {1}) get filelist({2}) md5 failed", m_VersionIdent, m_VersionNumber, remoteFile));
				yield break;
			}

			foreach (string dir in remoteUDF.dirList) {
				remoteFile = dir + "/" + FILE_LIST;
				localFile = dir + "/" + TMP_FILE_LIST;
				if (getRemoteGuideFileInfo(remoteFile, ref md5, ref size))
				{
					if(!CompareFileMD5(m_LocalPath + remoteFile, md5))
						fileListMap.Add(localFile, new VersionFile(remoteFile, md5, "#", size));
				}
				else {
					m_GameState = ((int)GameState.CHECK_VERSION << 16) | (int)GameState.EXCEPTION;
					Debug.LogError (string.Format ("[AssetBundle] CheckingVersion({0}) failed: getRemoteGuideFileInfo({1}) failed.", localRemoteUDFFile, remoteFile));
					SendLoadingError("更新文件列表不存在:" + remoteFile);
					SendDownloadState(string.Format("Error:CheckVersion({0}, {1}) get depend filelist({2}) md5 failed", m_VersionIdent, m_VersionNumber, remoteFile));
					yield break;
				}

				remoteFile = dir + "/" + UDF_FILE;
				localFile = dir + "/" + TMP_UDF_FILE;
				if (getRemoteGuideFileInfo(remoteFile, ref md5, ref size))
				{
					dependUDFMap.Add(localFile, new VersionFile(remoteFile, md5, "#", size));
				}
				else
				{
					m_GameState = ((int)GameState.CHECK_VERSION << 16) | (int)GameState.EXCEPTION;
					Debug.LogError(string.Format("[AssetBundle] CheckingVersion({0}) failed: getRemoteGuideFileInfo({1}) failed.", localRemoteUDFFile, remoteFile));
					SendLoadingError("更新文件数据不存在:" + remoteFile);
					SendDownloadState(string.Format("Error:CheckVersion({0}, {1}) get udf({2}) md5 failed", m_VersionIdent, m_VersionNumber, remoteFile));
					yield break;
				}
			}

			bool isFinish = false;
			if (fileListMap.Count <= 0)
				isFinish = true;
			else
			{
				yield return DownloadFileList(remotePath, m_LocalPath, fileListMap, (currentCnt, total) => {
					SendLoadingProgress(string.Format(LOADING_TITLE_DOWNLOAD, 0), 0.05f * currentCnt / total);
				}, (isOK) => {
					isFinish = isOK;
				});
			}
			
			if (!isFinish) {
				m_GameState = ((int)GameState.CHECK_VERSION << 16) | (int)GameState.EXCEPTION;
				m_ErrorCode = GameErrorCode.EXP_DL_FILELIST;

				if(IsBasicIdent())
					ShowHintNoticePanel("获取游戏数据列表失败,请重新运行游戏!");
				else
					SendDownloadState("Error:" + m_ErrorCode.ToString());

				Debug.LogError (string.Format ("[AssetBundle] CheckingVersion({0}) failed: Download filelists failed.", remoteUDFFile));

				yield break;
			}

			//compare
			long downloadBytes = 0;
			List<string> removeFiles = new List<string> ();
			Dictionary<string, VersionFile> updateFileMap = new Dictionary<string, VersionFile> ();
			if ((downloadBytes = CompareFileLists (fileListMap, ref updateFileMap, ref removeFiles)) < 0) {
				m_GameState = ((int)GameState.CHECK_VERSION << 16) | (int)GameState.EXCEPTION;
				SendDownloadState(string.Format("Error:CheckVersion({0}, {1}) compare failed", m_VersionIdent, m_VersionNumber));
				Debug.LogError (string.Format ("[AssetBundle] CheckingVersion({0}) failed: CompareFileLists filelists failed.", remoteUDFFile));

				yield break;
			}

			Debug.Log ("[Download Debug] CheckingVersion: download updateFiles: " + updateFileMap.Count);

			if (updateFileMap.Count > 0) {
				//登陆下载，大于阈值更新需要提示
				if (IsBasicIdent ())
					yield return CheckInternetCarrierHint (downloadBytes);

				//todo
				if(m_LoadingPanel != null)
					m_LoadingPanel.StartSwitchingDisplay (ResManager);

				isFinish = false;
				yield return DownloadFileList (remotePath, m_LocalPath, updateFileMap, (currentCnt, total) => {
					float percent = 0.05f + 0.9f * currentCnt / total;
					SendLoadingProgress (string.Format(LOADING_TITLE_DOWNLOAD, (int)(percent * 100)), percent);
					SendDownloadProgress(percent);
				}, (bool isOK) => {
					isFinish = isOK;

					if (isOK)
						Debug.Log(string.Format("[AssetBundle] CheckingVersion({0}) Download All OK", remoteUDFFile));
					else
						Debug.LogError(string.Format("[AssetBundle] CheckingVersion({0}) Download All Failed", remoteUDFFile));
				});

				if (!isFinish) {
					m_GameState = ((int)GameState.CHECK_VERSION << 16) | (int)GameState.EXCEPTION;
					m_ErrorCode = GameErrorCode.EXP_DL_DATA;
					if(IsBasicIdent())
						ShowHintNoticePanel("获取游戏数据失败,请重新运行游戏!");
					else
						SendDownloadState ("Error:" + m_ErrorCode.ToString ());

					Debug.LogError (string.Format ("[AssetBundle] CheckingVersion({0}) failed: Download bundles failed.", remoteUDFFile));
					yield break;
				}
			}

			if (removeFiles.Count > 0) {
				foreach (string file in removeFiles)
				{
					if(File.Exists(m_LocalPath + file))
						File.Delete(m_LocalPath + file);
				}
			}

			ApplyUpdateFiles (m_LocalPath, fileListMap, false);

			isFinish = false;
			yield return DownloadFileList(remotePath, m_LocalPath, dependUDFMap, (currentCnt, total) => {
				float percent = 0.95f + 0.05f * currentCnt / total;
				SendLoadingProgress(string.Format(LOADING_TITLE_DOWNLOAD, (int)(percent * 100)), percent);
				SendDownloadProgress(percent);
			}, (isOK) => {
				isFinish = isOK;
			});

			if (!isFinish)
			{
				m_GameState = ((int)GameState.CHECK_VERSION << 16) | (int)GameState.EXCEPTION;
				m_ErrorCode = GameErrorCode.EXP_DL_UDF;

				if (IsBasicIdent())
					ShowHintNoticePanel("获取游戏依赖配置失败,请重新运行游戏!");
				else
					SendDownloadState("Error:" + m_ErrorCode.ToString());

				Debug.LogError(string.Format("[AssetBundle] CheckingVersion({0}) failed: Download dependUDF failed.", remoteUDFFile));

				yield break;
			}

			ApplyUpdateFiles(m_LocalPath, dependUDFMap, false);

			//udf
			File.Copy (localRemoteUDFFile, m_LocalPath + GetRelateName (UDF_FILE), true);
			File.Delete (localRemoteUDFFile);

			Debug.Log (string.Format("Update Finish. MoveUDF ({0} to {1})", localRemoteUDFFile, GetRelateName(UDF_FILE)));

			m_SetupManifest = true;
			m_GameState = (int)GameState.ENTER_GAME;

			SendLoadingProgress (string.Format(LOADING_TITLE_DOWNLOAD, 100), 1.0f);
			SendDownloadProgress(1.0f);
		}

		private IEnumerator RunningGame(Action<bool> callback) {
			bool result = true;

			if (IsCheckVersion () && ResManager.UseAssetBundle ()) {
				string[] dots = new string[] { "", ".", ".  .", ".  .  .", ".  .  .  .", ".  .  .  .  .", ".  .  .  .  .  ." };
				int dotIdx = 0;
				//event
				int eventStatus = 0;
				while ((eventStatus = EvtManager.Status) == 0) {
					SendLoadingProgress (LOADING_TITLE_ENTERING + dots[dotIdx], 1.0f);
					dotIdx = ++dotIdx % dots.Length;
					yield return new WaitForSeconds(0.1f);
				}
				result = eventStatus > 0;

				if(result)
					SendLoadingProgress (LOADING_TITLE_ENTERING + ".     .  .     .", 1.0f);
				else
					SendLoadingProgress (LOADING_TITLE_ENTERING + ".  .        .  .", 1.0f);
			}

			callback.Invoke (result);
		}

		private void EnterGame() {
			m_GameState = ((int)GameState.ENTER_GAME << 16) | (int)GameState.WAITING;

			ResManager.SetupManifest ();
			m_SetupManifest = false;

			UpdateGameVersionStatus ();

			StartCoroutine (RunningGame ((bool isOK) => {
				m_GameState = (int)GameState.RUNNING;

				Debug.Log ("[AssetBundle] EnterGame. RunningGame : " + m_GameState);

				if (IsBasicIdent ()) {
					//这里注册预加载部分资源,这部分资源需要在切换场景前完成
					ResManager.AddToAssetTable("LodingPanel.prefab", AssetLife.AL_RESIDENT);
					ResManager.AddToAssetTable("FullSceneJHPrefab.prefab", AssetLife.AL_RESIDENT);

					AppFacade.Instance.SendMessageCommand (NotiConst.ENTER_MAIN);
				} else {
					SendDownloadState (m_VersionIdent);

					Debug.Log ("[AssetBundle] Update Finish. EnterGame : " + m_VersionIdent);
				}

			}));
		}

		private void EnterScene ()
		{
		}

		public void LoadSceneStart()
		{
			m_GameState = (int)GameState.ENTER_SCENE;

			if (m_LoadingPanel != null)
				m_LoadingPanel.SetActive (true);
		}
		public void LoadSceneFinish()
        {
            m_GameState = (int)GameState.RUNNING;

			if (m_LoadingPanel != null)
				m_LoadingPanel.SetActive (false);
        }

		private VersionMap FindVersionMap(string ident) {
			if (m_RemoteVersionMap == null)
				return null;
			for (int idx = 0; idx < m_RemoteVersionMap.games.Count; ++idx) {
				if (string.Compare (m_RemoteVersionMap.games [idx].Name, ident, true) == 0)
					return m_RemoteVersionMap;
			}
			return null;
		}
		private GameInfo FindRemoteGameInfo(string ident) {
			if (m_RemoteVersionMap == null)
				return null;

			for (int idx = 0; idx < m_RemoteVersionMap.games.Count; ++idx) {
				if (string.Compare (m_RemoteVersionMap.games [idx].Name, ident, true) == 0)
					return m_RemoteVersionMap.games [idx];
			}

			return null;
		}

		private String AdaptVersion (VersionMap vm, string basicVersion)
		{
			String adaptVersion = vm.last_version;

			if (vm.history.Count > 0) {
				Dictionary<string, string> versionGraph = new Dictionary<string, string> ();

				bool finded = false;
				string[] item = { };
				for (int idx = 0; idx < vm.history.Count; ++idx) {
					//old --> new
					item = vm.history [idx].Split ('|');
					if (item == null || item.Length != 2) {
						Debug.LogWarning (string.Format ("[AssetBundle] AdaptVersion exception: Parse history({0}) failed.", idx));
						continue;
					}
					if (string.Compare (basicVersion, item [0]) == 0) {
						adaptVersion = item [1];
						finded = true;
					}
					versionGraph.Add (item [0], item [1]);
				}

				if (finded) {
					string nextVersion = string.Empty;
					while (versionGraph.TryGetValue (adaptVersion, out nextVersion) && String.Compare (adaptVersion, nextVersion) != 0)
						adaptVersion = nextVersion;
				}
			}

			//cheat force version
			if (PlayerPrefs.HasKey (CHEAT_FORCE_VERSION)) {
				adaptVersion = PlayerPrefs.GetString (CHEAT_FORCE_VERSION);
				m_RemoteVersionMap.check_md5 = false;
				Debug.Log ("[AssetBundle] AdaptVersion ForceVersion:" + adaptVersion);
			}

			return adaptVersion;
		}

		public void SetForceVersion(string version) {
			if (string.IsNullOrEmpty (version))
				PlayerPrefs.DeleteKey (CHEAT_FORCE_VERSION);
			else
				PlayerPrefs.SetString (CHEAT_FORCE_VERSION, version);
			Debug.Log ("[AssetBundle] SetForceVersion:" + version);
		}

		public void SetForceConfig(string version) {
			if (string.IsNullOrEmpty (version))
				PlayerPrefs.DeleteKey (CHEAT_FORCE_CONFIG);
			else
				PlayerPrefs.SetString (CHEAT_FORCE_CONFIG, version);
			Debug.Log ("[AssetBundle] SetForceConfig:" + version);
		}

		public static UDF LoadUDF (string udfFile)
		{
			UDF udf;
			if (!Util.JsonHelper.LoadJson<UDF> (udfFile, out udf)) {
				Debug.LogWarning (string.Format ("[AssetBundle] LoadUDF LoadJson({0}) failed.", udfFile));
			}
			return udf;
		}

		private string PlatformFile (string file)
		{
			switch (Application.platform) {
			case RuntimePlatform.Android:
				return "Android/" + file;
			case RuntimePlatform.IPhonePlayer:
				return "IOS/" + file;
			case RuntimePlatform.WindowsPlayer:
			case RuntimePlatform.WindowsEditor:
				return "Windows/" + file;
			case RuntimePlatform.OSXEditor:
			case RuntimePlatform.OSXPlayer:
				return "Mac/" + file;
			default:
				return "Nonsupport RuntimePlatform";
			}
		}

		private bool _HangUp = false;
		public bool IsHangUp() {
			return _HangUp;
		}
		public void HandleOnBackGround() {
			_HangUp = true;
		}
		public void HandleOnForeGround() {
			_HangUp = false;
		}

		//GPS
		public string GetCityName() {
			GPS gps = gameObject.GetComponent<GPS> ();
			if (gps == null)
				return string.Empty;
			return gps.GetCityName ();
		}
		public float GetLatitude() {
			GPS gps = gameObject.GetComponent<GPS> ();
			if (gps == null)
				return 0.0f;
			return gps.GetLatitude ();
		}

		public float GetLongitude() {
			GPS gps = gameObject.GetComponent<GPS> ();
			if (gps == null)
				return 0.0f;
			return gps.GetLongitude ();
		}

		public bool CheckLuaExist(string fileName) {
			return EvtManager.CheckLuaExist (fileName);
		}

		public bool ReadLuaPatch(string fileName, ref byte[] data) {
			return EvtManager.ReadLocal (fileName, ref data);
		}

		#region begin "compare file list"
		//[file] = md5|code|size
		private int ParseFileList(string fileName, ref Dictionary<string, VersionFile> fileMap) {
			if (!File.Exists (fileName))
				return 0;

			string[] lines = File.ReadAllLines (fileName);
			if (lines == null || lines.Length <= 0)
				return 0;

			string[] item = { };
			foreach (string line in lines) {
				if (string.IsNullOrEmpty (line))
					continue;

				item = line.Split ('|');
				if (item.Length != 4) {
					Debug.LogError (string.Format ("[AssetBundle] ParseFileList({0}) failed: line({1}) invalid.", fileName, line));
					return -1;
				}

				fileMap.Add (item [0], new VersionFile (item [0], item [1], item[2], int.Parse (item [3])));
			}

			return fileMap.Count;
		}

		//filename|md5|code|size
		private long CompareFileList(string remoteFile, string localFile, ref Dictionary<string, VersionFile> updateFiles, ref List<string> removeFiles) {
			if (!File.Exists (remoteFile)) {
				Debug.LogError (string.Format ("[AssetBundle] CompareFileList({0}, {1}) failed: remoteFile not exist.", remoteFile, localFile));
				return -1;
			}

			string[] lines = File.ReadAllLines (remoteFile);
			if (lines == null || lines.Length <= 0) {
				Debug.LogError (string.Format ("[AssetBundle] CompareFileList({0}, {1}) failed: remoteFile is empty.", remoteFile, localFile));
				return -1;
			}

			Dictionary<string, VersionFile> fileMap = new Dictionary<string, VersionFile> ();
			if (ParseFileList (localFile, ref fileMap) < 0) {
				Debug.LogError (string.Format ("[AssetBundle] CompareFileList({0}, {1}) failed: ParseFileList failed.", remoteFile, localFile));
				return -1;
			}

			long downloadBytes = 0;
			string[] item = { };
			int size = 0;
			if (fileMap.Count == 0) {
				foreach (string line in lines) {
					if (string.IsNullOrEmpty (line))
						continue;

					item = line.Split ('|');
					if (item == null || item.Length != 4) {
						Debug.LogError (string.Format ("[AssetBundle] CompareFileList({0}, {1}) failed: remoteFile line({2}) invalid.", remoteFile, localFile, line));
						return -1;
					}

					size = int.Parse (item [3]);
					updateFiles.Add (item [0], new VersionFile (item[0], item[1], item[2], size));

					downloadBytes += size;
				}
			} else {
				List<string> commonFiles = new List<string> ();
				VersionFile vf;
				foreach (string line in lines) {
					if (string.IsNullOrEmpty (line))
						continue;

					item = line.Split ('|');
					if (item == null || item.Length != 4) {
						Debug.LogError (string.Format ("[AssetBundle] CompareFileList({0}, {1}) failed: remoteFile line({2}) invalid.", remoteFile, localFile, line));
						return -1;
					}

					size = int.Parse (item [3]);
					if (fileMap.TryGetValue (item [0], out vf)) {
						commonFiles.Add (item [0]);

						if(UseUpdateTiny() && string.Compare(item[2], "#", true) != 0)
						{
							if (string.Compare(vf.Code, item[2], true) == 0)
								continue;
						}
						else
						{
							if (string.Compare(vf.MD5, item[1], true) == 0)
								continue;
						}
					}

					updateFiles.Add(item[0], new VersionFile(item[0], item[1], item[2], size));
						
					downloadBytes += size;
				}

				foreach (string file in commonFiles)
					fileMap.Remove (file);

				if (fileMap.Count > 0) {
					Debug.Log (string.Format("[Debug] AssetBundle CompareFileList(({0}, {1}) removeFileList:", remoteFile, localFile));

					foreach (string file in fileMap.Keys) {
						removeFiles.Add (file);
						Debug.Log ("\t" + file);
					}
				}

			}

			return downloadBytes;
		}

		//<tmp_xxx, xxx>
		private long CompareFileLists(Dictionary<string, VersionFile> fileLists, ref Dictionary<string, VersionFile> updateFiles, ref List<string> removeFiles) {
			long totalBytes = 0, updateBytes = 0;
			string remoteFile, localFile;
			foreach (KeyValuePair<string, VersionFile> kv in fileLists) {
				remoteFile = m_LocalPath + kv.Key;
				localFile = m_LocalPath + kv.Value.Name;
				if ((updateBytes = CompareFileList (remoteFile, localFile, ref updateFiles, ref removeFiles)) < 0) {
					Debug.LogError (string.Format ("[AssetBundle] CompareFileLists failed: CompareFileList({0}, {1})  failed.", remoteFile, localFile));
					return -1;
				}
				totalBytes += updateBytes;
			}

			return totalBytes;
		}

		//<tmp_xxx, xxx>
		private IEnumerator DownloadFileList(string remotePath, string localPath, Dictionary<string, VersionFile> fileMap, Action<int, int> callbackProgress, Action<bool> callbackStatus) {
			HashSet<string> successSet = new HashSet<string> ();
			HashSet<string> failedSet = new HashSet<string> ();

			foreach (KeyValuePair<string, VersionFile> kv in fileMap) {
				DldManager.Push (remotePath + kv.Value.Name, localPath + kv.Key + TMP_SUFFIX, kv.Value.MD5, (bool isOK, string fn) => {
					//Debug.Log("[AssetBundle] DownloadFileList callback:" + fn + ", " + isOK);

					if(isOK)
						successSet.Add(fn);
					else
						failedSet.Add(fn);
				});
			}
			while ((successSet.Count + failedSet.Count) < fileMap.Count) {
				if (callbackProgress != null)
					callbackProgress.Invoke (successSet.Count + failedSet.Count, fileMap.Count);
				
				yield return new WaitForSeconds(0.1f);
			}

			if(callbackProgress != null)
				callbackProgress.Invoke (fileMap.Count, fileMap.Count);

			if (failedSet.Count <= 0)
				ApplyUpdateFiles (localPath, fileMap, true);

			if (callbackStatus != null)
				callbackStatus.Invoke (failedSet.Count <= 0);
		}

		private void ApplyUpdateFiles(string localPath, Dictionary<string, VersionFile> updateFileMap, bool suffix) {
			if (suffix) {
				foreach (KeyValuePair<string, VersionFile> kv in updateFileMap) {
					Debug.Log ("\t" + kv.Key + TMP_SUFFIX + " --> " + kv.Key);
					File.Copy (localPath + kv.Key + TMP_SUFFIX, localPath + kv.Key, true);
					File.Delete (localPath + kv.Key + TMP_SUFFIX);
				}
			} else {
				foreach (KeyValuePair<string, VersionFile> kv in updateFileMap) {
					Debug.Log ("\t" + kv.Key + " --> " + kv.Value.Name);
					File.Copy (localPath + kv.Key, localPath + kv.Value.Name, true);
					File.Delete (localPath + kv.Key);
				}
			}
		}

		#endregion

		#region begin "svr list"

		private void LoadSvrVipPassage() {
			string fileName = m_LocalPath + SVR_VIP_PASSAGE;
			if (!File.Exists (fileName))
				return;

			SVRVipPassage svp;
			if (!Util.JsonHelper.LoadJson<SVRVipPassage> (fileName, out svp)) {
				Debug.LogError ("[GameManager] LoadSvrVipPassage LoadJson failed.");
				return;
			}

			MixingSpliceList (svp.svr_list, ref svr_vip_lists, ',');
			MixingSpliceList (svp.svr_data, ref svr_vip_datas, ',');
			MixingSpliceList (svp.svr_game, ref svr_vip_games, ',');

			{
				DebugList ("vip list", svr_vip_lists);
				DebugList ("vip data", svr_vip_datas);
				DebugList ("vip game", svr_vip_games);
			}
		}

		private void OverrideSvr(List<string> list1, List<string> list2, ref List<string> result) {
			MixingSpliceList (list1, ref result, ',');
			if (result.Count <= 0)
				MixingSpliceList (list2, ref result, ',');
		}
		private void OverrideSvrAll(VersionMap vm, UDF udf) {
			if (vm != null) {
				OverrideSvr (vm.svr_list, null, ref svr_lists);
				OverrideSvr (vm.svr_data, null, ref svr_datas);
				OverrideSvr (vm.svr_game, null, ref svr_games);
			}

			if (udf != null) {
				OverrideSvr (null, udf.svr_list, ref svr_lists);
				OverrideSvr (null, udf.svr_data, ref svr_datas);
				OverrideSvr (null, udf.svr_game, ref svr_games);
			}

			svr_lists.AddRange (svr_vip_lists);
			svr_datas.AddRange (svr_vip_datas);
			svr_games.AddRange (svr_vip_games);

			{
				DebugList ("load svr list", svr_lists);
				DebugList ("load svr data", svr_datas);
				DebugList ("load svr game", svr_games);
			}
		}

		private void MixingSpliceList(List<string> list, ref List<string> result, char split) {
			if (list == null || list.Count <= 0)
				return;

			string[] items = { };
			int index = 0;
			string item = string.Empty;
			foreach (string line in list) {
				items = line.Split (split);
				if (items == null || items.Length <= 0)
					continue;

				if (items.Length > 1) {
					for (int idx = 0; idx < items.Length; ++idx) {
						index = UnityEngine.Random.Range (0, idx);
						item = items [index];
						items [index] = items [idx];
						items [idx] = item;
					}
				}

				for (int idx = 0; idx < items.Length; ++idx) {
					if (result.Contains (items [idx]))
						continue;
					result.Add (items [idx]);
				}
			}
		}

		private void DebugList(string title, List<string> list) {
			Debug.Log ("[GameManager] debug list:" + title);
			foreach (string item in list)
				Debug.Log ("\t" + item);
		}

		#endregion

		#region begin "Lua interface"
		//use urlFile
		public void DownloadURLFile(string urlFile, string localFile, LuaFunction func) {
			StartCoroutine(DldManager.DownloadingURL (urlFile, (bool isOK, byte[] data) => {
				if(isOK) {
					ResManager.WriteFile(localFile, data, 0, data.Length);
					if(func != null)
						func.Call(localFile, true);
				} else {
					Debug.LogError("[Download] DownloadURLFile failed:" + urlFile);
					if(func != null)
						func.Call(localFile, false);
				}
			}));
		}

		//use url & cdn list
		public void DownloadFile(string remoteFile, string md5, string localFile, LuaFunction func) {
			StartCoroutine (DldManager.Downloading (remoteFile, md5, (isOK, data) => {
				if(isOK) {
					ResManager.WriteFile(localFile, data, 0, data.Length);
					if(func != null)
						func.Call(localFile, true);
				} else {
					Debug.LogError("[Download] DownloadFile failed:" + remoteFile + " : " + md5);
					if(func != null)
						func.Call(localFile, false);
				}
			}));
		}

		public void DownloadFiles(string remotePath, string localPath, string[] assetNames, LuaFunction func, LuaFunction percentCallback) {
			if (assetNames.Length <= 0) {
				Debug.LogError ("[Download] DownloadFiles assets is empty:" + localPath);
				if(percentCallback != null) percentCallback.Call(1.0f);
				if(func != null) func.Call(false);
			}

			Dictionary<string, VersionFile> fileMap = new Dictionary<string, VersionFile> ();
			for (int idx = 0; idx < assetNames.Length; ++idx)
				fileMap.Add (assetNames [idx], new VersionFile (assetNames [idx]));

			//<tmp_xxx, xxx>
			StartCoroutine (DownloadFileList (remotePath, localPath, fileMap, (currentCnt, totalCnt) => {
				if(percentCallback != null)
					percentCallback.Call((float)currentCnt / totalCnt);
			}, (isOK) => {
				if(func != null) func.Call(isOK);
			}));
		}

		public void CheckFilesUpdate(string remotePath, string localPath, string fileListName, string md5, LuaFunction percentCallback, LuaFunction func) {
			StartCoroutine (CheckFilesUpdate (remotePath, localPath, fileListName, md5, (current, total) => {
				if (percentCallback != null)
					percentCallback.Call ((float)current / total);
			}, (isOK) => {
				if (func != null)
					func.Call (isOK);
			}));
		}

		[NoToLua]
		public IEnumerator CheckFilesUpdate(string remotePath, string localPath, string fileListName, string md5, Action<int, int> percentCallback, Action<bool> stateCallback) {
			string localTempFile = localPath + fileListName + TMP_SUFFIX;
			string localSaveFile = localPath + fileListName;

			bool hasException = false;
			yield return DldManager.Downloading (remotePath + fileListName, md5, (isOK, data) => {
				if(isOK)
					ResManager.WriteFile(localTempFile, data, 0, data.Length);
				else {
					hasException = true;
					Debug.LogError("[Download] CheckFilesUpdate failed(download filelist):" + remotePath + fileListName);
				}
			});

			if (hasException) {
				if (stateCallback != null)
					stateCallback.Invoke (false);
				
				yield break;
			}

			Dictionary<string, VersionFile> fileMap = new Dictionary<string, VersionFile> ();
			List<string> removeList = new List<string>();
			if(CompareFileList(localTempFile, localSaveFile, ref fileMap, ref removeList) < 0) {
				Debug.LogError("[Download] CheckFilesUpdate CompareFileList failed:" + remotePath + fileListName);

				if (stateCallback != null)
					stateCallback.Invoke (false);
				
				yield break;
			}

			yield return DownloadFileList (remotePath, localPath, fileMap, percentCallback, (isOK) => {
				if(!isOK) {
					hasException = true;
					Debug.LogError("[Download] CheckFilesUpdate failed(download data):" + remotePath + fileListName);
				}
			});

			if (hasException) {
				if (stateCallback != null)
					stateCallback.Invoke (false);

				yield break;
			}

			if (removeList.Count > 0) {
				foreach (string file in removeList)
					File.Delete (localPath + file);
			}

			File.Copy(localTempFile, localSaveFile, true);
			File.Delete(localTempFile);

			if (stateCallback != null)
				stateCallback.Invoke (true);
		}

		#endregion





		IEnumerator TestDownload() {
			Dictionary<string, VersionFile> fileMap = new Dictionary<string, VersionFile>();
			Dictionary<string, VersionFile> updateFiles = new Dictionary<string, VersionFile>();
			List<string> removeFiles = new List<string> ();
			//long totalBytes = CompareFileList (m_StreamingPath + "file_list_remote.txt", m_StreamingPath + FILE_LIST, ref fileMap, ref removeFiles);

			fileMap.Add ("commonprefab/file_list_remote.txt", new VersionFile ("commonprefab/" + FILE_LIST));
			fileMap.Add ("normal_ddz_common/file_list_remote.txt", new VersionFile ("normal_ddz_common/" + FILE_LIST));
			fileMap.Add ("normal_mj_common/file_list_remote.txt", new VersionFile ("normal_mj_common/" + FILE_LIST));
			long totalBytes = CompareFileLists(fileMap, ref updateFiles, ref removeFiles);

			List<string> urls = new List<string> ();
			urls.Add ("http://cdnjydown.jyhd919.cn/jydown/Version2019/V12/");
			DldManager.urlList = urls;

			yield return DownloadFileList ("Windows/12.1.1/", m_LocalPath, updateFiles, (current, total) => {
			}, (isOK) => {
				Debug.Log("isOK:" + isOK);
			});

			Debug.Log (totalBytes);
		}

	}
}
