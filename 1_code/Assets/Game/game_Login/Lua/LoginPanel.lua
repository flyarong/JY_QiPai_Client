local basefunc = require "Game.Common.basefunc"

package.loaded["Game.game_Login.Lua.NoticeConfig"] = nil
require "Game.game_Login.Lua.NoticeConfig"

package.loaded["Game.game_Login.Lua.LoginNotice"] = nil
require "Game.game_Login.Lua.LoginNotice"

package.loaded["Game.game_Login.Lua.LoginPhonePanel"] = nil
require "Game.game_Login.Lua.LoginPhonePanel"

local NeedJumpSystems = {
}

local NeedJumpPlatforms = {
}

local NeedJumpChannels = {
}

local function IsContain(key, tbl)
	tbl = tbl or {}
	if #tbl <= 0 then return false end
	for _, v in pairs(tbl) do
		if v == "" or v == key then return true end
	end
	return false
end

local function IsNeedReinstall()
	local system = gameRuntimePlatform
	local platform = gameMgr:getMarketPlatform()
	local channel = gameMgr:getMarketChannel()

	if not IsContain(system, NeedJumpSystems) then return false end
	if not IsContain(platform, NeedJumpPlatforms) then return false end
	if not IsContain(channel, NeedJumpChannels) then return false end

	local url = MainLogic.GetSYSUpURL()

	return true, url
end

LoginPanel = basefunc.class()

LoginPanel.name = "LoginPanel"

local instance
function LoginPanel.Create()
	DSM.PushAct({panel = "LoginPanel"})
	instance=LoginPanel.New()
	return createPanel(instance,LoginPanel.name)
end
function LoginPanel.Bind()
	local _in=instance
	instance=nil
	return _in
end

--启动事件--
function LoginPanel:Awake()
	ExtPanel.ExtMsg(self)

	LuaHelper.GeneratingVar(self.transform, self)
end

function LoginPanel:Start()
	local tran = self.transform
	self.behaviour:AddClick(self.login_phone_btn.gameObject, LoginPanel.OnLoginPhoneClick, self)
	self.behaviour:AddClick(self.login_phone_close_btn.gameObject, LoginPanel.OnLoginPhoneCloseClick, self)
	if GameGlobalOnOff.WXLoginChangeToYK then
		self.behaviour:AddClick(self.login_wx_btn.gameObject, LoginPanel.OnLoginYKClick, self)
	else
		self.behaviour:AddClick(self.login_wx_btn.gameObject, LoginPanel.OnLoginWXClick, self)
	end
	self.behaviour:AddClick(self.login_wx_close_btn.gameObject, LoginPanel.OnLoginWXCloseClick, self)
	self.behaviour:AddClick(self.login_yk_btn.gameObject, LoginPanel.OnLoginYKClick, self)
	self.behaviour:AddClick(self.login_yk_close_btn.gameObject, LoginPanel.OnLoginYKCloseClick, self)
	self.behaviour:AddClick(self.repair_btn.gameObject, LoginPanel.OnRepairClick, self)
	self.behaviour:AddClick(self.service_btn.gameObject, LoginPanel.OnServiceClick, self)

	self.Cheat = tran:Find("Cheat")

	--version
	local vf = resMgr.DataPath .. "udf.txt"
	if File.Exists(vf) then
		local luaTbl = json2lua(File.ReadAllText(vf))
		if luaTbl then
			local versionTxt = tran:Find("Version_txt"):GetComponent("Text")
			versionTxt.text = "Ver:" .. luaTbl.version .. " " .. gameMgr:getMarketChannel()
		end
	end

	local needReinstall, url = IsNeedReinstall()
	if needReinstall then
		print("need reinstall:" .. url)
		HintPanel.Create(1, "下载最新版本，全新体验升级", function()
			Event.Brocast("sys_quit", url)
			return false
		end)
	else
		self:OnStart()
	end

	self:OnOff()

	HandleLoadChannelLua("LoginPanel", self)

	local bg = self.transform:Find("login_bg")
	MainModel.SetGameBGScale(bg)
end

function LoginPanel:CheatButtonClick(key)
	self.cheatPwd = self.cheatPwd .. key
	--print("key:" .. key .. ", " .. self.cheatPwd)
	if self.cheatPwd == "264153" then
		self.cheatPwd = ""
		LoginLogic.checkServerStatus = false
		package.loaded["Game.game_Login.Lua.CheatPanel"] = nil
		require "Game.game_Login.Lua.CheatPanel"
		CheatPanel.Create()
	end
