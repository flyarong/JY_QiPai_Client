package.loaded["Game.game_Login.Lua.LoginModel"] = nil
require "Game.game_Login.Lua.LoginModel"

package.loaded["Game.game_Login.Lua.LoginPanel"] = nil
require "Game.game_Login.Lua.LoginPanel"

package.loaded["Game.game_Login.Lua.GameXYText"] = nil
local GameXY = require "Game.game_Login.Lua.GameXYText"

package.loaded["Game.game_Login.Lua.ClauseHintPanel"] = nil
require "Game.game_Login.Lua.ClauseHintPanel"

if GameGlobalOnOff.LoginProxy then
    package.loaded["Game.game_Login.Lua.LoginProxy"] = nil
    require "Game.game_Login.Lua.LoginProxy"
end

local basefunc = require "Game.Common.basefunc"

LoginLogic = {}

local this  -- 单例
local loginModel

local curChannel
local curLoginId
local curToken
local sms_vcode

local connectTimer

local connectTimeDelay = 3 --每次发起重连的时间间隔
local connectMaxTime = 3 --发起连接的最大次数
local connectCurTime = 0 --当前发起次数

--微信错误状态
-- 0-nil  1-第一次错误，进行重试
local wechatErrorStatus = 0

--[[登录菊花的超时
    如果发起了登录请求，很久都没有回应，则应该进行清理操作
]]
local sendLoginRequestOverTime = 20
local sendLoginRequestOverTimer

--[[
    0-login ok  
    1-longing   
    2-get tokening
    3-error
]]
local status

-- 预先定义函数
local readLogin
local cancelLogin
local connectServer

local function setSendLoginOverTimeCBK()
    if sendLoginRequestOverTimer then
        sendLoginRequestOverTimer:Stop()
    end

    local function cbk()
        if MainModel.myLocation ~= "game_Login" then
            return
        end
        if status == 1 or status == 2 then
            --微信的渠道就进行一次清除本地账号
            if curChannel == "vivo" then
                LoginLogic.clearWechatData()
            end

            Event.Brocast("cancel_login", {"timeout"})
            cancelLogin()

            HintPanel.Create(1, "登录服务器失败，请稍后重试")
        end
    end
    sendLoginRequestOverTimer = Timer.New(cbk, sendLoginRequestOverTime, 1, nil, true)
    sendLoginRequestOverTimer:Start()
end

--取消登陆
cancelLogin = function()
    curChannel = nil
    curLoginId = nil
    curToken = nil
    status = nil
    LoginLogic.SetGoodIP("")

    connectCurTime = 0
    wechatErrorStatus = 0

    FullSceneJH.RemoveAll()

    if connectTimer then
        connectTimer:Stop()
        connectTimer = nil
    end

    Network.DestroyConnect()
    print("<color=red> login is cancel or error </color>")
    Event.Brocast("bsds_send_power",{key = "login_fail"})
end

local function wechatTokenToLogin()
    local function callback(json_data)
        local lua_tbl = json2lua(json_data)
        if not lua_tbl then
            print("[LOGIN] wechatTokenToLogin exception: json_data invalid")
            return
        end

        dump(lua_tbl, "[LOGIN] wechatTokenToLogin")

        if lua_tbl.result == 0 then
            local loginData = {
                channel_type = "vivo",
                channel_args = lua2json(lua_tbl),
                device_id = loginModel.loginData.device_id,
                device_os = loginModel.loginData.device_os,
                market_channel = gameMgr:getMarketChannel(),
                platform = gameMgr:getMarketPlatform()
            }
            MainModel.LoginInfo = loginData
            UnityEngine.PlayerPrefs.SetString("_APPID_", lua_tbl.appid)
            Network.SendRequest("login", loginData)
            Event.Brocast("bsds_send_power",{key = "login_wechat"})
        else
            FullSceneJH.RemoveAll()
            status = nil
            if lua_tbl.result == -5 then
                --sdk error
                local channel = MainModel.LoginInfo.channel_type or ""
                HintPanel.Create(1, "登陆错误(" .. channel .. ":" .. lua_tbl.errno .. ")")
            elseif lua_tbl.result == -4 then
                HintPanel.ErrorMsg(3032)
            elseif lua_tbl.result == -2 then
                HintPanel.ErrorMsg(3031)
            elseif lua_tbl.result == -3 then
                HintPanel.ErrorMsg(3033)
            else
                HintPanel.ErrorMsg(lua_tbl.result)
            end
            cancelLogin()
        end
    end

    print("<color=white>sdkMgr login</color>")
    sdkMgr:Login("", callback)
end

