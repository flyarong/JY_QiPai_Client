-- 创建时间:2020-04-14
-- Panel:VipShowZZLBPanel
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

VipShowZZLBPanel = basefunc.class()
local C = VipShowZZLBPanel
C.name = "VipShowZZLBPanel"
local M = VIPManager

local qudao_base_data = {
	[1] = {
		t1_txt = "VIP11",
		help_info = "1.成为VIP11立即获得30次至尊礼包领取资格，每日可领1次,\n2.每领满30次至尊礼包可额外领取100万鱼币,\n3.每获得4点财富值增加1次至尊礼包领取资格，上限100次,",
		award_data = {
			[1] = {
				award_img = "vip_zzlb_icon",
				award_txt = "至尊礼包",
				task_id = 21248,
				tips = "4万~6万鲸币"
			},
			[2] = {
				award_img = "com_award_icon_yb1",
				award_txt = "100万鱼币",
				task_id = 21249,
			},
		}
	},
	[2] = {
		t1_txt = "VIP12",
		help_info = "1.成为VIP12立即获得30次至尊礼包领取资格，每日可领1次,\n2.每领满30次至尊礼包可额外领取200元话费,\n3.每获得5点财富值增加1次至尊礼包领取资格，上限100次,",
		award_data = {
			[1] = {
				award_img = "vip_ztlb_icon",
				award_txt = "至尊礼包",
				task_id = 21250,
			},
			[2] = {
				award_img = "com_award_icon_hfsp",
				award_txt = "200元话费",
				task_id = 21251,
				tips = "5万~15万鲸币"
			},
		}
	},
}