end

function LoginPanel:CheatCtrlButtonClick()
	local tran = self.transform

	self.cheatCtrlCount = self.cheatCtrlCount + 1
	if self.cheatCtrlCount >= 6 then
		self.cheatCtrlCount = 0

		for i = 1, 6, 1 do
			local btn = self.Cheat.transform:Find("cbtn_" .. i)
			btn.gameObject:SetActive(true)
		end
	end

	for i = 1, 6, 1 do
		local img = self.Cheat.transform:Find("cbtn_" .. i):GetComponent("Image")
		img.color = Color.New(1, 1, 1, 0.5)
	end
	self.cheatPwd = ""
end

function LoginPanel:OnOff()
	self.login_yk_btn.gameObject:SetActive(GameGlobalOnOff.YKLogin)
	self.login_wx_btn.gameObject:SetActive(GameGlobalOnOff.WXLogin)
	self.login_phone_btn.gameObject:SetActive(GameGlobalOnOff.PhoneLogin)
	if GameGlobalOnOff.YKLogin and (GameGlobalOnOff.WXLogin or GameGlobalOnOff.PhoneLogin) then
		self.login_yk_btn.transform.localPosition = Vector3.New(-406, -298, 0)
		self.login_wx_btn.transform.localPosition = Vector3.New(406, -298, 0)
		self.login_phone_btn.transform.localPosition = Vector3.New(406, -298, 0)
	elseif GameGlobalOnOff.YKLogin and not (GameGlobalOnOff.WXLogin or GameGlobalOnOff.PhoneLogin) then
		self.login_yk_btn.transform.localPosition = Vector3.New(0, -298, 0)
	elseif not GameGlobalOnOff.YKLogin then
		self.login_wx_btn.transform.localPosition = Vector3.New(0, -298, 0)
		self.login_phone_btn.transform.localPosition = Vector3.New(0, -298, 0)
	end

	if GameGlobalOnOff.FPS then
		self.login_yk_close_btn.gameObject:SetActive(true)
		self.login_wx_close_btn.gameObject:SetActive(true)
		self.login_phone_close_btn.gameObject:SetActive(true)
	else
		self.login_yk_close_btn.gameObject:SetActive(false)
		self.login_wx_close_btn.gameObject:SetActive(false)
		self.login_phone_close_btn.gameObject:SetActive(false)
	end
end
function LoginPanel:OnStart()
	local tran = self.transform

	if gameMgr:HasUpdated() and gameMgr:NeedRestart() then
		print("Has Update need restart ....")
		HintPanel.Create(1, "更新完毕，请重启游戏", function ()
			--UnityEngine.Application.Quit()
			gameMgr:QuitAll()
		end)
		return
	end

	self:MakeLister()
	self:AddMsgListener()
	self.privacy = true
	self.service = true
	local ClauseHintNode = tran:Find("ClauseHintNode")
	if ClauseHintNode then
		ClauseHintPanel.Create(ClauseHintNode)
	end

	--cheatbtn
	self.cheatPwd = ""
	local cheatNode = self.Cheat
	for i = 1, 6, 1 do
		local btn = cheatNode:Find("cbtn_" .. i):GetComponent("Button")
		btn.onClick:AddListener(function ()
			local img = cheatNode:Find("cbtn_" .. i):GetComponent("Image")
			img.color = Color.red

			self:CheatButtonClick(tostring(i))
		end)
	end
	self.cheatCtrlCount = 0
	local cheatBtn = cheatNode:Find("cheat_btn"):GetComponent("Button")
	cheatBtn.onClick:AddListener(function ()
		self:CheatCtrlButtonClick()
	end)

	--redir server ip:port
	local ip = LoginLogic.TryGetIP()
	if ip and ip ~= "" then
		AppConst.SocketAddress = ip

		print("[Debug] net redir:" .. ip)
	end
	self:AutoLogin()
end

function LoginPanel:AutoLogin()
	
	if MainModel.GetIsAutoLogin() then
		LoginLogic.AutoLogin()
	end

end

--游客登录
function LoginPanel:OnLoginYKClick(go)
	DSM.PushAct({button = "yk_btn"})
	Event.Brocast("bsds_send_power",{key = "click_login_youke"})
	--local b = self.gxImage.gameObject.activeInHierarchy
	if self.privacy == true and self.service == true then
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		LoginLogic.YoukeLogin()
	else
		LittleTips.Create("勾选同意下方协议才能进入游戏")
	end
