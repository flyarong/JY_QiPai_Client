-- 创建时间:2020-07-27
-- Panel:Act_032_XXLDHPanel
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

Act_032_XXLDHPanel = basefunc.class()
local C = Act_032_XXLDHPanel
C.name = "Act_032_XXLDHPanel"
local M = Act_032_XXLDHManager
local ex_change = M.ex_change
local ex_ids = M.ex_ids

local type2img = {
	jifen = "com_award_icon_jf",
	jing_bi = "pay_icon_gold2",
	prop_web_chip_huafei = "com_award_icon_hfsp",
	shop_gold_sum = "com_award_icon_money"
}

local tips = {
	[1] = "击杀带有花色的鱼可获得",
	[2] = "击杀带有花色的鱼可获得",
	[3] = "击杀带有花色的鱼可获得",
	[4] = "击杀带有花色的鱼可获得",
	[5] = "击杀章鱼boss可获得，章鱼boss不定时出现",
}

local _btn = {
	"sg_xxl_btn",
	"sh_xxl_btn",
	"cs_xxl_btn",
	"xy_xxl_btn",
}

local _mask = {
	"sg_xxl_mask",
	"sh_xxl_mask",
	"cs_xxl_mask",
	"xy_xxl_mask",
}

local _type = {
	"xiaochuhaoli_shuiguo",
	"xiaochuhaoli_shuihu",
	"xiaochuhaoli_caishen",
	"xiaochuhaoli_xiyou"
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
	self.lister["Act_032_XXLDHPanel_Refresh"] = basefunc.handler(self,self.On_Act_032_XXLDHPanel_Refresh)
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
	
	self:ChangeChoose(self:GetNowChoose())
	self:InitUI()
	self:InitBottomBtn()
end

function C:InitUI()
	self.duihuan_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		HintPanel.Create(2,"一键兑换功能会根据组合从多到少自动匹配兑换，是否确认兑换",function ()
			Network.SendRequest("box_all_exchange",{name = _type[self.now_xxl_choose_index] })
		end)
		
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	self.MainItems = {}
	self.NumItem = {}
	coroutine.start(
		function()
			Yield(0)
			destroyChildren(self.node)
			destroyChildren(self.Content)
			self:InitMainUI()
			self:InitNum()
			self:RefreshNum()
			self:RefreshMainUI()
		end
	)
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
	for i = 67,98 do
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
		temp_ui.item_img.sprite = GetTexture(M.GetImageName(self.now_xxl_choose_index)[config[i]])
		-- PointerEventListener.Get(temp_ui.item_img.gameObject).onDown = function ()
		-- 	GameTipsPrefab.ShowDesc(tips[config[i]], UnityEngine.Input.mousePosition)
		-- end
		-- PointerEventListener.Get(temp_ui.item_img.gameObject).onUp = function ()
		-- 	GameTipsPrefab.Hide()
		-- end
		self.NumItem[#self.NumItem + 1] = temp_ui
	end	
end

function C:RefreshNum()
	local config = {
		5,1,2,3,4
	}
	for i = 1,#self.NumItem do
		local num = GameItemModel.GetItemCount(M.GetTypeName(self.now_xxl_choose_index)[config[i]])
		self.NumItem[i].item_num_txt.text = M.MaxShowNum(num,5,self.NumItem[i].item_add)
	end
	self:RefreshRed()
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
			temp_ui2.ex_img.sprite = GetTexture(M.GetImageName(self.now_xxl_choose_index)[ex_change[i].need[j].parm])
			-- PointerEventListener.Get(temp_ui2.ex_img.gameObject).onDown = function ()
			-- 	GameTipsPrefab.ShowDesc(tips[ex_change[i].need[j].parm], UnityEngine.Input.mousePosition)
			-- end
			-- PointerEventListener.Get(temp_ui2.ex_img.gameObject).onUp = function ()
			-- 	GameTipsPrefab.Hide()
			-- end
			temp_ui2.ex_num_txt.text = ex_change[i].need[j].num
			temp_ui2.ex_add.gameObject:SetActive(j~=1)
		end
		temp_ui.go_btn.onClick:AddListener(function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			GameManager.GotoUI({gotoui = "game_MiniGame"})
		end)
		temp_ui.get_btn.onClick:AddListener(function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			Network.SendRequest("box_exchange",{id = ex_ids[self.now_xxl_choose_index][i],num = 1})
		end)
		for m = 1,#ex_change[i].award do
			temp_ui["award"..m.."_img"].sprite = GetTexture(  type2img[ex_change[i].award[m]._type] )
			temp_ui["award"..m.."_img"]:SetNativeSize()
			temp_ui["award"..m.."_txt"].text = ex_change[i].award[m].num
			if m == 3 then
				temp_ui["mask3_img"]:SetNativeSize()
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
		if GameItemModel.GetItemCount(M.GetTypeName(self.now_xxl_choose_index)[parm]) >= num then
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
			local num = Act_032_JFLBManager.GetBeiShu()
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

function C:InitBottomBtn()
	for i = 1,#_btn do
		self[_btn[i]].onClick:AddListener(
			function()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				self:ChangeChoose(i)
			end
		)
	end
end

function C:ChangeChoose(index)
	for i = 1,#_mask do
		self[_mask[i]].gameObject:SetActive(false)
	end
	self[_mask[index]].gameObject:SetActive(true)
	self.now_xxl_choose_index = index
	self:MyRefresh()
end

function C:GetNowChoose()
	local _data = {
		"game_Eliminate","game_EliminateSH","game_EliminateCS","game_EliminateXY",
	}
	for i = 1,#_data do
		if MainModel.myLocation == _data[i] then
			return i 
		end
	end
	return 1
end

function C:RefreshRed()
    local cheak_func1 = function (parm,num)
        for i = 1,4 do			
			if GameItemModel.GetItemCount(M.GetTypeName(i)[parm]) >= num then
				self["red"..i].gameObject:SetActive(true)
			else
				self["red"..i].gameObject:SetActive(false)
			end
        end
	end
	
    local cheak_func2 = function(Index)
        if M.ex_change[Index] then
            for i=1,#M.ex_change[Index].need do
				cheak_func1(M.ex_change[Index].need[i].parm,M.ex_change[Index].need[i].num)
            end
        end
    end
    
	for i = 1,#M.ex_change do
		cheak_func2(i)
    end
end

function C:On_Act_032_XXLDHPanel_Refresh()
	if not IsEquals(self.gameObject) then return end
	self:RefreshNum()
	self:RefreshMainUI()
end