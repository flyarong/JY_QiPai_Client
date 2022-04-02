using UnityEditor;
using UnityEngine;

public class ProjectMenu : EditorWindow
{
    const string NEWGAMEMENU = "Assets/新建游戏";
    const string SETCURRENTMENU = "Assets/设置为当前项目";

    /// <summary>
    /// 项目名称
    /// </summary>
    private string gameName = "";
    //绘制窗口时调用
    void OnGUI()
    {
        gameName = GUILayout.TextField(gameName, GUILayout.Height(50));
        if (GUILayout.Button("确定", GUILayout.Height(30)))
        {
            if (gameName != "")
            {
                ProjectEditUtility.CreateGameTemplateForlders(gameName);
                this.Close();
            }
            else
            {
                Debug.Log("<color=red>项目名不能为空！！！</color>");
            }
        }
    }
    [MenuItem(NEWGAMEMENU, true, 60)]
    public static bool CreateGameValidate()
    {
        string[] assetGUIDArray = Selection.assetGUIDs;

        if (assetGUIDArray.Length == 1)
            return AssetDatabase.GUIDToAssetPath(assetGUIDArray[0]) == "Assets";

        return false;
    }
    // 新建游戏
    [MenuItem(NEWGAMEMENU, false, 60)]
    public static void CreateGame()
    {
        //创建窗口
        Rect wr = new Rect(0, 0, 400, 200);
        ProjectMenu window = (ProjectMenu)EditorWindow.GetWindowWithRect(typeof(ProjectMenu), wr, true, "新建游戏名");
        window.Show();
    }

    // 设置为当前项目目录
    [MenuItem(SETCURRENTMENU, false, 61)]
    public static void SetCurrentProject()
    {
        string[] assetGUIDArray = Selection.assetGUIDs;

        if (assetGUIDArray.Length == 1)
            AppDefine.CurrentProjectPath = AssetDatabase.GUIDToAssetPath(assetGUIDArray[0]);
    }

    [MenuItem(SETCURRENTMENU, true, 61)]
    public static bool SelectProjectFounderValidate()
    {
        string[] assetGUIDArray = Selection.assetGUIDs;

        if (assetGUIDArray.Length == 1)
        {
            string path = AssetDatabase.GUIDToAssetPath(Selection.assetGUIDs[0]);
            return path == "Assets/Hall" || (path.Split('/').Length == 3 && path.Contains("Assets/Game"));
        }

        return false;
    }
    
    const string kSimulateAssetBundlesMenu = "Dev/模拟AssetBundles";

    [MenuItem(kSimulateAssetBundlesMenu, false, 1)]
    public static void ToggleSimulateAssetBundle()
    {
        AppDefine.IsLuaBundleMode = !AppDefine.IsLuaBundleMode;
    }

    [MenuItem(kSimulateAssetBundlesMenu, true, 1)]
    public static bool ToggleSimulateAssetBundleValidate()
    {
        Menu.SetChecked(kSimulateAssetBundlesMenu, AppDefine.IsLuaBundleMode);
        return true;
    }

    const string kSimulateDebug = "Dev/Debug开关";

    [MenuItem(kSimulateDebug, false, 1)]
    public static void ToggleSimulateDebug()
    {
        AppDefine.IsDebug = !AppDefine.IsDebug;
    }

    [MenuItem(kSimulateDebug, true, 1)]
    public static bool ToggleSimulateDebugValidate()
    {
        Menu.SetChecked(kSimulateDebug, AppDefine.IsDebug);
        return true;
    }

