-- 创建时间:2020-12-04
-- Panel:DMBJAutoTest
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

DMBJAutoTest = basefunc.class()
local C = DMBJAutoTest
C.name = "DMBJAutoTest"

function C.Create(DMBJPanel)
	return C.New(DMBJPanel)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["dmbj_clear_opened"] = basefunc.handler(self,self.on_dmbj_clear_opened)
	self.lister["dmbj_clear_closed"] = basefunc.handler(self,self.on_dmbj_clear_closed)
	self.lister["anim_dmbj_exchangepos_finsh"] = basefunc.handler(self,self.on_anim_dmbj_exchangepos_finsh)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(DMBJPanel)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.IsAuto = false
	self.main_txt.text = self.IsAuto and "自动中" or "手动中"
	self.DMBJPanel = DMBJPanel
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.main_btn.onClick:AddListener(
		function()
			self.IsAuto = not self.IsAuto
			self.main_txt.text = self.IsAuto and "自动中" or "手动中"
			if DMBJModel.Status ~= DMBJ_Enum.First and self.IsAuto then
				self:Step1()
			end
		end
	)
	self:MyRefresh()
end

function C:Step1()
	if not self.IsAuto then return end
	if not self.DMBJPanel.lock then
		if MainModel.UserInfo.jing_bi >= DMBJModel.Bet then
			self.DMBJPanel.lock = true
			DMBJModel.ReSetData()
			self.DMBJPanel:ClearBJHDItem()
			self.DMBJPanel.send_exchange = {}
			self.DMBJPanel:ReSetExchangeBtn()
			if DMBJModel.IsTest then
				self.DMBJPanel:DoFirstLottery()
			else
				Network.SendRequest("dmbj_first_kaijiang",{bet_money = DMBJModel.Bet,scene_id = DMBJModel.SceneID},"正在请求数据")
			end
		else
			Event.Brocast("show_gift_panel")
		end
	end
end

function C:Step2()
	if not self.IsAuto then return end
	if not self.DMBJPanel.lock and DMBJModel.Status == DMBJ_Enum.First then
		for i = 3,5 do
			self.DMBJPanel:ChooseExchange(i)
		end
	end
end

function C:on_anim_dmbj_exchangepos_finsh()
	if not self.IsAuto then return end
	self:Step2()
	if DMBJModel.Status == DMBJ_Enum.First then
		if self.DMBJPanel.send_exchange == nil or #self.DMBJPanel.send_exchange == 0 then
			LittleTips.Create("您还没有选择更换的宝物")
			return
		end
		if not self.DMBJPanel.lock then
			self.DMBJPanel.lock = true
			self.DMBJPanel:ReSetExchangeBtn()
			self.DMBJPanel:ClearBJHDItem()
			if DMBJModel.IsTest then
				self.DMBJPanel:DoSecondLottery()
			else
				Network.SendRequest("dmbj_second_kaijiang",{replace_pos = self.DMBJPanel.send_exchange or {}})
			end
		end
	end
end

function C:on_dmbj_clear_closed()
	if not self.IsAuto then return end
	if DMBJModel.Status == DMBJ_Enum.Sceond then
		self:Step1()
	end
end

function C:on_dmbj_clear_opened()
	if not self.IsAuto then return end
	Timer.New(
		function()
			self.DMBJPanel.DMBJClearPanel:MyExit()
		end,2,1
	):Start()
end

function C:MyRefresh()

end
