-- 创建时间:2020-05-28
-- Panel:Act_016_CPLXRQTLPanel
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

Act_016_CPLXRQTLPanel = basefunc.class()
local C = Act_016_CPLXRQTLPanel
C.name = "Act_016_CPLXRQTLPanel"
local M = Act_016_CPLXRQTLManager
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
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.backcall then
		self.backcall()
	end
	if self.updata_time then
		self.updata_time:Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent,backcall)
	local parent =  parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.backcall = backcall
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:UpdateTime()
	----dump(GameTaskModel.GetTaskDataByID(M.task_id),"<color=red>PPPPPPPPPPPPPPPPPPPPPPP</color>")
	--Network.SendRequest("get_task_award_new",{id = M.task_id,award_progress_lv = 1})
end

function C:InitUI()
	self.items = {}
	self.item_uis = {}
	for i = 1,7 do
		local temp_ui = {}
		local b = GameObject.Instantiate(self.item,self.node)
		b.gameObject:SetActive(true)
		self.items[i] = b
		LuaHelper.GeneratingVar(b.transform,temp_ui)
		temp_ui.ylq.gameObject:SetActive(false)
		temp_ui.ygq.gameObject:SetActive(false)
		temp_ui.day_txt.text = "第"..i.."天"
		self.item_uis[i] = temp_ui
	end
	self.close_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self.duihuan_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:GetAward()
		end
	)
	self.duihuan2_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:GetAward()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	self.num_txt.text =  string.format("%.2f", M.GetTotalNum()/100)
	for i = 1,7 do
		--dump(M.GetDayIndex(),"<color=red>XXXXXXXXXXXXXXXXXXXXXXXXXXX</color>")
		if i <= M.GetDayIndex() then
			if M.GetDayNum(i) then
				self.item_uis[i].ylq.gameObject:SetActive(true)
				self.item_uis[i].ygq.gameObject:SetActive(false)
			else
				if i ==  M.GetDayIndex() then
					self.item_uis[i].ylq.gameObject:SetActive(false)
					self.item_uis[i].ygq.gameObject:SetActive(false)
				else--过期处理
					self.item_uis[i].ylq.gameObject:SetActive(false)
					self.item_uis[i].ygq.gameObject:SetActive(true)
					self.item_uis[i].bg_img.sprite = GetTexture("yxhb_bg_jl2")
					self.item_uis[i].award_img.sprite = GetTexture("yxhb_icon_hbh")
					self.day_txt.color = Color.New(144,144,144,144)
					self.award_txt.color = Color.New(144,144,144,144)
				end
			end
		else
			self.item_uis[i].ylq.gameObject:SetActive(false)
			self.item_uis[i].ygq.gameObject:SetActive(false)
		end	
	end
	self.duihuan2_btn.gameObject:SetActive(M.GetDayIndex() == 7)
	local total_task = GameTaskModel.GetTaskDataByID(M.total_task_id)
	if total_task then
		self.duihuan2mask.gameObject:SetActive(total_task.award_status == 2)
	end 
end

function C:GetAward()
	if M.GetDayIndex() == 7 then
		if 10 - tonumber(string.format("%.2f", M.GetTotalNum()/100)) <= 0 then
			Network.SendRequest("get_task_award",{id = M.total_task_id})
		else
			Act_016_CPLXRQTLLBPanel.Create()
		end
	else
		HintPanel.Create(1,"还差"..10 - tonumber(string.format("%.2f", M.GetTotalNum()/100)).."元才能领取10元福卡哦~")
	end
end

function C:UpdateTime()
	local time = M.GetStartTime() + 6 * 86400 + M.get_today_remain_time(M.GetStartTime()) - os.time()
	if self.updata_time then
		self.updata_time:Stop()
	end
	self.time_txt.text = "福卡有效期："..StringHelper.formatTimeDHMS2(time)
	self.updata_time = Timer.New(function ()
		time = time - 1
		if time > 0 then
			self.time_txt.text = "福卡有效期："..StringHelper.formatTimeDHMS2(time)
		else
			if self.updata_time then
				self.updata_time:Stop()
			end
			self:MyExit()
		end
	end,1,-1)
	self.updata_time:Start()
end