basefunc =  require "Game.Common.basefunc"
require "Game.Common.define"
require "Game.Common.functions"
require "Game.Common.printfunc"
require "Game.Common.tools"
require "Game.Common.panelManager"
require "Game.Common.StringHelper"
require "Game.Common.MathExtend"
require "Game.Framework.events"
require "Game.CommonPrefab.Lua.GameGlobalOnOff"
require "Game.Framework.MainModel"
require "Game.Framework.Network"
require "Game.Framework.DOTweenManager"
require "Game.Common.AwardManager"
require "Game.Framework.GameManager"
require "Game.Framework.LocalDatabaseManager"

require "Game.Common.cardID_vertify"
require "Game.Common.normal_enum"
ewmTools = require "Game.Common.ewmTools"

util = require "Game.Common.3rd.cjson.util"
require "Game.Common.3rd.cjson.json2lua"
require "Game.Common.3rd.cjson.lua2json"

--支付相关
shoping_config = {}
shoping_config_revise = {}

--管理
require "Game.CommonPrefab.Lua.RedHintManager"
require "Game.Common.ExtendSoundManager"

-- 配置
require "Game.CommonPrefab.Lua.GameDefine"

ext_require_audio("Game.CommonPrefab.Lua.audio_game_config","game")

-- 大版本URL配置
local update_download_config = require "Game.CommonPrefab.Lua.update_download_config"


-- 组件
require "Game.CommonPrefab.Lua.GameTipsPrefab"
require "Game.CommonPrefab.Lua.GameTipsDescPrefab"
require "Game.CommonPrefab.Lua.PayTypePopPrefab"

-- Logic
require "Game.CommonPrefab.Lua.CachePrefabManager"
require "Game.CommonPrefab.Lua.TimerManager"
require "Game.CommonPrefab.Lua.GameButtonManager"
require "Game.CommonPrefab.Lua.AdvertisingManager"
require "Game.CommonPrefab.Lua.ActivityShopManager"
require "Game.Activity.sys_qx.Lua.SYSQXManager"

-- 公用Prefab
require "Game.CommonPrefab.Lua.CommonPrefabInit"
require "Game.Framework.URLImageManager"
require "Game.CommonPrefab.Lua.HotUpdatePanel"
require "Game.CommonPrefab.Lua.HotUpdateSmallPanel"

require ("Game.game_Loding.Lua.LodingLogic")

require "Game.CommonPrefab.Lua.ParticleManager" --特效

require "Game.CommonPrefab.Lua.AssetsGetPanel" --获得物品
require "Game.CommonPrefab.Lua.AssetsExtraGetPanel"
require "Game.CommonPrefab.Lua.RealAwardPanel" --获得实物

package.loaded["Game.CommonPrefab.Lua.GameSceneCfg"] = nil
require "Game.CommonPrefab.Lua.GameSceneCfg"

require "Game.CommonPrefab.Lua.SmallLodingPanel"
require "Game.CommonPrefab.Lua.GMPanel"

package.loaded["Game.CommonPrefab.Lua.IllustratePanel"] = nil
require "Game.CommonPrefab.Lua.IllustratePanel"

local qrencode = require "qrencode.core"

require "Game.Framework.IosPayManager"
require "Game.Framework.AndroidPayManager"
require "Game.Framework.DataStatisticsManager"
require "Game.Framework.BuriedStatisticalDataSystem"


errorCode = require "Game.Common.error_code"

package.loaded["Game.CommonPrefab.Lua.LTTipsPrefab"] = nil
require "Game.CommonPrefab.Lua.LTTipsPrefab"
require "Game.CommonPrefab.Lua.CommonTimeManager"
require "Game.CommonPrefab.Lua.CommonHuxiAnim"
require "Game.CommonPrefab.Lua.CommonCellAnim"
require "Game.CommonPrefab.Lua.CommonHYAnim"
require "Game.CommonPrefab.Lua.CommonRankEmail"
require "Game.CommonPrefab.Lua.CommonPMDManager"
require "Game.CommonPrefab.Lua.CommonAwardPanelManager"
require "Game.CommonPrefab.Lua.CommonLotteryAnim"
require "Game.CommonPrefab.Lua.GameComAnimToolDownGet"
require "Game.CommonPrefab.Lua.GameComAnimTool"