    const string kLocal1Menu = "Dev/渠道/Local1";
    [MenuItem(kLocal1Menu, false, 20)]
    public static void ToggleLocal1()
    {
        Debug.Log(Application.dataPath);
        Debug.Log("Local1");
        AppDefine.CurQuDao = "Local1";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kLocal1Menu, true, 20)]
    public static bool ToggleLocal1Validate()
    {
        if ("Local1" == AppDefine.CurQuDao)
            Menu.SetChecked(kLocal1Menu, true);
        else
            Menu.SetChecked(kLocal1Menu, false);
        return true;
    }

    const string kLocal2Menu = "Dev/渠道/Local2";
    [MenuItem(kLocal2Menu, false, 20)]
    public static void ToggleLocal2()
    {
        Debug.Log(Application.dataPath);
        Debug.Log("Local2");
        AppDefine.CurQuDao = "Local2";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kLocal2Menu, true, 20)]
    public static bool ToggleLocal2Validate()
    {
        if ("Local2" == AppDefine.CurQuDao)
            Menu.SetChecked(kLocal2Menu, true);
        else
            Menu.SetChecked(kLocal2Menu, false);
        return true;
    }

    const string kLocal3Menu = "Dev/渠道/Local3";
    [MenuItem(kLocal3Menu, false, 20)]
    public static void ToggleLocal3()
    {
        Debug.Log(Application.dataPath);
        Debug.Log("Local3");
        AppDefine.CurQuDao = "Local3";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kLocal3Menu, true, 20)]
    public static bool ToggleLocal3Validate()
    {
        if ("Local3" == AppDefine.CurQuDao)
            Menu.SetChecked(kLocal3Menu, true);
        else
            Menu.SetChecked(kLocal3Menu, false);
        return true;
    }


    // 渠道选择菜单
    // 自营渠道:main
    // 华为:huawei
    // ...
    const string kQudao1Menu = "Dev/渠道/自营渠道";
    [MenuItem(kQudao1Menu, false, 20)]
    public static void ToggleQuDao1()
    {
        Debug.Log(Application.dataPath);
        Debug.Log("自营渠道");
        AppDefine.CurQuDao = "main";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kQudao1Menu, true, 20)]
    public static bool ToggleQuDao1Validate()
    {
        if ("main" == AppDefine.CurQuDao)
            Menu.SetChecked(kQudao1Menu, true);
        else
            Menu.SetChecked(kQudao1Menu, false);
        return true;
    }

	const string kQudao3Menu = "Dev/渠道/彩云麻将(应用宝)";
    [MenuItem(kQudao3Menu, false, 22)]
    public static void ToggleQuDao3()
    {
		Debug.Log("彩云麻将(应用宝)");
        AppDefine.CurQuDao = "caiyunmj_yyb";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kQudao3Menu, true, 22)]
    public static bool ToggleQuDao3Validate()
    {
		if ("caiyunmj_yyb" == AppDefine.CurQuDao)
            Menu.SetChecked(kQudao3Menu, true);
        else
            Menu.SetChecked(kQudao3Menu, false);
        return true;
    }

    const string kQudao3_1Menu = "Dev/渠道/彩云麻将(应用宝正式)";
    [MenuItem(kQudao3_1Menu, false, 22)]
    public static void ToggleQuDao31()
    {
        Debug.Log("彩云麻将(应用宝正式)");
        AppDefine.CurQuDao = "caiyunmj_yyb_main";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kQudao3_1Menu, true, 22)]
    public static bool ToggleQuDao31Validate()
    {
        if ("caiyunmj_yyb_main" == AppDefine.CurQuDao)
            Menu.SetChecked(kQudao3_1Menu, true);
        else
            Menu.SetChecked(kQudao3_1Menu, false);
        return true;
    }

	const string kQudao4Menu = "Dev/渠道/彩云麻将(华为提审)";
	[MenuItem(kQudao4Menu, false, 22)]
	public static void ToggleQuDao4()
	{
		Debug.Log("彩云麻将(华为提审)");
		AppDefine.CurQuDao = "caiyunmj_hw";
        AppDefine.CurResPath = AppDefine.CurQuDao;
	}
	[MenuItem(kQudao4Menu, true, 22)]
	public static bool ToggleQuDao4Validate()
	{
		if ("caiyunmj_hw" == AppDefine.CurQuDao)
			Menu.SetChecked(kQudao4Menu, true);
		else
			Menu.SetChecked(kQudao4Menu, false);
		return true;
	}

	const string kQudao4_1Menu = "Dev/渠道/彩云麻将(华为正式)";
	[MenuItem(kQudao4_1Menu, false, 22)]
	public static void ToggleQuDao41()
	{
		Debug.Log("彩云麻将(华为正式)");
		AppDefine.CurQuDao = "caiyunmj_hw_main";
        AppDefine.CurResPath = AppDefine.CurQuDao;
	}
	[MenuItem(kQudao4_1Menu, true, 22)]
	public static bool ToggleQuDao41Validate()
	{
		if ("caiyunmj_hw_main" == AppDefine.CurQuDao)
			Menu.SetChecked(kQudao4_1Menu, true);
		else
			Menu.SetChecked(kQudao4_1Menu, false);
		return true;
	}

	const string kQudao7Menu = "Dev/渠道/玩棋牌斗地主(IOS提审)";
	[MenuItem(kQudao7Menu, false, 22)]
	public static void ToggleQuDao7()
	{
		Debug.Log("玩棋牌斗地主(IOS提审)");
		AppDefine.CurQuDao = "wqpddz_ios_ts";
        AppDefine.CurResPath = AppDefine.CurQuDao;
	}
	[MenuItem(kQudao7Menu, true, 22)]
	public static bool ToggleQuDao7Validate()
	{
		if ("wqpddz_ios_ts" == AppDefine.CurQuDao)
			Menu.SetChecked(kQudao7Menu, true);
		else
			Menu.SetChecked(kQudao7Menu, false);
		return true;
	}

	const string kQudao8Menu = "Dev/渠道/玩棋牌斗地主(华为提审)";
	[MenuItem(kQudao8Menu, false, 22)]
	public static void ToggleQuDao8()
	{
		Debug.Log("玩棋牌斗地主(华为提审)");
		AppDefine.CurQuDao = "wqpddz_hw";
        AppDefine.CurResPath = AppDefine.CurQuDao;
	}
	[MenuItem(kQudao8Menu, true, 22)]
	public static bool ToggleQuDao8Validate()
	{
		if ("wqpddz_hw" == AppDefine.CurQuDao)
			Menu.SetChecked(kQudao8Menu, true);
		else
			Menu.SetChecked(kQudao8Menu, false);
		return true;
	}

    const string kQudao9Menu = "Dev/渠道/玩棋牌斗地主(应用宝)";
    [MenuItem(kQudao9Menu, false, 22)]
    public static void ToggleQuDao9()
    {
        Debug.Log("玩棋牌斗地主(应用宝)");
        AppDefine.CurQuDao = "wqpddz_yyb";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kQudao9Menu, true, 22)]
    public static bool ToggleQuDao9Validate()
    {
        if ("wqpddz_yyb" == AppDefine.CurQuDao)
            Menu.SetChecked(kQudao9Menu, true);
        else
            Menu.SetChecked(kQudao9Menu, false);
        return true;
    }

	const string kQudao10Menu = "Dev/渠道/玩棋牌CLPS";
    [MenuItem(kQudao10Menu, false, 22)]
    public static void ToggleQuDao10()
    {
        Debug.Log("玩棋牌CLPS");
        AppDefine.CurQuDao = "wqp";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kQudao10Menu, true, 22)]
    public static bool ToggleQuDao10Validate()
    {
        if ("wqp" == AppDefine.CurQuDao)
            Menu.SetChecked(kQudao10Menu, true);
        else
            Menu.SetChecked(kQudao10Menu, false);
        return true;
    }

    const string kQudao11Menu = "Dev/渠道/玩棋牌白包";
    [MenuItem(kQudao11Menu, false, 22)]
    public static void ToggleQuDao11()
    {
        Debug.Log("玩棋牌白包");
        AppDefine.CurQuDao = "wqpddz_pad";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kQudao11Menu, true, 22)]
    public static bool ToggleQuDao11Validate()
    {
        if ("wqpddz_pad" == AppDefine.CurQuDao)
            Menu.SetChecked(kQudao11Menu, true);
        else
            Menu.SetChecked(kQudao11Menu, false);
        return true;
    }

    const string kQudao12Menu = "Dev/渠道/彩云麻将(审核包)";
    [MenuItem(kQudao12Menu, false, 22)]
    public static void ToggleQuDao12()
    {
        Debug.Log("彩云麻将(审核包)");
        AppDefine.CurQuDao = "caiyunmj_trial";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kQudao12Menu, true, 22)]
    public static bool ToggleQuDao12Validate()
    {
        if ("caiyunmj_trial" == AppDefine.CurQuDao)
            Menu.SetChecked(kQudao12Menu, true);
        else
            Menu.SetChecked(kQudao12Menu, false);
        return true;
    }

    const string kQudao13Menu = "Dev/渠道/玩棋牌斗地主(拼多多)";
    [MenuItem(kQudao13Menu, false, 22)]
    public static void ToggleQuDao13()
    {
        Debug.Log("玩棋牌斗地主(拼多多)");
        AppDefine.CurQuDao = "wqpddz_pdd";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kQudao13Menu, true, 22)]
    public static bool ToggleQuDao13Validate()
    {
        if ("wqpddz_pdd" == AppDefine.CurQuDao)
            Menu.SetChecked(kQudao13Menu, true);
        else
            Menu.SetChecked(kQudao13Menu, false);
        return true;
    }

    const string kQudao14Menu = "Dev/渠道/彩云麻将(CPLS)";
    [MenuItem(kQudao14Menu, false, 22)]
    public static void ToggleQuDao14()
    {
        Debug.Log("彩云麻将(cpl)");
        AppDefine.CurQuDao = "caiyunmj_cpls";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kQudao14Menu, true, 22)]
    public static bool ToggleQuDao14Validate()
    {
        if ("caiyunmj_cpls" == AppDefine.CurQuDao)
            Menu.SetChecked(kQudao14Menu, true);
        else
            Menu.SetChecked(kQudao14Menu, false);
        return true;
    }

    const string kQudao15Menu = "Dev/渠道/彩云麻将(华为不更新)";
    [MenuItem(kQudao15Menu, false, 22)]
    public static void ToggleQuDao15()
    {
        Debug.Log("彩云麻将(华为不更新)");
        AppDefine.CurQuDao = "caiyunmj_hw_noupdate";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kQudao15Menu, true, 22)]
    public static bool ToggleQuDao15Validate()
    {
        if ("caiyunmj_hw_noupdate" == AppDefine.CurQuDao)
            Menu.SetChecked(kQudao15Menu, true);
        else
            Menu.SetChecked(kQudao15Menu, false);
        return true;
    }

    const string kQudao16Menu = "Dev/渠道/鲸鱼斗地主(爱变现)";
    [MenuItem(kQudao16Menu, false, 22)]
    public static void ToggleQuDao16()
    {
        Debug.Log("鲸鱼斗地主(爱变现)");
        AppDefine.CurQuDao = "aibianxian";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kQudao16Menu, true, 22)]
    public static bool ToggleQuDao16Validate()
    {
        if ("aibianxian" == AppDefine.CurQuDao)
            Menu.SetChecked(kQudao16Menu, true);
        else
            Menu.SetChecked(kQudao16Menu, false);
        return true;
    }

    const string kQudao17Menu = "Dev/渠道/高手五子棋";
    [MenuItem(kQudao17Menu, false, 22)]
    public static void ToggleQuDao17()
    {
        Debug.Log("高手五子棋");
        AppDefine.CurQuDao = "wuziqi";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kQudao17Menu, true, 22)]
    public static bool ToggleQuDao17Validate()
    {
        if ("wuziqi" == AppDefine.CurQuDao)
            Menu.SetChecked(kQudao17Menu, true);
        else
            Menu.SetChecked(kQudao17Menu, false);
        return true;
    }

    const string kQudao18Menu = "Dev/渠道/高手五子棋(vivo)";
    [MenuItem(kQudao18Menu, false, 22)]
    public static void ToggleQuDao18()
    {
        Debug.Log("高手五子棋(vivo)");
        AppDefine.CurQuDao = "vivo_wuziqi";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kQudao18Menu, true, 22)]
    public static bool ToggleQuDao18Validate()
    {
        if ("vivo_wuziqi" == AppDefine.CurQuDao)
            Menu.SetChecked(kQudao18Menu, true);
        else
            Menu.SetChecked(kQudao18Menu, false);
        return true;
    }

    const string kQudao19Menu = "Dev/渠道/彩云麻将(vivo)";
    [MenuItem(kQudao19Menu, false, 22)]
    public static void ToggleQuDao19()
    {
        Debug.Log("彩云麻将(vivo)");
        AppDefine.CurQuDao = "vivo_cymj";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kQudao19Menu, true, 22)]
    public static bool ToggleQuDao19Validate()
    {
        if ("vivo_cymj" == AppDefine.CurQuDao)
            Menu.SetChecked(kQudao19Menu, true);
        else
            Menu.SetChecked(kQudao19Menu, false);
        return true;
    }

    const string kQudao20Menu = "Dev/渠道/彩云麻将(提审ts)";
    [MenuItem(kQudao20Menu, false, 22)]
    public static void ToggleQuDao20()
    {
        Debug.Log("彩云麻将(提审ts)");
        AppDefine.CurQuDao = "caiyunmj_ts";
        AppDefine.CurResPath = AppDefine.CurQuDao;
    }
    [MenuItem(kQudao20Menu, true, 22)]
    public static bool ToggleQuDao20Validate()
    {
        if ("caiyunmj_ts" == AppDefine.CurQuDao)
            Menu.SetChecked(kQudao20Menu, true);
        else
            Menu.SetChecked(kQudao20Menu, false);
        return true;
    }
}
