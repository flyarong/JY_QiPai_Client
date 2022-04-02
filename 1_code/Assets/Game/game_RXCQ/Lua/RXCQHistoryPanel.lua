-- 创建时间:2021-03-09
-- Panel:RXCQHistoryPanel
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

RXCQHistoryPanel = basefunc.class()
local C = RXCQHistoryPanel
C.name = "RXCQHistoryPanel"

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
	self.lister["rxcq_query_game_history_response"] = basefunc.handler(self,self.on_rxcq_query_game_history_response)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.Create_Timer then
		self.Create_Timer:Stop()
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
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	Network.SendRequest("rxcq_query_game_history")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function()
			self:MyExit()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()

end

function C:on_rxcq_query_game_history_response(_,data)
	if data.result == 0 then
		if #data.data == 0 then
			LittleTips.Create("暂无历史记录")
		else
			self:CreateItems(RXCQModel.GetHistory())
		end
	else
		self:CreateItems(RXCQModel.GetHistory())
	end
end

function C:CreateItems(data)
	local max = #data
	local index = 1
	local skill_name_str = {
		BanYueWanDao = "半月弯刀",
        CiShaJianShu = "刺杀剑术",
        GongShaJianShu = "攻杀剑术",
        LieHuoJianFa = "烈火剑法",
	}
	local get_str = function(monster,bet_id)
		local str = "<color=green>【"..RXCQModel.GetGuaiWuConfig(bet_id,monster[1]).name.."】</color>"
		for i = 2,#monster do
			if monster[i] > 0 then
				str = str.."、<color=green>【"..RXCQModel.GetGuaiWuConfig(bet_id,monster[i]).name.."】</color>"
			end
		end
		return str
	end
	self.Create_Timer = Timer.New(
		function()
			local curr_data = data[index]
			if tonumber(curr_data.time) + 25 < os.time() then
				local skill_name = RXCQModel.GetSkillNameByCid(curr_data.cid)
				local temp_ui = {}
				local b = GameObject.Instantiate(self.item,self.Content)
				b.gameObject:SetActive(true)
				LuaHelper.GeneratingVar(b.transform,temp_ui)
				temp_ui.time_txt.text = os.date("%Y-%m-%d %H:%M:%S", tonumber(curr_data.time))
				if skill_name_str[skill_name] then
					temp_ui.desc_txt.text = "使用<color=#19c3e1>【".. skill_name_str[skill_name].."】</color>".."击杀"..get_str(curr_data.monster,curr_data.bet_id).."获得了"..tonumber(curr_data.award_jinbi).."鲸币。"
				else
					if skill_name == "JueZhanShaCheng" then
						temp_ui.desc_txt.text = "触发了<color=#D02D2D>【决战沙城】</color>,获得了"..tonumber(curr_data.award_jinbi).."鲸币。"
					elseif skill_name == "TianRenHeYi" then
						temp_ui.desc_txt.text = "触发了<color=#E9CF3F>【天人合一】</color>,获得了"..tonumber(curr_data.award_jinbi).."鲸币。"
					elseif skill_name == "ShenBinTianJiang" then
						temp_ui.desc_txt.text = "触发了<color=#FF8A00>【神兵天降】</color>,获得了"..tonumber(curr_data.award_jinbi).."鲸币。"
					end
				end
			end
			index = index + 1
		end
	,0.02,max,nil,true)
	self.Create_Timer:Start()
	RXCQModel.AddTimers(self.Create_Timer)
end