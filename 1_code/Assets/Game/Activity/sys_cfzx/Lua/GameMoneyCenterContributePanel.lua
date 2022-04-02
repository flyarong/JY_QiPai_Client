-- 创建时间:2018-11-19

local basefunc = require "Game.Common.basefunc"

GameMoneyCenterContributePanel = basefunc.class()

GameMoneyCenterContributePanel.name = "GameMoneyCenterContributePanel"


local instance
function GameMoneyCenterContributePanel.Create(son_id, parent)
	instance = GameMoneyCenterContributePanel.New(son_id, parent)
	return instance
end

function GameMoneyCenterContributePanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function GameMoneyCenterContributePanel:MakeLister()
	self.lister = {}
	self.lister["model_query_son_base_contribute_info_response"] = basefunc.handler(self, self.on_model_query_son_base_contribute_info_response)
	self.lister["model_query_son_details_contribute_info_response"] = basefunc.handler(self, self.on_model_query_son_details_contribute_info_response)
	self.lister["model_update_contribute_info"] = basefunc.handler(self, self.on_model_update_contribute_info)
	self.lister["model_tglb_profit_activate"] = basefunc.handler(self, self.model_tglb_profit_activate)
end

function GameMoneyCenterContributePanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function GameMoneyCenterContributePanel:MyClose()
	self:MyExit()
end

function GameMoneyCenterContributePanel:MyExit()
	destroy(self.gameObject)
	GameMoneyCenterModel.contribute_page_index = 1
	self.history_item_table = nil
	self:RemoveListener()
end

function GameMoneyCenterContributePanel:ctor(son_id, parent)

	ExtPanel.ExtMsg(self)

	self.son_id = son_id
	self.parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(GameMoneyCenterContributePanel.name, self.parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform,self)

	GameMoneyCenterModel.contribute_page_index = 1
	self:MakeLister()
	self:AddMsgListener()

	self:InitUI()
end

function GameMoneyCenterContributePanel:MyRefresh()
end

function GameMoneyCenterContributePanel:InitUI()
	self.back_btn.onClick:AddListener(
		function (  )
			self:MyClose()
		end
	)
	self.goto_activate_btn.onClick:AddListener(
		function (  )
			self:GotoActivate()
		end
	)
	self.check_detail_btn.onClick:AddListener(
		function ()
			self:CheckDetailUI()
		end
	)

	self.back_detail_btn.onClick:AddListener(
		function (  )
			self:BackDetailUI()
		end
	)

    self.sv_sr = self.sv:GetComponent("ScrollRect")
    --滑动
    EventTriggerListener.Get(self.sv_sr.gameObject).onEndDrag = basefunc.handler(self, self.OnEndDrag)
    -- EventTriggerListener.Get(self.sea_sr.gameObject).onDrag = basefunc.handler(self, self.OnDrag)
	-- EventTriggerListener.Get(self.sea_sr.gameObject).onBeginDrag = basefunc.handler(self, self.OnBeginDrag)
	
	GameMoneyCenterModel.query_son_base_contribute_info(self.son_id)
end

function GameMoneyCenterContributePanel:GotoActivate()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	Event.Brocast("open_golden_pig")
	self:MyClose()
end

function GameMoneyCenterContributePanel:CheckDetailUI()
	self:ShowDetailUI(true)
	print("<color=yellow>GameMoneyCenterModel.contribute_page_index:</color>",GameMoneyCenterModel.contribute_page_index)
	if GameMoneyCenterModel.contribute_page_index == 1 then
		GameMoneyCenterModel.query_son_details_contribute_info(self.son_id,GameMoneyCenterModel.contribute_page_index)
	end
end

function GameMoneyCenterContributePanel:BackDetailUI()
	self:ShowDetailUI(false)
	-- destroyChildren(self.award_histroy_content)
end

function GameMoneyCenterContributePanel:ShowDetailUI(is_detail)
	self.award_histroy.gameObject:SetActive(is_detail)
	self.base_info_img.gameObject:SetActive(not is_detail)
	self.detail_info_img.gameObject:SetActive(is_detail)
	self.check_detail_btn.gameObject:SetActive(not is_detail)
	if is_detail == true then
		self.base_info.localPosition = Vector3.New(0,240,0)
	else
		self.base_info.localPosition = Vector3.New(0,82,0)
	end
end

function GameMoneyCenterContributePanel:IsItemExist(id)
	local isExist = false
	if self.history_item_table and #self.history_item_table > 0 then
		for _, it in ipairs(self.history_item_table) do
			if it.name == id then
				isExist = true
				break
			end
		end
	end
	return isExist
end

