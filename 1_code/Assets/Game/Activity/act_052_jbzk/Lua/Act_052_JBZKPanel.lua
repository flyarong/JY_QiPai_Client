-- 创建时间:2021-02-24
-- Panel:Act_052_JBZKPanel
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

Act_052_JBZKPanel = basefunc.class()
local C = Act_052_JBZKPanel
C.name = "Act_052_JBZKPanel"
local M = Act_052_JBZKManager
local config = {
	1888,3888,5888,8888,12000,16000,18000
}
local image = {
	"pay_icon_gold2","pay_icon_gold3","pay_icon_gold4","pay_icon_gold5","pay_icon_gold6","pay_icon_gold7","pay_icon_gold8"
}

function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["jbzk_refresh"] = basefunc.handler(self,self.MyRefresh)
	self.lister["award_jbzk_response"] = basefunc.handler(self,self.on_award_jbzk_response)
	self.lister["activate_jbzk_response"] = basefunc.handler(self,self.on_activate_jbzk_response)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self.huxi.Stop()
	for i = 1,#self.huxi_anim do
		self.huxi_anim[i].Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.huxi = CommonHuxiAnim.Go(self.go_btn.gameObject)
	self.huxi.Start()
end

function C:InitUI()
	self:InitMainUI()
	self.close_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self.go_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			AdvertisingManager.RandPlay("jbzk", nil, function ()
				print("<color=red>开始解锁</color>")
				Network.SendRequest("activate_jbzk",{watch_ad = 1})
			end)
		end
	)
	self.help_btn.onClick:AddListener(
		function()
			IllustratePanel.Create({ self.introduce_txt}, GameObject.Find("Canvas/LayerLv5").transform)
		end
	)
	self:MyRefresh()
	M.GetList()
end

function C:MyRefresh()
	if not IsEquals(self.gameObject) then return end
	local data = M.GetList()
	local day_index = M.GetDayIndex()

	if M.IsAct() then
		if self.cut_timer then
			self.cut_timer:Stop()
		end
		self.cut_timer = CommonTimeManager.GetCutDownTimer(M.GetOverTimer(M.GetActiveTime()),self.cut_down_txt)
		self.go_btn.gameObject:SetActive(false)
	else
		if self.cut_timer then
			self.cut_timer:Stop()
		end
		self.cut_timer = CommonTimeManager.GetCutDownTimer(M.GetOverTimer(MainModel.FirstLoginTime()),self.cut_down_txt)
		self.go_btn.gameObject:SetActive(true)
		for i = 1,#data do
			self.ui[i].bg1.gameObject:SetActive(true)
			self.ui[i].bg2.gameObject:SetActive(false)
			self.ui[i].bg3.gameObject:SetActive(false)
			self.ui[i].bl.gameObject:SetActive(false)
			self.ui[i].lq.gameObject:SetActive(false)
		end
		return
	end

	for i = 1,#data do
		if data[i] == 1 then
			self.ui[i].bg1.gameObject:SetActive(true)
			self.ui[i].bg2.gameObject:SetActive(false)
			self.ui[i].bg3.gameObject:SetActive(true)
			self.ui[i].bl.gameObject:SetActive(false)
			self.ui[i].lq.gameObject:SetActive(false)
		else
			if i < day_index then
				self.ui[i].bg1.gameObject:SetActive(true)
				self.ui[i].bg2.gameObject:SetActive(false)
				self.ui[i].bg3.gameObject:SetActive(false)
				self.ui[i].bl.gameObject:SetActive(true)
				self.ui[i].lq.gameObject:SetActive(false)
			elseif i == day_index then
				self.ui[i].bg1.gameObject:SetActive(true)
				self.ui[i].bg2.gameObject:SetActive(true)
				self.ui[i].bg3.gameObject:SetActive(false)
				self.ui[i].bl.gameObject:SetActive(false)
				self.ui[i].lq.gameObject:SetActive(true)
			else
				self.ui[i].bg1.gameObject:SetActive(true)
				self.ui[i].bg2.gameObject:SetActive(false)
				self.ui[i].bg3.gameObject:SetActive(false)
				self.ui[i].bl.gameObject:SetActive(false)
				self.ui[i].lq.gameObject:SetActive(false)
			end
		end
	end
end

function C:InitMainUI()
	self.ui = {}
	self.huxi_anim = {}
	for i = 1,#config do
		local temp_ui = {}
		local b = self["item"..i].transform
		LuaHelper.GeneratingVar(b,temp_ui)
		temp_ui.day_txt.text = "第"..i.."天"
		temp_ui.main_img.sprite = GetTexture(image[i])
		temp_ui.num_txt.text = config[i]
		self.huxi_anim[#self.huxi_anim + 1] = CommonHuxiAnim.Go(temp_ui.bl,1,0.95,1.05)
		self.huxi_anim[#self.huxi_anim ].Start()
		self.huxi_anim[#self.huxi_anim + 1] = CommonHuxiAnim.Go(temp_ui.lq,1,0.95,1.05)
		self.huxi_anim[#self.huxi_anim ].Start()
		temp_ui.main_btn.onClick:AddListener(
			function()
				self:OnBtnClick(i)
			end
		)
		self.ui[#self.ui + 1] = temp_ui
	end
end

function C:OnBtnClick(i) 
	local day_index = M.GetDayIndex()
	local data = M.GetList()
	if not M.IsAct() then
		return
	end
	if data[i] == 1 then
		return
	else
		if i > day_index then
			return
		elseif i == day_index then
			--前四天不看广告
			if i < 5 then
				Network.SendRequest("award_jbzk",{day_id = i,multiple = 1,watch_ad = 0})
			else
				self.morepanel.gameObject:SetActive(true)
				self.b1_btn.onClick:RemoveAllListeners()
				self.b3_btn.onClick:RemoveAllListeners()
				self.b3_img.sprite = GetTexture(image[i])
				self.num3_txt.text = config[i]
				self.num1_txt.text = math.floor(config[i]/3)
				self.b1_btn.onClick:AddListener(
					function()
						Network.SendRequest("award_jbzk",{day_id = i,multiple = 1,watch_ad = 0})
						self.morepanel.gameObject:SetActive(false)
					end
				)
				self.b3_btn.onClick:AddListener(
					function()
						AdvertisingManager.RandPlay("jbzk", nil, function ()
							Network.SendRequest("award_jbzk",{day_id = i,multiple = 3,watch_ad = 1})
							self.morepanel.gameObject:SetActive(false)
						end)
					end
				)
			end
		else
			AdvertisingManager.RandPlay("jbzk", nil, function ()
				local multiple
				if i < 5 then
					multiple = 1
				else
					multiple = 3
				end
				Network.SendRequest("award_jbzk",{day_id = i,multiple = multiple,watch_ad = 1})
			end)
		end
	end
end

function C:on_activate_jbzk_response(_,data)
	dump(data,"<color=red>激活周卡</color>")
	if data.result == 0 then
		Network.SendRequest("query_jbzk_info")
		HintPanel.Create(1,"恭喜您激活成功,记得每天来领金币哦 ~")
		self:MyRefresh()
	end
end

function C:on_award_jbzk_response(_,data)
	dump(data,"<color=red>奖励</color>")
	Network.SendRequest("query_jbzk_info")
end