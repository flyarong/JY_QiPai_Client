-- 创建时间:2020-04-07
-- Panel:Act_007_FKFLPanel
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

Act_007_FKFLPanel = basefunc.class()
local C = Act_007_FKFLPanel
C.name = "Act_007_FKFLPanel"
local M = Act_007_FKFLManager
local box_img = {
	"fkfl_btn_bx",
	"fkfl_btn_bx2",
	"fkfl_btn_bx3",
}
local box_img2 = {
	"fkfl_btn_bx3",
	"fkfl_btn_bx2",
	"fkfl_btn_bx",
}
local other_str = {
	sh_xxl = "（已选择水浒消消乐赢金）",
	sg_xxl = "（已选择萌宠消消乐赢金）",
	by = "（已选择捕鱼赢金）",
	cs_xxl = "（已选择财神消消乐赢金）",
	zjd = "（已选择砸金蛋赢金）",
	xy_xxl = "(已选择西游消消乐赢金)",
	bs_xxl = "(已选择宝石迷阵赢金)",
	fx_xxl = "(已选择福星高照赢金)",
}

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

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:OnSelectChange(1)
	dump(M.CheakIsNotSetTask(),"<color=red>是不是没有设置任务</color>")
	if M.CheakIsNotSetTask() then
		Act_007_FKFLChoosePanel.Create()
	end
end

function C:InitUI()
	self.help_btn.onClick:AddListener(
		function ()
			self:OpenHelpPanel()
		end
	)
	self.close_btn.onClick:AddListener(
		function ( )
			self:MyExit()
		end
	)
	self.buy_btn.onClick:AddListener(
		function ()	
			local data = M.GetShopConfig()
			if data and data[self.curr_index] then 
				dump(data[self.curr_index].shop_id)
				M.BuyShop(data[self.curr_index].shop_id)
			end 
		end
	)
	self.goto_btn.onClick:AddListener(
		function ()
			local gotoparm = {gotoui = "game_MiniGame"}
            GameManager.GotoUI(gotoparm)
		end
	)
	for i = 1,3 do 
		self["mask"..i.."_btn"].onClick:AddListener(
			function ()
				self:OnSelectChange(i)
			end
		)
		--self["mask"..i.."_txt"].color = Color.New(1,1,1)
	end
	self:InitLeftButtons()
	self:MyRefresh()
end

function C:MyRefresh()
end


function C:OpenHelpPanel()
	local info = {
		"1.活动时间：1月11日7:30~1月24日23:59:59",
		"2.每个礼包只能选择一个小游戏累计赢金，同一个小游戏不能被重复选择；",
		"3.礼包和对应的累计赢金每天0点重置，请及时领取您的奖励，过期视为自动放弃；",
	}
	local str = info[1]
	for i = 2, #info do
		str = str .. "\n" .. info[i]
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:InitLeftButtons()
	local data = M.GetShopConfig()
	dump(data,"<color=red>礼包数据</color>")
	for i = 1,#data do 
		self["button"..i.."_txt"].text = data[i].jg
		self["mask"..i.."_txt"].text = data[i].jg
	end
end

function C:OnSelectChange(index)
	for i = 1,3 do 
		self["mask"..i.."_btn"].gameObject:SetActive(true)
		self["b"..i].gameObject:SetActive(false)
	end
	self["mask"..index.."_btn"].gameObject:SetActive(false)
	self["b"..index].gameObject:SetActive(true)
	self.curr_index = index
	self:RefreshLeft()
	self:RefreshRight()
	self:ReFreshTaskItems()
end

