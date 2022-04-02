-- 数据埋点统计系统
--[[
详细格式说明:
    E 类型(环境信息)
	{
		"T": "E", 
		"V": "设备id", 
		TS-时间戳：当前实例的时间戳
		SN-序号：本次操作在当前实例中的顺序号
		"D": {
			"N": "启动次数", 
			"I": "玩家ip", 
			"L": "login id", 
			"P": "平台 platform",
			"C": "渠道号 marcket_channel", 
			"O": "操作系统版本信息"
		}
	}

    A 类型(埋点信息)
	{
		"T": "A", 
		"V": "设备id", 
		TS-时间戳：当前实例的时间戳
		SN-序号：本次操作在当前实例中的顺序号
		"D": ["234","12343","12343","12343","12343"]
	}
--]]

local basefunc=require "Game.Common.basefunc"
local cfg = HotUpdateConfig("Game.Framework.buried_statistical_data_system_config").main
BSDS = {}
local M = BSDS
local on_off = true --数据埋点开关
local on_off_old_player = true --老玩家开关，登录过的玩家不发送数据


local cd = 30--固定上传倒计时
local m_c = 10000 --上传最大长度
local m_f = 1 --每秒上传最大频率
local s_t --上传时间

local TS = os.time() --时间戳：当前实例的时间戳
local SN = 0 --序号：本次操作在当前实例中的顺序号
--设备信息
local deivesInfo		-- = Util.getDeviceInfo() --设备信息
-- device_id = deivesInfo[0],
-- device_os = deivesInfo[1],
local device_os		-- = deivesInfo[1] or ""	--操作系统信息
local device_id		-- = sdkMgr:GetDeviceID() or "" --设备id
local market_channel		-- = gameMgr:getMarketChannel() or "" --推广渠道
local market_platform		-- = gameMgr:getMarketPlatform() or "" --平台渠道
local ip		-- --= "http://cpl_server.jyhd919.cn/client_ip" --玩家ip
local start_num		-- = UnityEngine.PlayerPrefs.GetInt("BSDS",0)
local login_id

local lister
local function AddLister()
    lister={}
    lister["bsds_send"] = M.bsds_send
    lister["bsds_send_power"] = M.bsds_send_power
    lister["bsds_send_e"] = M.bsds_send_e
    lister["EnterScene"] = M.EnterScene
	lister["ExitScene"] = M.ExitScene
	lister["EnterForeGround"] = M.EnterForeGround
    lister["EnterBackGround"] = M.EnterBackGround
    lister["ConnecteServerSucceed"] = M.ServerConnectSucceed
    lister["ServerConnectException"] = M.ServerConnectException
    lister["ServerConnectDisconnect"] = M.ServerConnectDisconnect

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

function M.Init()
	if not on_off then return end

	--设备信息
	deivesInfo = Util.getDeviceInfo() --设备信息
	device_id = deivesInfo[0] or "" --设备id
	device_os = deivesInfo[1] or ""	--操作系统信息
	if gameRuntimePlatform == "Android" or gameRuntimePlatform == "Ios" then
		device_id = sdkMgr:GetDeviceID() or "" --设备id
	end
	
	market_channel = gameMgr:getMarketChannel() or "" --推广渠道
	market_platform = gameMgr:getMarketPlatform() or "" --平台渠道
	ip = "" --= "http://cpl_server.jyhd919.cn/client_ip" --玩家ip
	start_num = UnityEngine.PlayerPrefs.GetInt("BSDS",0)

	local function GetLocalLoginData(name)
		local path
		if AppDefine.IsEDITOR() then
			path = Application.dataPath .. "/" .. name .. ".txt"
		else
			path = AppDefine.LOCAL_DATA_PATH .. "/" .. name .. ".txt"
		end
		if File.Exists(path) then
			return File.ReadAllText(path)
		else
			return ""
		end
	end
	
	--获取登录数据
	local function GetLoginID()
		-- 游客 微信 手机号
		local login_qd = {"phone", "wechat", "youke"}
		local login_id
		for k,v in pairs(login_qd) do
			login_id = GetLocalLoginData(v)
			if login_id and login_id ~= "" then
				break
			end
		end
		dump(login_id, "<color=green>BSDS login_id</color>")
		return login_id
	end
	login_id = GetLoginID()

	if not on_off_old_player and login_id and login_id ~= "" then
		return
	end

	AddLister()
	M.update = Timer.New(function (  )
		if cd < 0 then
			M.Send()
			cd = 30
		end
		cd = cd - 1
	end,1,-1,false,true)
	M.update:Start()
end

function M.Exit()
	if not on_off then return end
	M.update:Stop()
end

