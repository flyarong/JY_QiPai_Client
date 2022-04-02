package.loaded["Game.game_Login.Lua.LoginModel"] = nil
require "Game.game_Login.Lua.LoginModel"

package.loaded["Game.game_Login.Lua.LoginPanel"] = nil
require "Game.game_Login.Lua.LoginPanel"

package.loaded["Game.game_Login.Lua.GameXYText"] = nil
local GameXY = require "Game.game_Login.Lua.GameXYText"

package.loaded["Game.game_Login.Lua.ClauseHintPanel"] = nil
require "Game.game_Login.Lua.ClauseHintPanel"

package.loaded["Game.wqpddz_yyb.Lua.TLOG"] = nil
require "Game.wqpddz_yyb.Lua.TLOG"

local basefunc = require "Game.Common.basefunc"

LoginLogic={}

local this -- 单例
local loginModel

local curChannel
local curLoginId
local curToken

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
            if curChannel == "yyb_wechat" then
                LoginLogic.clearWechatData()
            elseif curChannel == "yyb_qq" then
                LoginLogic.clearQqData()
            end

            cancelLogin()
            
            HintPanel.Create(1,"登录服务器失败，请稍后重试")

        end
    end
    sendLoginRequestOverTimer = Timer.New(cbk, sendLoginRequestOverTime,1,nil,true)
    sendLoginRequestOverTimer:Start()
end

--取消登陆
cancelLogin = function()
    print("[logininginging] cancel login")

    if curChannel == "yyb_wechat" then
        loginModel.loginData.wechat = nil
        loginModel.loginData.wx_refresh_token = ""
    elseif curChannel == "yyb_qq" then
        loginModel.loginData.qq = nil
        loginModel.loginData.qq_refresh_token = ""
    end

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
        connectTimer=nil
    end

    Network.DestroyConnect()
    print("<color=red> login is cancel or error </color>")
end

local function HandleLoginFailedResult(result)
    local tbl = {
        [1001] = 3041,
        [1002] = 3034,
        [1003] = 3035,
        [1004] = 3036,
        [1005] = 3037,
        [2000] = 3039,
        [2001] = 3040,
        [2002] = 3041,
        [2003] = 3042,
        [2004] = 3038,
        [3100] = 3043,
        [3101] = 3044,
        [3301] = 3045
    }

    if tbl[result] then
        HintPanel.ErrorMsg(tbl[result])
    else
        HintPanel.Create(1, "登陆异常:" .. result)
    end
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
            curToken = lua_tbl.refresh_token
            loginModel.loginData.wx_refresh_token = curToken

            lua_tbl.stamp = os.time()
            loginModel.UpdateChannelLuaTable("yyb_wechat", lua_tbl)

            local loginData = {
                channel_type = "yyb_wechat",
                channel_args = lua2json(lua_tbl),
                device_id = loginModel.loginData.device_id,
                device_os = loginModel.loginData.device_os,
                market_channel = gameMgr:getMarketChannel(),
                platform = gameMgr:getMarketPlatform()
            }
            MainModel.LoginInfo = loginData
            Network.SendRequest("login", loginData)
        else
            FullSceneJH.RemoveAll()
            status = nil
            if lua_tbl.result == -5 then
                HandleLoginFailedResult(lua_tbl.errno)
            else
                HintPanel.ErrorMsg(lua_tbl.result)
            end
            cancelLogin()
        end
    end

    local lua_tbl = {}
    lua_tbl.platform = "yyb_wechat"
    sdkMgr:Login(lua2json(lua_tbl), callback)
end

local function qqTokenToLogin()
    local function callback(json_data)
        local lua_tbl = json2lua(json_data)
        if not lua_tbl then
            print("[LOGIN] qqTokenToLogin exception: json_data invalid")
            return
        end

        dump(lua_tbl, "[LOGIN] qqTokenToLogin")

        if lua_tbl.result == 0 then
            curToken = lua_tbl.token
            loginModel.loginData.qq_refresh_token = curToken

            lua_tbl.stamp = os.time()
            lua_tbl.refresh_token = lua_tbl.token
            loginModel.UpdateChannelLuaTable("yyb_qq", lua_tbl)

            local loginData = {
                channel_type = "yyb_qq",
                channel_args = lua2json(lua_tbl),
                device_id = loginModel.loginData.device_id,
                device_os = loginModel.loginData.device_os,
                market_channel = gameMgr:getMarketChannel(),
                platform = gameMgr:getMarketPlatform()
            }
            MainModel.LoginInfo = loginData
	    UnityEngine.PlayerPrefs.SetString("_APPID_", lua_tbl.appid)
            Network.SendRequest("login", loginData)
        else
            FullSceneJH.RemoveAll()
            status = nil
            if lua_tbl.result == -5 then
                HandleLoginFailedResult(lua_tbl.errno)
            else
                HintPanel.ErrorMsg(lua_tbl.result)
            end
            cancelLogin()
        end
    end

    local lua_tbl = {}
    lua_tbl.platform = "yyb_qq"
    sdkMgr:Login(lua2json(lua_tbl), callback)
end

