using UnityEngine;
using System.IO;

/// <summary>
/// 程序固定基本信息定义
/// </summary>
public partial class AppDefine
{
    public static string m_CurrentProjectPath = string.Empty;

    /// <summary>
    /// 当前项目名
    /// </summary>
    public static string CurrentProjectPath
    {
        get
        {
            if (m_CurrentProjectPath == string.Empty)
                m_CurrentProjectPath = PlayerPrefs.GetString("CurrentProjectPath");

            return m_CurrentProjectPath;
        }
        set
        {
            if (m_CurrentProjectPath != value)
            {
                m_CurrentProjectPath = value;
                PlayerPrefs.SetString("CurrentProjectPath", value);
            }
        }
    }

    /// <summary>
    /// 获取平台字符串
    /// </summary>
    /// <returns></returns>
    static string GetPlatformString()
    {
#if UNITY_EDITOR
        switch (UnityEditor.EditorUserBuildSettings.activeBuildTarget)
        {
            case UnityEditor.BuildTarget.Android:
                return "Android";
            case UnityEditor.BuildTarget.iOS:
                return "iOS";
            case UnityEditor.BuildTarget.StandaloneWindows:
            case UnityEditor.BuildTarget.StandaloneWindows64:
            case UnityEditor.BuildTarget.StandaloneOSXIntel64:
            case UnityEditor.BuildTarget.StandaloneOSXIntel:
            case UnityEditor.BuildTarget.StandaloneOSX:
            case UnityEditor.BuildTarget.StandaloneLinux64:
            case UnityEditor.BuildTarget.StandaloneLinux:
            case UnityEditor.BuildTarget.StandaloneLinuxUniversal:
                return "Windows";
            default:
                return null;
        }
#else
        switch (Application.platform)
        {
            case RuntimePlatform.Android:
                return "Android";
            case RuntimePlatform.IPhonePlayer:
                return "iOS";
            case RuntimePlatform.WindowsPlayer:
            case RuntimePlatform.WindowsEditor:
            case RuntimePlatform.LinuxEditor:
            case RuntimePlatform.OSXEditor:
                return "Windows";
            default:
                return null;
        }
#endif
    }
    /// <summary>
    /// 平台路径
    /// </summary>
    public static string PlatformPath = GetPlatformString();

#if UNITY_EDITOR
    //private static string m_Loacl_Data_Path = string.Format("C:/Test/{0}/{1}", PlatformPath, "Cache/Data");
    private static string m_Loacl_Data_Path = string.Format("{0}/{1}/{2}", Application.persistentDataPath, PlatformPath, "Cache/Data");
#else
    private static string m_Loacl_Data_Path = string.Format("{0}/{1}/{2}", Application.persistentDataPath, PlatformPath, "Cache/Data");
#endif
    /// <summary>
    /// 本地数据根目录
    /// </summary>
    public static string LOCAL_DATA_PATH
    {
        get
        {
            return m_Loacl_Data_Path;
        }
    }
    public static bool IsEDITOR()
    {
#if UNITY_EDITOR
        return true;
#else
        return false;
#endif
    }
    /// <summary>
    /// AssetBundle模式
    /// </summary>
    public static bool IsLuaBundleMode
    {
        get
        {
            return PlayerPrefs.GetInt("IsLuaBundleMode", 1) == 1;
        }
        set
        {
            if (value)
            {
                PlayerPrefs.SetInt("IsLuaBundleMode", 1);
            }
            else
            {
                PlayerPrefs.SetInt("IsLuaBundleMode", 0);
            }
        }
    }

        /// <summary>
    /// AssetBundle模式
    /// </summary>
    public static bool IsDebug
    {
        get
        {
            return PlayerPrefs.GetInt("IsDebug", 1) == 1;
        }
        set
        {
            if (value)
            {
                PlayerPrefs.SetInt("IsDebug", 1);
                Debug.unityLogger.logEnabled = true;
            }
            else
            {
                PlayerPrefs.SetInt("IsDebug", 0);
                Debug.unityLogger.logEnabled = false;   
            }
        }
    }
    public static string CurResPath
    {
        get
        {
            string path = "";
            if (AppDefine.IsEDITOR())
            {                
                path = Application.dataPath;
            }
            else
            {
                path = AppDefine.LOCAL_DATA_PATH;
            }
            path = path + "/BY_CurResPath.txt";
            if (File.Exists(path) )
            {
                string ss = File.ReadAllText(path);
                if (ss == null || ss == "")
                {
                    return "main";
                }
                return ss;
            }
            else
            {
                return "main";
            }
        }
        set
        {
            string path = "";
            if (AppDefine.IsEDITOR())
            {                
                path = Application.dataPath;
            }
            else
            {
                path = AppDefine.LOCAL_DATA_PATH;
            }
            File.WriteAllText(path + "/BY_CurResPath.txt", value);
        }
    }

	#if UNITY_EDITOR
    /// <summary>
    /// 当前渠道
    /// </summary>
    private static string m_curQuDao;
    public static string CurQuDao
    {
        get
        {
            if (!string.IsNullOrEmpty(m_curQuDao))
                return m_curQuDao;

            m_curQuDao = "main";

            string path = "";
            if (AppDefine.IsEDITOR())
            {                
                path = Application.dataPath;
            }
            else
            {
                path = AppDefine.LOCAL_DATA_PATH;
            }
            path = path + "/JYDDZ_CurQuDao.txt";
            if (File.Exists(path) )
            {
                string ss = File.ReadAllText(path);
                if (!string.IsNullOrEmpty(ss))
                    m_curQuDao = ss;
            }
            return m_curQuDao;
        }
        set
        {
            m_curQuDao = value;

            string path = "";
            if (AppDefine.IsEDITOR())
            {                
                path = Application.dataPath;
            }
            else
            {
                path = AppDefine.LOCAL_DATA_PATH;
            }
            File.WriteAllText(path + "/JYDDZ_CurQuDao.txt", value);
        }
    }

	#else
		public static string CurQuDao
		{
			get {
				Debug.LogError("CurQuDao only run in editor mode");
				return string.Empty;
			}
			set {
				Debug.LogError("CurQuDao only run in editor mode");
			}
		}

    #endif

}