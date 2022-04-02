-- 创建时间:2021-01-05

require "Game.game_Login.Lua.LoginWXTSPanel"
require "Game.game_Login.Lua.LoginWXTSPrefab"

LoginWXTSManager = {}
local M = LoginWXTSManager

function M.Init()
    M.Exit()
    M.data = {}
end

function M.Exit()
    M.data = nil
	if connectTimer then
        connectTimer:Stop()
        connectTimer = nil
    end
end

local connectTimeDelay = 3 --每次发起重连的时间间隔
local connectMaxTime = 3 --发起连接的最大次数
local connectCurTime = 0 --当前发起次数
--取消登陆
local cancelLogin = function()
    LoginLogic.SetGoodIP("")

    connectCurTime = 0
    FullSceneJH.RemoveAll()

    if connectTimer then
        connectTimer:Stop()
        connectTimer = nil
    end

    Network.DestroyConnect()
    print("<color=red> login is cancel or error </color>")
    Event.Brocast("bsds_send_power",{key = "login_fail"})
end
function M.connectServer()
    if MainModel.IsConnectedServer then
        getWechatInfo()
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
                    HintPanel.Create(1, "连接服务器失败，请检查网络是否连接")
                end
            end
        end

        connectTimer = Timer.New(sendConnect, connectTimeDelay, -1, nil, true)
        connectTimer:Start()
        sendConnect()
    end
end
-- 获取微信账号信息
local getWechatInfo
-- 获取设备所有账号(微信账号除外)
local getDeviceAllUser

getDeviceAllUser = function()    
    Network.SendRequest("get_wechat_bind_list", {device_id = LoginModel.loginData.device_id, channel_args=M.data.channel_args}, "", function (data)
        dump(data, "<color=red>|||||||||||||||||||||||||||||||||</color>")
        if data.result == 0 then
            M.data.bind_datas = data.bind_datas

            LoginWXTSPanel.Create(function (d)
                dump(d)
                LoginLogic.login_wechat()
            end)
        else
            --HintPanel.ErrorMsg(data.result)
            LoginLogic.login_wechat()
        end
    end)
end
getWechatInfo = function()
    local function callback(json_data)
        print("sdk callback:" .. json_data)
        local lua_tbl = json2lua(json_data)
        if not lua_tbl then
            print("[LOGIN] wechatTokenToLogin exception: json_data invalid")
            return
        end

        dump(lua_tbl, "[LOGIN] wechatTokenToLogin")

        if lua_tbl.result == 0 then
            M.data.channel_args = lua2json(lua_tbl)
            getDeviceAllUser()
        else
            FullSceneJH.RemoveAll()
            if lua_tbl.result == -5 then
                local channel = MainModel.LoginInfo.channel_type or ""
                HintPanel.Create(1, "登陆微信错误(" .. channel .. ":" .. lua_tbl.errno .. ")")
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

    print("<color=red>sdkMgr login</color>")
    sdkMgr:Login("", callback)
end

-- function M.wechat()
--     local appid = UnityEngine.PlayerPrefs.GetString("_APPID_", "")
--     if appid ~= "" then
--         -- 直接微信登录
--         LoginLogic.WechatLogin()
--     else
--         connectServer()
--     end
-- end