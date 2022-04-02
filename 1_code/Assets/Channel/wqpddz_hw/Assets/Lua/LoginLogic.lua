package.loaded["Game.game_Login.Lua.LoginModel"] = nil
require "Game.game_Login.Lua.LoginModel"

package.loaded["Game.game_Login.Lua.LoginPanel"] = nil
require "Game.game_Login.Lua.LoginPanel"

package.loaded["Game.game_Login.Lua.GameXYText"] = nil
local GameXY = require "Game.game_Login.Lua.GameXYText"

package.loaded["Game.game_Login.Lua.ClauseHintPanel"] = nil
require "Game.game_Login.Lua.ClauseHintPanel"

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
        if status == 1
            or status == 2 then
            
            --微信的渠道就进行一次清除本地账号
            if curChannel=="huawei_wqp" then
                LoginLogic.clearWechatData()
            end

            cancelLogin()
            
            HintPanel.Create(1,"登录服务器失败，请稍后重试")

        end
    end
    sendLoginRequestOverTimer = Timer.New(cbk, sendLoginRequestOverTime,1,nil,true)
    sendLoginRequestOverTimer:Start()
end

--取消登陆
cancelLogin = function ()
    
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
			    channel_type = "huawei_wqp",
			    channel_args = lua2json(lua_tbl),
			    device_id = loginModel.loginData.device_id,
			    device_os = loginModel.loginData.device_os,
			    market_channel = gameMgr:getMarketChannel(),
			    platform = gameMgr:getMarketPlatform()
			}
			Network.SendRequest("login", loginData)
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

	sdkMgr:Login("", callback)
end

local function huaweiLogin()
	local function callback(json_data)
		local lua_tbl = json2lua(json_data)
		if not lua_tbl then
			print("[LOGIN] huaweiLogin exception: json_data invalid")
			return
		end

		dump(lua_tbl, "[LOGIN] huaweiLogin")

		if lua_tbl.result == 0 then
			local loginData = {
			    channel_type = "huawei_wqp",
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

    elseif curChannel == "huawei_wqp" then
        huaweiLogin()
  
        --if curLoginId then
	    -- if false then

        --     local loginData = {
        --         channel_type = "huawei_wqp",
        --         login_id = curLoginId,
        --         channel_args = "{\"refresh_token\":\""..curToken.."\"}",
        --         device_id = loginModel.loginData.device_id,
        --         device_os = loginModel.loginData.device_os,
		-- market_channel = gameMgr:getMarketChannel(),
		-- platform = gameMgr:getMarketPlatform()
        --     }
        --     dump(loginData, "[Debug] loginData")
        --     Network.SendRequest("login", loginData)
        --     print("login curLoginId "..curLoginId)
        --     dump(loginData)

        -- else

        --     wechatTokenToLogin()

        -- end

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

    FullSceneJH.Create("正在登陆...",1)
    
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
    elseif result == 2153 
        or result == 2155 
        or result == 2156 
        or (result == 2150 and curChannel=="huawei_wqp") then

        if wechatErrorStatus == 0 then
            cancelLogin()
            LoginModel.ClearChannelData("huawei_wqp")
            wechatErrorStatus = 1

            --等一帧再执行，等待消息分发出去，状态正确
            coroutine.start(function ( )
                Yield(0)
                LoginLogic.WechatLogin()
            end)

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
	readLogin("youke",loginId)
	--readLogin("huawei_wqp",loginId)
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
    readLogin("huawei_wqp",loginId,refresh_token)
end

function LoginLogic.AutoLogin()
    if loginModel.loginData.lastLoginChannel == "wechat" then
        LoginLogic.WechatLogin()
    elseif loginModel.loginData.lastLoginChannel == "phone" then
		LoginLogic.PhoneLogin()
	elseif loginModel.loginData.lastLoginChannel == "huawei_wqp" then
        --LoginLogic.huaweiLogin()
    else
        dump(loginModel.loginData, "<color=red>loginModel.loginData</color>")
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
    loginModel.ClearChannelData("huawei_wqp")
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