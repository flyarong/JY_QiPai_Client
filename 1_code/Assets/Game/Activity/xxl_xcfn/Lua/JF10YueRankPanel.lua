-- 创建时间:2019-07-17
-- Panel:SummerJFRankPanel
local basefunc = require "Game/Common/basefunc"

JF10YueRankPanel = basefunc.class()
local C = JF10YueRankPanel
C.name = "JF10YueRankPanel"
local config

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
    self.lister["ExitScene"] = basefunc.handler(self, self.onExitScene)
    self.lister["AssetChange"] = basefunc.handler(self, self.onAssetChange)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	destroy(self.gameObject)
	self.data = nil
	self.ui = nil
	self:RemoveListener()

	 
end

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

	config = XXLXCFNManager.GetConfigRank()
	parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	self.ui = {}
	self.ui.transform = obj.transform
	self.ui.gameObject = obj
	self.gameObject = obj
	self.data = {}
	self.data.query_index = 1
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	LuaHelper.GeneratingVar(self.ui.transform, self.ui)
	self.ui.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)
	self.HelpPanel=self.ui.gameObject.transform:Find("HelpPanel")
	self.HelpButton=self.ui.gameObject.transform:Find("DescribeButton"):GetComponent("Button")
	self.HelpButton.onClick:AddListener(
		function ()
			self.HelpPanel.gameObject:SetActive(true)	
		end
	)
	self.CloseHelpPanelButton=self.ui.gameObject.transform:Find("HelpPanel/CloseButton"):GetComponent("Button")
	self.CloseHelpPanelButton.onClick:AddListener(
		function ()
			self.HelpPanel.gameObject:SetActive(false)	
		end
	)
	local e1 = os.date("%m月%d日%H点", config.main[1].end_time)
	self.ui.act_info_txt.text = string.format("累计获得积分大于1000才能上榜，%s结算排行榜。", e1)

	self.ui.sv = self.ui.ScrollView:GetComponent("ScrollRect")
	EventTriggerListener.Get(self.ui.sv.gameObject).onEndDrag = function()
		local VNP = self.ui.sv.verticalNormalizedPosition
		if VNP <= 0 then
			self:RefreshRankInfo()		
		end
	end
	self:RefreshRankInfo()
	self:RefreshRankInfoMy()
end

function C:MyRefresh()

end

function C:OnBackClick()
	self:MyExit()
end

function C:onAssetChange()
	--self:RefreshRankInfoMy()
	-- self:ClearRankInfo()
	-- self:RefreshRankInfo()
end

function C:onExitScene()
	self:MyExit()
end

function C:RefreshRankInfo()
	Network.SendRequest("query_rank_data",  {rank_type = "19_october_lottery_rank",page_index = self.data.query_index},"请求数据",function(data)
		dump(data, "<color=white>排名数据</color>")
		if data.result == 0 then
			if not next(data.rank_data) then
				LittleTips.Create("暂无新数据")
				return
			end
			self.data.rank_data = self.data.rank_data or {}
			self.data.rank_data[self.data.query_index] = data.rank_data
			self.data.query_index = self.data.query_index + 1
			self:CreateRankItems(data.rank_data)
		else
			HintPanel.ErrorMsg(data.result)
		end
	end)
end

function C:ClearRankInfo()
	self.data.rank_data = {}
	self.data.query_index = 1
	destroyChildren(self.ui.content)
end

function C:CreateRankItems(data)
	if not data or not next(data) then return end
	for i,v in ipairs(data) do
		local obj = GameObject.Instantiate(self.ui.info,self.ui.content)
		local t = {}
		LuaHelper.GeneratingVar(obj.transform,t)
		if v.rank < 4 then
			t.ranking_img.sprite = GetTexture("localpop_icon_" .. v.rank)
			t.ranking_img.gameObject:SetActive(true)
			t.ranking2_img.gameObject:SetActive(false)
			t.rank_txt.text = ""
		else
			t.ranking_img.gameObject:SetActive(false)
			t.ranking2_img.gameObject:SetActive(true)
			t.rank_txt.text = v.rank
		end
		
		t.name_txt.text = v.name
		if v.player_id == MainModel.UserInfo.user_id then
			t.name_txt.text = MainModel.UserInfo.name
			t.bg_img.sprite = GetTexture("jfranking_bg_zj1")
			local outLine = t.num_txt.transform:GetComponent("Outline")
			--outLine.effectColor = Color.New(106/255,16/255,169/255,1)
			local outLine1 = t.award_txt.transform:GetComponent("Outline")
			--outLine1.effectColor = Color.New(106/255,16/255,169/255,1)
			t.name_txt.text = string.format("<color=white>%s</color>",t.name_txt.text)
		end
		t.num_txt.text = v.score  
		local award = C.GetAwardByRank(config.awards,v.rank)
		if not award then
			t.award_txt.text = ""
		else
			t.award_txt.text = award.name
			if 	award.id>10 then 
				t.award_img.sprite=GetTexture("com_icon_gold")
			end 	
		end
		obj.transform:SetSiblingIndex(v.rank - 1)
		obj.gameObject:SetActive(true)
	end
end

function C:RefreshRankInfoMy()
	self.ui.my_name_txt.text = MainModel.UserInfo.name
	Network.SendRequest("query_rank_base_info",{rank_type = "19_october_lottery_rank"},"请求数据",function(data)
		dump(data, "<color=yellow>我的排名</color>")
		if data.result == 0 then
			if data.rank == -1 then
				self.ui.my_rank_txt.text = "未上榜"
				self.ui.my_award_txt.text = "— —"
				self.ui.my_num_txt.text = data.score  or 0
				self.ui.my_ranking_img.gameObject:SetActive(false)
			else
				if data.rank < 4 then
					self.ui.my_ranking_img.sprite = GetTexture("localpop_icon_" .. data.rank)
					self.ui.my_ranking_img.gameObject:SetActive(true)
					self.ui.my_rank_txt.text = ""
				else
					self.ui.my_rank_txt.text = data.rank
					self.ui.my_ranking_img.gameObject:SetActive(false)
				end
				
				local award = C.GetAwardByRank(config.awards,data.rank)
				if not award then
					self.ui.my_award_txt.text = ""
				else
					self.ui.my_award_txt.text = award.name		
					if 	award.id>10 then 
						self.ui.my_award_img.sprite=GetTexture("com_icon_gold")
					end 		
				end
			end
			self.ui.my_num_txt.text = data.score  
		else
			self.ui.my_rank_txt.text = "未上榜"
			self.ui.my_award_txt.text = ""
			self.ui.my_num_txt.text = data.score  or 0
			HintPanel.ErrorMsg(data.result)
		end 
	end)
end

function C.GetAwardByRank(cfg,rank)
	if not cfg or not next(cfg) or not rank or type(rank) ~= "number" then return end
	for i,v in ipairs(cfg) do
		 if rank >= v.start_rank and rank <= v.end_rank then
			return v
		 end
	end
end