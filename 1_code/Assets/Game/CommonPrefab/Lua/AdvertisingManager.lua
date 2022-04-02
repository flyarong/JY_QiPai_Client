-- 创建时间:2019-11-25
-- 广告系统 管理器

local basefunc = require "Game/Common/basefunc"
AdvertisingManager = {}
local M = AdvertisingManager
local advertising_config = HotUpdateConfig("Game.CommonPrefab.Lua.advertising_config")

local this
local lister
local ad_map = {}
local ad_key_map = {}
local cur_ad_data
local isOnOff = true
-- 是否是测试阶段的广告
local isTest = false

local isDebug = true
local debug_map = {}

local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end
local function MakeLister()
    lister = {}
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed

    lister["EnterForeGround"] = this.on_backgroundReturn_msg
    lister["EnterBackGround"] = this.on_background_msg
    lister["sdk_ad_msg"] = this.on_sdk_ad_msg
    lister["AssetsGetPanelConfirmCallback"] = this.on_asset_get_confirm
end

function M.Init()
	M.Exit()

	this = AdvertisingManager
	this.m_data = {}
    this.ad_map = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig={}
    this.UIConfig.AD = advertising_config.config
    this.UIConfig.ADDotMap = {}
    this.UIConfig.AD_Random_List = {}
    for k,v in ipairs(advertising_config.config) do
        if v.ad_dot then
            for k1,v1 in ipairs(v.ad_dot) do
                this.UIConfig.ADDotMap[v1] = this.UIConfig.ADDotMap[v1] or {}
                this.UIConfig.ADDotMap[v1][#this.UIConfig.ADDotMap[v1] + 1] = v.ad_id
            end
            -- if v.type == "normal" then
            --     this.UIConfig.AD_Random_List[#this.UIConfig.AD_Random_List + 1] = v.ad_id
            -- end
        else
            this.UIConfig.AD_Random_List[#this.UIConfig.AD_Random_List + 1] = v.ad_id
        end
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
	end
end
function M.OnReConnecteServerSucceed()
end
function M.on_backgroundReturn_msg()
end
function M.on_background_msg()
end


function M.AddAdData(ad_id, key, val)
    if not M.ad_map[ad_id] then
        M.ad_map[ad_id] = {}
    end
    M.ad_map[ad_id][key] = val
end

local ad_error ={
    [20001] = "恭喜您获得免广告特权免除该次广告，充值6元以上可永久免广告哦！",
    [40007] = "广告获取失败，请重试。",
    [40020] = "开发注册新上线广告位超出日请求量限制",
    [40026] = "您的网络地址不正确，请切换网络后重试。",
    [50001] = "广告获取失败，请重试。",
    [60007] = "广告获取失败，请重试。",
    [-1] = "广告获取失败，请重试。",
    [-2] = "您的网络不稳定，待网络稳定后请重试",
    [-3] = "广告获取失败，请重试。",
    [-4] = "广告获取失败，请重试。",
    [-8] = "您看广告太频繁了，请稍作休息10秒后重试。",
    [101] = "广告获取失败，请重试。",
    [102] = "广告获取失败，请重试。",
    [106] = "广告获取失败，请重试。",
}

-- 对接广告接口
function M.OnError(data) -- 下载错误
    local ad_id = data.ad_id
    M.AddAdData(ad_id, "error_code", data.errorCode)
    if M.ad_map[ad_id].call then
        M.ad_map[ad_id].call({result=-999, errorCode = data.errorCode})
    else
        if data.errorCode == 40029 then
            local pre = HintPanel.Create(2, "检测到新版本，请重新下载！", function()
                local url = MainLogic.GetLandingPageURL()
                Event.Brocast("sys_quit",url)
            end)
            pre.confirm_txt.text = "前 往"
        else
            HintPanel.Create(1, "Error:"..( data.errorCode or "nil" ) .. "\n您的网络不稳定，待网络稳定后请重试..")
        end
    end
    Event.Brocast("model_sdk_ad_msg", {result=-999, errorCode = data.errorCode})
    
    if ad_error[data.errorCode] then
        HintPanel.Create(1, ad_error[data.errorCode], function ()
            if tonumber(data.errorCode) == 20001 or tonumber(data.errorCode) == 40020 then
                PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
            end
        end)
    end
end
function M.OnAdClose(data) -- 关闭
    cur_ad_data = nil
    local ad_id = data.ad_id
    if isDebug and debug_map[ad_id] then
        dump(debug_map[ad_id], "<color=red>SYS AD Close</color>")
    end
    dump(M.ad_map[ad_id], "<color=red>SYS AD State</color>")
    if M.ad_map[ad_id] then
        if M.ad_map[ad_id].call then
            M.ad_map[ad_id].call({result=0, isVerify=M.ad_map[ad_id].isVerify})
        else
            if not M.ad_map[ad_id].isVerify then
                HintPanel.Create(1, "广告观看失败，请重新观看.")
            end
        end
        if M.ad_map[ad_id].cg_call and M.ad_map[ad_id].isVerify then
            M.ad_map[ad_id].cg_call()
        end
        Event.Brocast("model_sdk_ad_msg", {result=0, isVerify=M.ad_map[ad_id].isVerify})
    else
        Event.Brocast("model_sdk_ad_msg", {result=0})
    end
end
function M.OnVideoComplete(data) -- 播放完成
    M.AddAdData(data.ad_id, "isVideoComplete", true)    
end
function M.OnVideoError(data) -- 播放错误
    HintPanel.Create(1,"广告播放错误，请重试")
    local ad_id = data.ad_id
    M.AddAdData(ad_id, "isVideoError", true)
    if M.ad_map[ad_id].call then
        M.ad_map[ad_id].call({result=2})
    else
        HintPanel.Create(1, "您的网络不稳定，待网络稳定后请重试...")
    end
    Event.Brocast("model_sdk_ad_msg", {result=2})
end
function M.OnRewardVerify(data) -- 播放有效
    if data.result == 0 and (isTest or data.rewardVerify) then
        M.AddAdData(data.ad_id, "isVerify", true)
        if cur_ad_data then
            ad_key_map[cur_ad_data.key] = {play_time=os.time()}
        end
    end
end
function M.on_sdk_ad_msg(fun_name, data)
    dump(data, "<color=red>SYS AD data</color>")
    if M[fun_name] then
        if isDebug then
            if debug_map[data.ad_id] then
                debug_map[data.ad_id] = debug_map[data.ad_id] .. "->" .. fun_name
            else
                print("<color=red>SYD AD Error</color>")
                debug_map[data.ad_id] = fun_name
            end
        end
        if not data.ad_id or data.ad_id == "" and cur_ad_data then
            data.ad_id = cur_ad_data.ad_id
        end
        dump(data, "<color=red>SYD AD fun_name = " .. fun_name .. " </color>")
        M[fun_name](data)
    end
end

-- 广告点对应的广告位
function M.GetADID(key)
    if this.UIConfig.ADDotMap[key] then
        local index = math.random(1, #this.UIConfig.ADDotMap[key])
        local ad_id = this.UIConfig.ADDotMap[key][index]
        return ad_id
    else
        local index = math.random(1, #this.UIConfig.AD_Random_List)
        local cfg = this.UIConfig.AD_Random_List[index]
        return cfg
    end
end

--广告点的类型
function M.GetADType(key)
    for k,v in ipairs(advertising_config.config) do
        if v.ad_dot then
            for i = 1,#v.ad_dot do
                if v.ad_dot[i] == key then
                    return v.type
                end
            end
        end
    end
    return "normal"
end

-- 随机播放广告
function M.RandPlay(key, call, cg_call)
    dump(key,"<color=white>AdvertisingManager.RandPlay</color>")
    if not isOnOff then
        if call then
            call({result=0, isVerify=true})
        end
        if cg_call then
            cg_call()
        end
        Event.Brocast("model_sdk_ad_msg", {result=0, isVerify=true})
        return
    end
    
    -- Ios看不了广告
    if not M.IsHaveAD() or not M.IsCanWatchAD() or not SYSQXManager.IsNeedWatchAD() then
        if call then
            call({result=0, isVerify=true})
        end
        if cg_call then
            cg_call()
        end
        Event.Brocast("model_sdk_ad_msg", {result=0, isVerify=true})
        return
    end
    
    if AppDefine.IsEDITOR() then
        ad_key_map[key] = {play_time=os.time()}
        if call then
            call({result=0, isVerify=true})
        end
        if cg_call then
            cg_call()
        end
        DSM.ADShow(key)
        Event.Brocast("model_sdk_ad_msg", {result=0, isVerify=true})
        return
    end

    local ad_id = M.GetADID(key)
    local ad_type = M.GetADType(key)
    ad_id = tostring(ad_id)
    local width = Screen.width
    local height = Screen.height
    local viewWidth = 0
    local viewHeight = 0
    if width / height < 1 then
        width,height = height,width
    end
    width = 1024
    height = 768
    viewWidth, viewHeight = Screen.width, Screen.height
    if ad_type == "banner"  then
        viewWidth, viewHeight = 384, 60
    end

    if ad_type == "interstitial"  then
        viewWidth, viewHeight = 450, 300
    end

    if ad_key_map[key] and ad_type == "normal" then
        local t = ad_key_map[key].play_time
        if (os.time() - t) < 30 then -- 小于30秒 不播放广告
            print("<color=white>同一广告播放间隔太短</color>")
            if call then
                call({result=3})
            else
                HintPanel.Create(1, "广告正在填充中，请稍后再播放")
            end
            Event.Brocast("model_sdk_ad_msg", {result=3})
            return
        end
    end

    cur_ad_data = {ad_id = ad_id, key=key}
    M.ad_map[ad_id] = {}
    M.AddAdData(ad_id, "key", key)
    M.AddAdData(ad_id, "call", call)
    M.AddAdData(ad_id, "cg_call", cg_call)

    if isDebug then
        debug_map[ad_id] = "RandPlay"
    end

    DSM.ADShow(key)


    dump({ type = ad_type, viewW = viewWidth, viewH = viewHeight},"<color=white>广告点类型</color>")
    RewardADMgr.PrepareAD(ad_id, "金币", 3, MainModel.UserInfo.user_id, "extra", width, height, ad_type, viewWidth, viewHeight ,function(id, preRet)
        print("[AD] prepare result:" .. id .. ", " .. preRet)
        if preRet == 0 then
            --准备成功
            print("<color=white>广告准备成功</color>")
        else
            print("<color=white>广告准备失败</color>")
        end
    end)
end

-- 是否有广告
function M.IsHaveAD()
    return not M.IsCloseAD()
end

function M.IsCloseAD()
    local channel_type = gameMgr:getMarketChannel()
    if channel_type == "hw_cymj" or gameRuntimePlatform == "Ios" or channel_type == "hw_wqp" then
        return true
    else
        return false
    end
end

function M.IsCanWatchAD()
     -- 对应权限的key
     local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="need_watch_ad", is_on_hint = true}, "CheckCondition")
     if a and b then
         return true
     end
end

function M.on_asset_get_confirm()
    sdkMgr:ClearAllAD()
end