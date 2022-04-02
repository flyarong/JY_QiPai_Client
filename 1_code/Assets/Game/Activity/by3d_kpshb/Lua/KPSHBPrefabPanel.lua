-- 创建时间:2020-06-28
-- Panel:KPSHBPrefabPanel
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

KPSHBPrefabPanel = basefunc.class()
local C = KPSHBPrefabPanel
C.name = "KPSHBPrefabPanel"

local offset_progress = {
	[1] = {min = 0.0001 ,max = 0.041},
	[2] = {min = 0.149 ,max = 0.205},
	[3] = {min = 0.317 ,max=0.365},
	[4] = {min = 0.479 ,max=0.531},
	[5] = {min = 0.639 ,max=0.695},
	[6] = {min = 0.807 ,max=1},
}

function C.Create(g_num,ui_data)
	return C.New(g_num,ui_data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["kpshb_model_task_change_msg"] = basefunc.handler(self,self.on_kpshb_model_task_change_msg)
    self.lister["kpshb_hb_hc_award_msg"] = basefunc.handler(self,self.on_kpshb_hb_hc_award_msg)
    self.lister["kpshb_hb_award_msg"] = basefunc.handler(self,self.on_kpshb_hb_award_msg)
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
	self:CloseCellUI()
	self:MyExit()
end

function C:ctor(g_num,ui_data)

	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	if g_num and g_num ~= 1 then
   		 self.need_txt.text = g_num
 	else
 		self.need_txt.text = "0"
	end
	if ui_data then
		self.huode_txt.text = StringHelper.ToCash(ui_data)
	end

	self.BackButton = tran:Find("BackButton"):GetComponent("Button")
	self.SMButton = tran:Find("shuoming_btn"):GetComponent("Button")
	self.Slider = tran:Find("bg/Slider"):GetComponent("Slider")
    self.BackButton.onClick:AddListener(function ()
        self:OnDestroy()
    end)
    self.SMButton.onClick:AddListener(function ()
        self:SMPanelCreate()
    end)
 	self.currTaskID = BY3DKPSHBManager.GetCurrTaskID()
 	self:RefreshProgressUI()
 	self:RefreshUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnBackClick()
    self:MyExit()
end

function C:SMPanelCreate()
     KPSHBSMPrefabPanel.Create()
end

-- 0-不能领取 | 1-可领取 | 2-已完成 | 3- 未启用
function  C:RefreshUI()  

	self:CloseCellUI()
	local cfg = BY3DKPSHBManager.GetConfigByGameID().hb
 	for i = 1,#cfg do
 		local pre = KPSHBHBPrefab.Create(self.hb, i, cfg[i])
 		self.hb_CellList[#self.hb_CellList + 1] = pre
 	end


	--elf.CellList[2]:UpdateData(dd)
	
end

function C:RefreshProgressUI()
	self.task_data = GameTaskModel.GetTaskDataByID(self.currTaskID)
	if self.task_data then
		local off = offset_progress[self.task_data.now_lv]
		local pro_value = (self.task_data.now_process/self.task_data.need_process) * (off.max - off.min) + off.min
		self.Slider.value = pro_value
	end
end

function C:on_kpshb_model_task_change_msg()
	self:RefreshProgressUI()
end

function C:on_kpshb_hb_hc_award_msg(data)
    if data ~=1 and data then
     	self.need_txt.text = data
	else 
	 	self.need_txt.text = 0
    end 
end

function C:on_kpshb_hb_award_msg(data)
	if data then
		self.huode_txt.text=StringHelper.ToCash(data)
	end
end

function C:CloseCellUI()
	if self.hb_CellList then
		for k,v in ipairs(self.hb_CellList) do
			v:OnDestroy()
		end
	end
	self.hb_CellList = {}
end