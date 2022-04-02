local basefunc = require "Game.Common.basefunc"

package.loaded["Game.game_Login.Lua.NoticeConfig"] = nil
require "Game.game_Login.Lua.NoticeConfig"

package.loaded["Game.game_Login.Lua.LoginNotice"] = nil
require "Game.game_Login.Lua.LoginNotice"

LoginPanel = basefunc.class()

LoginPanel.name = "LoginPanel"

local instance
function LoginPanel.Create()
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
	print(self.gameObject)
	LuaHelper.GeneratingVar(self.transform, self)
end

function LoginPanel:Start()
	local tran = self.transform
	self.XYButtonImage = tran:Find("TopUI/XYButtonImage")
	self.XYBack = tran:Find("TopUI/XYNode/BackImage")
	self.XYNode = tran:Find("TopUI/XYNode")
	self.Content = tran:Find("TopUI/XYNode/ScrollView/Viewport/Content"):GetComponent("RectTransform")
	self.GameXYText = tran:Find("TopUI/XYNode/ScrollView/Viewport/Content/GameXYText"):GetComponent("Text")
	self.GameXYText.text = LoginLogic.GameXY
	self.JYSpine = tran:Find("JYSpine")
	self.niao = tran:Find("niao")
	self.LoginPanel_che = tran:Find("LoginPanel_che")

	if GameGlobalOnOff.WXLoginChangeToYK then
		self.behaviour:AddClick(self.login_wx_btn.gameObject, LoginPanel.OnLoginYKClick, self)
	else
		self.behaviour:AddClick(self.login_wx_btn.gameObject, LoginPanel.OnLoginWXClick, self)
	end

	if GameGlobalOnOff.QQLoginChangeToYK then
		self.behaviour:AddClick(self.login_qq_btn.gameObject, LoginPanel.OnLoginYKClick, self)
	else
		self.behaviour:AddClick(self.login_qq_btn.gameObject, LoginPanel.OnLoginQQClick, self)
	end


	self.behaviour:AddClick(self.login_wx_close_btn.gameObject, LoginPanel.OnLoginWXCloseClick, self)
	self.behaviour:AddClick(self.login_btn.gameObject, LoginPanel.OnLoginYKClick, self)
	self.behaviour:AddClick(self.delete_visitor_btn.gameObject, LoginPanel.OnBtnDeleteVisitorClick, self)
	self.behaviour:AddClick(self.login_ipf_btn.gameObject, LoginPanel.OnLoginIpfClick, self)
	self.behaviour:AddClick(self.XYButtonImage.gameObject, LoginPanel.OnXYClick, self)
	self.behaviour:AddClick(self.XYBack.gameObject, LoginPanel.OnXYBackClick, self)
	self.behaviour:AddClick(self.GXK_btn.gameObject, LoginPanel.OnGXKClick, self)
	self.behaviour:AddClick(self.repair_btn.gameObject, LoginPanel.OnRepairClick, self)
	self.behaviour:AddClick(self.service_btn.gameObject, LoginPanel.OnServiceClick, self)

	self.Cheat = tran:Find("login_logo/Cheat")

	-- RectJH.Create(self.login_wx_btn.gameObject,1,{x=0,y=20},0.7)
	if gameMgr:ReinstallApp() then
		print("[REINSTALL] delete cache:" .. resMgr.DataPath)
		Directory.Delete(resMgr.DataPath, true)
		HintPanel.Create(1, "下载最新版本，全新体验升级", function()
			local url = ""

			if gameMgr:IsAndroid() then
				url = "http://cwww.jyhd919.cn/shareCaiYun/index.html?from=cymj"
				UnityEngine.Application.OpenURL(url)
			elseif gameMgr:IsIOS() then
				url = "https://itunes.apple.com/cn/app/%E9%B2%B8%E9%B1%BC%E6%96%97%E5%9C%B0%E4%B8%BB-%E5%85%AC%E7%9B%8A%E5%A4%A7%E5%A5%96%E8%B5%9B/id1419509963?mt=8"
				UnityEngine.Application.OpenURL(url)
			end

			--UnityEngine.Application.Quit()

			print("重新安装 url: " .. url)

			return false
		end)

	else
		self:OnStart()
	end

	self.Cheat.transform:SetParent(self.LoginPanel_che.transform)

	-- self.dlSpine = tran:Find("denglu_spine"):GetComponent("SkeletonAnimation")

	-- self.dlSpine.AnimationName = "renwu"
	-- self.spine = Timer.New(function ()
	-- 	self.dlSpine.AnimationName = "animation"
	-- end, 0.667, 1)
	-- self.spine:Start()
	self:OnOff()
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
	if GameGlobalOnOff.WXLogin or GameGlobalOnOff.QQLogin then
		self.login_wx_btn.gameObject:SetActive(GameGlobalOnOff.WXLogin)
		self.login_qq_btn.gameObject:SetActive(GameGlobalOnOff.QQLogin)
		self.others_node.gameObject:SetActive(true)
	else
		self.others_node.gameObject:SetActive(false)
	end

	self.login_btn.gameObject:SetActive(GameGlobalOnOff.YKLogin)
	self.yk_node.gameObject:SetActive(GameGlobalOnOff.YKLogin)

	--[[if GameGlobalOnOff.WXLogin and GameGlobalOnOff.YKLogin then
		self.login_btn.gameObject:SetActive(true)
		self.login_wx_btn.gameObject:SetActive(true)
		self.login_btn.transform.localPosition = Vector3.New(-406, -298, 0)
		self.login_wx_btn.transform.localPosition = Vector3.New(406, -298, 0)
	elseif not GameGlobalOnOff.WXLogin and GameGlobalOnOff.YKLogin then
		self.login_btn.gameObject:SetActive(true)
		self.login_wx_btn.gameObject:SetActive(false)
		self.login_btn.transform.localPosition = Vector3.New(0, -298, 0)
	elseif GameGlobalOnOff.WXLogin and not GameGlobalOnOff.YKLogin then
		self.login_btn.gameObject:SetActive(false)
		self.login_wx_btn.gameObject:SetActive(true)
		self.login_wx_btn.transform.localPosition = Vector3.New(0, -298, 0)
	else
		self.login_btn.gameObject:SetActive(false)
		self.login_wx_btn.gameObject:SetActive(false)		
	end]]--

	if GameGlobalOnOff.FPS then
		self.delete_visitor_btn.gameObject:SetActive(true)
		self.login_wx_close_btn.gameObject:SetActive(true)
	else
		self.delete_visitor_btn.gameObject:SetActive(false)
		self.login_wx_close_btn.gameObject:SetActive(false)
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

	--[[local ip = ""
	local port = 0

	local serverList = gameMgr:getOverrideServerList()
	if serverList then
		--debug
		print("server list: ------------------------------------------------------------------------------------")
		for i = 0, serverList.Length - 1 do
			print("\t" .. serverList[i])
		end


		for i = 0, serverList.Length - 1 do
			local segs = basefunc.string.split(serverList[i], ":")
			--todo use first
			if #segs == 2 then
				ip = segs[1]
				port = tonumber(segs[2])
				break
			end
		end
	end
	
	if ip ~= "" or port > 0 then
		local serverAddress = AppConst.SocketAddress
		local segs = basefunc.string.split(serverAddress, ":")
		if #segs ~= 2 then
			print("[Error] server ip_port is invalid:" .. serverAddress)
		end
		if ip ~= "" then
			segs[1] = ip
		end
		if port > 0 then
			segs[2] = port
		end
		local newServerAddress = segs[1] .. ":" .. segs[2]
		if serverAddress ~= newServerAddress then
			AppConst.SocketAddress = newServerAddress
			print("[Debug] net redir:" .. newServerAddress)
		end
	end]]--

	--self:UpdateNotice()

	--阻塞性提示不能自动登录[todo]非阻塞性提示需要等待点击OK再继续
	--if not LoginLogic.CheckServerStatus(true) then
	--	return
	--end

	self:AutoLogin()
