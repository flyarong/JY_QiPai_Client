-- 创建时间:2020-08-21
-- Panel:Act_027_ZNQGPanel
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

Act_027_ZNQGPanel = basefunc.class()
local C = Act_027_ZNQGPanel
C.name = "Act_027_ZNQGPanel"
local M = Act_027_ZNQGManager
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
	self.lister["activity_exchange_response"] = basefunc.handler(self,self.on_activity_exchange_response)
	self.lister["act_027_znqg_get_new_info"] = basefunc.handler(self,self.on_act_027_znqg_get_new_info)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.UpdateTimer then
		self.UpdateTimer:Stop()
	end
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
	self.close_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:MyExit()
		end
	)
	self:InitUpdate()
end

function C:InitUI()
	destroyChildren(self.ItemNode)
	local status_index = M.StatusIndex
	local show_data = M.GetUIConfig()
	if not show_data or not status_index then return end
	self.Item = {}
	local award_data = M.GetAwardData(show_data[status_index].id)
	for i = 1,#award_data do
		local temp_ui = {}
		local b = GameObject.Instantiate(self.shop_item,self.ItemNode)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform,temp_ui)
		local value = show_data[status_index].use_goods[1] == "shop_gold_sum" and  award_data[i].use_num[1] / 100 or award_data[i].use_num[1]
		local str = self:Type2Str(show_data[status_index].use_goods[1]) 
		temp_ui.money_txt.text = value..str
		temp_ui.get_btn.onClick:AddListener(
			function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				self:GoExChange(show_data[status_index].id, award_data[i].award_id,value)
			end
		)
		self:InitAwardUI(temp_ui.AwardNode,award_data[i])
		self.Item[#self.Item + 1] = temp_ui
		-- --特殊处理：万元赛加2.5折标签
		-- if i == 2 then
		-- 	temp_ui.tag_img.gameObject:SetActive(true)
		-- 	local tt = GameObject.Instantiate(self.tt_txt,b.transform)
		-- 	tt.gameObject:SetActive(true)
		-- end
	end
end

function C:InitAwardUI(parent,config)
	for i = 1,#config.asset_type do
		local temp_ui = {}
		local b = GameObject.Instantiate(self.award_item,parent)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform,temp_ui)
		temp_ui.award_img.sprite =GetTexture(self:Type2Img(config.asset_type[i]))
		if config.asset_type[i] == "jing_bi" then
			temp_ui.award_img.gameObject.transform.localScale = Vector3.New(0.7,0.7,0.7)
		end
		temp_ui.award_img:SetNativeSize()
		--dump(config,"<color=red>RRRRRRRRRRRRRRRRRRRRRRRRRRR</color>")
		local value = config.asset_type[i] == "shop_gold_sum" and config.asset_count[i] / 100 or config.asset_count[i]
		temp_ui.award_txt.text = "x"..value
	end
end


function C:Type2Str(_type)
	local data = {
		shop_gold_sum = "福卡",
		jing_bi = "鲸币",
		prop_2year_jinianbi1 = "纪念币",
	}
	if _type then
		return data[_type]
	end
end

function C:Type2Img(_type)
	local data = {
		shop_gold_sum = "com_award_icon_money",
		jing_bi = "com_award_icon_jingbi",
		prop_2year_jinianbi1 = "yjlqjnb_icon_jnb",
		prop_2year_jinianbi2 = "yjlqjnb_icon_jnb",
		prop_2year_jinianbi3 = "yjlqjnb_icon_jnb",
		prop_3 = "com_award_icon_wys",
	}
	if _type then
		return data[_type]
	end
end


function C:MyRefresh()

end

function C:SetTexts()
	
end

function C:on_act_027_znqg_get_new_info()
	local data = M.GetData()
	if data then
		local base_data = M.GetBaseData()
		if base_data and data.type == base_data.id then
			self:RefreshUI()
		end
	end
end

function C:RefreshUI()
	self.timer_txt.text = M.t1
	--dump(M.t1,"<color=red>KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK</color>")
	if not IsEquals(self.gameObject) then return end
	--在售卖时间段内
	local base_data = M.GetBaseData()
	if base_data then
		local ED = M.GetData()
		if ED and ED[base_data.id] then
			for i = 1,#self.Item do
				self.Item[i].num_txt.text = "剩余"..ED[base_data.id].exchange_all_day_data[i].."份"
				if ED[base_data.id].exchange_day_data[i] > 0 and ED[base_data.id].exchange_all_day_data[i] > 0 then
					self.Item[i].ButtonMask.gameObject:SetActive(false)
					self.Item[i].get_btn.gameObject:SetActive(true)
				else
					self.Item[i].ButtonMask.gameObject:SetActive(true)
					self.Item[i].get_btn.gameObject:SetActive(false)
					if ED[base_data.id].exchange_all_day_data[i] == 0 then
						self.Item[i].mask_txt.text = "售罄"
						self.Item[i].num_txt.text = "剩余0份"
					elseif ED[base_data.id].exchange_day_data[i] == 0 then
						self.Item[i].mask_txt.text = "已兑换"
					end
				end
			end
		end
	else
		local show_data = M.GetUIConfig()
		if show_data and M.StatusIndex then
			local award_data = M.GetAwardData(show_data[M.StatusIndex].id)
			for i = 1,#self.Item do
				self.Item[i].num_txt.text = "剩余"..award_data[i].all_limit_day_num.."份"
				self.Item[i].ButtonMask.gameObject:SetActive(false)
				self.Item[i].get_btn.gameObject:SetActive(true)
			end
		end
	end
end

function C:GoExChange(_type,_id,need)
	dump({_type = _type,_id = _id,need = need},"发送请求")
	--在售卖时间段内
	if  M.GetBaseData() then
		if need <= MainModel.GetHBValue() then
			Network.SendRequest("activity_exchange",{ type = _type , id = _id })
		else
			HintPanel.Create(1,"您的福卡数量不足")
		end
	else
		HintPanel.Create(1,M.t2)
	end	
end

function C:InitUpdate()
	if self.UpdateTimer then
		self.UpdateTimer:Stop()
	end
	self:RefreshUI()
	self.UpdateTimer = Timer.New(
		function ()
			self:RefreshUI()
		end
	,1,-1)
	self.UpdateTimer:Start()
end

function C:on_activity_exchange_response(_,data)
	dump(data,"<color=red>兑换返回</color>")
	local base_data = M.GetBaseData()
	if M.IsActive() and base_data then
		Network.SendRequest("query_activity_exchange",{type = base_data.id})
	end
end