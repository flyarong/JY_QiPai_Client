-- 创建时间:2020-07-27
-- Panel:Act_033_BZDHPanel
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

Act_033_BZDHPanel = basefunc.class()
local C = Act_033_BZDHPanel
C.name = "Act_033_BZDHPanel"
local M = Act_033_BZDHManager
--"♠ : 1","♥ : 2","♣ : 3","♦ : 4",46-54
local ex_change = {
	{ex_change_id = 99,need = {{parm = 4,num =2}},award ={{num = 30,_type = "jifen"},{num = 1000,_type = "jing_bi"},{num = 10,_type = "jifen"}}},
	{ex_change_id = 100,need = {{parm = 3,num =2}},award ={{num = 50,_type = "jifen"},{num = 1500,_type = "jing_bi"},{num = 15,_type = "jifen"}}},
	{ex_change_id = 101,need = {{parm = 2,num =2}},award ={{num = 80,_type = "jifen"},{num = 2000,_type = "jing_bi"},{num = 20,_type = "jifen"}}},
	{ex_change_id = 102,need = {{parm = 1,num =2}},award ={{num = 100,_type = "jifen"},{num = 3000,_type = "jing_bi"},{num = 30,_type = "jifen"}}},
	{ex_change_id = 103,need = {{parm = 5,num =25}},award ={{num = 500,_type = "jifen"},{num = 8000,_type = "jing_bi"},{num = 100,_type = "jifen"}}},
	{ex_change_id = 104,need = {{parm = 1,num =2},{parm = 2,num =2},{parm = 3,num =2},{parm = 4,num =2}},award ={{num = 400,_type = "jifen"},{num = 50,_type = "prop_web_chip_huafei"},{num = 80,_type = "jifen"}}},
	{ex_change_id = 105,need = {{parm = 5,num =25},{parm = 1,num =2},{parm = 2,num =2},{parm = 3,num =2},{parm = 4,num =2}},award ={{num = 1000,_type = "jifen"},{num = 3,_type = "shop_gold_sum"},{num = 200,_type = "jifen"}}},
}

local type2img = {
	jifen = "com_award_icon_jf2",
	jing_bi = "pay_icon_gold2",
	prop_web_chip_huafei = "com_award_icon_hfsp",
	shop_gold_sum = "com_award_icon_money"
}

local tips = {
	[1] = "击杀带有花色的鱼可获得",
	[2] = "击杀带有花色的鱼可获得",
	[3] = "击杀带有花色的鱼可获得",
	[4] = "击杀带有花色的鱼可获得",
	[5] = "击杀宝藏蟹boss可获得，宝藏蟹boss不定时出现",
	
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
	self.lister["box_all_exchange_response"] = basefunc.handler(self,self.on_box_all_exchange_response)
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
	self.lister["box_exchange_response"] = basefunc.handler(self,self.onGetInfo)
	self.lister["Act_033_DHPanel_Refresh"] = basefunc.handler(self,self.On_Act_033_DHPanel_Refresh)
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
	self:InitMainUI()
	self:InitNum()
	self:RefreshNum()
	self:RefreshMainUI()
end

function C:InitUI()
	self.duihuan_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		HintPanel.Create(2,"一键兑换功能会根据花色组合从多到少自动匹配兑换，是否确认兑换",function ()
			Network.SendRequest("box_all_exchange",{name = "bzdh_10_12"})
		end)
		
	end)
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnAssetChange(data)
	if not IsEquals(self.gameObject) then return end
	self:RefreshNum()
	self:RefreshMainUI()
	if data.change_type and not table_is_null(data.data)  and self:IsCareType(data.change_type) then
		Event.Brocast("AssetGet",data)
	end
end


function C:IsCareType(change_type)
	local str = "box_exchange_active_award_"
	for i = 99,105 do
		if change_type == str..i then
			return true
		end
	end
	return false
end