local function login()
    PROTO_TOKEN = nil
    if curChannel == "youke" then

        local loginData = {
            channel_type = "youke",
            login_id = curLoginId,
            device_id = loginModel.loginData.device_id,
            device_os = loginModel.loginData.device_os,
	    market_channel = gameMgr:getMarketChannel(),
	    platform = gameMgr:getMarketPlatform()
        }
        Network.SendRequest("login", loginData)

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
    elseif curChannel == "yyb_wechat" then
        --curLoginId = loginModel.loginData.wechat or ""
        --curToken = loginModel.loginData.wx_refresh_token or ""

        if curLoginId and curToken then
            print("[logininginging] wx loging() " .. curLoginId .. "," .. curToken)

            local kvs = {
                openid = "openid",
                refresh_token = "refresh_token",
                pf = "pf",
                pfkey = "pfkey",
                paytoken = "paytoken"
            }
            local json_data = loginModel.ChannelLuaTableToJson("yyb_wechat", kvs)
            print("compare json_data:", json_data)

            local loginData = {
                channel_type = "yyb_wechat",
                login_id = curLoginId,
                channel_args = json_data,
                device_id = loginModel.loginData.device_id,
                device_os = loginModel.loginData.device_os,
                market_channel = gameMgr:getMarketChannel(),
                platform = gameMgr:getMarketPlatform()
            }
            Network.SendRequest("login", loginData)
            print("login curLoginId " .. curLoginId .. " curToken:" .. curToken)
            dump(loginData)
        else
            print("[logininginging] wx relogin")
            wechatTokenToLogin()
        end
    elseif curChannel == "yyb_qq" then
        --curLoginId = loginModel.loginData.qq or ""
        --curToken = loginModel.loginData.qq_refresh_token or ""

        if curLoginId and curToken then
            print("[logininginging] qq loging() " .. curLoginId .. "," .. curToken)

            local kvs = {
                openid = "openid",
                refresh_token = "refresh_token",
                pf = "pf",
                pfkey = "pfkey",
                paytoken = "paytoken"
            }
            local json_data = loginModel.ChannelLuaTableToJson("yyb_qq", kvs)
            print("compare json_data:", json_data, json_data1)

            local loginData = {
                channel_type = "yyb_qq",
                login_id = curLoginId,
                channel_args = json_data,
                device_id = loginModel.loginData.device_id,
                device_os = loginModel.loginData.device_os,
                market_channel = gameMgr:getMarketChannel(),
                platform = gameMgr:getMarketPlatform()
            }
            Network.SendRequest("login", loginData)
            print("login curLoginId " .. curLoginId)
            dump(loginData)
        else
            print("[logininginging] qq relogin")
            qqTokenToLogin()
        end
    end

    setSendLoginOverTimeCBK()

end


local function connectServer()
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
					cancelLogin()
					HintPanel.Create(1,"连接服务器失败，请检查网络是否连接")
				end
			end
		end

		connectTimer = Timer.New(sendConnect, connectTimeDelay, -1,nil,true)
		connectTimer:Start()
		sendConnect()
	end
end

readLogin = function(channel,loginId,refresh_token)
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

    print("[logininginging] start loging: ", curChannel, curLoginId, curToken)

    FullSceneJH.Create("正在登陆...", 1)

    connectServer()

end

local lister
local function AddLister()
    lister={}
    lister["ConnecteServerSucceed"] = this.OnConnecteServerSucceed
    lister["OnLoginResponse"] = this.OnLoginResult
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


local IP_KEY = "_GOOD_IP_"
local ip_list = {}
local ip_count = 0
local ip_index = 0

local function SetupIPList()
	local function checking(item)
		for k, v in ipairs(ip_list) do
			if item == v then return k end
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
    LoginPanel.Create()

	TLOG.Init()

    return this
end


function LoginLogic.OnConnecteServerSucceed(result)
    
    if connectTimer then
        connectTimer:Stop()
        connectTimer=nil
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
    elseif result == 2153 or result == 2155 or result == 2156 or (result == 2150 and (curChannel == "yyb_wechat" or curChannel == "yyb_qq")) then
        if wechatErrorStatus == 0 then
            local channel = curChannel
            cancelLogin()

            LoginModel.ClearChannelData(channel)
            wechatErrorStatus = 1

            --等一帧再执行，等待消息分发出去，状态正确
            coroutine.start(
                function()
                    Yield(0)
                    if channel == "yyb_wechat" then
                        LoginLogic.WechatLogin()
                    elseif channel == "yyb_qq" then
                        LoginLogic.QQLogin()
                    end
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
    else

        print("login error : " , result)
        cancelLogin()
        HintPanel.ErrorMsg(result)
    end

end

function LoginLogic.CheckServerStatus(showHint)
	print("CheckServerStatus ........................................")
	local serverStatus = gameMgr:getServerStatus() or ""
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

function LoginLogic.QQLogin()
    if LoginLogic.checkServerStatus then
        if not LoginLogic.CheckServerStatus(true) then
            return
        end
    end

    local loginId = loginModel.loginData.qq
    local refresh_token = loginModel.loginData.qq_refresh_token
    readLogin("yyb_qq", loginId, refresh_token)
end

--微信登陆
function LoginLogic.WechatLogin()
    if LoginLogic.checkServerStatus then
        if not LoginLogic.CheckServerStatus(true) then
            return
        end
    end

    local loginId = loginModel.loginData.wechat
    local refresh_token = loginModel.loginData.wx_refresh_token
    readLogin("yyb_wechat", loginId, refresh_token)
end

function LoginLogic.AutoLogin()
    local lastChannel = loginModel.loginData.lastLoginChannel or ""
    if lastChannel == "yyb_wechat" then
        LoginLogic.WechatLogin()
    elseif lastChannel == "yyb_qq" then
        LoginLogic.QQLogin()
    end
end

--测试登陆
function LoginLogic.testLogin(loginId)

    readLogin("robot",loginId)

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
    loginModel.ClearChannelData("yyb_wechat")
end

function LoginLogic.clearQqData()
    loginModel.ClearChannelData("yyb_qq")
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