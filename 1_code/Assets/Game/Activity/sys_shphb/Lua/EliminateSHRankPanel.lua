-- 创建时间:2019-09-03
-- Panel:EliminateSHRankPanel
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

EliminateSHRankPanel = basefunc.class()
local C = EliminateSHRankPanel
C.name = "EliminateSHRankPanel"

local HGList={
	[1] ="localpop_icon_1",
	[2] ="localpop_icon_2",
	[3] ="localpop_icon_3",
}
local Award={
	100,50,30,20,20,20,10,10,10,10
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
	self.lister["query_xiaoxiaole_shuihu_once_game_rank_base_info_response"] = basefunc.handler(self,self.onMyInfoGet)
	self.lister["query_xiaoxiaole_shuihu_once_game_rank_response"] = basefunc.handler(self,self.onInfoGet)
	self.lister["query_xiaoxiaole_shuihu_once_game_rank_history_response"] = basefunc.handler(self,self.onHistoryInfoGet)
end

function C:onMyInfoGet(_,data)
	dump(data,"<color=red>onMyInfoGet</color>")
	if data and data.result  ==  0 and IsEquals(self.gameObject) then
		self.my_name_txt.text=MainModel.UserInfo.name
		self.my_get_txt.text=StringHelper.ToCash(data.award_money)
		self.my_num_txt.text=StringHelper.ToCash(data.bet_money)
		if data.rank==-1 then
			self.my_ranking_img.gameObject:SetActive(false)
			self.my_rank2_txt.text="未上榜"		
			self.my_award_txt.text="--"	
		elseif data.rank < 4 then
			self.my_ranking_txt.text=" "
			self.my_ranking_img.sprite = GetTexture(HGList[data.rank])
			self.my_rank2_txt.text=" "
			self.my_award_txt.text=	Award[data.rank]
			self.my_ranking_img:SetNativeSize() 
		elseif data.rank< 11 then 
			self.my_ranking_txt.text=data.rank
			self.my_ranking_img.sprite = GetTexture("localpop_icon_ranking")
			self.my_rank2_txt.text=" "
			self.my_award_txt.text=	Award[data.rank]
			self.my_ranking_img:SetNativeSize() 
		else
			self.my_ranking_img.gameObject:SetActive(false)
			self.my_rank2_txt.text="未上榜"
		end  
	end 
end

function C:onInfoGet(_,data)
	dump(data,"<color=red>onInfoGet</color>")
	if data and data.result ==0 and IsEquals(self.gameObject) then 
		for i = 1, #data.rank_data do
			local b = GameObject.Instantiate(self.info,self.content)
			LuaHelper.GeneratingVar(b.transform, self)
			b.gameObject:SetActive(true)
			self.name_txt.text=data.rank_data[i].name
			self.award_txt.text=Award[data.rank_data[i].rank]
			self.get_txt.text=StringHelper.ToCash(data.rank_data[i].award_money)
			self.num_txt.text=StringHelper.ToCash(data.rank_data[i].bet_money)
			if data.rank_data[i].rank < 4 then
				self.rank_img.sprite = GetTexture(HGList[data.rank_data[i].rank])
				self.rank_img:SetNativeSize() 
			else
				self.rank_img.sprite = GetTexture("localpop_icon_ranking")
				self.rank_img:SetNativeSize() 
				self.rank_txt.text=data.rank_data[i].rank
			end
			if data.rank_data[i].player_id == MainModel.UserInfo.user_id then 
				b.transform:Find("BG"):GetComponent("Image").sprite = GetTexture("shyxb_bg_zj")
			else
				b.transform:Find("BG"):GetComponent("Image").enabled = false
			end 
			if i == 10 then return end 
		end
	end 
end

function C:onHistoryInfoGet(_,data)
	dump(data,"<color=red>onHistoryInfoGet</color>")	
	if data and data.result == 0 and IsEquals(self.gameObject) then 
		for i = 1, #data.rank_data do
			self.HistoryChild[i].gameObject:SetActive(true)
			self.HistoryMask[i].gameObject:SetActive(false)
			URLImageManager.UpdateHeadImage(data.rank_data[i].head_image,self.HistoryChild[i].transform:Find("Image"):GetComponent("Image"))
			self.HistoryChild[i].transform:Find("WinText"):GetComponent("Text").text= "赢得:"..StringHelper.ToCash(data.rank_data[i].award_money)
			self.HistoryChild[i].transform:Find("GoldText"):GetComponent("Text").text="投入:"..StringHelper.ToCash(data.rank_data[i].bet_money) 
			self.HistoryChild[i].transform:Find("DateText"):GetComponent("Text").text= os.date("%Y/%m/%d",data.rank_data[i].time) 
			self.HistoryChild[i].transform:Find("NameText"):GetComponent("Text").text=data.rank_data[i].name
			self.HistoryChild[i].transform:Find("GoldText"):GetComponent("Text").gameObject:SetActive(false)
			if i == 3 then return end 
		end
	end 
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
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	--//
	self:InitLeftPanel()
	self:InitRightPanel()
	--//
	self:OnButtonClick()
	self:OnLeftButtonClick(1)
	self:SentQuery()
	self.dbtr = self.transform:Find("bg2/Image (9)/Text (2)")
	self.dbtr.gameObject:SetActive(false)
	self.infodbtr = self.info.transform:Find("BG/Image")
	self.infodbtr.gameObject:SetActive(false)
	self.num_txt.gameObject:SetActive(false)

	self.mybg = self.my_info.transform:Find("BG/Image")
	self.mybg.gameObject:SetActive(false)
	self.my_num_txt.gameObject:SetActive(false)	

	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
end


function C:SentQuery()
	Network.SendRequest("query_xiaoxiaole_shuihu_once_game_rank_base_info")
	Network.SendRequest("query_xiaoxiaole_shuihu_once_game_rank")
	Network.SendRequest("query_xiaoxiaole_shuihu_once_game_rank_history")
end



function C:InitUI()
	--找面板
	self.HelpPanel=self.transform:Find("HelpPanel")
	self.HistoryPanel=self.transform:Find("HistoryPanel")

	-- 找按鈕
	self.CloseButton=self.transform:Find("CloseButton"):GetComponent("Button")
	self.SMButton=self.transform:Find("SMButton"):GetComponent("Button")
	self.HistoryButton=self.transform:Find("HistoryButton"):GetComponent("Button")
	self.CloseHistory=self.HistoryPanel.transform:Find("Close"):GetComponent("Button")
	self.CloseHelp=self.HelpPanel.transform:Find("ImgPopupPanel/close_btn"):GetComponent("Button")

	--历史面板的子物体
	self.HistoryChild={}
	self.HistoryMask={}
	for i = 1, 3 do
		self.HistoryChild[i]=self.HistoryPanel.transform:Find(i)
		self.HistoryMask[i]=self.HistoryPanel.transform:Find("Mask"..i)
	end
	
end

--当按钮按下的时候
function C:OnButtonClick()
	self.CloseButton.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:MyExit()
		end
	)
	self.CloseHistory.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self.HistoryPanel.gameObject:SetActive(false)
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
	self.HistoryButton.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self.HistoryPanel.gameObject:SetActive(true)
		end
	)
end

function C:InitLeftPanel()
	self.Buttons={}
	for i = 1, 2 do
		local b = self.transform:Find("LeftPanel/Button"..i):GetComponent("Button")
		self.Buttons[i]=b
		b.onClick:AddListener(
			function ()
				self:OnLeftButtonClick(i)
			end
		)
	end
end

function C:InitRightPanel()
	self.Panels={}
	for i = 1, 2 do
		local b = self.transform:Find("RightPanel/Panel"..i)
		self.Panels[i]=b
	end
end


function C:OnLeftButtonClick(index)
	for i=1,#self.Buttons do
		self.Buttons[i].gameObject.transform:Find("Mask").gameObject:SetActive(true)
	end	
	self.Buttons[index].gameObject.transform:Find("Mask").gameObject:SetActive(false)
	for i=1,#self.Panels do
		self.Panels[i].gameObject:SetActive(false)
	end
	self.Panels[index].gameObject:SetActive(true)	
end
