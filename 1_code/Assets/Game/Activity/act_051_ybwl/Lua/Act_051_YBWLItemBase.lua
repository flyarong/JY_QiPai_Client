-- 创建时间:2020-11-02
-- Panel:Act_051_YBWLItemBase
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

Act_051_YBWLItemBase = basefunc.class()
local C = Act_051_YBWLItemBase
C.name = "Act_051_YBWLItemBase"
local M = Act_051_YBWLManager
function C.Create(panelSelf,parent,index,config)
	return C.New(panelSelf,parent,index,config)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
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

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(panelSelf,parent,index,config)
	--dump(config,"<color=yellow><size=15>++++++++++data++++++++++</size></color>")
	self.panelSelf = panelSelf
	self.index = index
	self.config = config
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.slider = self.Slider.transform:GetComponent("Slider")

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.go_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnGoClick()
	end)
	self.get_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnGetClick()
	end)

	self.award_txt.text = StringHelper.ToCash(self.config.award_txt[self.index])
	self.taskdesc_txt.text = StringHelper.ToCash(self.config.need_num[self.index]) .. "鲸币"
	--dump({bool=M.CheckGiftWasBought(self.config.gift_id),id=self.config.gift_id},"<color=green><size=15>++++++++++data++++++++++</size></color>")
	if M.CheckGiftWasBought(self.config.gift_id) then--买了
		local task_data = GameTaskModel.GetTaskDataByID(self.config.task_id)
		--dump(task_data,"<color=yellow><size=15>++++++++++data++++++++++</size></color>")
		if task_data then
			if task_data.now_total_process >= self.config.need_num[self.index] then
				self.slider.value = self.config.need_num[self.index] / self.config.need_num[self.index]
				self.process_txt.text = StringHelper.ToCash(self.config.need_num[self.index]) .. "/" .. StringHelper.ToCash(self.config.need_num[self.index])
			else
				self.slider.value = task_data.now_total_process / self.config.need_num[self.index]
				self.process_txt.text = StringHelper.ToCash(task_data.now_total_process) .. "/" .. StringHelper.ToCash(self.config.need_num[self.index])
			end
		end
		if self.config.award_status[self.index] == 1 then
			self.go_btn.gameObject:SetActive(false)
			self.get_btn.gameObject:SetActive(true)
			self.already.gameObject:SetActive(false)
		elseif self.config.award_status[self.index] == 0 then
			self.go_btn.gameObject:SetActive(true)
			self.get_btn.gameObject:SetActive(false)
			self.already.gameObject:SetActive(false)
		elseif self.config.award_status[self.index] == 2 then
			self.go_btn.gameObject:SetActive(false)
			self.get_btn.gameObject:SetActive(false)
			self.already.gameObject:SetActive(true)
		end
	else
		self.go_btn.gameObject:SetActive(true)
		self.get_btn.gameObject:SetActive(false)
		self.already.gameObject:SetActive(false)
		self.slider.value = 0
		self.process_txt.text = "待激活"
	end

	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnGoClick()
	if M.CheckGiftWasBought(self.config.gift_id) then--买了
		if self.config.award_status[self.index] == 1 then
		else
		    -- local channel_type = gameMgr:getMarketPlatform()
		    -- if channel_type == "cjj" then
				--GameManager.GuideExitScene({gotoui = "game_MiniGame"})
		    -- else
			-- 	GameManager.GuideExitScene({gotoui = "game_Fishing3DHall"})
			-- end

			GameManager.GotoUI({gotoui = "game_MiniGame"})
		end
	else
		LittleTips.Create("您当前还未购买此礼包,无法完成此累计赢金任务")
	end
end

function C:OnGetClick()
	--获取奖励
	--dump(self.index,"<color=blue>++++++++++index++++++++++</color>")
	M.GetAward(self.config.task_id,self.config.lv[self.index])
end

--检查是否被领过
function C:CheckStatusIs2()
	--[[if self.config.award_status[self.index] == 2 then
		return true
	else
		return false
	end--]]
end

function C:GetOrderType()
	local data = {
		[0] = "cannot_item",
		[1] = "canget_item",
		[2] = "allready_item",
	}
	return data[self.config.award_status[self.index]]
end