function C:InitNum()
	local config = {
		5,1,2,3,4
	}
	self.NumItem = {}
	for i = 1,#config do
		local temp_ui = {}
		local b = GameObject.Instantiate(self.nodeItem,self.node)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform,temp_ui)
		temp_ui.item_img.sprite = GetTexture(M.parm_img[config[i]])
		PointerEventListener.Get(temp_ui.item_img.gameObject).onDown = function ()
			GameTipsPrefab.ShowDesc(tips[config[i]], UnityEngine.Input.mousePosition)
		end
		PointerEventListener.Get(temp_ui.item_img.gameObject).onUp = function ()
			GameTipsPrefab.Hide()
		end
		self.NumItem[#self.NumItem + 1] = temp_ui
	end	
end

function C:RefreshNum()
	local config = {
		5,1,2,3,4
	}
	for i = 1,#self.NumItem do
		local num = GameItemModel.GetItemCount(M.parm[config[i]])
		self.NumItem[i].item_num_txt.text = M.MaxShowNum(num,5,self.NumItem[i].item_add)
	end	
end

function C:InitMainUI()
	self.MainItems = {}
	for i = 1,#ex_change do
		local temp_ui = {}
		local b = GameObject.Instantiate(self.duihuan_item,self.Content)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform,temp_ui)
		for j = 1,#ex_change[i].need do
			local temp_ui2 = {}
			local c = GameObject.Instantiate(self.ex_item,temp_ui.lay_node.transform)
			c.gameObject:SetActive(true)
			LuaHelper.GeneratingVar(c.transform,temp_ui2)
			temp_ui2.ex_img.sprite = GetTexture(M.parm_img[ex_change[i].need[j].parm])
			PointerEventListener.Get(temp_ui2.ex_img.gameObject).onDown = function ()
				GameTipsPrefab.ShowDesc(tips[ex_change[i].need[j].parm], UnityEngine.Input.mousePosition)
			end
			PointerEventListener.Get(temp_ui2.ex_img.gameObject).onUp = function ()
				GameTipsPrefab.Hide()
			end
			temp_ui2.ex_num_txt.text = ex_change[i].need[j].num
			temp_ui2.ex_add.gameObject:SetActive(j~=1)
		end
		temp_ui.go_btn.onClick:AddListener(function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			GameManager.CommonGotoScence({gotoui="game_Fishing"},function ()
				self:MyExit()
			end)
		end)
		temp_ui.get_btn.onClick:AddListener(function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			Network.SendRequest("box_exchange",{id = ex_change[i].ex_change_id,num = 1})
		end)
		for m = 1,#ex_change[i].award do
			temp_ui["award"..m.."_img"].sprite = GetTexture(  type2img[ex_change[i].award[m]._type] )
			temp_ui["award"..m.."_img"]:SetNativeSize()
			temp_ui["award"..m.."_txt"].text = ex_change[i].award[m].num
			if m == 3 then
				--temp_ui["mask3_img"].sprite = GetTexture(  type2img[ex_change[i].award[m]._type] )
				temp_ui["mask3_img"]:SetNativeSize()
				PointerEventListener.Get(temp_ui["award"..m.."_img"].gameObject).onDown = function ()
					GameTipsPrefab.ShowDesc("购买宝藏礼包后可获得", UnityEngine.Input.mousePosition)
				end
				PointerEventListener.Get(temp_ui["award"..m.."_img"].gameObject).onUp = function ()
					GameTipsPrefab.Hide()
				end
			end
			if m == 1 then
				PointerEventListener.Get(temp_ui["award"..m.."_img"].gameObject).onDown = function ()
					GameTipsPrefab.ShowDesc("用于参加宝藏蟹争霸活动！", UnityEngine.Input.mousePosition)
				end
				PointerEventListener.Get(temp_ui["award"..m.."_img"].gameObject).onUp = function ()
					GameTipsPrefab.Hide()
				end
			end
		end
		self.MainItems[#self.MainItems + 1] = temp_ui
	end
end

function C:onGetInfo(_,data)
	dump(data,"<color=red>宝箱返回数据</color>")
	if data.result ~= 0 then
		HintPanel.ErrorMsg(data.result)
	end
end

function C:IsCanGetAward(Index)
	local cheak_func = function (parm,num)
		if GameItemModel.GetItemCount(M.parm[parm]) >= num then
			return true
		end
		return false
	end
	if ex_change[Index] then
		for i=1,#ex_change[Index].need do
			if cheak_func(ex_change[Index].need[i].parm,ex_change[Index].need[i].num) == false then
				return false
			end
		end
		return true
	end
	return false
end

function C:RefreshMainUI()
	for i = 1,#self.MainItems do
		self.MainItems[i].get_btn.gameObject:SetActive(self:IsCanGetAward(i))
		self.MainItems[i].go_btn.gameObject:SetActive( not self:IsCanGetAward(i))
		Timer.New(function()
			local num = Act_033_BZLBManager.GetBeiShu()
			if IsEquals(self.gameObject) and self.MainItems[i] then
				if num and num ~= 0 then
					self.MainItems[i].beishu.gameObject:SetActive(true)
					self.MainItems[i].beishu_txt.text = num.."倍"
					self.MainItems[i].mask3_img.gameObject:SetActive(false)
				else
					self.MainItems[i].beishu.gameObject:SetActive(false)
					self.MainItems[i].mask3_img.gameObject:SetActive(true)
				end
			end
		end,0.5,1):Start()
	end
end

function C:on_box_all_exchange_response(_,data)
	dump(data,"一键兑换")
	if data.result == 0 then

	else
		HintPanel.ErrorMsg(data.result)
	end
end

function C:On_Act_033_DHPanel_Refresh()
	if not IsEquals(self.gameObject) then return end
	self:RefreshNum()
	self:RefreshMainUI()
end