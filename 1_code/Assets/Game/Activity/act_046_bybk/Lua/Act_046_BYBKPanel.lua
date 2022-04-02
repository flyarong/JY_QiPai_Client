-- 创建时间:2020-12-29
-- Panel:Template_NAME
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

Act_046_BYBKPanel = basefunc.class()
local C = Act_046_BYBKPanel
C.name = "Act_046_BYBKPanel"
local key = "prop_fishingmedal"
local help_info = {
	[1]=
	{
		id = 1,
		text = "1.活动时间：1月12日7:30~1月18日23:59:59;",
	},
	[2]=
	{
		id = 2,
		text = "2.捕鱼勋章可通过街机捕鱼和活动获得",
	},
	[3]=
	{
		id = 3,
		text = "3.普通宝箱单次抽奖必得3000鲸币和40~50积分，黄金宝箱单次抽奖必得6万鲸币和240~300积分",
	},
	[4]=
	{
		id = 4,
		text = "4.收集图鉴参与“狂欢图鉴”活动，可获得巨额奖励。",
	},
}
function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["box_exchange_response"] = basefunc.handler(self,self.on_box_exchange_response)
	self.lister["AssetChange"] = basefunc.handler(self,self.OnAssetChange)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyExit()
	if self.Main_Timer then
		self.Main_Timer:Stop()
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
	self.cut_time = 0.3
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:MianTimer()
	self.can_click = true
end

function C:InitUI()	
	self.level1_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if self.can_click then
			self.can_click = false
			local Count = GameItemModel.GetItemCount(key)		
			if Count >= 10 * 50 then
				Network.SendRequest("box_exchange",{id = 129,num = 10,is_merge_asset = 1})
			elseif Count >= 50 then
				Network.SendRequest("box_exchange",{id = 129,num = 1})
			else
				HintPanel.Create(1,"捕鱼勋章不足")
				self.can_click = true
			end
		end
	end)

	self.level2_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if self.can_click then
			self.can_click = false
			local Count = GameItemModel.GetItemCount(key)		
			if Count >= 10 * 900 then
				Network.SendRequest("box_exchange",{id = 130,num = 10,is_merge_asset = 1})
			elseif Count >= 900 then
				Network.SendRequest("box_exchange",{id = 130,num = 1})
			else
				HintPanel.Create(1,"捕鱼勋章不足")
				self.can_click = true
			end
		end
	end)

	self.get_btn.onClick:AddListener(
		function()
			GameManager.GotoUI({gotoui="game_FishingHall"})
		end
	)

	self.help_btn.onClick:AddListener(
		function()
			self:OpenHelpPanel()
		end
	)
	self:ReFreshUI()
	self:MyRefresh()
end

function C:OpenHelpPanel()
	local str = help_info[1].text
	for i = 2, #help_info do
		str = str .. "\n" .. help_info[i].text
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:MyRefresh()

end

function C:OnAssetChange(data)
	self:ReFreshUI()
	if self:IsCareType(data.change_type) then
		self.cut_time = 0.5
		if self.cur_award == nil then
			self.cur_award = data
		else
			for i = 1,#data.data do
				self.cur_award.data[#self.cur_award.data + 1] = data.data[i]
			end
		end
	end
end

function C:MianTimer()
	self.Main_Timer = Timer.New(function()
		if self.cut_time > 0 then
			self.cut_time = self.cut_time - 0.02
		else
			if self.cur_award then
				self.cur_award = self:MegreData(self.cur_award)
				Event.Brocast("AssetGet", self.cur_award)
				self.cur_award = nil
				self.can_click = true
			end
		end
	end,0.02,-1)
	self.Main_Timer:Start()
end

function C:ReFreshUI()
	local num = GameItemModel.GetItemCount(key)	
	if num >= 10 * 900 then
		self.level2_txt.text = "抽十次"
		self.tt2_txt.text = "x9000"
	else
		self.level2_txt.text = "抽一次"
		self.tt2_txt.text = "x900"
	end

	if num >= 10 * 50 then
		self.level1_txt.text = "抽十次"
		self.tt1_txt.text = "x500"
	else
		self.level1_txt.text = "抽一次"
		self.tt1_txt.text = "x50"
	end
	self.num_txt.text = "x"..num
end

function C:on_box_exchange_response(_,data)

end

function C:IsCareType(_type)
	local types = {"box_exchange_active_award_129","box_exchange_active_award_130","task_p_046_khtj_first"}
	for i = 1,#types do
		if _type == types[i] then
			return true
		end
	end
end

function C:MegreData(data)
	local re = {}
	re.change_type = data.change_type
	re.data = {}
	local temp = {}
	for i = 1,#data.data do
		temp[data.data[i].asset_type] = temp[data.data[i].asset_type] and temp[data.data[i].asset_type] + data.data[i].value or data.data[i].value
	end
	for k,v in pairs(temp) do
		local data = {}
		data.asset_type = k
		data.value = v
		re.data[#re.data + 1] = data
	end
	local order = {
		"jing_bi","prop_grade","other"
	}
	local data = {}
	for i = 1,#order do
		for j = 1,#re.data do	
			if order[i] == re.data[j].asset_type then
				data[#data + 1] = re.data[j]
			elseif i == 3 then
				if re.data[j].asset_type ~= "jing_bi" and re.data[j].asset_type ~= "prop_grade" then
					data[#data + 1] = re.data[j]
				end
			end
		end
	end
	re.data = data
	return re
end