end

function LoginPanel:AutoLogin()
	
	if MainModel.GetIsAutoLogin() then
		LoginLogic.AutoLogin()
	end

end

--移到ClauseHintPanel
--[[
function LoginPanel:UpdateNotice()
	if gameMgr:IsFirstRun() or gameMgr:HasUpdated() then
		print("UpdateNotice update....")
		PlayerPrefs.DeleteKey("NoticeCnt")
		PlayerPrefs.DeleteKey("NoticeTime")
	end

	if not NoticeConfig then return end

	local PlayerPrefs = UnityEngine.PlayerPrefs

	local NoticeType = NoticeConfig.NoticeType or 0
	print("UpdateNotice noticeType: " .. NoticeType)
	dump(NoticeConfig)

	if NoticeType <= 0 or NoticeType > MaxNoticeType then
		PlayerPrefs.DeleteKey("NoticeCnt")
		PlayerPrefs.DeleteKey("NoticeTime")
		return
	end

	--
	--		最大次数	起始时间	截止时间	间隔
	--每次               *               *                *             *
	--每天一次           *               *                *
	--只提示一次                         *                *
	--

	local currTime = os.time()
	local currCnt = 1

	local Condition = NoticeConfig.Condition or {}

	--check time
	local StartStamp = Condition.StartStamp or 0
	local EndStamp = Condition.EndStamp or 0
	if StartStamp > 0 and currTime < StartStamp then
		print(string.format("LoginPanel:UpdateNotice currStamp(%u) not reach StartStamp(%u)", currTime, StartStamp))
		return
	end
	if EndStamp > 0 and currTime > EndStamp then
		print(string.format("LoginPanel:UpdateNotice currStamp(%u) has pass EndStamp(%u)", currTime, EndStamp))
		return
	end

	--check 只提示一次
	if NoticeType == NoticeOnce and PlayerPrefs.HasKey("NoticeTime") then
		print("LoginPanel:UpdateNotice NoticeOnce was Happen")
		return
	end

	if NoticeType == NoticeEverytime or NoticeType == NoticeEveryday then
		--check MaxCnt
		local MaxCnt = Condition.MaxCnt or 0
		if MaxCnt > 0 and PlayerPrefs.HasKey("NoticeCnt") then
			currCnt = PlayerPrefs.GetInt("NoticeCnt")
			currCnt = currCnt + 1
			if currCnt > MaxCnt then
				print(string.format("LoginPanel:UpdateNotice currCnt(%d) > MaxCnt(%d)", currCnt, MaxCnt))
				return
			end
		end

		--check IntervalStamp
		if NoticeType == NoticeEverytime then
			--check IntervalStamp
			local IntervalStamp = Condition.IntervalStamp or 0
			if IntervalStamp > 0 and PlayerPrefs.HasKey("NoticeTime") then
				local lastTime = tonumber(PlayerPrefs.GetString("NoticeTime"))
				if currTime - lastTime < IntervalStamp then
					print(string.format("LoginPanel:UpdateNotice currTime(%u) - lastTime(%u) < IntervalStamp(%d)", currTime, lastTime, IntervalStamp))
					return
				end
			end
		end

		--check 每天一次
		if NoticeType == NoticeEveryday then
			if PlayerPrefs.HasKey("NoticeTime") then
				local lastTime = tonumber(PlayerPrefs.GetString("NoticeTime"))

				local lastDate = os.date("!*t", lastTime)
				local currDate = os.date("!*t", currTime)
				if lastDate.day == currDate.day then
					print(string.format("LoginPanel:UpdateNotice currDate(%d) == lastDate(%d)", currDate.day, lastDate.day))
					return
				end
			end
		end

	end

	PlayerPrefs.SetInt("NoticeCnt", currCnt)
	PlayerPrefs.SetString("NoticeTime", tostring(currTime))

	LoginNotice.Create(LoginNoticeText)
end
]]--

