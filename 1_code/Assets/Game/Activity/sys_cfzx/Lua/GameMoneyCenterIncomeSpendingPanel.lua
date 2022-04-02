-- 创建时间:2018-11-19

local basefunc = require "Game.Common.basefunc"

GameMoneyCenterIncomeSpendingPanel = basefunc.class()

GameMoneyCenterIncomeSpendingPanel.name = "GameMoneyCenterIncomeSpendingPanel"

MONEY_TYPE = {
	income = "income",
	spending = "spending",
}

local RECORD_CODE = {
	[0] = "审核中",
	[1] = "已通过",
	[2] = "未通过",
	[3] = "提现成功",
	[4] = "提现失败",
}

local instance
function GameMoneyCenterIncomeSpendingPanel.Create(parent)
	instance = GameMoneyCenterIncomeSpendingPanel.New(parent)
	return instance
end
function GameMoneyCenterIncomeSpendingPanel.Close()
	if instance then
		instance:MyClose()
	end
end

function GameMoneyCenterIncomeSpendingPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function GameMoneyCenterIncomeSpendingPanel:MakeLister()
	self.lister = {}
	self.lister["model_query_my_sczd_income_details_response"] = basefunc.handler(self, self.model_query_my_sczd_income_details_response)
	self.lister["model_update_income_info"] = basefunc.handler(self, self.model_update_income_info)
	self.lister["model_query_my_sczd_spending_details_response"] = basefunc.handler(self, self.model_query_my_sczd_spending_details_response)
	self.lister["model_update_spending_info"] = basefunc.handler(self, self.model_update_spending_info)
	self.lister["model_tglb_profit_activate"] = basefunc.handler(self, self.model_tglb_profit_activate)
end

function GameMoneyCenterIncomeSpendingPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function GameMoneyCenterIncomeSpendingPanel:MyClose()
	self:MyExit()
end

function GameMoneyCenterIncomeSpendingPanel:MyExit()
	GameMoneyCenterModel.income_page_index = 1
	GameMoneyCenterModel.spending_page_index = 1
	self.tge_config = nil
	self.sv_item_table = nil
	self.tge_item_table = nil
	self.income_item_table = nil
	self.spending_item_table = nil
	self:RemoveListener()

	destroy(self.gameObject)
	instance = nil
end

function GameMoneyCenterIncomeSpendingPanel:ctor(parent)

	ExtPanel.ExtMsg(self)

	self.tge_config = GameMoneyCenterModel.GetIncomeSpendingTge()
	self.parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(GameMoneyCenterIncomeSpendingPanel.name, self.parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform,self)

	self:MakeLister()
	self:AddMsgListener()

	self:InitUI()
end

function GameMoneyCenterIncomeSpendingPanel:InitUI()
	self.close_btn.onClick:AddListener(
		function (  )
			self:MyClose()
		end
	)
	for i,v in ipairs(self.tge_config) do
		self:InitSV(v.type)
	end

	for i,v in ipairs(self.tge_config) do
		self:InitTge(v.type)
	end
	self.tge_item_table[MONEY_TYPE.income].item_tge.isOn = true
end

function GameMoneyCenterIncomeSpendingPanel:InitSV(money_type)
    local go = GameObject.Instantiate(self.SVItem, self.Center)
    go.gameObject:SetActive(false)
    local ui_table = {}
    ui_table.transform = go.transform
    ui_table.gameObject = go.gameObject
    LuaHelper.GeneratingVar(go.transform, ui_table)
    self.sv_item_table = self.sv_item_table or {}
	self.sv_item_table[money_type] = ui_table
	
	ui_table.sv_sr = go.transform:GetComponent("ScrollRect")
    --滑动
	EventTriggerListener.Get(ui_table.sv_sr.gameObject).onEndDrag = function()
		local VNP = ui_table.sv_sr.verticalNormalizedPosition
		if VNP <= 0 then
			if money_type == MONEY_TYPE.income then
				GameMoneyCenterModel.query_my_sczd_income_details(GameMoneyCenterModel.income_page_index)
			elseif money_type == MONEY_TYPE.spending then
				GameMoneyCenterModel.query_my_sczd_spending_details(GameMoneyCenterModel.spending_page_index)
			end
		end
	end
end

function GameMoneyCenterIncomeSpendingPanel:InitTge(type)
    local config = {}
    for i,v in ipairs(self.tge_config) do
        if type == v.type then
            config = v
            break
        end
    end
    local TG = self.toggle_content.transform:GetComponent("ToggleGroup")
    local go = GameObject.Instantiate(self.tgeItem, self.toggle_content)
    go.gameObject:SetActive(config.is_show == 1)
    go.name = config.id
    local ui_table = {}
    ui_table.transform = go.transform
    LuaHelper.GeneratingVar(go.transform, ui_table)
    ui_table.item_tge = go.transform:GetComponent("Toggle")
    ui_table.item_tge.group = TG
    ui_table.item_tge.onValueChanged:AddListener(
		function(val)
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            ui_table.tge_img.gameObject:SetActive(not val)
            ui_table.mark_tge_img.gameObject:SetActive(val)
            if val then
                self:SwitchGroup(type)
            end
        end
    )
    ui_table.tge_img.sprite = GetTexture(config.tge_img)
    ui_table.mark_tge_img.sprite = GetTexture(config.mask_tge_img)

    self.tge_item_table = self.tge_item_table or {}
    self.tge_item_table[type] = ui_table