require "Game.Common.RewardADMgr"
-- require "Game.Common.OpenInstallMgr"
require "Game.Common.UniWebViewMgr"

-- 登录场景初始化
MainLogic = {}

MainLogic.GetSYSUpURL = function (channel, platform)
    channel = channel or gameMgr:getMarketChannel()
    platform = platform or gameMgr:getMarketPlatform()

    local cfg = update_download_config
    if cfg then
        if cfg.info and cfg.info[channel] then
            local url
            if gameRuntimePlatform == "Ios" then
                url = cfg.info[channel].ios_url
            else
                url = cfg.info[channel].url
            end
            if url then
                return url
            end
        end

        if cfg.platform_info and cfg.platform_info[platform] then
            local url
            if gameRuntimePlatform == "Ios" then
                url = cfg.platform_info[platform].ios_url
            else
                url = cfg.platform_info[platform].url
            end
            if url then
                return url
            end
        end
    end
    if gameRuntimePlatform == "Ios" then
        return cfg.info.normal.ios_url
    else
        return cfg.info.normal.url
    end
end
MainLogic.GetLandingPageURL = function (channel, platform)
    channel = channel or gameMgr:getMarketChannel()
    platform = platform or gameMgr:getMarketPlatform()

    local cfg = update_download_config
    if channel == platform then
        return cfg.landing_page[platform] or cfg.landing_page.normal
    else
        return MainLogic.GetSYSUpURL(channel, platform)
    end
end

local this
local mainModel
local hasInitAppPurchasing = false

local lister
local function AddLister()
    lister={}
    lister["ReConnecteServerResponse"] = this.OnReConnecteServerResponse
    lister["AssetGet"] = this.AssetGet
    lister["AssetExtraGet"] = this.AssetExtraGet
    lister["GMPanel"] = this.GMPanel
    lister["model_deeplink_notify_msg"] = this.handle_deeplink_notify_msg
    lister["sys_quit"] = this.handle_sys_quit

    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end

local Reboot = true
function MainLogic.Init()
    if Reboot then
        --第一次启动
        -- BSDS.Init()
        Event.Brocast("bsds_send_e")
        Event.Brocast("bsds_send_power",{key = "up_end"})
        Reboot = false
    end
    if gameRuntimePlatform == "Ios" or gameRuntimePlatform == "Android" then
        AppDefine.IsDebug = false
    else
        AppDefine.IsDebug = true
    end
    PlayerPrefs.SetString("LuaSetCurSceneName", "game_Login")

    DOTweenManager.Init()
    -- 解决登出DoTween崩溃
    DG.Tweening.DOTween.Clear()
    -- 设置dotween可回收利用 设置dotween安全运行
    DG.Tweening.DOTween.Init(false, true)
    -- 设置dotween初始大小Tweeners/ sequence
    DG.Tweening.DOTween.SetTweensCapacity(500, 100)

	resMgr:DestroyAssetObject("LodingPanel.prefab")

    this = MainLogic

    mainModel = MainModel.Init()
    MainLogic.InitDeepLinkAppkey()
    MainLogic.InitShopingConfig()
    MainLogic.InitShopingConfigRevise()
    URLImageManager.Init()
    Network.Init()
    ExtendSoundManager.Init()
    TimerManager.Init()
    GameButtonManager.Init()
    AdvertisingManager.Init()
    SYSQXManager.Init()
    CommonTimeManager.Init()
    CommonHuxiAnim.Init()
    CommonAwardPanelManager.Init()
    MainModel.sound_pattern = nil
    MainModel.banner_if_first_run = true    
    AddLister()    
    this.SkipToScene("game_Login")
    DSM.Init()
end

function MainLogic.InitDeepLinkAppkey()
    deeplink_appkey_cfg = require "Game.CommonPrefab.Lua.deeplink_appkey"
    deeplink_appkey_cfg = deeplink_appkey_cfg.info