--游客登录
function LoginPanel:OnLoginYKClick(go)

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


	--local b = self.gxImage.gameObject.activeInHierarchy
	if self.privacy == true and self.service == true then
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		LoginLogic.WechatLogin()
	else
		LittleTips.Create("勾选同意下方协议才能进入游戏")
	end
end

--微信登录
function LoginPanel:OnLoginQQClick(go)
	--local b = self.gxImage.gameObject.activeInHierarchy
	if self.privacy == true and self.service == true then
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		LoginLogic.QQLogin()
	else
		LittleTips.Create("勾选同意下方协议才能进入游戏")
	end
end

--测试的输入登录
function LoginPanel:OnLoginIpfClick(go)
	LoginLogic.testLogin(self.user_name_ipf.text)
end

function LoginPanel:OnXYClick(go)
	self:ShowXY()
end
function LoginPanel:OnGXKClick()
	local b = self.gxImage.gameObject.activeInHierarchy
	self.gxImage.gameObject:SetActive(not b)
end
function LoginPanel:OnXYBackClick(go)
	self.XYNode.gameObject:SetActive(false)
end
function LoginPanel:ShowXY()
	self.Content.localPosition = Vector3.zero
	self.XYNode.gameObject:SetActive(true)
end

function LoginPanel:OnBtnDeleteVisitorClick(go)
	LoginLogic.clearYoukeData()
end


function LoginPanel:OnLoginWXCloseClick(go)
	LoginLogic.clearWechatData()
	LoginLogic.clearQqData()
end

function LoginPanel:OnRepairClick()
	if Directory.Exists(resMgr.DataPath) then
		Directory.Delete(resMgr.DataPath, true)
	end
	HintPanel.Create(1, "修复完毕，请重新运行游戏", function ()
		--UnityEngine.Application.Quit()
		gameMgr:QuitAll()
	end)
end

function LoginPanel:OnServiceClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	--sdkMgr:CallUp("400-8882620")
	Event.Brocast("callup_service_center", "400-8882620")
	--self.service_btn.gameObject:SetActive(false)
end

function LoginPanel:OnDestroy()
	if self.spine then
		self.spine:Stop()
	end
	self.spine = nil

	ClauseHintPanel.Close()
	self:RemoveListener()
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
