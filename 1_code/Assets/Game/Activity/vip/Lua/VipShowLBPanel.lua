-- 创建时间:2019-12-18
-- Panel:VipShowLBPanel
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 --]]

local basefunc = require "Game/Common/basefunc"

VipShowLBPanel = basefunc.class()
local C = VipShowLBPanel
C.name = "VipShowLBPanel"
local config
function C.Create(parent)
	DSM.PushAct({panel = C.name})
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["model_vip_task_change_msg"] = basefunc.handler(self, self.OnReFreshInfo)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if IsEquals(self.gameObject) and self.gameObject.activeSelf then
		DSM.PopAct()
	end
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.transform.localPosition = Vector3.zero
	config = VIPManager.GetVIPCfg() 
	self.JDTlen = 391.48
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.LBpanel = self.transform:Find("LB")
	self.LBChild = self.transform:Find("LBChild")
	self.LBCText = self.LBpanel:Find("CText"):GetComponent("Text")
	self.LBContent = self.LBpanel:Find("Scroll View/Viewport/Content")
	self.AwardChild = self.transform:Find("AwardChild")
	self:OnTask(VIPManager.get_vip_task())
end

function C:OnTask(data)
	if data == nil or not IsEquals(self.gameObject) then return end
	if data then
		self:DoLB(data[111])
	end
end

function C:OnReFreshInfo()
	local data = VIPManager.get_vip_task()
	if data == nil or not IsEquals(self.gameObject) then return end
	if data and data[111] then 
		self:RefreshLB(data[111])
	end 
end

function C:DoLB(data)
	if data == nil then return end
	local b = basefunc.decode_task_award_status(data.award_get_status)
	b = basefunc.decode_all_task_award_status(b, data,VIPExtManager.GetUserMaxVipLevel())
	--dump(b,"------礼包-------")
	self.LBChilds = {}
	for i = 1, VIPExtManager.GetUserMaxVipLevel() do
		local m    = GameObject.Instantiate(self.LBChild, self.LBContent)
		self.LBChilds[#self.LBChilds + 1] = m
		m.gameObject:SetActive(true)
		local content = m.transform:Find("Scroll View/Viewport/Content")
		if i <= 10 then
			m.transform:Find("CZButton").gameObject:GetComponent("Button").onClick:AddListener(
			function()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
				PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
				Event.Brocast("TRY_VIP_SHOW_TASK_COLSE")
			end        
			)
		else
			self.LBChilds[i].transform:Find("CZButton/Text"):GetComponent("Text").text = "前往赢金"
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			m.transform:Find("CZButton").gameObject:GetComponent("Button").onClick:AddListener(
			function()
				local gotoparm = {gotoui = "game_MiniGame"}
				GameManager.GotoUI(gotoparm)
			end        
			)			
		end
		m.transform:Find("LQButton").gameObject:GetComponent("Button").onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			Network.SendRequest("get_task_award_new", { id = 111, award_progress_lv = i })
		end        
		)
		m.transform:Find("TopText/Text1"):GetComponent("Text").text = "VIP等级达到"
		m.transform:Find("TopText/Text2"):GetComponent("Text").text = i .. "级"
		m.transform:Find("TopText/Text3"):GetComponent("Text").text = "时领取"
		for j = 1, #config.lb[i].image do
			local n = GameObject.Instantiate(self.AwardChild, content)
			n.gameObject:SetActive(true)
			n.transform:Find("Image"):GetComponent("Image").sprite = GetTexture(config.lb[i].image[j])
			n.transform:Find("Text"):GetComponent("Text").text = config.lb[i].text[j]
		end
	end
	self:RefreshLB(data)
end

