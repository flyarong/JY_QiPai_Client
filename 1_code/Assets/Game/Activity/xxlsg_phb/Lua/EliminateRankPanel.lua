-- 创建时间:2019-09-03
-- Panel:EliminateRankPanel
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

EliminateRankPanel = basefunc.class()
local C = EliminateRankPanel
C.name = "EliminateRankPanel"

local HGList = {
	[1] ="localpop_icon_1",
	[2] ="localpop_icon_2",
	[3] ="localpop_icon_3",
}

local XxlNameTxt = {
	xxl_xy = "<color=#d85c0a>西游消消乐</color>",
	xxl_cs = "<color=#c50000>财神消消乐</color>",
	xxl_sg = "<color=#00b875>萌宠消消乐</color>",
	xxl_cj = "<color=#b01adb>超级消消乐</color>",
	xxl_sh = "<color=#1a4cdb>水浒消消乐</color>",
	xxl_sgsy = "<color=#3dafe3>三国消消乐</color>",
	xxl_bs = "<color=#5D35BA>宝石迷阵</color>",
	xxl_fx = "<color=#FF0089>福星高照</color>",
}

local Award={
	200,100,50,30,30,30,15,15,15,15
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
	self.lister["query_rank_data_response"] = basefunc.handler(self,self.on_query_rank_data_response)
	self.lister["query_rank_base_info_response"] = basefunc.handler(self,self.on_query_rank_base_info_response)
end

-- function C:onMyInfoGet(_,data)
-- 	dump(data,"<color=red>onMyInfoGet</color>")
-- 	if data and data.result  ==  0 and IsEquals(self.gameObject) then
-- 		self.my_name_txt.text=MainModel.UserInfo.name
-- 		self.my_get_txt.text=StringHelper.ToCash(data.award_money)
-- 		self.my_num_txt.text=StringHelper.ToCash(data.bet_money)
-- 		self.jinb = self.my_info.transform:Find("BG/Image")
-- 		self.jinb.gameObject:SetActive(false)
-- 		self.num_txt.gameObject:SetActive(false)
-- 		self.my_num_txt.gameObject:SetActive(false)
-- 		if data.rank==-1 then
-- 			self.my_ranking_img.gameObject:SetActive(false)
-- 			self.my_rank2_txt.text="未上榜"		
-- 			self.my_award_txt.text="--"	
-- 		elseif data.rank < 4 then
-- 			self.my_ranking_txt.text=" "
-- 			self.my_ranking_img.sprite=GetTexture(HGList[data.rank])
-- 			self.my_rank2_txt.text=" "
-- 			self.my_award_txt.text=	Award[data.rank]
-- 			self.my_ranking_img:SetNativeSize() 
-- 		elseif data.rank< 11 then 
-- 			self.my_ranking_txt.text=data.rank
-- 			self.my_ranking_img.sprite=GetTexture("localpop_icon_ranking")
-- 			self.my_rank2_txt.text=" "
-- 			self.my_award_txt.text=	Award[data.rank]
-- 			self.my_ranking_img:SetNativeSize() 
-- 		else
-- 			self.my_ranking_img.gameObject:SetActive(false)
-- 			self.my_rank2_txt.text="未上榜"
-- 		end  
-- 	end 
-- end


-- function C:onInfoGet(_,data)
-- 	dump(data,"<color=red>onInfoGet</color>")
-- 	if data and data.result ==0 and IsEquals(self.gameObject) then 
		
-- 			local b = GameObject.Instantiate(self.info,self.content)
-- 			LuaHelper.GeneratingVar(b.transform, self)
-- 			self.jinb = b.transform:Find("BG/Image")
-- 			self.jinb.gameObject:SetActive(false)
-- 			self.num_txt.gameObject:SetActive(false)
-- 			b.gameObject:SetActive(true)
-- 			self.name_txt.text=data.rank_data[i].name
-- 			self.award_txt.text=Award[data.rank_data[i].rank]
-- 			self.get_txt.text=StringHelper.ToCash(data.rank_data[i].award_money)
-- 			self.num_txt.text=StringHelper.ToCash(data.rank_data[i].bet_money)
-- 			if data.rank_data[i].rank < 4 then
-- 				self.rank_img.sprite=GetTexture(HGList[data.rank_data[i].rank])
-- 				self.rank_img:SetNativeSize() 
-- 			else
-- 				self.rank_img.sprite=GetTexture("localpop_icon_ranking")
-- 				self.rank_img:SetNativeSize() 
-- 				self.rank_txt.text=data.rank_data[i].rank
-- 			end
-- 			if data.rank_data[i].player_id == MainModel.UserInfo.user_id then 
-- 				local img = b.transform:Find("BG"):GetComponent("Image")
-- 				img.sprite = GetTexture("xxl_bg_phb1")
-- 				img = nil
-- 			end 
-- 			if i == 10 then return end 
-- 		end
-- 	end 
-- end

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
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	if MainModel.myLocation == "game_EliminateFX" then
		parent = GameObject.Find("Canvas/LayerLv4").transform
	end
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:SetButtonClick()
	self:Query()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
end

function C:Query()
    Network.SendRequest("query_rank_data", { page_index = 1, rank_type = "xiaoxiaole_award_rank" })
    Network.SendRequest("query_rank_base_info", { rank_type = "xiaoxiaole_award_rank" })
end

function C:InitUI()
	self.HelpPanel=self.transform:Find("HelpPanel")

	self.CloseButton=self.transform:Find("CloseButton"):GetComponent("Button")
	self.SMButton=self.transform:Find("SMButton"):GetComponent("Button")
	self.CloseHelp=self.HelpPanel.transform:Find("ImgPopupPanel/close_btn"):GetComponent("Button")	
end

--当按钮按下的时候
function C:SetButtonClick()
	self.CloseButton.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:MyExit()
		end
	)
	self.CloseHelp.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self.HelpPanel.gameObject:SetActive(false)
		end
	)
	self.SMButton.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self.HelpPanel.gameObject:SetActive(true)
		end
	)