function GameMoneyCenterContributePanel:UpdateDetailUI(page_index)
	local data = GameMoneyCenterModel.GetDetailContributeInfo(self.son_id, page_index)
	dump(data, "<color=green>detail_contribute_data </color>" .. page_index)
	if data then
		for i,v in ipairs(data.detail_infos) do
			local itemName = v.id .. "_" .. v.time .. "_" .. v.treasure_type
			self.history_item_table = self.history_item_table or {}
			if not self:IsItemExist(itemName) then
				local item = GameObject.Instantiate(self.HistroyItem.gameObject,self.award_histroy_content.transform)
				item.name = itemName
				self.history_item_table[#self.history_item_table + 1] = item
				local item_table = {}
				item_table.transform = item.transform
				LuaHelper.GeneratingVar(item.transform,item_table)
				item_table.time_txt.text = os.date("%Y-%m-%d %H:%M", v.time)
				item_table.money_txt.text = string.format("+%s元奖金",StringHelper.ToRedNum(v.treasure_value/100))
				local is_active = ""
				--[[if (v.treasure_type <= 100 and GameMoneyCenterModel.data.is_activce_profit == 1) or (v.treasure_type == 101 and GameMoneyCenterModel.data.is_active_tglb1_profit == 1) or v.treasure_type == 102 then
					is_active = ""
				else
					is_active = "（未激活）"
				end]]
				local treasure_type = ""
				if v.treasure_type == 1 then
					treasure_type = string.format("完成了新人福卡一天所有任务")
				elseif v.treasure_type <= 100 then
					treasure_type = string.format("完成新人福卡第%s天", v.treasure_type)
				elseif v.treasure_type == 102 then
					treasure_type = string.format("购买了金猪礼包II")
				elseif v.treasure_type == 103 then
					treasure_type = string.format("购买全返礼包")
				elseif v.treasure_type == 150 then
					treasure_type = string.format("完成了比赛任务")
				else
					treasure_type = string.format("购买了金猪礼包I")
				end
				item_table.info_txt.text = string.format("%s %s",is_active,treasure_type)
				item.transform:SetAsLastSibling()
				item.gameObject:SetActive(true)
			end
		end
	end

	--self.nodata_txt.gameObject:SetActive(not data or #data.detail_infos <= 0)
	self.nodata_txt.gameObject:SetActive(false)
end

function GameMoneyCenterContributePanel:OnEndDrag(  )
	local VNP = self.sv_sr.verticalNormalizedPosition
	if VNP <= 0 then
		GameMoneyCenterModel.query_son_details_contribute_info(self.son_id, GameMoneyCenterModel.contribute_page_index)
		--测试数据
		-- Event.Brocast("query_reward_task_find_record_response","query_reward_task_find_record_response",
		-- {
		-- 	result = 0,
		-- 	total_find = 500,
		-- 	record_data = {{time = 1,status = 1,get_award_value = 1},{time = 2,status = 2,get_award_value = 2},{time = 3,status = 3,get_award_value = 3}}
		-- })
	end
end

function GameMoneyCenterContributePanel:UpdateBaseInfoUI()
	local data = GameMoneyCenterModel.GetBaseContributeInfo(self.son_id)
	local sczd_data = GameMoneyCenterModel.GetPlayerSczdBaseInfo(self.son_id)
	dump(data, "<color=green>data</color>")
	dump(sczd_data, "<color=green>sczd_data</color>")
	if data and sczd_data then
		local id = data.son_id
		self.base_info_txt.text = string.format( "ID:%s  %s", data.son_id, sczd_data.name )
		self.contribute_info_txt.text = string.format( "新人福卡第%s天 ：总贡献%s元", data.son_bbsc_progress, StringHelper.ToRedNum(data.son_bbsc_gx/100))
		self.vip_info_txt.text = string.format( "购买金猪礼包：贡献%s元", StringHelper.ToRedNum(data.son_tgli_gx/100))
		if not data.son_vip_lb_gx then data.son_vip_lb_gx = 0 end
		self.vip_gift_info_txt.text = string.format( "购买全返礼包：贡献%s元", StringHelper.ToRedNum(data.son_vip_lb_gx/100))
		if GameMoneyCenterModel.data.is_active_tglb1_profit == 1 then
			self.vip_activate_txt.gameObject:SetActive(false)
		else
			--self.vip_activate_txt.gameObject:SetActive(true)
		end
	end
end

function GameMoneyCenterContributePanel:on_model_query_son_base_contribute_info_response()
	self:UpdateBaseInfoUI()
end

function GameMoneyCenterContributePanel:on_model_query_son_details_contribute_info_response(page_index)
	self:UpdateDetailUI(page_index)
end

function GameMoneyCenterContributePanel:on_model_update_contribute_info()
	destroyChildren(self.award_histroy_content)
	self.award_histroy_content.localPosition = Vector3.zero
	LittleTips.Create("数据已经更新，请继续游戏")
end

-- 推广礼包激活状态变化
function GameMoneyCenterContributePanel:model_tglb_profit_activate()
	self:UpdateBaseInfoUI()
	GameMoneyCenterModel.contribute_page_index = 1
	GameMoneyCenterModel.query_son_details_contribute_info(self.son_id,GameMoneyCenterModel.contribute_page_index)
end
