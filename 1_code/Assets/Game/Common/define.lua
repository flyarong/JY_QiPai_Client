
CtrlNames = {
    Login = "LoginCtrl",
}

PanelNames = {
	"LoginPanel",	
}

--协议类型--
ProtocalType = {
	BINARY = 0,
	PB_LUA = 1,
	PBC = 2,
	SPROTO = 3,
}

-- Network msg
Protocal = {
    Connect     = '101';    --连接服务器
    Exception   = '102';    --异常掉线
    Disconnect  = '103';    --正常断线   
    Message     = '104';    --接收消息
}

--当前使用的协议类型--
TestProtoType = ProtocalType.SPROTO

Util = LuaFramework.Util
AppConst = LuaFramework.AppConst
LuaHelper = LuaFramework.LuaHelper
ByteBuffer = LuaFramework.ByteBuffer
ImageConversion = UnityEngine.ImageConversion

sdkMgr = LuaHelper.GetSDKManager()
resMgr = LuaHelper.GetResManager()
panelMgr = LuaHelper.GetPanelManager()
soundMgr = LuaHelper.GetSoundManager()
networkMgr = LuaHelper.GetNetManager()
gameMgr = LuaHelper.GetGameManager()
gameWeb = LuaHelper.GetWebManager()
gestureMgr = LuaHelper.GetGestureManager()
luaMgr = LuaHelper.GetLuaManager()

SceneManager = UnityEngine.SceneManagement.SceneManager
Directory = System.IO.Directory
File = System.IO.File
Rect = UnityEngine.Rect
PlayerPrefs = UnityEngine.PlayerPrefs
Application = UnityEngine.Application
Sprite = UnityEngine.Sprite
Texture2D = UnityEngine.Texture2D
WWW = UnityEngine.WWW;
GameObject = UnityEngine.GameObject
Color = UnityEngine.Color
List = System.Collections.Generic.List
Dictionary = System.Collections.Generic.Dictionary
Vector3 = UnityEngine.Vector3
Vector2 = UnityEngine.Vector2
Screen = UnityEngine.Screen
Quaternion = UnityEngine.Quaternion
Dropdown = UnityEngine.UI.Dropdown
OptionData = UnityEngine.UI.Dropdown.OptionData
InputField = UnityEngine.UI.InputField
gameRuntimePlatform = LuaHelper.GetRuntimePlatform()
Application = UnityEngine.Application
SkeletonAnimation = Spine.Unity.SkeletonAnimation
EventSystem = UnityEngine.EventSystems.EventSystem
Stopwatch = System.Diagnostics.Stopwatch

-- 无限循环滑动
PoolObject = SG.PoolObject
LoopHorizontalScrollRect = UnityEngine.UI.LoopHorizontalScrollRect
LoopScrollSendIndexSource = UnityEngine.UI.LoopScrollSendIndexSource
LoopScrollPrefabSource = UnityEngine.UI.LoopScrollPrefabSource
LoopVerticalScrollRect = UnityEngine.UI.LoopVerticalScrollRect
ScrollIndexCallback = ScrollIndexCallback