end

--微信登录
function LoginPanel:OnLoginWXClick(go)
	DSM.PushAct({button = "wx_btn"})
	Event.Brocast("bsds_send_power",{key = "click_login_wechat"})
	--local b = self.gxImage.gameObject.activeInHierarchy
	if self.privacy == true and self.service == true then
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		LoginLogic.WechatLogin()
	else
		LittleTips.Create("勾选同意下方协议才能进入游戏")
	end
end

--手机登录
function LoginPanel:OnLoginPhoneClick(go)
	DSM.PushAct({button = "phone_btn"})
	Event.Brocast("bsds_send_power",{key = "click_login_phone"})
	--local b = self.gxImage.gameObject.activeInHierarchy
	if self.privacy == true and self.service == true then
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		LoginLogic.PhoneLogin()
	else
		LittleTips.Create("勾选同意下方协议才能进入游戏")
	end
end

function LoginPanel:OnXYClick(go)
	self:ShowXY()
end

function LoginPanel:OnLoginYKCloseClick(go)
	LittleTips.Create("清除游客登录")
	LoginLogic.clearYoukeData()
end


function LoginPanel:OnLoginWXCloseClick(go)
	LittleTips.Create("清除微信登录")
	LoginLogic.clearWechatData()
end

function LoginPanel:OnLoginPhoneCloseClick(go)
	LittleTips.Create("清除手机登录")
	LoginLogic.clearPhoneData()
end

function LoginPanel:OnRepairClick()
	if Directory.Exists(resMgr.DataPath) then
		Directory.Delete(resMgr.DataPath, true)
	end
	local web_caches = {"_shop_"}
	-- for _, v in pairs(web_caches) do
	-- 	gameWeb:ClearCookies(v)
	-- end
	UniWebViewMgr.CleanCookies()
	UniWebViewMgr.CleanCacheAll()
	HintPanel.Create(1, "修复完毕，请重新运行游戏", function ()
		--UnityEngine.Application.Quit()
		gameMgr:QuitAll()
	end)
	Event.Brocast("bsds_send_power",{key = "click_repair"})
end

function LoginPanel:OnServiceClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	--sdkMgr:CallUp("400-8882620")
	--self.service_btn.gameObject:SetActive(false)
	Event.Brocast("callup_service_center", "400-8882620")
	Event.Brocast("bsds_send_power",{key = "click_service"})
end

function LoginPanel:MyExit()
	if self.spine then
		self.spine:Stop()
	end
	self.spine = nil

	ClauseHintPanel.Close()
	self:RemoveListener()

	destroy(self.gameObject)
end

function LoginPanel:OnDestroy()
	self:MyExit()
end

function LoginPanel:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function LoginPanel:MakeLister()
	self.lister = {}
	self.lister["upd_privacy_setting"] = basefunc.handler(self, self.upd_privacy_setting)
	self.lister["upd_service_setting"] = basefunc.handler(self, self.upd_service_setting)
	self.lister["model_phone_login_ui"] = basefunc.handler(self, self.on_model_phone_login_ui)
end

function LoginPanel:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function LoginPanel:upd_privacy_setting(value)
	self.privacy = value
end
function LoginPanel:upd_service_setting(value)
	self.service = value
end
function LoginPanel:on_model_phone_login_ui()
	if not GameGlobalOnOff.PhoneLogin then return end
	LoginPhonePanel.Create()
end

--强制大版本更新
--更次更新为Android平台升级为新广告版本,包含鲸鱼斗地主（主渠道，pc蛋蛋，闲玩，英雄鸡）
function LoginPanel:get_upgrade_url()
	local url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V1/Android/jyddz.apk"
	local marketChannel = gameMgr:getMarketChannel()
	if marketChannel == "pceggs" then
		url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V1/Android/jyddz_pceggs.apk"
	elseif marketChannel == "xianwan" then
		url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V1/Android/jyddz_xianwan.apk"
	elseif marketChannel == "yingxiongji" then
		url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V1/Android/jyddz_yingxiongji.apk"
	end
	return url
end
function LoginPanel:force_upgrade()
	HintPanel.Create(1, "请卸载旧版本，下载最新版本，全新体验升级", function()
		Event.Brocast("sys_quit", self:get_upgrade_url())
	end)
end