function M.Add(key)
	local v = cfg[key]
	if not v then 
		print("<color=white>not key :</color>",key)
		return 
	end
	if not v.value then
		print("<color=white>not value :</color>",v.value)
		return
	end
	if M.val_list then
		if #M.val_list > m_c then
			print("<color=white>#M.val_list > 10000 </color>",#M.val_list)
			return
		end
	end
	M.val_list = M.val_list or {}
	table.insert(M.val_list,v.value)
	-- M.val_list = M.val_list .. v.value .. ","
	dump(M.val_list, "<color=white>数据埋点统计系统 val_list ：</color>")
end

function M.Send()
	cd = 30
	--数据检查
	--if not MainModel or not MainModel.UserInfo or not MainModel.UserInfo.user_id then return end
	if not M.val_list or #M.val_list == 0 then return end
	if #M.val_list > m_c then
		local _val_list = {}
		local sc = m_c	--发送最近的10000条
		for i=#M.val_list,#M.val_list - sc,-1 do
			_val_list[sc] = M.val_list[i]
			sc = sc - 1
		end
		M.val_list = _val_list
	end
	--频率检查
	if s_t then
		local c = os.time() - s_t
		if c < m_f then
			print("<color=white>超过上传频率</color>", c)
			return
		end
	end
	SN = SN + 1
	local data = {
		T = "A",
		V = device_id,
		TS = TS,
		SN = SN,
		D = M.val_list,
	}
	--上传
	dump(data,"<color=green>SendPostBSDS A</color>")
	Network.SendPostBSDS(data, function (code)
		code = code or ""
		dump(data,"<color=green>SendPostBSDS A Result</color>" .. code)
		M.AddFail(data,code)
	end)
	s_t = os.time()
	M.val_list = {}

	M.SendFail()
end

--强制上传数据
function M.SendPower(key)
	M.Add(key)
	cd = 30
	--数据检查
	--if not MainModel or not MainModel.UserInfo or not MainModel.UserInfo.user_id then return end
	if not M.val_list or #M.val_list == 0 then return end
	if #M.val_list > m_c then
		local _val_list = {}
		local sc = m_c	--发送最近的10000条
		for i=#M.val_list,#M.val_list - sc,-1 do
			_val_list[sc] = M.val_list[i]
			sc = sc - 1
		end
		M.val_list = _val_list
	end
	SN = SN + 1
	local data = {
		T = "A",
		V = device_id,
		TS = TS,
		SN = SN,
		D = M.val_list,
	}
	--上传
	dump(data,"<color=green>SendPostBSDS A</color>")
	Network.SendPostBSDS(data, function (code)
		code = code or ""
		dump(data,"<color=green>SendPostBSDS A Result</color>" .. code)
		M.AddFail(data,code)
	end)
	s_t = os.time()
	M.val_list = {}

	M.SendFail()
end

function M.bsds_send(data)
	M.Add(data.key)
end

function M.bsds_send_power(data)
	M.SendPower(data.key)
end

function M.EnterScene()
	local s = MainModel.myLocation or ""
    M.Add(s .. "_enter")
end

function M.ExitScene()
	local s = MainModel.myLocation or ""
	M.Add( s .. "_exit")
end

function M.EnterForeGround()
	M.bsds_send_power({key = "enter_fore_ground"})
end

function M.EnterBackGround()
	M.bsds_send_power({key = "enter_back_ground"})
end

function M.ServerConnectSucceed()
	M.bsds_send_power({key = "server_connect_succeed"})
end

function M.ServerConnectException()
	M.bsds_send_power({key = "server_connect_exception"})
end

function M.ServerConnectDisconnect()
	M.bsds_send_power({key = "server_connect_disconnect"})
end

--lua层更新完成后调用
function M.bsds_send_e()
	start_num = start_num or 0
	start_num = start_num + 1
	UnityEngine.PlayerPrefs.SetInt("BSDS",start_num)
	SN = SN + 1
	local _sn = SN
	coroutine.start(function ( )
		local www = WWW.New("http://cpl_server.jyhd919.cn/client_ip")
		coroutine.www(www)
		dump(www.text)
		local _ip = json2lua(www.text)
		if not table_is_null(_ip) then
			ip = _ip.ip
		end
		local data = {
			T = "E",
			V = device_id,
			TS = TS,
			SN = _sn,
			D = {
				N = start_num,
				I = ip,
				C = market_channel,
				P = market_platform,
				O = device_os,
				L = login_id,
			}
		}
		dump(data,"<color=green>SendPostBSDS E</color>")
		Network.SendPostBSDS(data, function(code)
			code = code or ""
			dump(data,"<color=green>SendPostBSDS E Result</color>" .. code)
			M.AddFail(data,code)
		end)
	end)	
	M.SendFail()
end

function M.AddFail(data,code)
	if code == 200 then return end --已经发送成功
	if table_is_null(data) then return end --数据没有
	dump(data,"<color=white>data</color>")
	local e_data = basefunc.deepcopy(data)
	M.fail_list = M.fail_list or {}
	table.insert(M.fail_list,e_data)
	dump(M.fail_list, "<color=red>数据埋点统计系统 fail_list ：</color>")
end

function M.SendFail()
	if table_is_null(M.fail_list) then return end
	local fail_list = basefunc.deepcopy(M.fail_list)
	M.fail_list = nil
	local i = 1
	M.SendPostFailData(fail_list,i)
end

function M.SendPostFailData(fail_list,i)
	if i > #fail_list then
		fail_list = nil
		return
	end
	local data = fail_list[i]
	if table_is_null(data) then 
		--数据有误，尝试发送下一条数据
		M.SendPostFailData(fail_list,i + 1)
		return 
	end
	dump(data,"<color=red>Fail SendPostBSDS</color>")
	Network.SendPostBSDS(data, function(code)
		code = code or ""
		dump(data,"<color=red>Fail SendPostBSDS Result</color>" .. code)
		M.AddFail(data,code)
		M.SendPostFailData(fail_list,i + 1)
	end)
end

--初始化
M.Init()