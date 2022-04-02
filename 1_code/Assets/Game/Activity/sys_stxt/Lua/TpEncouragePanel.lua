local basefunc = require "Game/Common/basefunc"

TpEncouragePanel = basefunc.class()
local C = TpEncouragePanel
C.name = "TpEncouragePanel"
local CFG = SYSSTXTManager.TP_encourage_config
local config = basefunc.deepcopy(CFG)
local curr_data
local award_objs
function C.Create(parent,data)
	return C.New(parent,data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["query_motivate_config_response"] = basefunc.handler(self,self.on_query_motivate_config_response)
	self.lister["motivate_apprentice_by_give_props_response"] = basefunc.handler(self,self.on_motivate_apprentice_by_give_props_response)
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

function C:ctor(parent,data)

	ExtPanel.ExtMsg(self)

	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.data = data
	self.Can_Click = false
	LuaHelper.GeneratingVar(self.transform, self)
	curr_data = {}
	award_objs = {}
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	Network.SendRequest("query_motivate_config",{apprentice_id = self.data})
end

function C:InitUI()
	local temp_ui = {}
	for i=1,#config.Award do
		local b = GameObject.Instantiate(self.award_item,self.Content)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform, temp_ui)
		temp_ui.award_img.sprite = GetTexture(config.Award[i].image)
		award_objs[config.Award[i].text] = b
		temp_ui.less_btn.onClick:AddListener(
			function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
				self:OnButtonClick(config.Award[i],-1) 
			end
		)
		temp_ui.more_btn.onClick:AddListener(
			function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
				self:OnButtonClick(config.Award[i],1)
			end
		)
	end
	self.confirm_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
			self:On_GO()
		end
	)
	self.close_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	local temp_ui = {}
	local total_need = 0
	self.notfree_box_num = 0
	for i = 1, #config.Award do
		LuaHelper.GeneratingVar(award_objs[config.Award[i].text].transform, temp_ui)
		if curr_data[config.Award[i].text] then 
			if curr_data[config.Award[i].text] <= 0 then 
				curr_data[config.Award[i].text] = 0	
				temp_ui.less_mask.gameObject:SetActive(true)
				temp_ui.more_mask.gameObject:SetActive(false)
			elseif curr_data[config.Award[i].text] >= config.Award[i].num_limit then 
				curr_data[config.Award[i].text] = config.Award[i].num_limit
				temp_ui.less_mask.gameObject:SetActive(false)
				temp_ui.more_mask.gameObject:SetActive(true)
			else
				temp_ui.less_mask.gameObject:SetActive(false)
				temp_ui.more_mask.gameObject:SetActive(false)	
			end 
		else
			curr_data[config.Award[i].text] = 0	
			temp_ui.less_mask.gameObject:SetActive(true)
			temp_ui.more_mask.gameObject:SetActive(false)
		end

		if config.Award[i].need == 0 then 
			temp_ui.not_free.gameObject:SetActive(false)
			temp_ui.award_need_txt.text = ""
			temp_ui.award_num_txt.text = curr_data[config.Award[i].text]
			temp_ui.tips_txt.text = "免费激励"
		else
			temp_ui.not_free.gameObject:SetActive(true)
			temp_ui.award_num_txt.text = curr_data[config.Award[i].text]
			temp_ui.award_need_txt.text = curr_data[config.Award[i].text] * config.Award[i].need
			self.notfree_box_num = curr_data[config.Award[i].text]
			total_need = total_need + tonumber(temp_ui.award_need_txt.text)
		end

		if config.Award[i].num_limit == 0 then
			temp_ui.not_free.gameObject:SetActive(false)
			temp_ui.award_need_txt.text = ""
			temp_ui.award_num_txt.text = 0
			temp_ui.less_mask.gameObject:SetActive(true)
			temp_ui.more_mask.gameObject:SetActive(true)
			temp_ui.tips_txt.text = "今日已达上限"
		end 
	end
	self.total_need = total_need
	self.message_txt.text = "总花费"..total_need.."鲸币"
end

function C:OnButtonClick(Cfg,IsUp)
	if not self.Can_Click then return  end 
	if 	curr_data[Cfg.text] then
		curr_data[Cfg.text] = curr_data[Cfg.text] + 1 * IsUp
		if  curr_data[Cfg.text] > Cfg.num_limit or curr_data[Cfg.text] < 0 then 
			curr_data[Cfg.text] = curr_data[Cfg.text] - 1 * IsUp
		end 
	else
		curr_data[Cfg.text] = 0
	end
	self:MyRefresh()
end

function C:On_GO()
	local send_data = {}
	local is_had = false
	for k,v in pairs(curr_data) do
		local data = {}
		if v and v ~= 0 then 
			is_had = true
		end 
		if self:GetIDByText(k) then 
			data.id = self:GetIDByText(k)
			data.num = v
			send_data[#send_data + 1] = data
		end
	end 
	if is_had then 
		if self.re_reset_total then 
			HintPanel.Create(2,"您一共需要花费"..self.total_need.."鲸币,是否赠送？",function ()
				if self.notfree_box_num > self.re_reset_total then 
					HintPanel.Create(1,"超出今日宝箱数量上限"..self.notfree_box_num - self.re_reset_total.."个")
					return 
				end 
				if MainModel.UserInfo.jing_bi >= self.total_need then 
					Network.SendRequest("motivate_apprentice_by_give_props",{apprentice_id = self.data,prop = send_data})
				else
					HintPanel.Create(2,"您的鲸币不足",function ()
						PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
					end)
				end 
			end)
		end 
	else
		HintPanel.Create(1,"请选择一项礼物赠送")
	end 
end

function C:GetIDByText(text)
	for i=1,#config.Award do
		if text == config.Award[i].text then
			return  config.Award[i].ID
		end 
	end
end

function C:on_query_motivate_config_response(_,data)
	if data and data.result == 0 then 
		for i=1,#data.prop do
			if data.prop[i].num ~= -1 then
				config.Award[data.prop[i].id].num_limit = data.prop[i].num
			else
				-- 付费宝箱的总数量限制
				if i == 2 then 
					config.Award[data.prop[i].id].num_limit = data.re_reset_total
				end
			end 
		end
		self.re_reset_total = data.re_reset_total
		self.Can_Click = true
		self:MyRefresh()
	end
end

function C:on_motivate_apprentice_by_give_props_response(_,data)
	if data and data.result == 0 then 
		HintPanel.Create(1,"激励奖励已经发送到徒弟的背包")
	else
		HintPanel.ErrorMsg(data.result)
	end
end