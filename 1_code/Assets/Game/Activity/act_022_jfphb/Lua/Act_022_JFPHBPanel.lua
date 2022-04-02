-- 创建时间:2020-05-25
-- Panel:Act_022_JFPHBPanel
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

Act_022_JFPHBPanel = basefunc.class()
local C = Act_022_JFPHBPanel
C.name = "Act_022_JFPHBPanel"
local M = Act_022_JFPHBManager
local HGList={
	[1] ="localpop_icon_1",
	[2] ="localpop_icon_2",
	[3] ="localpop_icon_3",
}
local Award={
	1000,300,100,50,30,30,20,20,20,20,10,10,10,10,10,5,5,5,5,5
}
local base_txt = {
	[1] = {"任意消消乐游戏<color=yellow><size=35>3万</size></color>及以上档次且获得倍数大于等于5倍，可参与排行榜","活动时间：7月7日7:30-7月13日23:59:59"},
}
local type_color = {
	sgxxl = Color.New(228/255,253/255,255/255),--水果消消乐
	sgxxl_outline = Color.New(73/255,91/255,201/255),
	shxxl = Color.New(250/255,237/255,255/255),--水浒消消乐
	shxxl_outline = Color.New(201/255,73/255,199/255),
	csxxl = Color.New(255/255,237/255,237/255),--财神消消乐
	csxxl_outline = Color.New(201/255,63/255,15/255),
}
local curr_index = 1
local DESCRIBE_TEXT = {
	[1] = "1.活动时间：7月7日7:30-7月13日23:59:59",
	[2] = "2.活动期间玩任意消消乐游戏3万及以上档次且获得倍数大于等于5倍，可参与排行榜",
	[3] = "3.所有满足条件的倍数，按游戏分类求和，倍数越大排名越靠前",
	[4] = "4.倍数相同时，上榜时间越早排名越靠前",
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
    self.lister["act_015_xxlbd_base_info_get"] = basefunc.handler(self,self.on_act_015_xxlbd_base_info_get)
    self.lister["query_rank_data_response"] = basefunc.handler(self,self.on_query_rank_data_response)
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
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
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnDestroy()
	self:MyExit()
end

function C:onMyInfoGet()
	local data = M.GetRankData(M.base_types[curr_index])
	dump(data,"<color=green>GetRankData</color>")
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
			if json_data.source_type == "xiaoxiaole_award_rate" then
				txt = "水果消消乐"
				color1 = type_color["sgxxl"]
				color2 = type_color["sgxxl_outline"]
			elseif json_data.source_type == "xiaoxiaole_shuihu_award_rate" then
				txt = "水浒消消乐"
				color1 = type_color["shxxl"]
				color2 = type_color["shxxl_outline"]
			elseif json_data.source_type == "xiaoxiaole_caishen_award_rate" then
				txt = "财神消消乐"
				color1 = type_color["csxxl"]
				color2 = type_color["csxxl_outline"]
			end
			self.my1_game_type_txt.gameObject:SetActive(true)
			self.my1_game_type_txt.text = txt
			self.my1_game_type_txt.color = color1
			self.my1_game_type_txt.transform:GetComponent("Outline").effectColor = color2
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
	dump("<color>+++++++++++++++++++++++++++++++</color>")
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
			if json_data then
				local txt = ""
				local color = Color.New(0,0,0)
				if json_data.source_type == "xiaoxiaole_award_rate" then
					txt = "水果消消乐"
					color1 = type_color["sgxxl"]
					color2 = type_color["sgxxl_outline"]
				elseif json_data.source_type == "xiaoxiaole_shuihu_award_rate" then
					txt = "水浒消消乐"
					color1 = type_color["shxxl"]
					color2 = type_color["shxxl_outline"]
				elseif json_data.source_type == "xiaoxiaole_caishen_award_rate" then
					txt = "财神消消乐"
					color1 = type_color["csxxl"]
					color2 = type_color["csxxl_outline"]
				end
				self["I"..curr_index.."_game_type_txt"].text = txt
				self["I"..curr_index.."_game_type_txt"].color = color1
				self["I"..curr_index.."_game_type_txt"].transform:GetComponent("Outline").effectColor = color2
			end
			-- self.num_txt.text = StringHelper.ToCash(json_data.bet_spend)
			if json_data then
				self["I"..curr_index.."_get_txt"].text = json_data.gun_rate
			end
			if data.rank_data[i].rank < 4 then
				self["I"..curr_index.."_rank_img"].sprite=GetTexture(HGList[data.rank_data[i].rank])
				self["I"..curr_index.."_rank_img"]:SetNativeSize()
				self.I1_goto_zjf_btn.gameObject:SetActive(true)
				self.I1_goto_zjf_btn.onClick:AddListener(function ()
					--跳转到"我要赚积分"界面
					ActivityYearPanel.Close()
					ActivityYearPanel.Create(nil,nil,{ID = 111})
				end)
			else
				self["I"..curr_index.."_rank_img"].transform:GetComponent("Image").enabled = false
				--self["I"..curr_index.."_rank_img"]:SetNativeSize() 
				self["I"..curr_index.."_rank_txt"].text=data.rank_data[i].rank
			end
			--[[if math.fmod(i,2) == 1 then
				self["I"..curr_index.."_info1_img"].gameObject:SetActive(false)
			else
				self["I"..curr_index.."_info1_img"].gameObject:SetActive(true)
			end--]]
				
			if i == 20 then return end 				
			if data.rank_data[i].rank >= 1 and data.rank_data[i].rank <= 20 then
			    local pre = self.content.transform:GetChild(data.rank_data[i].rank - 1)
			    local pre_ = pre.transform:GetChild(0)
				local pre1 = pre_.transform:GetChild(0)
				local img = pre1.transform:GetComponent("Image")
			    if data.rank_data[i].rank%2 == 0 then
			    	dump(data.rank_data[i].rank,"<color=green>++++++++++()()()+++++++++++++</color>")
			    	img.sprite = GetTexture("jfphb_bg_4")
			    else	
			    	img.sprite = GetTexture("jfphb_bg_2")
			    end	
			    if data.rank_data[i].player_id	== MainModel.UserInfo.user_id then
			    	--自己不一样
			    	img.sprite = GetTexture("bzzy_bg_bzzy2")
				end
				img = nil
			end		    
		end
		if table_is_null(data.rank_data) then 
			LittleTips.Create("暂无新数据")
		end 
	end 
end


function C:on_act_015_xxlbd_base_info_get()
	dump("<color>+++++++++++++++++++++++++++++++</color>")
	self:onMyInfoGet()
end


function C:on_query_rank_data_response(_,data)
	dump(data,"<color=red>消消乐榜单数据--</color>")
	if data and data.result == 0 then
		if data.rank_type == M.base_types[curr_index] then
			self:onInfoGet(data)
		end
	end
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
	--[[for i = 1,#base_txt[curr_index] do
		self["tips"..i.."_txt"].text = base_txt[curr_index][i]
	end--]]
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