local function login()
    PROTO_TOKEN = nil
    print("<color=white>curChannel</color>", curChannel)
    if curChannel == "youke" then
        local loginData = {
            channel_type = "youke",
            login_id = curLoginId,
            device_id = loginModel.loginData.device_id,
            device_os = loginModel.loginData.device_os,
            market_channel = gameMgr:getMarketChannel(),
            platform = gameMgr:getMarketPlatform()
        }
        -- 创建账号用设备ID，如果本地存有ID就用本地的
        if not loginData.login_id or loginData.login_id == "" then
            loginData.login_id = sdkMgr:GetDeviceID()
        end
        Network.SendRequest("login", loginData)
        Event.Brocast("bsds_send_power",{key = "login_youke"})
    elseif curChannel == "robot" then
        local loginData = {
            channel_type = "robot",
            login_id = curLoginId,
            device_id = loginModel.loginData.device_id,
            device_os = loginModel.loginData.device_os,
            market_channel = "",
            market_platform = ""
        }
        Network.SendRequest("login", loginData)
    elseif curChannel == "vivo" then
         LoginLogic.vivoLogin()
    elseif curChannel == "wechat" then
        local appid = UnityEngine.PlayerPrefs.GetString("_APPID_", "")
        dump({curLoginId = curLoginId,appid = appid,curToken = curToken},"<color=white>请求登录</color>")
        if curLoginId and appid ~= "" then
            local tbl = {}
            tbl.appid = appid
            tbl.refresh_token = curToken
            local loginData = {
                channel_type = "wechat",
                login_id = curLoginId,
                channel_args = lua2json(tbl),
                device_id = loginModel.loginData.device_id,
                device_os = loginModel.loginData.device_os,
                market_channel = gameMgr:getMarketChannel(),
                platform = gameMgr:getMarketPlatform()
            }

            dump(loginData, "[Debug] loginData")
            Network.SendRequest("login", loginData)
            Event.Brocast("bsds_send_power",{key = "login_wechat"})
            print("login curLoginId " .. curLoginId)
            dump(loginData)
        else
            wechatTokenToLogin()
        end
    elseif curChannel == "phone" then
        dump({curLoginId = curLoginId,curToken = curToken},"<color=>phone</color>")
        if curLoginId and curLoginId ~= "" and curToken and curToken ~= "" then
            local loginData = {
                channel_type = "phone",
                login_id = curLoginId,
                channel_args = '{"token":"' .. curToken .. '"}',
                device_id = loginModel.loginData.device_id,
                device_os = loginModel.loginData.device_os,
                market_channel = gameMgr:getMarketChannel(),
                platform = gameMgr:getMarketPlatform()
            }

            dump(loginData, "[Debug] loginData")
            Network.SendRequest("login", loginData)
            Event.Brocast("bsds_send_power",{key = "login_phone"})
        else
            if not MainModel.IsConnectedServer then
                connectServer()
            else
                FullSceneJH.RemoveAll()
                status = nil
                Event.Brocast("model_phone_login_ui")
            end
            return
        end
    elseif curChannel == "phone_vcode" then
        if curLoginId then
            local loginData = {
                channel_type = "phone",
                login_id = curLoginId,
                channel_args = '{"sms_vcode":"' .. sms_vcode .. '"}',
                device_id = loginModel.loginData.device_id,
                device_os = loginModel.loginData.device_os,
                market_channel = gameMgr:getMarketChannel(),
                platform = gameMgr:getMarketPlatform()
            }

            dump(loginData, "[Debug] loginData")
            Network.SendRequest("login", loginData)
            Event.Brocast("bsds_send_power",{key = "login_phone"})
        end
    end

    setSendLoginOverTimeCBK()
end

function connectServer()
    if MainModel.IsConnectedServer then
        login()
    else
        --断网情况下，每3秒尝试一次重新连接
        local sendConnect = function()
            if not MainModel.IsConnectedServer then
                networkMgr:SendConnect()
            end
            connectCurTime = connectCurTime + 1
            if connectCurTime >= connectMaxTime then
                local ip = LoginLogic.TryGetIP()
                if ip and ip ~= "" then
                    AppConst.SocketAddress = ip
                    connectCurTime = 0
                    print("reconnect server use ip: " .. ip)
                else
                    Event.Brocast("cancel_login", {"connectout"})
                    cancelLogin()
                    HintPanel.Create(1, "连接服务器失败，请检查网络是否连接")
                end
            end
        end

        connectTimer = Timer.New(sendConnect, connectTimeDelay, -1, nil, true)
        connectTimer:Start()
        sendConnect()
    end
end

readLogin = function(channel, loginId, refresh_token, _sms_vcode, appid)
    if status then
        print("<color=red>error !!! hasing logining</color>")
        return
    end

    status = 1

    --登录后就关闭自动登录
    MainModel.AutoLoginState = 1

    curChannel = channel
    curLoginId = loginId
    curToken = refresh_token
    sms_vcode = _sms_vcode

    print("<color=red>readLogin</color>")
    dump(curChannel)
    dump(sms_vcode)
    FullSceneJH.Create("正在登陆...", 1)

    connectServer()
