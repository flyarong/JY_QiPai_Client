local basefunc = require "Game.Common.basefunc"
local sproto = require "Game.Framework.sproto"
local sprotoparser = require "Game.Framework.sprotoparser"

local sproto_core = require "sproto.core"

require "Game.Framework.NetConfig"

local host
local request
local session = 0

NetConfig.NetConfigInit()

local response_callbacks = {}
local response_JH = {}

Network = {}

local this = Network

local transform
local gameObject
local timer


local function transform_proto(proto_content)
	
	local lines = basefunc.string.split(proto_content,"\n")

	local text = {}

	local id = 1
	local sid = 0
	local l = ""
	local n = 0

	for i,line in ipairs(lines) do

		l,n = string.gsub(line, "@", tostring(id))
		if n > 0 then
			id = id + 1
		else

			l,n = string.gsub(line, "%$", tostring(sid))

			if n > 0 then
				sid = sid + 1
			end

		end

		text[#text+1]=l
	end

	return table.concat(text,"\n")

end

local function load_proto(fileName)
	local fn = gameMgr:getLocalPath("localconfig/" .. fileName)
	if File.Exists(fn) then
		local data = File.ReadAllText(fn)
		return basefunc.string.split(data,"\n")
	else
		local data = resMgr:LoadText(fileName, nil)
		return basefunc.string.split(data,"\n")
	end
end

local function parse_proto(data_lines)
	local text = {}

	local id = 1
	local sid = 0
	local l = ""
	local n = 0

	for i,line in ipairs(data_lines) do

		l,n = string.gsub(line, "@", tostring(id))
		if n > 0 then
			id = id + 1
		else

			l,n = string.gsub(line, "%$", tostring(sid))

			if n > 0 then
				sid = sid + 1
			end

		end

		text[#text+1]=l
	end

	return table.concat(text,"\n")
end

function Network.Init()
    --resMgr:LoadSProtoStr(this.loadSproto)
    --resMgr:LoadSProtoStr2(this.loadSproto)

    local s2c = load_proto("whole_proto_s2c.txt")
    local c2s = load_proto("whole_proto_c2s.txt")

    local s2cbin = sprotoparser.parse(parse_proto(s2c));
    local c2sbin = sprotoparser.parse(parse_proto(c2s));

    host = sproto.new(s2cbin):host "package"
    request = host:attach(sproto.new(c2sbin))
end

function Network.loadSproto(s2c, c2s)
    s2c = transform_proto(s2c)
    c2s = transform_proto(c2s)

    local s2cbin = sprotoparser.parse(s2c);
    local c2sbin = sprotoparser.parse(c2s);

    host = sproto.new(s2cbin):host "package"
    request = host:attach(sproto.new(c2sbin))
end


function Network.Start()
    Event.AddListener(Protocal.Connect, this.OnConnect);
    Event.AddListener(Protocal.Message, this.OnMessage);
    Event.AddListener(Protocal.Exception, this.OnException);
    Event.AddListener(Protocal.Disconnect, this.OnDisconnect);

end

--Socket消息--
function Network.OnSocket(key, data)
    Event.Brocast(tostring(key),  data);
end

--当连接建立时--
function Network.OnConnect()

    print("<color=green>connect server " .. AppConst.SocketAddress .. "succeed !!!</color>")

    MainModel.IsConnectedServer = true

    --连接成功清空消息回调
    response_callbacks = {}
    response_JH = {}
    Event.Brocast("ConnecteServerSucceed")
    
end

--异常断线--
function Network.OnException()
    logError("OnException------->>>>");
    MainModel.IsConnectedServer = false
    Event.Brocast("ServerConnectException")
end

--连接中断，或者被踢掉--
function Network.OnDisconnect()
    logError("OnDisconnect------->>>>");
    MainModel.IsConnectedServer = false
    Event.Brocast("ServerConnectDisconnect")
end



--主动销毁链接 - 会触发异常断线消息
function Network.DestroyConnect()
    networkMgr:DestroyConnect()
end



--处理网络数据--
function Network.OnMessage(buffer)
    
    local ok, result_type, arg1, arg2 = xpcall(function ()

        -- by lyx 
        if PROTO_TOKEN and sproto_core then
            buffer = sproto_core.xteadecrypt(buffer,PROTO_TOKEN)
        end


        return host:dispatch(buffer)
    end
    ,function (err)

        print(" Invalid unpack stream decode error")
        print(err)

    end)

    if not ok then
        print(" OnMessage buffer error destroy connect ")
        Network.DestroyConnect()
        return
    end

    if result_type == "REQUEST" then
        -- print("REQUEST>>>",arg1, arg2)
        -- table.print("<color=green> >>>>>>>REQUEST</color>" .. arg1, arg2)
        Network.OnREQUEST(arg1, arg2)
    else
        -- print("RESPONSE>>>",arg1, arg2)
        -- table.print("<color=yellow> >>>>>>>RESPONSE</color>" .. arg1 , arg2)
        Network.OnRESPONSE(arg1, arg2)
    end
end

function Network.OnREQUEST(proto_name, args)

    -- dump(args,"REQUEST proto_name="..proto_name)
    Event.Brocast(proto_name, proto_name, args)
end

function Network.OnRESPONSE(session_id, args)
    local response_content = response_callbacks[session_id]
    --dump(response_content, "<color=yellow>response_content</color>")
    if response_content ~= nil then

        -- by lyx: 通讯 标识
        if response_content.jh_key == "login" and args.proto_token and string.len(args.proto_token) > 5 then
            PROTO_TOKEN = args.proto_token
        end

		-- by lyx 有 callback ，则不再分发 response
		if response_content.callback then
			response_content.callback(args)

        --作为事件分发出去
        elseif response_content.msg_name then
            -- dump(args, "RESPONSE event="..response_content.msg_name);
            Event.Brocast(response_content.msg_name, response_content.msg_name, args)
        end
        if response_JH[response_content.jh_key] then
            FullSceneJH.RemoveByTag(response_content.jh_key)
        end
        response_JH[response_content.jh_key] = nil
    else
        print("callback is nil,session_id=", session_id)
    end
    response_callbacks[session_id] = nil

end

-- by lyx 如果提供 参数 callback，则不会出发 msgname_response
-- 参数 JHData,callback 均可选
function Network.SendRequest(name, args, JHData,callback)

    --都没有连接上就不要发送消息了
    if not MainModel.IsConnectedServer then
        print("SendRequest!!!!!!!!")
        print(debug.traceback())
        return false
    end

    -- by lyx
    if not callback and "function" == type(JHData) then
		callback = JHData
		JHData = nil
    end

    session = session + 1
    response_callbacks[session] =
    {
        jh_key = name,
        msg_name = name.."_response",
		callback = callback,
    }

    if JHData then
        response_JH[name] = 1
        FullSceneJH.Create(JHData, name)
	end


    -- print(string.format("send message session id=%d name=%s", session, name), args)

    local code = request(name, args, session)

    -- by lyx 
    if PROTO_TOKEN and sproto_core then
        code = sproto_core.xteaencrypt(code,PROTO_TOKEN)
    end
    
    networkMgr:SendMessageData(code)
    return true
end

local delay_time = 0
function Network.RandomDelayedSendRequest(name, args, JHData,callback)
    delay_time = delay_time + 0.002
    if delay_time >= 1 then 
        delay_time = 0 
    end 
    Timer.New(function ()
        Network.SendRequest(name, args, JHData,callback)
    end, delay_time, 1):Start()
end

--卸载网络监听--
function Network.Unload()
    Event.RemoveListener(Protocal.Connect, this.OnConnect);
    Event.RemoveListener(Protocal.Message, this.OnMessage);
    Event.RemoveListener(Protocal.Exception, this.OnException);
    Event.RemoveListener(Protocal.Disconnect, this.OnDisconnect);
    logWarn('Unload Network...');
end

function Network.SendPostLOG(tbl, callback)
	local loginInfo = MainModel.LoginInfo
	if not loginInfo then return end

	local is_test = loginInfo.is_test or 1
	local openid = loginInfo.openid or ""
	if openid == "" then
		print("[TLOG] openid invalid")
		return
	end

	if gameRuntimePlatform ~= "Ios" and gameRuntimePlatform ~= "Android" then
		print("[TLOG] platform invalid:" .. gameRuntimePlatform)
		--return
	end

	local url = "https://gamelog.3g.qq.com/game/log/test"
	if is_test == 0 then
		url = "https://gamelog.3g.qq.com/game/log"
	end

	tbl.appid = "1110236145"
	tbl.openid = openid
	tbl.event_time = os.time()
	tbl.zone_id = "1"
	tbl.zone_name = "default"

	if gameRuntimePlatform == "Ios" then
		tbl.platform = "2"
	else
		tbl.platform = "1"
	end

	local data = lua2json(tbl)
	local authorization = Util.HMACSHA1Encrypt(data, "wqpddz_523k8oec79gy")

	print("[TLOG] debug json:" .. data)

	networkMgr:SendPostRequest(url, data, "application/json", authorization, callback)
end

function Network.SendPostBSDS(bsds, callback)
    if not MainModel or not MainModel.UserInfo or not MainModel.UserInfo.user_id then return end
    local url = "http://md.jyhd919.cn/GameClientClickTransactor.create.command"
    local is_test = true
	if is_test then
		url = "http://testmd.jyhd919.cn/GameClientClickTransactor.create.command"
    end
    local t = {}
    t.data = {}
    t.data.playerId = MainModel.UserInfo.user_id
    t.data.clickContent = {}
    t.data.clickContent.jddata = bsds
    
    local data = lua2json(t)
    local authorization = Util.HMACSHA1Encrypt(data, "cymj_yb34a1b64xmf")

    print("<color=white>SendPostBSDS data :</color>",data)

	networkMgr:SendPostRequest(url, data, "application/json", authorization, callback)
end