-- 创建时间:2019-09-03
-- Panel:Act_011_XXLPHBPanel
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

Act_011_XXLPHBPanel = basefunc.class()
local C = Act_011_XXLPHBPanel
C.name = "Act_011_XXLPHBPanel"
local M = Act_011_XXLPHBManager
local HGList={
	[1] ="localpop_icon_1",
	[2] ="localpop_icon_2",
	[3] ="localpop_icon_3",
}
local Award={
	200,100,50,30,30,30,20,20,20,20,10,10,10,10,10,5,5,5,5,5
}
local base_txt = {
	[1] = {"单笔投入越高,上榜的机会越大!","任意消消乐游戏任意档次,可参与赢金榜排名"},
	[2] = {"倍数相同时,单笔投入越高越排在前面","任意消消乐游戏3万及以上档次,可参与倍数榜排名"}
}
local str2gameName = {
	xiaoxiaole_award = "水果消消乐",
	xiaoxiaole_shuihu_award = "水浒消消乐",
	xiaoxiaole_caishen_award = "财神消消乐",
}
local str2gameName_rate = {
	xiaoxiaole_award_rate = "水果消消乐",
	xiaoxiaole_shuihu_award_rate = "水浒消消乐",
	xiaoxiaole_caishen_award_rate = "财神消消乐",
}
local curr_index = 1
local DESCRIBE_TEXT = {
	[1] = "1.活动时间：5月12日7:00-5月18日23:59:59",
	[2] = "2.活动期间玩水果消消乐、水浒消消乐和财神消消乐都可以参与排行榜",
	[3] = "3.单笔倍数榜中只记录3万及以上档次的单笔赢金倍数，倍数相同时，档次越高排名越靠前",
	[4] = "4.排行榜中数据都相同时，上榜时间越早排名越靠前",
	[5] = "5.活动结束后，排行榜奖励通过邮件发放，请注意查收",
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
	self.lister["act_011_xxlphb_base_info_get"] = basefunc.handler(self,self.on_act_011_xxlphb_base_info_get)
	self.lister["query_rank_data_response"] = basefunc.handler(self,self.on_query_rank_data_response)
end

function C:onMyInfoGet()
	local data = M.GetRankData(M.base_types[curr_index])
	dump(data,"<color=red>GetRankData</color>")
	local json_data = json2lua(data.other_data)
	self.my_name_txt.text=MainModel.UserInfo.name
	if data and data.result ==  0 and IsEquals(self.gameObject)  then
		self.my_get_txt.text = M.base_types[curr_index] == "20_4_xiaoxiaole_danbi_yingjin_rank" and StringHelper.ToCash(data.score) or string.format("%.2f",(tonumber(data.score))/100) 
		if json_data then
			self.my_num_txt.text=StringHelper.ToCash(json_data.bet_spend)
			self.my_game_name_txt.text = str2gameName[json_data.source_type] or str2gameName_rate[json_data.source_type]
		else
			self.my_num_txt.text= 0
			self.my_game_name_txt.text = "--"
		end
		self.my_ranking_img.gameObject:SetActive(true)
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
		elseif data.rank <= 100 then 
			self.my_ranking_txt.text=data.rank
			self.my_ranking_img.sprite=GetTexture("localpop_icon_ranking")
			self.my_rank2_txt.text=" "
			self.my_award_txt.text=	Award[data.rank]
			self.my_ranking_img:SetNativeSize() 
		else
			self.my_ranking_img.gameObject:SetActive(false)
			self.my_rank2_txt.text="未上榜"
		end  
	end 
end

function C:onInfoGet(data)
	if data and data.result ==0 and IsEquals(self.gameObject) then 
		for i = 1, #data.rank_data do
			local json_data = json2lua(data.rank_data[i].other_data)
			dump(json_data,"<color=red>other_data</color>")
			if json_data then
				local b = GameObject.Instantiate(self.info,self.content)
				LuaHelper.GeneratingVar(b.transform, self)
				b.gameObject:SetActive(true)
				self.jinb = b.transform:Find("Image (1)")
				self.jinb.gameObject:SetActive(false)
				self.name_txt.text=data.rank_data[i].name
				self.num_txt.gameObject:SetActive(false)
				self.award_txt.text=Award[data.rank_data[i].rank]
				self.game_name_txt.text =  str2gameName[json_data.source_type] or str2gameName_rate[json_data.source_type]
				self.get_txt.text = M.base_types[curr_index] == "20_4_xiaoxiaole_danbi_yingjin_rank" and StringHelper.ToCash(data.rank_data[i].score) or string.format("%.2f",(tonumber(data.rank_data[i].score))/100) 
				self.num_txt.text = StringHelper.ToCash(json_data.bet_spend)
				if data.rank_data[i].rank < 4 then
					self.rank_img.sprite=GetTexture(HGList[data.rank_data[i].rank])
					self.rank_img:SetNativeSize() 
				else
					self.rank_img.sprite=GetTexture("localpop_icon_ranking")
					self.rank_img:SetNativeSize() 
					self.rank_txt.text=data.rank_data[i].rank
				end
				if data.rank_data[i].player_id == MainModel.UserInfo.user_id then 
					self.info1_img.sprite = GetTexture("xxldz_bg_7")
					self.info2_img.sprite = GetTexture("xxldz_bg_5")
					self.name_txt.color = Color.New(195/255,123/255,1/255)
					self.num_txt.color = Color.New(195/255,123/255,1/255)
					self.get_txt.color = Color.New(195/255,123/255,1/255)
					self.award_txt.color = Color.New(195/255,123/255,1/255)
					self.game_name_txt.color = Color.New(195/255,123/255,1/255)
				end 
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
	self.t4_txt.gameObject:SetActive(false)
	self.myjbImg = self.transform:Find("@my_info/BG/Image")
	self.myjbImg.gameObject:SetActive(false)
	self.my_num_txt.gameObject:SetActive(false)

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

function C:on_act_011_xxlphb_base_info_get()
	self:onMyInfoGet()
end

function C:on_query_rank_data_response(_,data)
	dump(data,"<color=red>消消乐排行榜数据--</color>")
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
	self.t5_txt.text = curr_index == 1 and "获得赢金" or "获得倍数"
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
end

function C:OpenHelpPanel()
    local str = DESCRIBE_TEXT[1]
    for i = 2, #DESCRIBE_TEXT do
        str = str .. "\n" .. DESCRIBE_TEXT[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end