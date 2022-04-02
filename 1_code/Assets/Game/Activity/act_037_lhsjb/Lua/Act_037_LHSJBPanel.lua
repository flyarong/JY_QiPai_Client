-- 创建时间:2020-10-27
-- Panel:Act_037_LHSJBPanel
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

Act_037_LHSJBPanel = basefunc.class()
local C = Act_037_LHSJBPanel
C.name = "Act_037_LHSJBPanel"

local M = Act_037_LHSJBManager

local HGList={
	[1] ="localpop_icon_1",
	[2] ="localpop_icon_2",
	[3] ="localpop_icon_3",
}
local Award={
	1000,300,100,30,30,30,20,20,20,20,10,10,10,10,10,5,5,5,5,5
}
local curr_index = 1

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
	self.lister["act_037_lhsjb_base_info_get"] = basefunc.handler(self,self.on_act_037_lhsjb_base_info_get)
	self.lister["query_rank_data_response"] = basefunc.handler(self,self.on_query_rank_data_response)
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
	local parent = parent or GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshPanel()
end

function C:onMyInfoGet()
	local data = M.GetRankData(M.base_types[curr_index])
	dump(data,"<color=red>GetRankData</color>")
	local json_data = json2lua(data.other_data)
	self.my1_name_txt.text = MainModel.UserInfo.name
	self.my2_name_txt.text = MainModel.UserInfo.name
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
		if data.rank == -1 then
			self["my"..curr_index.."_ranking_img"].gameObject:SetActive(false)
			self["my"..curr_index.."_rank2_txt"].text="未上榜"		
			self["my"..curr_index.."_award_txt"].text="- -"
		elseif data.rank < 4 then
			self["my"..curr_index.."_ranking_img"].enabled = true
			self["my"..curr_index.."_ranking_img"].sprite = GetTexture(HGList[data.rank])
			self["my"..curr_index.."_rank2_txt"].text = " "
			self["my"..curr_index.."_award_txt"].text =	Award[data.rank]
			self["my"..curr_index.."_ranking_img"]:SetNativeSize() 
		elseif data.rank <= 100 then 
			self["my"..curr_index.."_ranking_img"].enabled = false
			self["my"..curr_index.."_ranking_txt"].text = data.rank
			self["my"..curr_index.."_rank2_txt"].text = " "
			self["my"..curr_index.."_award_txt"].text =	Award[data.rank]
			self["my"..curr_index.."_ranking_img"]:SetNativeSize() 
		else
			self["my"..curr_index.."_ranking_img"].gameObject:SetActive(false)
			self["my"..curr_index.."_rank2_txt"].text = "未上榜"
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
			self["I"..curr_index.."_name_txt"].text = data.rank_data[i].name
			self["I"..curr_index.."_award_txt"].text = Award[data.rank_data[i].rank]
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
				self["I"..curr_index.."_rank_img"].enabled = true
				self["I"..curr_index.."_rank_img"].sprite = GetTexture(HGList[data.rank_data[i].rank])
				self["I"..curr_index.."_rank_img"]:SetNativeSize()
				self.goto_btn.gameObject:SetActive(true)
			else
				self["I"..curr_index.."_rank_img"].enabled = false
				self["I"..curr_index.."_rank_txt"].text = data.rank_data[i].rank
			end
			if math.fmod(i,2) == 1 then
				self["I"..curr_index.."_info1_img"].gameObject:SetActive(false)
			else
				self["I"..curr_index.."_info1_img"].gameObject:SetActive(true)
			end
			if data.rank_data[i].player_id	== MainModel.UserInfo.user_id then
				--自己不一样
				self["I"..curr_index.."_info1_mask"].gameObject:SetActive(true)
			end
			if i == 20 then return end 			
		end
		if table_is_null(data.rank_data) then 
			LittleTips.Create("暂无新数据")
		end 
	end 
end

function C:on_act_037_lhsjb_base_info_get()	
	self:onMyInfoGet()
end

function C:on_query_rank_data_response(_,data)
	if data and data.result == 0 then
		if data.rank_type == M.base_types[curr_index] then
			self:onInfoGet(data)
		end
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

function C:OnDestroy()
    self:MyExit()
end