end

local lister
local function AddLister()
    lister = {}
    lister["ConnecteServerSucceed"] = this.OnConnecteServerSucceed
    lister["OnLoginResponse"] = this.OnLoginResult
    for msg, cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg, cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister = nil
end

local IP_KEY = "_GOOD_IP_"
local ip_list = {}
local ip_count = 0
local ip_index = 0

local function SetupIPList()
    local function checking(item)
        for k, v in ipairs(ip_list) do
            if item == v then
                return k
            end
        end
        return -1
    end

    local function fill_list(list, revert)
        revert = revert or false

        local item

        if revert then
            for i = list.Length - 1, 0, -1 do
                item = list[i]
                if checking(item) == -1 then
                    table.insert(ip_list, item)
                end
            end
        else
            for i = 0, list.Length - 1, 1 do
                item = list[i]
                if checking(item) == -1 then
                    table.insert(ip_list, item)
                end
            end
        end

        ip_count = #ip_list
        ip_index = 1
    end

    ip_list = {}
    ip_count = 0
    ip_index = 0

    local serverList = gameMgr:getServerList()
    if serverList and serverList.Length > 0 then
        fill_list(serverList, false)

        --debug
        dump(ip_list, "server ip list")
    end

    if PlayerPrefs.HasKey(IP_KEY) then
        local ip = PlayerPrefs.GetString(IP_KEY, "")
        if ip and ip ~= "" then
            local idx = checking(ip)
            if idx > 1 then
                local item = ip_list[idx]
                ip_list[idx] = ip_list[1]
                ip_list[1] = item

                print("good id: " .. item)
            end
        end
    end
end

function LoginLogic.GetIP()
    if ip_index <= 0 or ip_index > ip_count then
        return ""
    end
    return ip_list[ip_index]
end

function LoginLogic.TryGetIP()
    if ip_index <= 0 or ip_index > ip_count then
        return ""
    end

    local ip = ip_list[ip_index]
    ip_index = ip_index + 1

    return ip
end

function LoginLogic.SetGoodIP(ip)
    print("set good ip:" .. ip)
    if not ip or ip == "" then
        PlayerPrefs.DeleteKey(IP_KEY)
    else
        PlayerPrefs.SetString(IP_KEY, ip)
    end
end

function LoginLogic.Init()
    LoginLogic.Exit()

    ExtendSoundManager.PlaySceneBGM(audio_config.game.bgm_main_hall.audio_name)
    this = LoginLogic

    loginModel = LoginModel.Init()
    this.GameXY = GameXY
    this.checkServerStatus = true
    AddLister()

    SetupIPList()

    if GameGlobalOnOff.LoginProxy then
        LoginProxy.Init(this)
    end

    LoginPanel.Create()

    return this
end

function LoginLogic.OnConnecteServerSucceed(result)
    if connectTimer then
        connectTimer:Stop()
        connectTimer = nil
    end

    login()
end

-- 登录完成，逻辑处理
function LoginLogic.OnLoginResult(result)
    status = 3

    if result == 0 then
        status = 0

        --go to hall
        FullSceneJH.RemoveByTag(1)
        LoginLogic.Exit()
        MainLogic.GotoScene("game_Hall")
        Event.Brocast("bsds_send_power",{key = "login_succes"})
    elseif result == 2153 or result == 2155 or result == 2156 or (result == 2150 and curChannel == "vivo") then
        if wechatErrorStatus == 0 then
            cancelLogin()
            LoginModel.ClearChannelData("vivo")
            wechatErrorStatus = 1

            --等一帧再执行，等待消息分发出去，状态正确
            coroutine.start(
                function()
                    Yield(0)
                    LoginLogic.WechatLogin()
                end
            )
        else
            cancelLogin()
            HintPanel.ErrorMsg(result)
        end
    elseif result == 2150 then
        print("login id is error please clear login id data!!!")
        cancelLogin()
        HintPanel.ErrorMsg(result)
    elseif result == 1042 or result == 1044 then
		--登录信息过期或无效，需要重新验证
    else
        print("login error : ", result)
        cancelLogin()
        HintPanel.ErrorMsg(result)
    end

    -- 手机登录失败后清除数据
    if result ~= 0 and curChannel == "phone" then
        status = nil
        LoginModel.ClearChannelData("phone")
    end
end

function LoginLogic.CheckServerStatus(showHint)
    print("CheckServerStatus ........................................")
    local serverStatus = gameMgr:getServerStatus() or ""
    print("CheckServerStatus result >>>>>>>>>:")
    if serverStatus == "" then
        return true
    end

    local result = false

    local segs = basefunc.string.split(serverStatus, "#")
    local text = ""
    if #segs ~= 2 then
        text = serverStatus
    else
        text = segs[2]
        if string.lower(segs[1]) == "on" then
            result = true
        end
    end

    local hint = showHint or false
    if hint then
        HintPanel.Create(1, text)
    end
    print("CheckServerStatus result :")
    return result
