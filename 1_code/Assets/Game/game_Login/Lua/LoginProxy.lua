
LoginProxy = LoginProxy or {}

local C = LoginProxy

--登出后等待n秒后开始登入
local AUTO_LOGIN_IDLETIME = 10
--登入后等待n秒后开始登出
local LOGINED_LIFETIME = 20

local STEP_NONE = 0
local STEP_CONNECTING = 1
local STEP_CONNECTED = 2
local STEP_LOGINING = 3
local STEP_LOGINED = 4
local STEP_LOGOUT = 5
local STEP_AUTO_LOGIN = 6

C.step = C.step or STEP_NONE

local timer = nil
function C.Init(loginlogic)
	C.Exit()
	C.MakeLister()
	C.AddMsgListener()

	timer = Timer.New(function ()
		local step = C.step or STEP_NONE
		if step == STEP_CONNECTING then
			C.step_connecting()
		elseif step == STEP_CONNECTED then
			C.step_connected()
		elseif step == STEP_LOGINING then
			C.step_logining()
		elseif step == STEP_LOGINED then
			C.step_logined()
		elseif step == STEP_AUTO_LOGIN then
			C.step_auto_login()
		end
	end, 1, -1)
	timer:Start()
end

function C.Exit(loginlogic)
	C.RemoveListener()
	if timer then
		timer:Stop()
		timer = nil
	end
end

function C.step_connecting()
end

function C.step_connected()
end

function C.step_logining()
end

local logined_countdown = 0
function C.step_logined()
	logined_countdown = logined_countdown - 1
	if logined_countdown > 0 then return end

	step = STEP_LOGOUT
	C.logout()
end

local auto_login_countdown = 0
function C.step_auto_login()
	auto_login_countdown = auto_login_countdown + 1
	if auto_login_countdown < AUTO_LOGIN_IDLETIME then return end

	C.step = STEP_NONE
	--LoginLogic.AutoLogin()
	LoginLogic.YoukeLogin()
end

function C.logout()
	Network.SendRequest("player_quit", nil, "登出",function (ret)
		if ret and ret.result~=0 then
			HintPanel.ErrorMsg(ret.result)
		end
	end)
	LoginModel.ClearLastLoginData()
	MainModel.IsLoged = false
end

local lister = {}
function C.AddMsgListener()
	for proto_name,func in pairs(lister) do
		Event.AddListener(proto_name, func)
	end
end
function C.MakeLister()
	lister = {}
	lister["ConnecteServerSucceed"] = C.on_connected
	lister["OnLoginResponse"] = C.on_logined
	lister["ServerConnectDisconnect"] = C.on_logout
	lister["cancel_login"] = C.cancel_login
end
function C.RemoveListener()
	for proto_name,func in pairs(lister) do
		Event.RemoveListener(proto_name, func)
	end
	lister = {}
end

function C.on_connected(result)
	print("handle on connected")
	C.step = STEP_CONNECTED
end

function C.on_logined(result)
	if result == 0 then
		logined_countdown = LOGINED_LIFETIME
		C.step = STEP_LOGINED
	else
		C.cancel_login({"loginerror", result})
	end
end

function C.on_logout()
	C.Exit()
	DOTweenManager.KillAllStopTween()
	DOTweenManager.KillAllExitTween()
	DOTweenManager.CloseAllSequence()

	RedHintManager.CloseAllRed()
	MainLogic.Exit()
	networkMgr:Init()
	Network.Start()
	MainLogic.Init()

	C.step = STEP_AUTO_LOGIN
end

function C.cancel_login(result)
	dump(result, "cancel_login")
end