local base_data = {
	[1] = {
		t1_txt = "VIP11",
		help_info = "1.成为VIP11立即获得30次至尊礼包领取资格，每日可领1次,\n2.每领满30次至尊礼包可额外领取100万鱼币,\n3.每获得2点财富值增加1次至尊礼包领取资格，上限100次,",
		award_data = {
			[1] = {
				award_img = "vip_zzlb_icon",
				award_txt = "至尊礼包",
				task_id = 21248,
				tips = "4万~6万鲸币"
			},
			[2] = {
				award_img = "com_award_icon_yb1",
				award_txt = "100万鱼币",
				task_id = 21249,
			},
		}
	},
	[2] = {
		t1_txt = "VIP12",
		help_info = "1.成为VIP12立即获得30次至尊礼包领取资格，每日可领1次,\n2.每领满30次至尊礼包可额外领取200元话费,\n3.每获得3点财富值增加1次至尊礼包领取资格，上限100次,",
		award_data = {
			[1] = {
				award_img = "vip_ztlb_icon",
				award_txt = "至尊礼包",
				task_id = 21250,
				tips = "5万~15万鲸币"
			},
			[2] = {
				award_img = "com_award_icon_hfsp",
				award_txt = "200元话费",
				task_id = 21251,
			},
		}
	},
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
	self.lister["model_query_task_data_response"] = basefunc.handler(self,self.MyRefresh)
	self.lister["model_vip_task_change_msg"] = basefunc.handler(self,self.MyRefresh)
	self.lister["model_vip_upgrade_change_msg"] = basefunc.handler(self,self.MyRefresh)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	GameTipsPrefab.Hide()
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
	self:InitBaseData()
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.ui_data = {}
	for i = 1,#base_data do
		local temp_ui = {}
		local b = GameObject.Instantiate(self.VIP_item, self.Content)
		b.gameObject:SetActive(true)
		local data = {vip_item = b}
		LuaHelper.GeneratingVar(b.transform, temp_ui)
		temp_ui.t1_txt.text = base_data[i].t1_txt
		self.ui_data[i] = data
		data.award_items = {}
		temp_ui.help_btn.onClick:AddListener(
			function()
				LTTipsPrefab.Show(temp_ui.help_btn.gameObject.transform,1,base_data[i].help_info)
			end
		)
		for j = 1,#base_data[i].award_data do
			local _b = GameObject.Instantiate(self.AwardChild, temp_ui.node)
			local temp_ui2 = {}
			LuaHelper.GeneratingVar(_b.transform, temp_ui2)
			temp_ui2.award_img.sprite = GetTexture(base_data[i].award_data[j].award_img)
			temp_ui2.award_txt.text = base_data[i].award_data[j].award_txt
			_b.gameObject:SetActive(true)
			if base_data[i].award_data[j].tips and VIPManager.get_vip_level() >= 10 then
				PointerEventListener.Get(temp_ui2.award_img.gameObject).onDown = function ()
					GameTipsPrefab.ShowDesc(base_data[i].award_data[j].tips, UnityEngine.Input.mousePosition)
				end
				PointerEventListener.Get(temp_ui2.award_img.gameObject).onUp = function ()
					GameTipsPrefab.Hide()
				end
			end
			temp_ui2.get_btn.onClick:AddListener(
				function()
					if VIPManager.get_vip_level() >= 10+i then
						Network.SendRequest("get_task_award", {id = base_data[i].award_data[j].task_id})
					else
						HintPanel.Create(1,"成为VIP"..10+i.."即可领取奖励")
					end
				end
			)
			data.award_items[j] = _b
			Network.SendRequest("query_one_task_data",{task_id = base_data[i].award_data[j].task_id})
		end
	end
	dump(self.ui_data,"<color=red>UI数据</color>")
	self:MyRefresh()
end

function C:MyRefresh()
	if not IsEquals(self.gameObject) then return end
	self.nowvip_txt.text = M.get_vip_level()
	if VIPManager.get_vip_level() >= 11 then
		if M.get_vip_level() == 12 then
			self.ui_data[1].vip_item.gameObject:SetActive(false)
			self:ReFreshItemUI(2)
		else
			self:ReFreshItemUI(1)
			self:ReFreshItemUI(2)
		end
	end
end

function C:ReFreshItemUI(index)
	local remain = VIPManager.get_vip_data().vip_gift_remain
	local cfz = VIPManager.get_vip_data().treasure_value 
	for i = 1,#self.ui_data[index].award_items do
		local temp_ui = {}
		local data = GameTaskModel.GetTaskDataByID(base_data[index].award_data[i].task_id)	
		dump({id = base_data[index].award_data[i].task_id,data = data},"<color=red>数据</color>")
		LuaHelper.GeneratingVar(self.ui_data[index].award_items[i].transform, temp_ui)
		temp_ui.count_txt.text = " "
		local Image = temp_ui.get_btn.gameObject.transform:GetComponent("Image")
		local Outline = temp_ui.get_btn.gameObject.transform:Find("Text"):GetComponent("Outline")
		Image.color = Color.New(1, 1, 1, 1)
		Outline.enabled = true
		temp_ui.get_btn.enabled = true
		if data then
			if data.award_status == 2  then
				temp_ui.get_btn.gameObject:SetActive(false)
				temp_ui.MASK.gameObject:SetActive(true)
			elseif data.award_status == 1 then
				temp_ui.get_btn.gameObject:SetActive(true)
				temp_ui.MASK.gameObject:SetActive(false)
				--对于至尊礼包,当次数为0的时候也置灰
				if i == 1 and remain == 0 then
					Image.color = Color.New(114/255, 114/255, 114/255, 1)
					Outline.enabled = false
					temp_ui.get_btn.enabled = false
				end
			else
				Image.color = Color.New(114/255, 114/255, 114/255, 1)
				Outline.enabled = false
				temp_ui.get_btn.enabled = false
				if i == 2 then 
					temp_ui.count_txt.text = "再领"..30 - data.now_total_process .."次至尊礼包可领"
				end
			end
		else
			
		end
		if i == 1 then
			--对于至尊礼包们来说，只在符合自己条件的礼包下面显示次数
			if M.get_vip_level() - 10 == index then   
				temp_ui.count_txt.text = "剩余次数:"..remain.."/100"
				if remain == 0 then
					Image.color = Color.New(114/255, 114/255, 114/255, 1)
					Outline.enabled = false
					temp_ui.get_btn.enabled = false
				end
			end
		end
	end

end

function C:InitBaseData()
	if VIPManager.IsQuDaoChannel() then
		base_data = qudao_base_data
	end
end