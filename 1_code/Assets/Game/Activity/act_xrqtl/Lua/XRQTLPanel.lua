-- 创建时间:2020-01-15
-- Panel:XRQTLPanel
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

XRQTLPanel = basefunc.class()
local C = XRQTLPanel
C.name = "XRQTLPanel"
local config = XRQTLManager.config
local M = XRQTLManager
local Chinese = {"一","二","三","四","五","六","七","八","九","十","零"}
function C.Create(parent,backcall)
	return C.New(parent,backcall)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["global_hint_state_set_msg"] = basefunc.handler(self,self.on_global_hint_state_set_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.timer then
		self.timer:Stop()
		self.timer = nil
	end
	if self.backcall then 
		self.backcall()
	end
	self:RemoveListener()
	Event.Brocast("sys_023_exxsyd_panel_close")
	destroy(self.gameObject)

	 
end

function C:ctor(parent,backcall)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.backcall = backcall
	LuaHelper.GeneratingVar(self.transform, self)
	self.btn_image = self.get_btn.gameObject.transform:GetComponent("Image")
	self:MakeLister()
	self:AddMsgListener()
	self.timer = Timer.New(function (  )
		local b = StringHelper.GetTodayEndTime() == os.time()
		if b then
			self:MyRefresh()
		end
	end,1,-1,false,false)
	self.timer:Start()
	self:InitUI()
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	local temp_ui = {}
	self.award_items = {}
	for i=1,#config.Info do
		local b = GameObject.Instantiate(self.award_item,self.node)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform, temp_ui)
		temp_ui.award_txt.text = config.Info[i].task_award_text
		temp_ui.award_day_txt.text = "第"..Chinese[i].."天"
		temp_ui.award_img.sprite = GetTexture(config.Info[i].task_award_image) 
		temp_ui.bg2_img.gameObject:SetActive(false)
		self.award_items[i] = b
	end
	self:MyRefresh()
end

function C:MyRefresh()
	if not IsEquals(self.gameObject) then return end
	local today
	local temp_ui = {}
	local d = M.GetDayIndex() + 1
	dump(d,"第"..d.."天")
	self.day_txt.text = "第"..d.."天"
	self.get_btn.onClick:RemoveAllListeners()
	if d <= 7 then 
		self.tips_txt.text = config.Info[d].task_info
		local task_data = M.GetCurrTaskData()
		dump(task_data,"<color=red>新人七天乐任务数据=====</color>")
		if task_data then 
			local lgh = 518.11 * task_data.now_process/task_data.need_process
			if IsEquals(self.p_txt) then
				self.p_txt.text = task_data.now_process.."/"..task_data.need_process
			end
			if IsEquals(self.p_lengh) then
				self.p_lengh.transform.sizeDelta = {
					x = lgh > 518.11 and  518.11 or lgh,
					y = 26.16
				}
			end
		end
		if task_data and task_data.award_status == 1 then
			self.get_txt.text = "领 取"
			self.btn_image.sprite = GetTexture("com_btn_5")
			self.get_btn.onClick:AddListener(
				function ()
					Network.SendRequest("get_task_award",{id = task_data.id})
				end
			)
		elseif task_data and task_data.award_status == 2 then 
			self.get_txt.text = "已领取"
			self.btn_image.sprite = GetTexture("com_btn_8")
		elseif task_data then
			self.get_txt.text = "前 往"
			self.btn_image.sprite = GetTexture("com_btn_5")
			self.get_btn.onClick:AddListener(
				function ()
					GameManager.GotoUI({gotoui = "game_MiniGame"}, function ()
						self:MyExit()
					end)
				end
			)
		end
		for i=1,#config.Info do
			local task_data = M.GetTaskDataByDay(i)
			-- dump(task_data,"任务")
			if IsEquals(self.award_items[i]) then
				LuaHelper.GeneratingVar(self.award_items[i],temp_ui)
			end
			if IsEquals(temp_ui.get_award_btn) then
				temp_ui.get_award_btn.onClick:RemoveAllListeners()
			end
			if task_data then
				if i < d then 
					if task_data.award_status == 2 then 
						temp_ui.lq.gameObject:SetActive(true)
					else
						temp_ui.gq.gameObject:SetActive(true)
					end
				elseif  i == d then 
					if task_data.award_status == 2 then 
						temp_ui.lq.gameObject:SetActive(true)
						temp_ui.bg2_img.gameObject:SetActive(false)
					elseif task_data.award_status == 1 then
						temp_ui.get_award_btn.onClick:AddListener(
							function()
								Network.SendRequest("get_task_award",{id = task_data.id})
							end
						)
						temp_ui.lq.gameObject:SetActive(false)
						temp_ui.bg2_img.gameObject:SetActive(true)
					else
						temp_ui.bg2_img.gameObject:SetActive(true)
					end
				elseif d > 1 then
					
				end
			end 
		end
	end
	self:SetHint()
end

function C:on_global_hint_state_set_msg(data)
	if data and data.gotoui == M.key then 
		self:MyRefresh()
	end 
end

function C:SetHint()
	local day = M.GetDayIndex() + 1
	if day > 6 or day < 1 then return end
	local task_data = M.GetCurrTaskData()
	if task_data and task_data.award_status == 2 then 
		--"已领取"
		local b = StringHelper.GetTodayEndTime() > os.time()
		local txt = config.Info[day + 1].task_award_text
		if string.find(txt,"鲸币") then
			txt = "明天来领鲸币哦"
		elseif string.find(txt,"福卡") then
			txt = "明天来领福卡哦"
		end
		local temp_ui = {}
		LuaHelper.GeneratingVar(self.award_items[day + 1],temp_ui)
		temp_ui.hint_txt.text = txt
		temp_ui.hint.gameObject:SetActive(b)
		temp_ui.bg2_img.gameObject:SetActive(b)
	end
end