end

function GameMoneyCenterIncomeSpendingPanel:SwitchGroup(money_type)
	self.money_type = money_type
	self.sv_item_table = self.sv_item_table or {}
    self.sv_item_table[MONEY_TYPE.income].gameObject:SetActive(MONEY_TYPE.income == money_type)
    self.sv_item_table[MONEY_TYPE.spending].gameObject:SetActive(MONEY_TYPE.spending == money_type)

    self.sv_item_table[money_type].sv_content.localPosition = Vector3.zero
    if self.sv_item_table[money_type].sv_content.childCount == 0 then
        self:CreateHistoryItemsToContent(money_type,  self.sv_item_table[money_type].sv_content)
    end
end

function GameMoneyCenterIncomeSpendingPanel:CreateHistoryItemsToContent(money_type, sv_content)
	if money_type == MONEY_TYPE.income then
		GameMoneyCenterModel.income_page_index = 1
		GameMoneyCenterModel.query_my_sczd_income_details(GameMoneyCenterModel.income_page_index)
	elseif money_type == MONEY_TYPE.spending then
		GameMoneyCenterModel.spending_page_index = 1
		GameMoneyCenterModel.query_my_sczd_spending_details(GameMoneyCenterModel.spending_page_index)
	end
end

function GameMoneyCenterIncomeSpendingPanel:model_query_my_sczd_income_details_response(page_index)
	self:UpdateIncomeUI(page_index)
end

function GameMoneyCenterIncomeSpendingPanel:model_update_income_info(  )
	destroyChildren(self.sv_item_table[MONEY_TYPE.income].sv_content)
	self.sv_item_table[MONEY_TYPE.income].sv_content.localPosition = Vector3.zero
	LittleTips.Create("数据已经更新，请继续游戏")
end

function GameMoneyCenterIncomeSpendingPanel:model_query_my_sczd_spending_details_response(page_index)
	self:UpdateSpendingUI(page_index)
end

function GameMoneyCenterIncomeSpendingPanel:model_update_spending_info(  )
	destroyChildren(self.sv_item_table[MONEY_TYPE.spending].sv_content)
	self.sv_item_table[MONEY_TYPE.spending].sv_content.localPosition = Vector3.zero
	LittleTips.Create("数据已经更新，请继续游戏")
end

-- 推广礼包激活状态变化
function GameMoneyCenterIncomeSpendingPanel:model_tglb_profit_activate()
    self.sv_item_table[self.money_type].sv_content.localPosition = Vector3.zero
    if self.sv_item_table[self.money_type].sv_content.childCount == 0 then
        self:CreateHistoryItemsToContent(self.money_type, self.sv_item_table[self.money_type].sv_content)
    end
end

