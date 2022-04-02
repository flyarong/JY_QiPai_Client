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

Act_050_YXBXPanel = basefunc.class()
local C = Act_050_YXBXPanel
local M = Act_050_YXBXManager
C.name = "Act_050_YXBXPanel"
local key = "prop_fish_drop_act_2" --汤圆
--money "106765","prop_fish_drop_act_2",180
local help_info = {
	[1]=
	{
		id = 1,
		text = "1.活动时间：2月23日7:30~3月1日23:59:59;",
	},
	[2]=
	{
		id = 2,
		text = "2.汤圆道具可通过街机捕鱼小游戏获得",
	},
	[3]=
	{
		id = 3,
		text = "3.普通宝箱单次抽奖赠送40~50积分，黄金宝箱单次抽赠送120~150积分",
	},
	[4]=
	{
		id = 4,
		text = "4.收集图鉴参与“元宵图鉴”活动，可获得巨额奖励",
	},
	[5]=
	{
		id = 5,
		text = "5.实物图片仅供参考，具体奖励以实际发出为准",
	},
	[6]=
	{
		id = 6,
		text = "6.抽奖获得的比赛门票为限时门票，活动结束后将全部清除，请及时使用",
	},
}

local real_lis = {
	[13207] = {text = "华为手机",image = "activity_icon_gift188_hwsj"},
	[13208] = {text = "智能手表",image = "activity_icon_gift264_znsb"},
	[13209] = {text = "食用油",image = "activity_icon_gift75_jlyddy"},
	[13210] = {text = "纯棉长袜",image = "activity_icon_gift243_cmcw"},
	[13237] = {text = "华为手机",image = "activity_icon_gift188_hwsj"},	
	[13238] = {text = "智能手表",image = "activity_icon_gift264_znsb"},
	[13239] = {text = "食用油",image = "activity_icon_gift75_jlyddy"},
	[13240] = {text = "纯棉长袜",image = "activity_icon_gift243_cmcw"},
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
	self.lister["box_all_exchange_response"] = basefunc.handler(self,self.on_box_all_exchange_response)

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
	-- if self.Main_Timer then
	-- 	self.Main_Timer:Stop()
	-- end
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
	--self:MianTimer()
	self.can_click = true
end

function C:InitUI()	
	self.level1_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if self.can_click then
			self.can_click = false
			local Count = GameItemModel.GetItemCount(key)		
			if Count < 200 then
				self.can_click = true
				HintPanel.Create(1,"汤圆道具不足")
			elseif self.is_exchange_all then
				self.can_click = true
				HintPanel.Create(2,"确认全部兑换吗？",function()
					Network.SendRequest("box_all_exchange",{name = "yxbx_nor_2_23" })
				end)
			elseif Count >= 10 * 200 then
				Network.SendRequest("box_exchange",{id = 164,num = 10,is_merge_asset = 1})
			elseif Count >= 200 and Count < 10 * 200 then
				Network.SendRequest("box_exchange",{id = 164,num = 1})
			end
		end
	end)

	self.level2_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if self.can_click then
			self.can_click = false
			local Count = GameItemModel.GetItemCount(key)	
			if Count < 500 then
				self.can_click = true
				HintPanel.Create(1,"汤圆道具不足")
			elseif self.is_exchange_all then
				self.can_click = true
				HintPanel.Create(2,"确认全部兑换吗？",function()
					Network.SendRequest("box_all_exchange",{name = "yxbx_nor_2_23" })
				end)
			elseif Count >= 10 * 500 then
				Network.SendRequest("box_exchange",{id = 165,num = 10,is_merge_asset = 1})
			elseif Count >= 500 and Count < 10 * 500 then
				Network.SendRequest("box_exchange",{id = 165,num = 1})
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

	CommonTimeManager.GetCutDownTimer(M.end_time,self.T1_txt)

	self.is_exchange_all = false
	self.lottery_all_tge.onValueChanged:AddListener(function(val)
		self.is_exchange_all = val
		if val then
			HintPanel.Create(1,"一键兑换功能会根据道具组合从多到少自动匹配兑换")
		end
		--self:RefreshBtnUI()
	end)
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
	dump(data,"<color=white>+++++OnAssetChange+++++</color>")
	if self:IsCareType(data.change_type) then
		--self.cut_time = 0.5

		if #data.data < 1 then
			return
		end

		if self.cur_award == nil then
			self.cur_award = data
		else
			for i = 1,#data.data do
				self.cur_award.data[#self.cur_award.data + 1] = data.data[i]
			end
		end
		self:ShowAward()
		self:ReFreshUI()
	end
end

function C:ShowAward()
	if self.cur_award then
		self.cur_award = self:MegreData(self.cur_award)
		Event.Brocast("AssetGet", self.cur_award)
		self.cur_award = nil
		self.can_click = true
	end
end

function C:ReFreshUI()
	local num = GameItemModel.GetItemCount(key)
	self.num_txt.text = "x"..num
	if num >= 10 * 500 then
		self.level2_txt.text = "抽十次"
		self.tt2_txt.text = "x5000"
	else
		self.level2_txt.text = "抽一次"
		self.tt2_txt.text = "x500"
	end

	if num >= 10 * 200 then
		self.level1_txt.text = "抽十次"
		self.tt1_txt.text = "x2000"
	else
		self.level1_txt.text = "抽一次"
		self.tt1_txt.text = "x200"
	end
end

function C:on_box_exchange_response(_,data)
	dump(data,"<color=white>+++++on_box_exchange_response+++++</color>")
	if data.result == 0 and (data.id == 164 or data.id == 165) then
		if #data.award_id < 1 then
			return 
		end

		local _id
		local _real_data = {}
		_real_data.text = {}
		_real_data.image = {}
		for i = 1, #data.award_id do
			_id = data.award_id[i]
			if real_lis[_id] then
				_real_data.text[#_real_data.text + 1] = real_lis[_id].text
				_real_data.image[#_real_data.image + 1] = real_lis[_id].image
			end
		end

		if #_real_data.text >= 1 then
			RealAwardPanel.Create(_real_data)
		end
	end
end

function C:on_box_all_exchange_response(_,data)
	dump(data,"<color=white>+++++on_box_all_exchange_response+++++</color>")
	
end

function C:IsCareType(_type)
	local types = {"box_exchange_active_award_164","box_exchange_active_award_165","task_p_046_khtj_first"}
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
		"jing_bi","prop_grade_2","other"
		--"prop_grade_2","other"
	}
	local data = {}
	for i = 1,#order do
		for j = 1,#re.data do	
			if order[i] == re.data[j].asset_type then
				data[#data + 1] = re.data[j]
			elseif i == 3 then
				if re.data[j].asset_type ~= "jing_bi" and re.data[j].asset_type ~= "prop_grade_2" then
					data[#data + 1] = re.data[j]
				end
			end
		end
	end
	re.data = data
	return re
end