end

--游客登陆
function LoginLogic.YoukeLogin()
    if LoginLogic.checkServerStatus then
        if not LoginLogic.CheckServerStatus(true) then
            return
        end
    end

    local loginId = loginModel.loginData.youke
    readLogin("youke", loginId)
end

function LoginLogic.AutoLogin()
    if loginModel.loginData.lastLoginChannel == "wechat" then
        LoginLogic.WechatLogin()
    elseif loginModel.loginData.lastLoginChannel == "phone" then
        LoginLogic.PhoneLogin()
    elseif loginModel.loginData.lastLoginChannel == "vivo" then
       -- LoginLogic.vivoLogin()
    else
        dump(loginModel.loginData, "<color=red>loginModel.loginData</color>")
    end
end

--vivo登录
 function LoginLogic.vivoLogin()
    local function callback(json_data)
        local lua_tbl = json2lua(json_data)
        if not lua_tbl then
            print("[LOGIN] vivoLogin exception: json_data invalid")
            return
        end

        dump(lua_tbl, "[LOGIN] vivoLogin")

        if lua_tbl.result == 0 then
            local loginData = {
                channel_type = "vivo",
                channel_args = lua2json(lua_tbl),
                device_id = loginModel.loginData.device_id,
                device_os = loginModel.loginData.device_os,
                market_channel = gameMgr:getMarketChannel(),
                platform = gameMgr:getMarketPlatform()
            }
            MainModel.LoginInfo = loginData
            UnityEngine.PlayerPrefs.SetString("_APPID_", lua_tbl.appid)
            Network.SendRequest("login", loginData)
        elseif lua_tbl.result == 1000 then
            FullSceneJH.RemoveAll()
            status = nil
            HintPanel.Create(1, "实名认证后，点击确定重启游戏:" .. lua_tbl.errno or 0, function ()
                gameMgr:QuitAll()
            end)
        else
            FullSceneJH.RemoveAll()
            status = nil
            if lua_tbl.result == -5 then
                --sdk error
                local channel = MainModel.LoginInfo.channel_type or ""
                HintPanel.Create(1, "登陆错误(" .. channel .. ":" .. lua_tbl.errno .. ")")
            else
                HintPanel.ErrorMsg(lua_tbl.result)
            end
            cancelLogin()
        end
    end

    sdkMgr:Login("{\"needCertification\":false}", callback)
end
--微信登陆
function LoginLogic.WechatLogin()
    if LoginLogic.checkServerStatus then
        if not LoginLogic.CheckServerStatus(true) then
            return
        end
    end

    local loginId = loginModel.loginData.wechat
    local refresh_token = loginModel.loginData.refresh_token
    dump({loginId = loginId, refresh_token = refresh_token}, "<color=white></color>")
    readLogin("vivo", loginId, refresh_token)
end

--手机登陆
function LoginLogic.PhoneLogin()
    if LoginLogic.checkServerStatus then
        if not LoginLogic.CheckServerStatus(true) then
            return
        end
    end

    local loginId = loginModel.loginData.phone
    local refresh_token = loginModel.loginData.refresh_token
    dump({loginId = loginId, refresh_token = refresh_token}, "<color=white></color>")
    readLogin("phone", loginId, refresh_token)
end
-- 手机验证码登录
function LoginLogic.PhoneVcodeLogin(phone, sms_vcode)
    if LoginLogic.checkServerStatus then
        if not LoginLogic.CheckServerStatus(true) then
            return
        end
    end

    local loginId = phone
    dump({loginId = loginId, refresh_token = refresh_token, sms_vcode = sms_vcode}, "<color=white></color>")
    readLogin("phone_vcode", loginId, nil, sms_vcode)
end

--测试登陆
function LoginLogic.testLogin(loginId)
    readLogin("robot", loginId)
end

--清除游客数据
function LoginLogic.clearYoukeData()
    loginModel.ClearChannelData("youke")

    PlayerPrefs.DeleteKey("SGE_SALE_DAY_3")
    PlayerPrefs.DeleteKey("SGE_SALE_DAY_4")
    PlayerPrefs.DeleteKey("_CLAUSE_IDENT_")
end

--清除微信数据
function LoginLogic.clearWechatData()
    loginModel.ClearChannelData("vivo")
end

--清除手机数据
function LoginLogic.clearPhoneData()
    loginModel.ClearChannelData("phone")
end

function LoginLogic.Exit()
    if this then
        RemoveLister()

        loginModel.Exit()

        curChannel = nil
        curLoginId = nil
        connectTimer = nil
        status = nil
        this = nil
    end
end

return LoginLogic