function GameMoneyCenterIncomeSpendingPanel:UpdateIncomeUI(page_index)
	local data = GameMoneyCenterModel.GetIncomeInfo(page_index)
	dump(data, "<color=green>detail_contribute_data </color>" .. page_index)
	if data then
		if data.detail_infos and next(data.detail_infos) then
			self.sv_item_table[MONEY_TYPE.income].not_data.gameObject:SetActive(false)
			if self.income_item_table and self.income_item_table[page_index] and next(self.income_item_table[page_index]) then
				for i,v in ipairs(self.income_item_table[page_index]) do
					if IsEquals(v) then
						destroy(v)
					end
				end
				self.income_item_table[page_index] = nil
			end

			for i,v in ipairs(data.detail_infos) do
				self.income_item_table = self.income_item_table or {}
				self.income_item_table[page_index] = self.income_item_table[page_index] or {}
				local item = GameObject.Instantiate(self.HistroyItem.gameObject,self.sv_item_table[MONEY_TYPE.income].sv_content.transform)
				self.income_item_table[page_index][#self.income_item_table[page_index] + 1] = item
				local item_table = {}
				item_table.transform = item.transform
				LuaHelper.GeneratingVar(item.transform,item_table)
				item_table.time_txt.text = os.date("%Y-%m-%d %H:%M", v.time)
				item_table.money_txt.text = string.format("+%s元奖金",StringHelper.ToRedNum(v.treasure_value/100))
				
				local treasure_type = ""
				if v.treasure_type == 1 then
					treasure_type = string.format("新用户 %s 完成了新人福卡一天所有任务", v.name)
				elseif v.treasure_type <= 100 then
					treasure_type = string.format( "%s 完成新人福卡第%s天",v.name, v.treasure_type)
				elseif v.treasure_type == 101 then
					treasure_type = string.format("%s 购买了金猪礼包I", v.name)
				elseif v.treasure_type == 102 then
					treasure_type = string.format("%s 购买了金猪礼包II", v.name)
				elseif v.treasure_type == 103 then
					treasure_type = string.format("%s 购买全返礼包", v.name)
				elseif v.treasure_type == 105 then
					treasure_type = string.format("历史账单转入")
				elseif v.treasure_type == 110 then
					treasure_type = string.format("完成了金猪任务")
				elseif v.treasure_type == 150 then
					treasure_type = string.format( "%s 完成了比赛任务", v.name)
				elseif v.treasure_type == 201 then
					treasure_type = string.format( "%s 完成了全返礼包I", v.name)
				elseif v.treasure_type == 202 then
					treasure_type = string.format( "%s 完成了全返礼包II", v.name)
				elseif v.treasure_type == 203 then
					treasure_type = string.format( "%s 完成了全返礼包III", v.name)
				elseif v.treasure_type == 211 then
					treasure_type = string.format( "全返礼包I 自己的任务加成")
				elseif v.treasure_type == 212 then
					treasure_type = string.format( "全返礼包II 自己的任务加成")
				elseif v.treasure_type == 213 then
					treasure_type = string.format( "全返礼包III 自己的任务加成")
				elseif v.treasure_type == 200 then
					treasure_type = string.format( "%s 完成了兑换2元福卡任务", v.name)
				elseif v.treasure_type == 151 then
					treasure_type = string.format( "%s 完成了千元赛进入前96名任务", v.name)
				elseif v.treasure_type == 204 then
					treasure_type = string.format( "%s 完成了限时红包兑换奖励金任务", v.name)	
				end

				item_table.info_txt.text = string.format( "%s",treasure_type)
				item_table.goto_activate_btn.onClick:AddListener(
					function (  )
						ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
						if v.treasure_type <= 100 then
							Event.Brocast("open_activity_seven_day", true)
						else
							Event.Brocast("open_golden_pig")
						end
					end
				)
				if (v.treasure_type <= 100 and GameMoneyCenterModel.data.is_activce_profit == 1) or (v.treasure_type == 101 and GameMoneyCenterModel.data.is_active_tglb1_profit == 1) or v.treasure_type == 110 or v.treasure_type == 105 or v.treasure_type == 102 then
					item_table.vip_activate_txt.gameObject:SetActive(false)
					local local_pos = item_table.info_txt.transform.localPosition
					item_table.info_txt.transform.localPosition = Vector3.New(268,local_pos.y,local_pos.z)				
				else		
					item_table.vip_activate_txt.gameObject:SetActive(false)
					--local local_pos = item_table.info_txt.transform.localPosition
					--item_table.info_txt.transform.localPosition = Vector3.New(548,local_pos.y,local_pos.z)
				end
				item.transform:SetAsLastSibling()
				item.gameObject:SetActive(true)
			end
		else
			if page_index == 1 then
				self.sv_item_table[MONEY_TYPE.income].not_data.gameObject:SetActive(true)
			end
		end
	end
end

function GameMoneyCenterIncomeSpendingPanel:UpdateSpendingUI(page_index)
	local data = GameMoneyCenterModel.GetSpendingInfo(page_index)
	dump(data, "<color=green>detail_contribute_data </color>" .. page_index)
	if data then
		if data.extract_infos and next(data.extract_infos) then
			self.sv_item_table[MONEY_TYPE.spending].not_data.gameObject:SetActive(false)
			if self.spending_item_table and self.spending_item_table[page_index] and next(self.spending_item_table[page_index]) then
				for i,v in ipairs(self.spending_item_table[page_index]) do
					if IsEquals(v) then
						destroy(v)
					end
				end
				self.spending_item_table[page_index] = nil
			end

			for i,v in ipairs(data.extract_infos) do
				self.spending_item_table = self.spending_item_table or {}
				self.spending_item_table[page_index] = self.spending_item_table[page_index] or {}
				local item = GameObject.Instantiate(self.HistroyItem.gameObject,self.sv_item_table[MONEY_TYPE.spending].sv_content.transform)
				self.spending_item_table[page_index][#self.spending_item_table[page_index] + 1] = item
				local item_table = {}
				item_table.transform = item.transform
				LuaHelper.GeneratingVar(item.transform,item_table)
				item_table.time_txt.text = os.date("%Y-%m-%d %H:%M", v.extract_time)
				local status_str = "<color=black>（" .. RECORD_CODE[v.extract_status] .. "）</color>"
				item_table.money_txt.text = string.format("%s元奖金  提取奖金",StringHelper.ToRedNum(v.extract_value / 100)) .. status_str
				item_table.info_txt.text = ""
				item.transform:SetAsLastSibling()
				item.gameObject:SetActive(true)
			end
		else
			if page_index == 1 then
				self.sv_item_table[MONEY_TYPE.spending].not_data.gameObject:SetActive(true)
			end
		end
	end
end