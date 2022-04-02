-- 创建时间:2020-11-08
-- Panel:CPL_LJYJCFK_CJXXLPrefab
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

CPL_LJYJCFK_CJXXLPrefab = basefunc.class()
local C = CPL_LJYJCFK_CJXXLPrefab
C.name = "CPL_LJYJCFK_CJXXLPrefab"
local M = CPL_LJYJCFKManager
local config = M.config
--两端的间距
local head_space = 93.7
local point_width = 50
local normal_spcae = 211.75

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
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
	self.lister["get_task_award_response"] = basefunc.handler(self,self.on_get_task_award_response)
	self.lister["eliminate_cj_game_over"] = basefunc.handler(self,self.on_eliminate_cj_game_over)
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

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("GUIRoot/EliminateCJGamePanel/bg/@Activity_Node").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.sv = self.transform:Find("Scroll View"):GetComponent("ScrollRect")
	self:MakeLister()
	self:AddMsgListener()
	self.huxi = CommonHuxiAnim.Go(self.lottery_btn.gameObject,1.6,0.9,1.3)
	self:InitUI()
	HandleLoadChannelLua(C.name,self)
end

function C:InitUI()
	self.lottery_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			GameManager.GotoUI({gotoui = M.key,goto_scene_parm = "panel_lottery"})
			self:RefreshPro()
		end
	)
	self:InitPro()
	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshPro()
end

function C:InitPro()
	local length = 2 * head_space + (#M.config.base - 1) * normal_spcae
	local point_pos_list = {}
	point_pos_list[1] = head_space
	for i = 2,#M.config.base do
		point_pos_list[#point_pos_list + 1] = (i - 1) * normal_spcae + head_space
	end
	self.process.transform.sizeDelta = {
		x = 0,y = 29
	}
	self.process_bg.transform.sizeDelta = {
		x = length,y = 29.5
	}
	self.p_node.transform.sizeDelta = {
		x = length,y = 30
	}
	self.Content.transform.sizeDelta = {
		x = length,y = 100
	}
	self.hb_node.transform.sizeDelta = {
		x = length,y = 30
	}
	self.point_table = {}
	self.hb_table = {}
	for i = 1,#point_pos_list do
		local temp_p = {}
		local point = GameObject.Instantiate(self.point,self.p_node)
		point.gameObject:SetActive(true)
		point.transform.localPosition = Vector3.New(point_pos_list[i],0,0)
		LuaHelper.GeneratingVar(point,temp_p)
		self.point_table[#self.point_table + 1] = temp_p
		temp_p.full.gameObject:SetActive(false)

		local temp_hb = {}
		local hb = GameObject.Instantiate(self.hb_item,self.hb_node)
		LuaHelper.GeneratingVar(hb,temp_hb)
		hb.gameObject:SetActive(true)
		self.hb_table[#self.hb_table + 1] = temp_hb
		temp_p.num_txt.text = M.config.base[i].show_hb
		temp_hb.hb_img.sprite = GetTexture("ty_icon_flq"..(i > 3 and 3 or i))
		hb.transform.localPosition = Vector3.New(point_pos_list[i],40,0)
	end
	self.point_pos_list = point_pos_list
	self.p_node.transform.parent = self.Content
	self.p_node.transform.localPosition = Vector3.New(0,0,0)
end

function C:RefreshPro()
	local level = self:GetNowLevel()
	local base_len = 0
	if level and level >= 2 then
		base_len = self.point_pos_list[level - 1] + point_width / 2
	end
	for i = 1,#self.hb_table do
		self.hb_table[i].guang.gameObject:SetActive(false)
		self.point_table[i].full.gameObject:SetActive(false)
	end
	local task_id = M.config.base[1].task
	local data = GameTaskModel.GetTaskDataByID(task_id)
	if data then
		if data.award_status == 1 then
			self.hb_table[level - 1].guang.gameObject:SetActive(true)
			self.huxi.Start()
			Event.Brocast("WZQGuide_Check",{guide = 2 ,guide_step = 1})
		else
			self.huxi.Stop()
		end

		for i = 1,level - 1 do
			self.point_table[i].full.gameObject:SetActive(true)
		end

		if level <= #self.hb_table then
			self:RefreshHintText(data,level,M.config.base[level].hb[3])
		else
			self.hint_txt.text = "请立即点击领取奖励"
		end
		local now_total = data.now_total_process
		local now_had = 0
		local one_length = 0
		if level >= 2  then
			now_had = M.config.base[level - 1].total
			one_length = normal_spcae - point_width / 2
		elseif level < 2 then
			one_length = head_space - point_width / 2
		end
		--加0.1 是避免除0问题
		local now_need = M.config.base[level > 10 and 10 or level].total + 0.1
		local bfb = (now_total - now_had)/(now_need - now_had)
		-- 当当前的等级为11（就是所有完成了所有的等级），直接满进度条
		local total_length = 2 * head_space + (#M.config.base - 1) * normal_spcae
		local len = level <= 10 and (bfb * one_length + base_len) or total_length
		self.process.transform.sizeDelta = {
			x = len,y = 29
		}
		if level > 8 then
			self.sv.horizontalNormalizedPosition = 1
		elseif level < 4 then
			self.sv.horizontalNormalizedPosition = 0
		else
			self.sv.horizontalNormalizedPosition = len / total_length
		end
	end
end

function C:RefreshHintText(data,level,hb)
	self.hint_txt.text = string.format("再赢金<color=#fffd00ff>%s</color>，可抽取<color=#fffd00ff>%s福卡！</color>", StringHelper.ToCash(data.need_process - data.now_process),M.config.base[level].hb[3])	
end

function C:GetNowLevel()
	local task_id = M.config.base[1].task
	local data = GameTaskModel.GetTaskDataByID(task_id)
	if data then
		local now_total = data.now_total_process
		local level = 1
		for i = 2,#M.config.base + 1 do 
			if now_total >= M.config.base[i - 1].total then
				level = i
			end
		end
		return level
	end
end

function C:on_eliminate_cj_game_over(data)
	self:RefreshPro()
end

function C:on_get_task_award_response()
	self:RefreshPro()
end