-- 创建时间:2020-12-29
-- Panel:Act_050_YXTJPanel
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

Act_050_YXTJPanel = basefunc.class()
local C = Act_050_YXTJPanel
C.name = "Act_050_YXTJPanel"
local M = Act_050_YXTJManager

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
	self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
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

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:OnDestroy()
	self:MyExit()
end

function C:InitUI()
	--dump(M.config.books,"<color=red>BBBBBBBBBBBBBBBBBBBBBBBBBBBook</color>")
	self.book_lis = {}
	for i = 1,#M.config.books do 
		local temp = {}
		local b = GameObject.Instantiate(self.item,self.Content)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform,temp)
		temp.item_img.sprite = GetTexture(M.config.books[i].icon)
		temp.item_txt.text = "x"..M.config.books[i].award_txt
		temp.item_mask.gameObject:SetActive(false) 
		temp.can_get_award_btn.onClick:AddListener(
			function()
				Network.SendRequest("get_task_award",{id = M.config.books[i].task_id})
			end
		)
		self.book_lis[i] = temp
	end

	for i = 1, 3 do
		self["t"..i.."_img"].sprite = GetTexture(M.config.award.award_image[i])
		self["t"..i.."_txt"].text = M.config.award.award_name[i]
	end

	self.open_bag_btn.onClick:AddListener(function ()
		Act_050_YXTJBagPanel.Create()
	end)

	self.task_get_btn.onClick:AddListener(
		function()
			Network.SendRequest("get_task_award",{id = M.task_get_id})
		end
	)
	self.task_go_btn.onClick:AddListener(
		function()
			ActivityYearPanel.Create(nil, nil, nil,{ ID =  36}, true)
		end
	)

	self.t3_btn.onClick:AddListener(function ()
		local show_tit = "随机鲸币宝箱"
		local show_desc = "打开可随机获得10万~100万鲸币！"
		LTTipsPrefab.Show2(self.task_item_3.transform,show_tit,show_desc)
	end)

	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshMainUI()
	self:RefreshButtomTaskUI()
end

function C:ClearChild()
	destroyChildren(self.Content)
end

function C:on_model_task_change_msg()
	self:RefreshMainUI()
	self:RefreshButtomTaskUI()
end

function C:RefreshButtomTaskUI()
	local data = GameTaskModel.GetTaskDataByID(M.task_get_id)
	if data then
		self.task_pro_txt.text = "收集进度"..math.floor(data.now_process/data.need_process * 100).."%"
		self.pro.gameObject.transform.sizeDelta = {x = data.now_process/data.need_process * 291.8,y = 30}
		if data.award_status == 0 then
			self.task_get_btn.gameObject:SetActive(false)
			self.task_mask.gameObject:SetActive(false)
			self.task_go_btn.gameObject:SetActive(true)
		elseif data.award_status == 1 then
			self.task_get_btn.gameObject:SetActive(true)
			self.task_mask.gameObject:SetActive(false)
			self.task_go_btn.gameObject:SetActive(false)		
		else
			self.task_get_btn.gameObject:SetActive(false)
			self.task_mask.gameObject:SetActive(true)
			self.task_go_btn.gameObject:SetActive(false)		
		end
	end
end

function C:RefreshMainUI()
	for i = 1,#self.book_lis do
		local ui = self.book_lis[i]
		local task_id = M.config.books[i].task_id
		local task_data = GameTaskModel.GetTaskDataByID(task_id)
		if task_data then
			if task_data.award_status == 1 then
				ui.got.gameObject:SetActive(false)
				ui.item_mask.gameObject:SetActive(false)
				ui.can_get.gameObject:SetActive(true)
			elseif task_data.award_status == 2 then
				ui.got.gameObject:SetActive(true)
				ui.item_mask.gameObject:SetActive(false)
				ui.can_get.gameObject:SetActive(false)
			else
				ui.got.gameObject:SetActive(false)
				ui.item_mask.gameObject:SetActive(true)
				ui.can_get.gameObject:SetActive(false)
			end
		end
	end
end