end

function MainLogic.GetDeepLinkAppkey()
    --老版本兼容
    -- local dp_appkey = "jingyu"
    -- local mc = gameMgr:getMarketPlatform()
    -- if mc == "normal" then
    --     dp_appkey = "jingyu"
    -- elseif mc == "wqp" then
    --     dp_appkey = "wqp"
    -- end
    -- return dp_appkey

    local dp_appkey = "x8opi6"
    if table_is_null(deeplink_appkey_cfg) then
        return dp_appkey
    end
    local mc = gameMgr:getMarketChannel()
    for i,v in ipairs(deeplink_appkey_cfg) do
        if mc == v.market_channel then
            dp_appkey = v.deeplink_appkey
        end
    end
    return dp_appkey
end

function MainLogic.InitShopingConfig()
    --根据配置选择导入的购物表
    -- print("<color=red>当前平台</color>",gameRuntimePlatform)
    local update_shoping_config
    local platform = ((GameGlobalOnOff.PGPay or GameGlobalOnOff.QIYE) and gameRuntimePlatform == "Ios") and "ios" or "android"
	if GameGlobalOnOff.QIYE then
        shoping_config = require "Game.CommonPrefab.Lua.QIYE_shoping_config"
    else
        shoping_config = require "Game.CommonPrefab.Lua.shoping_config"
    end
    LuaHelper.AddInAppPurchasing()
    
    -- for k,v in pairs(shoping_config) do
    --     dump(v, "<color=yellow>shoping_config 1 </color>" .. k)
    -- end
    local _shoping_config = {}
    for i_sc,v_sc in pairs(shoping_config) do
        _shoping_config[i_sc] = _shoping_config[i_sc] or {}
        for i,v in ipairs(v_sc) do
            if v.platform then
                if v.platform == platform then
                    _shoping_config[i_sc][# _shoping_config[i_sc] + 1] = v
                end
            else
                _shoping_config[i_sc][# _shoping_config[i_sc] + 1] = v
            end
        end
    end
    shoping_config = _shoping_config
    -- for k,v in pairs(shoping_config) do
    --     dump(v, "<color=yellow>shoping_config 2 </color>" .. k) 
    -- end
end

function MainLogic.InitShopingConfigRevise()
    --根据配置选择导入的购物表
    -- print("<color=red>当前平台</color>",gameRuntimePlatform)
    local platform = ((GameGlobalOnOff.PGPay or GameGlobalOnOff.QIYE) and gameRuntimePlatform == "Ios") and "ios" or "android"
    shoping_config_revise = HotUpdateConfig("Game.CommonPrefab.Lua.shoping_config_revise")

    -- dump(shoping_config_revise, "<color=yellow>shoping_config_revise</color>")
    local _shoping_config = {}
    for i_sc,v_sc in pairs(shoping_config_revise) do
        _shoping_config[i_sc] = _shoping_config[i_sc] or {}
        for i,v in ipairs(v_sc) do
            if v.platform then
                if v.platform == platform then
                    _shoping_config[i_sc][# _shoping_config[i_sc] + 1] = v
                end
            else
                _shoping_config[i_sc][# _shoping_config[i_sc] + 1] = v
            end
            
        end
    end
    shoping_config_revise = _shoping_config
    -- dump(shoping_config_revise, "<color=yellow>shoping_config_revise</color>")
end

function MainLogic.SetupAppPurchasing()
	local platform = (GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios") and "ios" or "android"
	if platform == "ios" then
		if not hasInitAppPurchasing then
			hasInitAppPurchasing = true
			local purchasIds = {}
			for k, v in pairs(shoping_config.goods) do
				table.insert(purchasIds, v.product_id)
			end
			--for i,v in ipairs(shoping_config.goods) do
			--    purchasIds[i] = shoping_config.goods[i].product_id
			--end
			dump(purchasIds, "[Debug] SetupAppPurchasing")
			LuaHelper.InitInAppPurchasing(purchasIds)
            LuaHelper.RegistluaPurchaseCallback(function(receipt, transactionID,definition_id)
                local order = {}
                order.transactionId = transactionID
                order.definition_id = definition_id
                order.productId = definition_id
                order.receipt = receipt
                --是否用沙盒支付 0-no  1-yes
                order.isSandbox = GameGlobalOnOff.PGPayFun and 1 or 0
                if definition_id == "com.jyjjddz.zs.diamond6" or
                    definition_id == "com.jyjjddz.zs.diamond30" or
                    definition_id == "com.jyjjddz.zs.diamond98" or
                    definition_id == "com.jyjjddz.zs.diamond198" or
                    definition_id == "com.jyjjddz.zs.diamond298" then
                    --兑换成金币
                    order.convert = GOODS_TYPE.jing_bi
                end
                IosPayManager.AddOrder(order)
            end)
		end
	end
end

--[[进入游戏 - 当客户端确定进入游戏时必须调用
    此时玩家所在位置即为所进入的位置
    此时游戏位置也是当前位置
]]
function MainLogic.EnterGame()
    PlayerPrefs.SetString("LuaSetCurSceneName", mainModel.myLocation)

    mainModel.Location = mainModel.myLocation
    mainModel.GamingLocation = mainModel.myLocation

end

--[[退出游戏 - 当玩家确认退出游戏时必须调用
    退出游戏此时服务器的位置和本地游戏位置都清空
]]
function MainLogic.ExitGame()
    mainModel.Location = nil
    mainModel.GamingLocation = nil
end

function MainLogic.SkipToScene(sceneName, param)
	if MainModel.CurrLogic and MainModel.CurrLogic.Exit then
		DOTweenManager.KillAllStopTween()
		DOTweenManager.KillAllExitTween()
		DOTweenManager.CloseAllSequence()
		MainModel.CurrLogic.Exit()
		MainModel.CurrLogic = nil
	end

	MainLogic.ExitScene()

	resMgr:TryUnloadAllBundles(true)
    resMgr:LoadSceneSync(sceneName, function(sn)
		if string.lower(System.IO.Path.GetFileNameWithoutExtension(sceneName)) ~= string.lower(sn) then return end

		mainModel.lastmyLocation = mainModel.myLocation
		mainModel.myLocation = sceneName
        DSM.PushAct({scene = mainModel.myLocation})
		resMgr:LoadSceneFinish(sceneName)
		gameMgr:LoadSceneFinish()
		resMgr:LoadSceneLuaBundle(sceneName)

			local ns = StringHelper.Split(sceneName, "_")
			if #ns ~= 2 then
				print("<color=red> Error GotoScene ".. sceneName .. " </color>")
				return
			end

			local needR = "Game." .. sceneName .. ".Lua.".. ns[2] .. "Logic"
			package.loaded[needR] = nil

			MainModel.CurrLogic = require (needR)
			MainModel.CurrLogic.Init(param)

			local canvasS = GameObject.Find("Canvas").transform:GetComponent("CanvasScaler")
			if canvasS then
                local width = Screen.width
                local height = Screen.height
                if width / height < 1 then
                    width,height = height,width
                end
                canvasS.matchWidthOrHeight = MainModel.GetScene_MatchWidthOrHeight(width, height)
			else
				print("<color=red>适配策略 Error</color>")
			end

		print("---debug--- enter scene")

		MainLogic.EnterScene()
	end)
end

local record_scene_list = {}
local unload_enter_scene_name_map = {
	game_Fishing3D = true,
	game_Fishing = true
}
local unload_leave_scene_name_map = {
	game_Fishing3D = true,
	game_Fishing = true
}

function MainLogic.IsNeedUnloadAllBundles()
	local enter_scene_name = mainModel.myLocation or ""
	local leave_scene_name = mainModel.lastmyLocation or ""

	if unload_enter_scene_name_map[enter_scene_name] or unload_leave_scene_name_map[leave_scene_name] then
		return true
	end

	for _, v in pairs(record_scene_list) do
		if v == enter_scene_name then return false end
	end
	table.insert(record_scene_list, enter_scene_name)
	if table.getn(record_scene_list) > 6 then
		return true
	end

	return false
end

function MainLogic.GotoScene( sceneName, parm, cbk)
    if MainLogic.is_lock_goto_scene then
		LittleTips.Create("下载中，不能切换场景")
		return
	end
	resMgr:CaptureScreen(function(tex)
		if MainModel.CurrLogic and MainModel.CurrLogic.Exit then
			DOTweenManager.KillAllStopTween()
			DOTweenManager.KillAllExitTween()
			DOTweenManager.CloseAllSequence()
			RedHintManager.CloseAllRed()
			MainModel.CurrLogic.Exit()
			MainModel.CurrLogic = nil
		end

		MainLogic.ExitScene()
		mainModel.lastmyLocation = mainModel.myLocation
		mainModel.myLocation = sceneName
		DSM.PushAct({scene = mainModel.myLocation})
        Event.Brocast("bsds_send_power",{key = "scene_" .. string.lower(sceneName)})
		PlayerPrefs.SetString("LuaSetCurSceneName", sceneName)

		if MainLogic.IsNeedUnloadAllBundles() then
			record_scene_list = {}
			resMgr:TryUnloadAllBundles(true)
		end

		-- nmg todo 等配置
		if true then
			LodingLogic.Init(parm, cbk, true, tex)
		else
			--[[resMgr:LoadSceneAsync(sceneName, function ()
				MainLogic.LoadScene(sceneName, parm, cbk)
			end)]]--
		end
	end)
end

--我的本地位置永远跟随真实所在场景位置
function MainLogic.LoadScene(sceneName, parm, cbk)
    print("<color=red>MainLogic.LoadScene</color>")
    mainModel.myLocation = sceneName
    DSM.PushAct({scene = mainModel.myLocation})
    SceneManager.LoadScene(resMgr:FormatSceneName("game_Loding.unity"))
    coroutine.start(function ( )
        Yield(0)
        LodingLogic.Init(parm, cbk)
    end)
end


--进入了一个场景
function MainLogic.EnterScene()
    Event.Brocast("EnterScene")
end

--即将退出当前场景
function MainLogic.ExitScene()
    Event.Brocast("ExitScene")
end


--断线重连后登录成功
function MainLogic.OnReConnecteServerResponse(result)
    if result==0 then
        print("<color=yellow>location:</color>",mainModel.Location,mainModel.GamingLocation,mainModel.myLocation)
        --都不在游戏中 什么也不做
        if not mainModel.Location and not mainModel.GamingLocation then
            Event.Brocast("ReConnecteServerSucceed")
            return
        end

        --服务器有游戏状态 进行同步位置
        if mainModel.Location then
            
            mainModel.GamingLocation = mainModel.Location
            
            local ll = GameConfigToSceneCfg[MainModel.getServerToClient(mainModel.Location)]
            if ll and ll.SceneName == mainModel.myLocation then
                Event.Brocast("ReConnecteServerSucceed")
            else
                --去大厅自己跳转处理
                this.GotoScene("game_Hall",nil,function ()
                    Event.Brocast("ReConnecteServerSucceed")
                end)
            end

            return
        end

        --服务器没有游戏位置 恢复至大厅
        if not mainModel.Location then
            --恢复至
            mainModel.GamingLocation = nil
            if mainModel.myLocation ~= "game_Hall" then
                this.GotoScene("game_Hall",nil,function ()
                    Event.Brocast("ReConnecteServerSucceed")
                end)
            else
                Event.Brocast("ReConnecteServerSucceed")
            end

            return
        end

    elseif result > 0 then

        --服务器那边正常的报错 网络正常
        --重连后登录失败，应该跳转到登陆场景
        print("<color=red> OnReConnecteServerResponse fail goto login scene </color>")

        HintPanel.Create(1,"您连接服务器失败，需要重新登录",function ()
            MainLogic.GotoScene( "game_Login" )
        end)

    else

        --重连后异常 客户端可能处于断网状态，此消息由客户端发出 通常是-1
        print("<color=red> OnReConnecteServerResponse result is exception "..result.." </color>")

        --[[
            有时候是连接有问题，需要完全重连
            有时候是堆积的第一个消息，后面可能有正常的登录消息
            处理：一段时间后进行一次检测是否登录成功，否则强制回到大厅
        ]]

        FullSceneJH.Create("正在重连服务器...",1101)

        Timer.New(function ()

            FullSceneJH.RemoveAll()
            print("<color=red> ReConnecte exception overtime cbk </color>")

            if not MainModel.IsLoged then
                print("<color=red> ReConnecte exception overtime MainModel.IsLoged is false </color>")
                HintPanel.Create(1,"您连接服务器失败，需要重新登录",function ()
                    MainLogic.GotoScene( "game_Login" )
                end)
            end

        end, 2, 1):Start()

    end
end

--断线重连后登录
function MainLogic.reLogin()
    
    --从玩家信息中获取登录信息进行重新登录
    local channel_args = mainModel.LoginInfo.channel_args
    local tbl = json2lua(channel_args)
    if tbl then
        tbl.appid = UnityEngine.PlayerPrefs.GetString("_APPID_")
        mainModel.LoginInfo.channel_args = lua2json(tbl)
    end
    mainModel.LoginInfo.market_channel = gameMgr:getMarketChannel()
    mainModel.LoginInfo.platform = gameMgr:getMarketPlatform()
    local deivesInfo = Util.getDeviceInfo()
    mainModel.LoginInfo.device_id = deivesInfo[0]
    mainModel.LoginInfo.device_os = deivesInfo[1]
    if gameRuntimePlatform == "Android" or gameRuntimePlatform == "Ios" then
       mainModel.LoginInfo.device_id = sdkMgr:GetDeviceID()
    end
    Network.SendRequest("login", mainModel.LoginInfo)

    print("<color=red> MainLogic.reLogin </color>")
    dump(mainModel.LoginInfo, "MainLogic.reLogin")
end



--断线重连后登录
function MainLogic.Exit()
    if this then
        -- BSDS.Exit()
        if EmailLogic then
            EmailLogic.Exit()
        end

        RedHintManager.CloseAllRed()
        mainModel.Exit()

        RemoveLister()

        Network.Unload()

        this = nil
    end

end

local deeplink_keyword = "jingyu://www.jyhd919.cn"
-- 获取平台
function MainLogic.GetPTDeeplinkKeyword()
    return "jingyu://www.jyhd919.cn"
end
local function ParseDeepLink(url)
	if not url or url == "" then return false end

	local segs = basefunc.string.split(url, "?")
	if #segs ~= 2 then
		print("<color=red>[DeepLink] ParseDeepLink invalid url: " .. url .. "</color>")
		return false
	end

	if segs[1] ~= MainLogic.GetPTDeeplinkKeyword() then
		print("<color=red>[DeepLink] ParseDeepLink invalid keyword: " .. url .. "</color>")
		return false
	end

	return true, segs[2]
end

function MainLogic.HandleOpenURL(url)
	local result, seg = ParseDeepLink(url)
	if not result then
		print("<color=red>[DeepLink] HandleOpenURL ParseDeepLink failed: url: " .. url .. "</color>")
		return
	end

	local context = seg
	local kv = basefunc.string.split(context, "/")
	if #kv == 2 then
		print("[DeepLink] key: " .. kv[1] .. ", value: " .. kv[2])

		Event.Brocast("model_deeplink_notify_msg", kv)
	else
		print("<color=red>[DeepLink] invalid params: " .. context .. "</color>")
	end

	--[[--xxx://xxxx?key=value
	local segs = basefunc.string.split(url, "?")
	if #segs == 2 then
		local check_keyword = "jingyu://www.jyhd919.cn"
		if segs[1] ~= check_keyword then
			print("<color=red>[DeepLink] invalid keyword: " .. url .. "</color>")
			return false
		end

		local context = segs[2]
		local kv = basefunc.string.split(context, "/")
		if #kv == 2 then
			print("[DeepLink] key: " .. kv[1] .. ", value: " .. kv[2])

			Event.Brocast("model_deeplink_notify_msg", kv)
			if kv[1] == "room_no" then
				MainModel.RoomCardInfo = kv
				RoomCardLogic.JoinRoomCard(kv[2])
			else
			end
		else
			print("<color=red>[DeepLink] invalid params: " .. context .. "</color>")
		end

		return true
	else
		print("<color=red>[DeepLink] invalid url: " .. url .. "</color>")
		return false
	end]]--
end

--游戏错误状态
local GameStateErrorMsg = {
	[1] = "缓存数据已经清除，请重新运行游戏",
	[2] = "请重新运行游戏",
	[3] = "下载最新版本，全新体验升级",
	[4] = "下载版本信息失败",
	[5] = "下载游戏配置失败",
	[6] = "获取数据列表失败",
	[7] = "获取数据失败",
	[8] = "版本中没有包含的游戏",
	[9] = "版本号有误"
}
function MainLogic.FormatGameStateError(errorInfo)
	local ns = StringHelper.Split(errorInfo, ":")
	if #ns ~= 2 or ns[1] ~= "Error" then
		print("<color=red> FormatGameStateError exception: ".. errorInfo .. " </color>")
		return ""
	end

	--local errorNo = math.abs(tonumber(ns[2]))
	--return GameStateErrorMsg[errorNo] or GameStateErrorMsg[1]
	return ns[2] or "未知错误"
end

local openSendBreakdownInfo=true
local showSendBreakdownInfo=true
local last_errorinfo={}
function MainLogic.SendBreakdownInfoToServer(errorInfo,stack)

    if not MainModel.IsLoged then
        return
    end

    if openSendBreakdownInfo and errorInfo and stack then
        if last_errorinfo[errorInfo] then
            return 
        end
        last_errorinfo[errorInfo]=true

        local base_msg = ""
        base_msg = base_msg .. "Version:" .. gameMgr:GetVersionNumber() .. "\n"
        base_msg = base_msg .. "Device:" .. gameRuntimePlatform .. "\n"
        base_msg = base_msg .. "Platform:" .. (gameMgr:getMarketPlatform() or "nil") .. "\n"
        base_msg = base_msg .. "Channel:" .. (gameMgr:getMarketChannel() or "nil") .. "\n"

        local error= base_msg .. errorInfo .. "  " .. stack
        if string.len(error) >=64*1024 then
            error=string.sub(error,1,64*1000)
        end
        --发向服务器
        Network.SendRequest("client_breakdown_info",{error=error})
    end
    if showSendBreakdownInfo then
  local path
  if AppDefine.IsEDITOR() then
    path = Application.dataPath
  else
    path = AppDefine.LOCAL_DATA_PATH
  end
  File.WriteAllText(path .. "/last_login_channel.txt", "")
        local id = ""
        if MainModel and MainModel.UserInfo and  MainModel.UserInfo.user_id then
            id = MainModel.UserInfo.user_id
        end
        if AppDefine.IsEDITOR() then
            --根据配置将error发向服务器
            HintPanel.Create(1,id .. "<size=15>发生崩溃，点击确定自动通知开发人员"..errorInfo .. "</size>")
        else
            --根据配置将error发向服务器
            HintPanel.Create(1, id .. "发生崩溃，点击确定自动通知开发人员")
        end
    end
end


function MainLogic.AssetGet(data)
    if data then
        if data.change_type and data.change_type == ASSET_CHANGE_TYPE.GOLD_PIG2_TASK_AWARD then
        else
            AssetsGetPanel.Create(data)
        end
    end
end

function MainLogic.AssetExtraGet(data)
    if data then
        AssetsExtraGetPanel.Create(data)
    end
end

function MainLogic.GMPanel(data)
	if not MainModel.IsLoged then
		return
	end
	local UserInfo = MainModel.UserInfo or {}
	local player_level = UserInfo.player_level or 0
	print("[Debug] GMPanel player_level:" .. player_level)
	if player_level > 0 then
		GMPanel.Create()
	end
end

function MainLogic.handle_deeplink_notify_msg(data)
	local kv = data or {}
	if kv[1] == "room_no" then
		MainModel.RoomCardInfo = kv
		RoomCardLogic.JoinRoomCard(kv[2])
	end
end

function MainLogic.handle_sys_quit(url)
print("handle sys quit")
	url = url or "www.baidu.com"
	if Directory.Exists(resMgr.DataPath) then
	print("clear dir:" ..resMgr.DataPath)
            Directory.Delete(resMgr.DataPath, true)
        end
	UnityEngine.Application.OpenURL(url)
	print("quit all")
	gameMgr:QuitAll()
end

function MainLogic.GetCameraPermission()
	local permission = sdkMgr:GetCanCamera(true)
	if permission == 2 then
		local PREF_KEY = "CameraPermission"
		local PlayerPrefs = UnityEngine.PlayerPrefs
		if not PlayerPrefs.HasKey(PREF_KEY) then
			PlayerPrefs.SetInt(PREF_KEY, 1)
			permission = 1
		end
	end
	return permission
end

local try_start_scan_callback = nil
function MainLogic.TryStartScan(callback)
	try_start_scan_callback = callback

	local permission = MainLogic.GetCameraPermission()
	if permission == 0 then
		MainLogic.GotoScene("game_ScannerQRCode")
	elseif permission == 1 then
		local requestOpen = -1
		local permissionTimer = Timer.New(function()
			if requestOpen ~= permission then
				requestOpen = permission
				if permission == 1 then
					sdkMgr:OpenCamera()
				else
					if permissionTimer then
						permissionTimer:Stop()
						permissionTimer = nil
					end
					
					if permission == 0 then
						MainLogic.GotoScene("game_ScannerQRCode")
					else
						HintPanel.Create(1,"扫描二维码需要相机权限",function () end)
					end
				end
			else
				if permission == 1 then
					permission = sdkMgr:GetCanCamera(false)
				end
			end
		end, 1, -1)
		permissionTimer:Start()
	else
		HintPanel.Create(1,"扫描二维码需要相机权限",function () end)
	end
end

function MainLogic.HandleStartScan(key, value)
	--todo
	print("[SCANNER QR CODE] ok: ", key, value)

	local result, seg = ParseDeepLink(value)
	if not result then
		print("<color=red>[DeepLink] HandleStartScan ParseDeepLink failed: url: " .. value .. "</color>")
		HintPanel.Create(1, "二维码异常，请扫描有效二维码!")
		return
	end

	if try_start_scan_callback then
		try_start_scan_callback(key, value)
	end
end

--玩家提现, min_cash单位分
function MainLogic.Withdraw(callback ,min_cash)
    if not min_cash then
        min_cash = 1000
    end
    dump(min_cash, "<color=green>玩家提现</color>")
    local withdrow_func = function ()
        if MainModel.UserInfo.cash < min_cash then
            local tips = string.format( "奖金在 %s 元以上才可提现！",min_cash / 100)
            LittleTips.Create(tips)
            return
        end
        Network.SendRequest("withdraw_cash", {cash_type=1}, "发送请求", function (data)
            if data.result == 0 then
                if callback then
                    callback()
                end
                -- if data.withdraw_type == "cash" then
                --     local str = string.format( "成功提现%s元，请前往支付宝查看余额",data.value / 100)
                --     HintPanel.Create(1,str)
                -- end 
                HintPanel.Create(1,"<size=52>提取完成，等待系统审核</size>\n<size=32>(系统将在两个工作日内完成审核)</size>")
            else
                HintPanel.ErrorMsg(data.result)
            end
        end)
    end

    local call = function(  )
        --检查手机
        if GameGlobalOnOff.BindingPhone and ((not MainModel.UserInfo.phoneData) or (not MainModel.UserInfo.phoneData.phone_no)) then
            local parent = GameObject.Find("Canvas/LayerLv4").transform
            local tips = "请先绑定手机"
            GameManager.GotoUI({gotoui = "sys_binding_phone",goto_scene_parm = "panel",parent = parent,tips = tips,})
            return            
        end
        withdrow_func()
    end
    MainModel.GetBindPhone(call)
end

function MainLogic.GetCurSceneName()
    return (mainModel and mainModel.myLocation or "")
end