function C:RefreshLeft()
	local data = M.GetShopConfig()
	self.tips1_txt.text= data[self.curr_index].gmld
	self.tips2_txt.text= data[self.curr_index].hbq
	if MainModel.UserInfo.vip_level >= 4 then
		self.gift_img.sprite = GetTexture(box_img2[self.curr_index])
	else
		self.gift_img.sprite = GetTexture(box_img[self.curr_index])
	end
	if self:CheakCurrBuyorNot() then
		self.buy.gameObject:SetActive(false)
		self.after_buy.gameObject:SetActive(true)
		local data = self:GetCurrTaskData()
		if data.net_data then
			self.curr_txt.text = StringHelper.ToCash(data.net_data.now_total_process)
		end
	else
		self.buy.gameObject:SetActive(true)
		self.after_buy.gameObject:SetActive(false)
	end
	dump(self:GetCurrTaskData(),"<color=red>总数据0000000</color>")
end

function C:CheakCurrBuyorNot()
	local buy_data = GameTaskModel.GetTaskDataByID(M.only_buy_task[self.curr_index])
	if buy_data.now_total_process >= 1  then 
		return true
	end
	return false
end

function C:GetCurrTaskData()
	local task_id = M.config["base_"..M.now_level][self.curr_index].task_id
	dump(task_id,"<color=red>当前任务ID</color>")
	local base = M.GetTaskConfig()[self.curr_index]
	dump(base,"<color=red>当前任务配置数据</color>")
	local net_data = GameTaskModel.GetTaskDataByID(task_id)
	dump(net_data,"<color=red>当前任务数据</color>")
	return {base = base,net_data = net_data,task_id = task_id}
end

function C:RefreshRight()
	if not table_is_null(self.task_items) then
		for i = 1,#self.task_items do
			destroy(self.task_items[i].gameObject)
		end
	end
	self.task_items = {}
	local data = self:GetCurrTaskData()
	local temp = {}
	if data and  data.net_data and data.net_data.other_data_str then 
		self.now_task_txt.gameObject:SetActive(true)
		self.now_task_txt.text = other_str[data.net_data.other_data_str]
	else
		self.now_task_txt.gameObject:SetActive(false)
	end
	for i = 1,#data.base do 
		local b = GameObject.Instantiate(self.task_item,self.content)
		b.gameObject:SetActive(true)
		self.task_items[i] = b
		LuaHelper.GeneratingVar(b.transform,temp)
		temp.award_txt.text = data.base[i].award_txt
		temp.task_txt.text = data.base[i].task_txt
	end
end

function C:ReFreshTaskItems()
	local data = self:GetCurrTaskData()
	local temp_ui = {}
	if data and data.net_data then 
		local b = basefunc.decode_task_award_status(data.net_data.award_get_status)
		b = basefunc.decode_all_task_award_status(b, data.net_data, #data.base)
		for i = 1,#b do
			LuaHelper.GeneratingVar(self.task_items[i].transform,temp_ui)
			if b[i] == 0 then 
				temp_ui.fkfl_get.gameObject:SetActive(false)
				temp_ui.can_get.gameObject:SetActive(false)
			elseif b[i] == 1 then 
				temp_ui.get_award_btn.onClick:RemoveAllListeners()
				temp_ui.get_award_btn.onClick:AddListener(
					function ()
						Network.SendRequest("get_task_award_new", {id = data.net_data.id, award_progress_lv = i})
					end
				)
				temp_ui.fkfl_get.gameObject:SetActive(true)
				temp_ui.can_get.gameObject:SetActive(true)
			elseif b[i] == 2 then
				self.task_items[i].transform:SetAsLastSibling()
				temp_ui.award_img.sprite = GetTexture("fkfl_btn_hb")
				temp_ui.award_txt.color = Color.gray
				temp_ui.award_txt.gameObject.transform:GetComponent("Outline").enabled = false
			end
		end
	end
end

function C:on_model_task_change_msg(data)
	dump(data,"<color=red>任务改变</color>")
	self:OnSelectChange(self.curr_index)
	if M.CheakIsNotSetTask() and M.CheckIsBuyDataChange(data.id) then
		Act_007_FKFLChoosePanel.Create()
	end
	if M.config["base_"..M.now_level][self.curr_index].task_id == data.id then 
		self:ReFreshTaskItems()
	end
end