function C:RefreshLB(data)
	if data == nil then return end
	local vip_data = VIPManager.get_vip_data()
	if not vip_data then return end
	local b = basefunc.decode_task_award_status(data.award_get_status)
	b = basefunc.decode_all_task_award_status(b, data, VIPExtManager.GetUserMaxVipLevel())
	for i = 1, VIPExtManager.GetUserMaxVipLevel() do
		if b[i] == 0 then
			self.LBChilds[i].transform:Find("CZButton").gameObject:SetActive(true)
			self.LBChilds[i].transform:Find("LQButton").gameObject:SetActive(false)
			self.LBChilds[i].transform:Find("MASK").gameObject:SetActive(false)
			if config.dangci[i].total then
				local temp = StringHelper.ToCash(config.dangci[i].total)
				self.LBChilds[i].transform:Find("BFBText"):GetComponent("Text").text = StringHelper.ToCash(vip_data.now_charge_sum/100) .."/"..temp
				self.LBChilds[i]:Find("Progress_bg/progress_mask").sizeDelta = {
					x = self.JDTlen * (vip_data.now_charge_sum/100 / config.dangci[i].total),
					y = self.LBChilds[i]:Find("Progress_bg/progress_mask").rect.height
				}
			elseif config.dangci[i].cfz then
				local temp = StringHelper.ToCash(config.dangci[i].cfz)
				self.LBChilds[i].transform:Find("BFBText"):GetComponent("Text").text = StringHelper.ToCash(vip_data.treasure_value) .."/"..temp
				self.LBChilds[i]:Find("Progress_bg/progress_mask").sizeDelta = {
					x = self.JDTlen * (vip_data.treasure_value / config.dangci[i].cfz),
					y = self.LBChilds[i]:Find("Progress_bg/progress_mask").rect.height
				}
			end
		end
		if b[i] == 1 then
			self.LBChilds[i].transform:Find("CZButton").gameObject:SetActive(false)
			self.LBChilds[i].transform:Find("LQButton").gameObject:SetActive(true)
			self.LBChilds[i].transform:Find("MASK").gameObject:SetActive(false)
			if config.dangci[i].total then
				local temp = StringHelper.ToCash(config.dangci[i].total)
				self.LBChilds[i].transform:Find("BFBText"):GetComponent("Text").text = temp.."/"..temp
				self.LBChilds[i]:Find("Progress_bg/progress_mask").sizeDelta = {
					x = self.JDTlen,
					y = self.LBChilds[i]:Find("Progress_bg/progress_mask").rect.height
				}
			elseif config.dangci[i].cfz then
				local temp = StringHelper.ToCash(config.dangci[i].cfz)
				self.LBChilds[i].transform:Find("BFBText"):GetComponent("Text").text = temp.."/"..temp
				self.LBChilds[i]:Find("Progress_bg/progress_mask").sizeDelta = {
					x = self.JDTlen,
					y = self.LBChilds[i]:Find("Progress_bg/progress_mask").rect.height
				}
			end
		end
		if b[i] == 2 then
			self.LBChilds[i].transform:Find("CZButton").gameObject:SetActive(false)
			self.LBChilds[i].transform:Find("LQButton").gameObject:SetActive(false)
			self.LBChilds[i].transform:Find("MASK").gameObject:SetActive(true)
			self.LBChilds[i].transform:SetSiblingIndex(#self.LBChilds)
			if config.dangci[i].total then
				local temp = StringHelper.ToCash(config.dangci[i].total)
				self.LBChilds[i].transform:Find("BFBText"):GetComponent("Text").text = temp.."/"..temp
				self.LBChilds[i]:Find("Progress_bg/progress_mask").sizeDelta = {
					x = self.JDTlen,
					y = self.LBChilds[i]:Find("Progress_bg/progress_mask").rect.height
				}
			elseif config.dangci[i].cfz then
				local temp = StringHelper.ToCash(config.dangci[i].cfz)
				self.LBChilds[i].transform:Find("BFBText"):GetComponent("Text").text = temp.."/"..temp
				self.LBChilds[i]:Find("Progress_bg/progress_mask").sizeDelta = {
					x = self.JDTlen,
					y = self.LBChilds[i]:Find("Progress_bg/progress_mask").rect.height
				}
			end
		end
	end
	for i = vip_data.vip_level+2, VIPExtManager.GetUserMaxVipLevel() do
		if i>=7 then
			self.LBChilds[i].transform:Find("Progress_bg").gameObject:SetActive(false)
			self.LBChilds[i].transform:Find("BFBText").gameObject:SetActive(false)
		end 
	end
	self.LBCText.text = VIPManager.get_vip_level()
end

function C:OnDestroy()
	self:MyExit()
end

function C:OnShow(  )
	if IsEquals(self.gameObject) then
		DSM.PushAct({panel = C.name})
		self.gameObject:SetActive(true)
	end
end

function C:OnHide(  )
	if IsEquals(self.gameObject) and self.gameObject.activeSelf then
		DSM.PopAct()
		self.gameObject:SetActive(false)
	end
end