end

--排行榜信息
function C:on_query_rank_data_response(_,data)
	dump(data,"<color=red>+++++消消乐排行榜RankData+++++</color>")
	if data and data.result ==0 and IsEquals(self.gameObject) and data.rank_type and data.rank_type == "xiaoxiaole_award_rank" then 
		for i = 1, #data.rank_data do
			local b = GameObject.Instantiate(self.info,self.content)
			local temp_ui = {}
			LuaHelper.GeneratingVar(b.transform, temp_ui)
			b.gameObject:SetActive(true)
			temp_ui.name_txt.text = data.rank_data[i].name
			temp_ui.num_txt.text = StringHelper.ToCash(data.rank_data[i].score)
			temp_ui.get_txt.text = "100"
			local json_data = json2lua(data.rank_data[i].other_data)
			if json_data then
				local _source_type = json_data.source_type
				self:ViewXxlTxt(temp_ui.game_txt,_source_type)
			end
			if data.rank_data[i].rank < 4 then
				temp_ui.rank_img.sprite=GetTexture(HGList[data.rank_data[i].rank])
				temp_ui.rank_img:SetNativeSize() 
			else
				temp_ui.rank_img.sprite=GetTexture("localpop_icon_ranking")
				temp_ui.rank_img:SetNativeSize() 
				temp_ui.rank_txt.text=data.rank_data[i].rank
			end
			temp_ui.get_txt.text = Award[data.rank_data[i].rank]
			if data.rank_data[i].player_id == MainModel.UserInfo.user_id then 
				local img = b.transform:Find("BG"):GetComponent("Image")
				img.sprite = GetTexture("xxl_bg_phb1")
				img = nil
			end 
			if i == 10 then return end 
		end
	end
end

--玩家信息
function C:on_query_rank_base_info_response(_,data)
	dump(data,"<color=red>+++++消消乐排行榜BaseInfo+++++</color>")
	if data and data.result == 0 and IsEquals(self.gameObject) and data.rank_type and data.rank_type == "xiaoxiaole_award_rank"  then
		self.my_name_txt.text=MainModel.UserInfo.name
		self.my_get_txt.text=StringHelper.ToCash(data.score)
		local json_data = json2lua(data.other_data)
		if json_data then
			local _source_type = json_data.source_type
			self:ViewXxlTxt(self.my_game_txt,_source_type)
		end
		if data.rank==-1 then
			self.my_ranking_img.gameObject:SetActive(false)
			self.my_rank2_txt.text="未上榜"		
			self.my_award_txt.text="--"	
		elseif data.rank < 4 then
			self.my_ranking_txt.text=" "
			self.my_ranking_img.sprite=GetTexture(HGList[data.rank])
			self.my_rank2_txt.text=" "
			self.my_award_txt.text=	Award[data.rank]
			self.my_ranking_img:SetNativeSize() 
		elseif data.rank< 11 then 
			self.my_ranking_txt.text=data.rank
			self.my_ranking_img.sprite=GetTexture("localpop_icon_ranking")
			self.my_rank2_txt.text=" "
			self.my_award_txt.text=	Award[data.rank]
			self.my_ranking_img:SetNativeSize() 
		else
			self.my_ranking_img.gameObject:SetActive(false)
			self.my_rank2_txt.text="未上榜"
		end 
		self.my_game_txt.gameObject:SetActive(data.rank ~= -1) 
	end 
end

function C:ViewXxlTxt(txt_obj,source_type)
	if source_type == "xiaoxiaole_award" then
        txt_obj.text = XxlNameTxt.xxl_sg
    elseif source_type == "xiaoxiaole_shuihu_award" then
        txt_obj.text = XxlNameTxt.xxl_sh
    elseif source_type == "xiaoxiaole_caishen_award" then
        txt_obj.text = XxlNameTxt.xxl_cs
    elseif source_type == "xiaoxiaole_xiyou_award" then
        txt_obj.text = XxlNameTxt.xxl_xy 
	elseif source_type == "lianxianxiaoxiaole_award" then
        txt_obj.text = XxlNameTxt.xxl_cj 
	elseif source_type == "xiaoxiaole_sanguo_award" then
        txt_obj.text = XxlNameTxt.xxl_sgsy 
	elseif source_type == "xiaoxiaole_baoshi_award" then
        txt_obj.text = XxlNameTxt.xxl_bs 
	elseif source_type == "xiaoxiaole_fuxing_award" then
        txt_obj.text = XxlNameTxt.xxl_fx
    end
end