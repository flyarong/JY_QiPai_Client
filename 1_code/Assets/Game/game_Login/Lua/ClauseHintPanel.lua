local basefunc = require "Game.Common.basefunc"

package.loaded["Game.game_Login.Lua.ClausePanel"] = nil
require "Game.game_Login.Lua.ClausePanel"
-- package.loaded["Game.game_Login.Lua.PrivacyTxt"] = nil
-- require "Game.game_Login.Lua.PrivacyTxt"
-- package.loaded["Game.game_Login.Lua.ServiceTxt"] = nil
-- require "Game.game_Login.Lua.ServiceTxt"
HotUpdateConfig("Game.game_Login.Lua.ServiceTxt")
HotUpdateConfig("Game.game_Login.Lua.PrivacyTxt")

ClauseHintPanel = basefunc.class()
ClauseHintPanel.name = "ClauseHintPanel"
local CLAUSE_IDENT = "_CLAUSE_IDENT_"

local instance

function ClauseHintPanel.Create(parent)
	instance = ClauseHintPanel.New(parent)
	return instance
end

function ClauseHintPanel:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function ClauseHintPanel.Close()
	if instance then
		instance:MyExit()
		instance = nil
	end
end

function ClauseHintPanel:ctor(parent)

	ExtPanel.ExtMsg(self)

	local obj = newObject(ClauseHintPanel.name, parent)
	self.transform = obj.transform
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitRect()
end

function ClauseHintPanel:InitRect()
	local transform = self.transform

	local privacyImg = transform:Find("PrivacyNode/Check_btn/Check_img"):GetComponent("Image")
	local privacyBtn = transform:Find("PrivacyNode/Check_btn"):GetComponent("Button")
	privacyBtn.onClick:AddListener(function()
		local b = privacyImg.gameObject.activeInHierarchy
		b = not b
		privacyImg.gameObject:SetActive(b)
		Event.Brocast("upd_privacy_setting", b)
	end)

	local privacyTxt = transform:Find("PrivacyNode/Check_btn/Text_img"):GetComponent("Image")
	PointerEventListener.Get(privacyTxt.gameObject).onClick = function()
		ClausePanel.Create(1, PrivacyTitle, PrivacyText)
	end
	

	local serviceImg = transform:Find("ServiceNode/Check_btn/Check_img"):GetComponent("Image")
	local serviceBtn = transform:Find("ServiceNode/Check_btn"):GetComponent("Button")
	serviceBtn.onClick:AddListener(function()
		local b = serviceImg.gameObject.activeInHierarchy
		b = not b
		serviceImg.gameObject:SetActive(b)
		Event.Brocast("upd_service_setting", b)
	end)
	
	local serviceTxt = transform:Find("ServiceNode/Check_btn/Text_img"):GetComponent("Image")
	PointerEventListener.Get(serviceTxt.gameObject).onClick = function()
		ClausePanel.Create(2, ServiceTitle, ServiceText)
	end

	if gameMgr:IsFirstRun() then
		if not PlayerPrefs.HasKey(CLAUSE_IDENT) then
			PlayerPrefs.SetInt(CLAUSE_IDENT, 1)
			ClausePanel.Create(1, PrivacyTitle, PrivacyText)
		end
	else
		if PlayerPrefs.HasKey(CLAUSE_IDENT) then
			PlayerPrefs.DeleteKey(CLAUSE_IDENT)
		end

		self:UpdateNotice()
	end
end

function ClauseHintPanel:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function ClauseHintPanel:MakeLister()
	self.lister = {}
	self.lister["clause_ok"] = basefunc.handler(self, self.clause_ok)
end

function ClauseHintPanel:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function ClauseHintPanel:clause_ok(value)
	local ident = PlayerPrefs.GetInt(CLAUSE_IDENT, 0)
	if ident == 1 then
		if value == 1 then
			PlayerPrefs.SetInt(CLAUSE_IDENT, 2)
			ClausePanel.Create(2, ServiceTitle, ServiceText)
		end
	end
	if ident > 0 then
		if value == 2 then
			self:UpdateNotice()
		end
	end
end

function ClauseHintPanel:UpdateNotice()
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

	--[[
			最大次数	起始时间	截止时间	间隔
	每次               *               *                *             *
	每天一次           *               *                *
	只提示一次                         *                *
	]]--

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

--启动事件--
function ClauseHintPanel:Awake()
end

function ClauseHintPanel:Start()	
end

function ClauseHintPanel:OnDestroy()
end
