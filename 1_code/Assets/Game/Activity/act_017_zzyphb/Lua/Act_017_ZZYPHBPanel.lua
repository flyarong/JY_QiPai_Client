local basefunc = require "Game/Common/basefunc"

Act_017_ZZYPHBPanel = basefunc.class()
local C = Act_017_ZZYPHBPanel
C.name = "Act_017_ZZYPHBPanel"
local M = Act_017_ZZYPHBManager
local HGList={
	[1] ="localpop_icon_1",
	[2] ="localpop_icon_2",
	[3] ="localpop_icon_3",
}
local Award={
	200,100,50,30,30,30,20,20,20,20,10,10,10,10,10,5,5,5,5,5
}
local base_txt = {
	[1] = {"街机捕鱼中500及以上炮倍击杀粽子Boss鱼记录击杀倍数,参与排行榜"," "},
}
local curr_index = 1
local DESCRIBE_TEXT = {
	[1] = "1.活动时间：6月23日7:30-6月29日23:59:5",
	[2] = "2.活动期间街机捕鱼中500及以上炮倍击杀粽子鱼获得击杀倍数，累加有效的击杀倍数参与排行榜",
	[3] = "3.倍数越大排名越靠前，倍数相同时，上班时间越早排名越靠前",
	[4] = "4.活动结束后，排行榜奖励通过邮件发放，请注意查收",
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
	self.lister["act_012_byphb_base_info_get"] = basefunc.handler(self,self.on_act_012_byphb_base_info_get)
	self.lister["query_rank_data_response"] = basefunc.handler(self,self.on_query_rank_data_response)
end

function C:onMyInfoGet()
	local data = M.GetRankData(M.base_types[curr_index])
	dump(data,"<color=red>GetRankData</color>")
	if not data then return end
	local json_data = json2lua(data.other_data)
	self.my1_name_txt.text=MainModel.UserInfo.name
	self.my2_name_txt.text=MainModel.UserInfo.name
	if data and data.result ==  0 and IsEquals(self.gameObject)  then
		self["my"..curr_index.."_num_txt"].text = data.score
		dump(json_data,"<color=red>json_datajson_datajson_data</color>")
		if not json_data then
			self["my"..curr_index.."_get_txt"].text = 0
		else
			self["my"..curr_index.."_get_txt"].text = json_data.gun_rate
		end
		self["my"..curr_index.."_ranking_img"].gameObject:SetActive(true)
		self["my"..curr_index.."_ranking_txt"].text= " "
		if data.rank==-1 then
			self["my"..curr_index.."_ranking_img"].gameObject:SetActive(false)
			self["my"..curr_index.."_rank2_txt"].text="未上榜"		
			self["my"..curr_index.."_award_txt"].text="--"	
		elseif data.rank < 4 then
			self["my"..curr_index.."_ranking_img"].sprite=GetTexture(HGList[data.rank])
			self["my"..curr_index.."_rank2_txt"].text=" "
			self["my"..curr_index.."_award_txt"].text=	Award[data.rank]
			self["my"..curr_index.."_ranking_img"]:SetNativeSize() 
		elseif data.rank <= 100 then 
			self["my"..curr_index.."_ranking_txt"].text=data.rank
			self["my"..curr_index.."_ranking_img"].sprite=GetTexture("localpop_icon_ranking")
			self["my"..curr_index.."_rank2_txt"].text=" "
			self["my"..curr_index.."_award_txt"].text=	Award[data.rank]
			self["my"..curr_index.."_ranking_img"]:SetNativeSize() 
		else
			self["my"..curr_index.."_ranking_img"].gameObject:SetActive(false)
			self["my"..curr_index.."_rank2_txt"].text="未上榜"
		end  
	end 
end

function C:onInfoGet(data)
	if data and data.result ==0 and IsEquals(self.gameObject) then 
		for i = 1, #data.rank_data do
			local json_data = json2lua(data.rank_data[i].other_data)
			dump(json_data,"<color=red>other_data</color>")
			local b = GameObject.Instantiate(self["info"..curr_index],self.content)
			LuaHelper.GeneratingVar(b.transform, self)
			b.gameObject:SetActive(true)
			self["I"..curr_index.."_name_txt"].text=data.rank_data[i].name
			self["I"..curr_index.."_award_txt"].text=Award[data.rank_data[i].rank]
			self["I"..curr_index.."_num_txt"].text = data.rank_data[i].score
			self.goto_btn.onClick:AddListener(
				function ()
					GameManager.GotoUI({gotoui = "game_FishingHall"})
				end
			)
			self.goto_btn.gameObject:SetActive(false)
			-- self.num_txt.text = StringHelper.ToCash(json_data.bet_spend)
			if json_data then
				self["I"..curr_index.."_get_txt"].text = json_data.gun_rate
			end
			if data.rank_data[i].rank < 4 then
				self["I"..curr_index.."_rank_img"].sprite=GetTexture(HGList[data.rank_data[i].rank])
				self["I"..curr_index.."_rank_img"]:SetNativeSize()
				self.goto_btn.gameObject:SetActive(true)
			else
				self["I"..curr_index.."_rank_img"].sprite=GetTexture("localpop_icon_ranking")
				self["I"..curr_index.."_rank_img"]:SetNativeSize() 
				self["I"..curr_index.."_rank_txt"].text=data.rank_data[i].rank
			end
			if math.fmod(i,2) == 1 then
				self["I"..curr_index.."_info1_img"].gameObject:SetActive(false)
			else
				self["I"..curr_index.."_info1_img"].gameObject:SetActive(true)
			end
			if i == 20 then return end 			
		end
		if table_is_null(data.rank_data) then 
			LittleTips.Create("暂无新数据")
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

function C:ctor(parent)
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	--//
	self:OnButtonClick()
	self:SwitchButton(1)
	self.b2.gameObject:SetActive(false)
end

function C:InitUI()

end

--当按钮按下的时候
function C:OnButtonClick()
	self.help_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:OpenHelpPanel()
		end
	)
	for i = 1,2 do
		self["b"..i.."_btn"].onClick:AddListener(
			function ()
				self:SwitchButton(i)
			end
		)
	end
