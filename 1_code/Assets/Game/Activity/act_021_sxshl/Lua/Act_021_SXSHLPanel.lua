-- 创建时间:2020-07-07
-- Panel:Act_021_SXSHLPanel
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

Act_021_SXSHLPanel = basefunc.class()
local C = Act_021_SXSHLPanel
C.name = "Act_021_SXSHLPanel"
local M = Act_021_SXSHLManager

local goto_key = {
	"by","xxl","csxxl","shxxl","xyxxl"
}
local goto_scene = {
	"game_FishingHall","game_Eliminate","game_EliminateCS","game_EliminateSH","game_EliminateXY"
}
local DESCRIBE_TEXT = {
	[1] = "1.活动时间：9月22日7:30-9月28日23:59:59",
	[2] = "2.多次触发奖励未领取，只保留最后一次触发的奖励，请及时领取奖励",
	[3] = "3.消耗翻倍卡可使获得的奖励相应的翻倍，活动结束后未使用的翻倍卡自动清除",
	[4] = "4.每个玩家每天最多瓜分50次彩金池奖励",
	[5] = "5.游戏档次越高，参与瓜分的份额越大哦",
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
	self.lister["AssetChange"] = basefunc.handler(self, self.AssetChange)
	self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
	self.lister["act_021_sxshl_get"] = basefunc.handler(self,self.act_021_sxshl_get)
	self.lister["query_fake_data_response"] = basefunc.handler(self,self.AddPMD)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.UpdatePMD then
		self.UpdatePMD:Stop()
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
	self.transform.localPosition = Vector2.New(0,0)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:act_021_sxshl_get()
	self:RefreshTaskUI()
	self:RefreshFBK()
	self.pmd_cont = CommonPMDManager.Create({parent = self.pmd_node,speed = 5,space_time = 20,start_pos = 1000})
	self:UpDatePMD()
end

function C:InitUI()
	for i = 1,5 do
		self["go"..i.."_btn"].onClick:AddListener(
			function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				GameManager.CommonGotoScence({gotoui = goto_scene[i] }, function ()
					self:MyExit()
				end)
			end
		)
	end
	self.help_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:OpenHelpPanel()
		end
	)
	self.max_fb_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self.fabeipanel.gameObject:SetActive(true)
		end
	)
	self.huoqu_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			-- Act_021_SXLBPanel.Create(nil,nil,Act_021_SXLBManager.GetConfig())
			Act_030_CJFBLBPanel.Create()
			self.fabeipanel.gameObject:SetActive(false)
		end
	)
	self.close2_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self.fabeipanel.gameObject:SetActive(false)
		end
	)
	self.get_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			local data = GameTaskModel.GetTaskDataByID(M.task_id)
			if data then
				if data.award_status == 1 then
					Network.SendRequest("get_task_award",{id = M.task_id})
				else
					HintPanel.Create(1,"完成任务即可领取彩金哦")
				end
			end
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()

end

function C:OnDestroy()
	self:MyExit()
end 

function C:OpenHelpPanel()
    local str = DESCRIBE_TEXT[1]
    for i = 2, #DESCRIBE_TEXT do
        str = str .. "\n" .. DESCRIBE_TEXT[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:act_021_sxshl_get()
	local data = M.GetJiangChiVar()
	--dump(data,"<color=red>act_021_sxshl_get</color>")
	for i = 7, 1, -1 do
		self["num"..(8 - i).."_txt"].text = data[i]
	end
end

function C:AssetChange(data)
	if data.change_type then
		if data.change_type == "super_money_prop_double_card_normal" then
			Act_021_SXSHLShowAwardPanel.Create({value = data.data[1].value/100})
		end
		if data.change_type == "super_money_prop_double_card_silver" then
			Act_021_SXSHLShowAwardPanel.Create({value = data.data[1].value/100,jb="1.5倍"})
		end
		if data.change_type == "super_money_prop_double_card_brass" then
			Act_021_SXSHLShowAwardPanel.Create({value = data.data[1].value/100,jb="1.2倍"})
		end
		if data.change_type == "super_money_prop_double_card_gold" then
			Act_021_SXSHLShowAwardPanel.Create({value = data.data[1].value/100,jb="2倍"})
		end

	end
	self:RefreshFBK()
end

function C:on_model_task_change_msg(data)
	self:RefreshTaskUI()
end

function C:RefreshTaskUI()
	local data = GameTaskModel.GetTaskDataByID(M.task_id)
	if data then
		if data.award_status == 1 then
			self.kuang_01.gameObject:SetActive(true)
		else
			self.kuang_01.gameObject:SetActive(false)
		end
		if M.GetAwardNum() >= 50 then
			self.get_btn.enabled = false
			self.get_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("com_btn_8")
			self.get_txt.text = "<size=40>今日已达上限</size>"
			self.kuang_01.gameObject:SetActive(false)
		end
	end
end

function C:RefreshFBK()
	local total = 0
	local str = {"铜","银","金"}
	for i = 1,#M.item_keys do
		total = total + GameItemModel.GetItemCount(M.item_keys[i])
		self["fbk"..i.."_txt"].text = "翻倍"..str[i].."卡("..GameItemModel.GetItemCount(M.item_keys[i])..")"
	end
	self.max_fb_txt.text = total
end

function C:UpDatePMD()
	if self.UpdatePMD then
		self.UpdatePMD:Stop()
	end
	Network.SendRequest("query_fake_data",{data_type = "summer_super_money"})
	self.UpdatePMD = Timer.New(
		function ()
			Network.SendRequest("query_fake_data",{data_type = "summer_super_money"})
		end
	,13,-1)
	self.UpdatePMD:Start()
end

local task_name = {
	"<color=#fcf137>街机捕鱼</color>中击杀黄金龙分奖池",
	"<color=#fcf137>水果消消乐</color>触发幸运时刻分奖池",
	"<color=#fcf137>财神消消乐</color>触发天女散花分奖池",
	"<color=#fcf137>水浒消消乐</color>触发≥2个英雄分奖池",
	"<color=#fcf137>西游消消乐</color>触发免费游戏打村姑分奖池",
}
function C:AddPMD(_,data)
	dump(data,"<color=red>PMD</color>")
	if not IsEquals(self.gameObject) then return end
	math.randomseed(os.time())
	local rom = math.random(1,5)
	if data and data.result == 0 then
		local b = GameObject.Instantiate(self.pmd_item,self.pmd_node)
		b.gameObject:SetActive(true)
		local temp_ui = {}
		LuaHelper.GeneratingVar(b.transform,temp_ui)
		temp_ui.t1_txt.text = "玩家【"..data.player_name.."】在"..task_name[rom].."瓜分彩金<color=#fc6137>"..(data.award_data/100).."</color>福卡"
		UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(b.transform)
		self.pmd_cont:AddObj(b)
	end
end