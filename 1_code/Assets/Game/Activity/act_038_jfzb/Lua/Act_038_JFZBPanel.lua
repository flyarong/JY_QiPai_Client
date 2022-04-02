local basefunc = require "Game/Common/basefunc"

Act_038_JFZBPanel = basefunc.class()
local C = Act_038_JFZBPanel
C.name = "Act_038_JFZBPanel"
local M = Act_038_JFZBManager
local HGList={
	[1] ="localpop_icon_1",
	[2] ="localpop_icon_2",
	[3] ="localpop_icon_3",
}
local Award={
	400,150,50,22,22,22,12,12,12,12,6,6,6,6,6,3,3,3,3,3
}
local curr_index = 1
local DESCRIBE_TEXT = {
	"1.活动时间：9月21日7:30~9月27日23:59:59",
	"2.活动结束后，所有的道具将被全部清除，请及时兑换",
	"3.购买“积分礼包”后兑换时可获得额外积分奖励",
	"4.积分可参与“积分争霸”排行榜活动，活动结束后排行榜奖励通过邮件发放",
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
	self.lister["act_038_base_info_get"] = basefunc.handler(self,self.on_act_038_base_info_get)
	self.lister["query_rank_data_response"] = basefunc.handler(self,self.on_query_rank_data_response)
end

function C:onMyInfoGet()
	if not IsEquals(self.gameObject) then return end
	local data = M.GetRankData(M.base_type)
	dump(data,"<color=red>GetRankData</color>")
	local json_data = json2lua(data.other_data)
	self.my1_name_txt.text=MainModel.UserInfo.name
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
			self["my"..curr_index.."_award_ext_txt"].text="--"	
			self["my"..curr_index.."_award_ext2_mask"].gameObject:SetActive(true)
			self["my"..curr_index.."_award_ext_mask"].gameObject:SetActive(true)
		elseif data.rank < 4 then
			self["my"..curr_index.."_ranking_img"].sprite=GetTexture(HGList[data.rank])
			self["my"..curr_index.."_rank2_txt"].text=" "
			self["my"..curr_index.."_award_txt"].text =	Award[data.rank]
			self["my"..curr_index.."_award_ext_txt"].text =	self.extCfg[data.rank].ext_award_num[1]
			self["my"..curr_index.."_ranking_img"]:SetNativeSize() 

			local ext2Condi = self.extCfg[data.rank].ext_award_condi
			if tonumber(data.score) < ext2Condi then
				self["my"..curr_index.."_award_ext2_mask"].gameObject:SetActive(true)
				self["my"..curr_index.."_award_ext_mask"].gameObject:SetActive(true)
			end
		elseif data.rank <= 20 then 
			self["my"..curr_index.."_ranking_txt"].text=data.rank
			self["my"..curr_index.."_ranking_img"].sprite = GetTexture("localpop_icon_ranking")
			self["my"..curr_index.."_rank2_txt"].text = " "
			self["my"..curr_index.."_award_txt"].text =	Award[data.rank]
			self["my"..curr_index.."_award_ext_txt"].text =	self.extCfg[data.rank].ext_award_num[1]
			self["my"..curr_index.."_ranking_img"]:SetNativeSize() 
			local ext2Condi = self.extCfg[data.rank].ext_award_condi
			if tonumber(data.score) < ext2Condi then
				self["my"..curr_index.."_award_ext2_mask"].gameObject:SetActive(true)
				self["my"..curr_index.."_award_ext_mask"].gameObject:SetActive(true)
			end
		else
			self["my"..curr_index.."_ranking_img"].gameObject:SetActive(false)
			self["my"..curr_index.."_rank2_txt"].text="未上榜"
			self["my"..curr_index.."_award_txt"].text="--"	
			self["my"..curr_index.."_award_ext_txt"].text="--"	
		end  
	end 
end

function C:onInfoGet(data)
	if data and data.result ==0 and IsEquals(self.gameObject) then 
		for i = 1, #data.rank_data do
			local json_data = json2lua(data.rank_data[i].other_data)
			-- dump(json_data,"<color=red>other_data</color>")
			local b = GameObject.Instantiate(self["info"..curr_index],self.content)
			LuaHelper.GeneratingVar(b.transform, self)
			b.gameObject:SetActive(true)
			self["I"..curr_index.."_name_txt"].text=data.rank_data[i].name
			self["I"..curr_index.."_award_txt"].text=Award[data.rank_data[i].rank]
			self["I"..curr_index.."_award_ext_txt"].text = self.extCfg[data.rank_data[i].rank].ext_award_num[1]
			local ext2Key = self.extCfg[data.rank_data[i].rank].ext_award[2]
			self["I"..curr_index.."_award_ext2_img"].sprite = GetTexture(GameItemModel.GetItemToKey(ext2Key).image)
			local score = data.rank_data[i].score
			self["I"..curr_index.."_num_txt"].text = data.rank_data[i].score
			local ext2Condi = self.extCfg[data.rank_data[i].rank].ext_award_condi
			if tonumber(score) < ext2Condi then
				self["I"..curr_index.."_award_ext2_mask"].gameObject:SetActive(true)
				self["I"..curr_index.."_award_mask"].gameObject:SetActive(true)
			end
			-- self.goto_btn.onClick:AddListener(
			-- 	function ()
			-- 		Event.Brocast("switch_change",1)					
			-- 	end
			-- )
			-- self.goto_btn.gameObject:SetActive(false)
			-- self.num_txt.text = StringHelper.ToCash(json_data.bet_spend)
			if json_data then
				self["I"..curr_index.."_get_txt"].text = json_data.gun_rate
			end
			if data.rank_data[i].rank < 4 then
				self["I"..curr_index.."_rank_img"].sprite=GetTexture(HGList[data.rank_data[i].rank])
				self["I"..curr_index.."_rank_img"]:SetNativeSize()
				-- self.goto_btn.gameObject:SetActive(true)
			else
				self["I"..curr_index.."_rank_img"].sprite=GetTexture("localpop_icon_ranking")
				self["I"..curr_index.."_rank_img"]:SetNativeSize() 
				self["I"..curr_index.."_rank_txt"].text=data.rank_data[i].rank
			end
			-- if math.fmod(i,2) == 1 then
			-- 	self["I"..curr_index.."_info1_img"].gameObject:SetActive(false)
			-- else
			-- 	self["I"..curr_index.."_info1_img"].gameObject:SetActive(true)
			-- end
			if data.rank_data[i].player_id == MainModel.UserInfo.user_id then
				self["I"..curr_index.."_info1_img"].gameObject:SetActive(true)
			else
				self["I"..curr_index.."_info1_img"].gameObject:SetActive(false)
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
	self.extCfg = M.GetExtCfg()
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:OnButtonClick()
	self:RefreshPanel()
	self.rank_info_btn.onClick:AddListener(function()
		self:OnRankInfoClick()
	end)
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
end

function C:OnDestroy()
	self:MyExit()
end

function C:on_act_038_base_info_get()
	self:onMyInfoGet()
end

function C:on_query_rank_data_response(_,data)
	dump(data,"<color=red>排行榜数据--</color>")
	if data and data.result == 0 then
		if data.rank_type == M.base_type then
			self:onInfoGet(data)
		end
	end
end

function C:RefreshPanel()
	self.page_index = 1
	--目前只需要有1页，20个
	destroyChildren(self.content)
	Network.SendRequest("query_rank_data",{rank_type = M.base_type,page_index = self.page_index})
	M.QueryMyData(M.base_type)
end

function C:OpenHelpPanel()
    local str = DESCRIBE_TEXT[1]
    for i = 2, #DESCRIBE_TEXT do
        str = str .. "\n" .. DESCRIBE_TEXT[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:OnRankInfoClick()
	local parent = GameObject.Find("Canvas/LayerLv4").transform
    local rank_info_obj = newObject("Act_Ty_RankInfo_Ea",parent)
    self.rank_info_ui = {}
    self.rank_info_ui.transform = rank_info_obj.transform
    self.rank_info_ui.gameObject = rank_info_obj

    LuaHelper.GeneratingVar(rank_info_obj.transform, self.rank_info_ui)
    local info_data = self.extCfg

    for i = 1, #info_data do
        local b = GameObject.Instantiate(self.rank_info_ui.info_item,self.rank_info_ui.Content)
        b.gameObject:SetActive(true)
        local temp_ui = {}
        LuaHelper.GeneratingVar(b.transform, temp_ui)
        temp_ui.arward_ext_txt.text = info_data[i].ext_award_num[1] .. " 福卡"
        temp_ui.arward_ext2_txt.text = info_data[i].ext_award_num[2] .. " ".. GameItemModel.GetItemToKey(info_data[i].ext_award[2]).name
        temp_ui.arward_ext_condi_txt.text = info_data[i].ext_award_condi_txt
        self:LoadRankNumUI(temp_ui.rank_txt,temp_ui.rank_icon_img,i)
    end
    self.rank_info_ui.back_btn.onClick:AddListener(function ()
        if self.rank_info_ui then
            -- dump("<color=white>-------------------------</color>")
            destroy(self.rank_info_ui.gameObject)
        else
            local my_panel = GameObject.Find("Act_Ty_RankInfo_Ea")
            if my_panel then
                destroy(my_panel.gameObject)
            end 
        end
    end)
end


function C:LoadRankNumUI(txt_obj,img_obj,_rank_data)

    if _rank_data > 0 then
        txt_obj.text = _rank_data
    else
        txt_obj.text = "未上榜"
    end

    if _rank_data >= 1 and  _rank_data <=3 then
        img_obj.gameObject:SetActive(true)
        txt_obj.gameObject:SetActive(false)
        img_obj.sprite = GetTexture(Act_Ty_RankManager.GetWinIcon(_rank_data))
        txt_obj.text = ""
    else
        img_obj.gameObject:SetActive(false)
        txt_obj.gameObject:SetActive(true)
    end
end