end

function C:OnDestroy()
	self:MyExit()
end

function C:on_act_012_byphb_base_info_get()
	self:onMyInfoGet()
end

function C:on_query_rank_data_response(_,data)
	dump(data,"<color=red>排行榜数据--</color>")
	if data and data.result == 0 then
		if data.rank_type == M.base_types[curr_index] then
			self:onInfoGet(data)
		end
	end
end

function C:SwitchButton(index)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	for i = 1,2 do
		self["b"..i.."_mask"].gameObject:SetActive(false)
	end
	self["b"..index.."_mask"].gameObject:SetActive(true)
	curr_index = index
	self:RefreshText()
	self:RefreshPanel()
end

function C:RefreshText()
	for i = 1,#base_txt[curr_index] do
		self["tips"..i.."_txt"].text = base_txt[curr_index][i]
	end
end

function C:RefreshPanel()
	self.page_index = 1
	--目前只需要有1页，20个
	destroyChildren(self.content)
	Network.SendRequest("query_rank_data",{rank_type = M.base_types[curr_index],page_index = self.page_index})
	M.QueryMyData(M.base_types[curr_index])
	for i = 1,2 do
		self["node"..i].gameObject:SetActive(false)
		self["my"..i.."_info"].gameObject:SetActive(false)
	end
	self["node"..curr_index].gameObject:SetActive(true)
	self["my"..curr_index.."_info"].gameObject:SetActive(true)
end

function C:OpenHelpPanel()
    local str = DESCRIBE_TEXT[1]
    for i = 2, #DESCRIBE_TEXT do
        str = str .. "\n" .. DESCRIBE_TEXT[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end