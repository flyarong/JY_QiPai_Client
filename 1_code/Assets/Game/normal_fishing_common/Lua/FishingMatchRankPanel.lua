-- 创建时间:2019-05-29
-- Panel:FishingMatchRankPanel
local basefunc = require "Game/Common/basefunc"

FishingMatchRankPanel = basefunc.class()
local C = FishingMatchRankPanel
C.name = "FishingMatchRankPanel"
local config

function C.Create(parm)
	return C.New(parm)
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
    self.lister["fsmg_match_gaming_rank_data_response"] = basefunc.handler(self, self.fsmg_match_gaming_rank_data_response)
    self.lister["fsmg_my_match_gaming_rank_data_response"] = basefunc.handler(self, self.fsmg_my_match_gaming_rank_data_response)
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

function C:ctor(parm)

	ExtPanel.ExtMsg(self)

	self.parm = parm
	config = FishingManager.GetGameIDToAward(self.parm.game_id)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
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

    self.ui.hint_no_money.gameObject:SetActive(false)

	self.ui.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)

	self.ui.hint_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self.ui.hint.gameObject:SetActive(true)
	end)

	self.ui.hint_close_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self.ui.hint.gameObject:SetActive(false)
	end)

	self.ui.sv = self.ui.ScrollView:GetComponent("ScrollRect")
	EventTriggerListener.Get(self.ui.sv.gameObject).onEndDrag = function()
		local VNP = self.ui.sv.verticalNormalizedPosition
		if VNP <= 0 then
			self:RefreshRankInfo()		
		end
	end
	self.ui.my_not_rank_txt.gameObject:SetActive(false)
	self.ui.my_ranking_img.gameObject:SetActive(false)
	self.ui.my_ranking_img1.gameObject:SetActive(false)

	self:RefreshRankInfo()
	self:RefreshRankInfoMy()
end

function C:MyRefresh()

end

function C:OnBackClick()
	self:MyExit()
end

function C:onAssetChange()
end

function C:onExitScene()
	self:MyExit()
end

function C:RefreshRankInfo()
	Network.SendRequest("fsmg_match_gaming_rank_data",  {index = self.data.query_index},"请求数据")
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
			t.ranking_img1.gameObject:SetActive(false)
			t.rank_txt.text = ""
		else
			t.ranking_img.gameObject:SetActive(false)
			t.ranking_img1.gameObject:SetActive(true)
			t.rank_txt.text = v.rank
		end
		
		t.name_txt.text = basefunc.deal_hide_player_name(v.player_name)
		t.num_txt.text = StringHelper.ToCash(v.grades)
		local award = C.GetAwardByRank(config,v.rank)

		if not award then
			t.award_txt.text = ""
		else
			if award.award then
				if award.extra_award_desc then
					local dd = string.format("%.1f", award.extra_award_desc * 100)
					t.award_txt.text = award.award .. "+额外" .. dd .. "%的奖池金"
				else
					t.award_txt.text = award.award
				end
			else
				if award.extra_award_desc then
					local dd = string.format("%.1f", award.extra_award_desc * 100)
					t.award_txt.text = "" .. dd .. "%的奖池金"
				else
					t.award_txt.text = ""
				end
			end
		end

		if v.player_id == MainModel.UserInfo.user_id then
			t.name_txt.text = MainModel.UserInfo.name
			t.bg_img.sprite = GetTexture("bydrb_bg_zj2")
			local outLine = t.num_txt.transform:GetComponent("Outline")
			outLine.effectColor = Color.New(106/255,16/255,169/255,1)
			local outLine1 = t.award_txt.transform:GetComponent("Outline")
			outLine1.effectColor = Color.New(106/255,16/255,169/255,1)
			t.name_txt.text = string.format("<color=white>%s</color>",t.name_txt.text)
		end

		obj.transform:SetSiblingIndex(v.rank - 1)
		obj.gameObject:SetActive(true)
	end
end

function C:RefreshRankInfoMy()
	self.ui.my_name_txt.text = MainModel.UserInfo.name
	Network.SendRequest("fsmg_my_match_gaming_rank_data", nil, "请求数据")
end

function C.GetAwardByRank(cfg,rank)
	if not cfg or not next(cfg) or not rank or type(rank) ~= "number" then return end
	for i,v in ipairs(cfg) do
		 if rank >= v.min_rank and rank <= v.max_rank then
			return v
		 end
	end
end

function C:fsmg_match_gaming_rank_data_response(_, data)
	dump(data, "<color=white>排名数据</color>")
	if data.result == 0 then
		if not next(data.rank_list) then
			LittleTips.Create("暂无新数据")
			return
		end
		FishingMatchModel.CacheRankData(data.rank_list, self.data.query_index)
		self.data.rank_data = self.data.rank_data or {}
		self.data.rank_data[self.data.query_index] = data.rank_list
		self.data.query_index = self.data.query_index + 1
		self:CreateRankItems(data.rank_list)
	else
		local rank_list = FishingMatchModel.GetRankData(self.data.query_index)
		if rank_list then
			self.data.rank_data = self.data.rank_data or {}
			self.data.rank_data[self.data.query_index] = rank_list
			self.data.query_index = self.data.query_index + 1
			self:CreateRankItems(rank_list)
		end
	end
end

function C:fsmg_my_match_gaming_rank_data_response(_, data)
	dump(data, "<color=yellow>我的排名</color>")
	self.ui.my_not_rank_txt.gameObject:SetActive(false)
	self.ui.my_ranking_img.gameObject:SetActive(false)
	self.ui.my_ranking_img1.gameObject:SetActive(false)
	if data.result ~= 0 then
		local my_rank = FishingMatchModel.GetMyRankData()
		if my_rank then
			data.result = 0
			data.my_rank = my_rank
		end
	else
		FishingMatchModel.CacheMyRankData(data.my_rank)
	end

	if data.result == 0 and data.my_rank then
		if data.my_rank.rank == -1 then
			self.ui.my_rank_txt.text = "99+"
			self.ui.my_award_txt.text = "--"
			self.ui.my_ranking_img.gameObject:SetActive(false)
			self.ui.my_ranking_img1.gameObject:SetActive(true)
		else
			self.ui.my_not_rank_txt.gameObject:SetActive(false)
			if data.my_rank.rank < 4 then
				self.ui.my_ranking_img.sprite = GetTexture("localpop_icon_" .. data.my_rank.rank)
				self.ui.my_ranking_img.gameObject:SetActive(true)
				self.ui.my_ranking_img1.gameObject:SetActive(false)
				self.ui.my_rank_txt.text = ""
			elseif data.my_rank.rank < 100 then
				self.ui.my_rank_txt.text = data.my_rank.rank
				self.ui.my_ranking_img.gameObject:SetActive(false)
				self.ui.my_ranking_img1.gameObject:SetActive(true)
			else
				self.ui.my_rank_txt.text = "99+"
				self.ui.my_ranking_img.gameObject:SetActive(false)
				self.ui.my_ranking_img1.gameObject:SetActive(true)
			end
			
			local award = C.GetAwardByRank(config,data.my_rank.rank)
			if award then
				if award.award then
					if award.extra_award_desc then
						local dd = string.format("%.1f", award.extra_award_desc * 100)
						self.ui.my_award_txt.text = award.award .. "+额外" .. dd .. "%的奖池金"
					else
						self.ui.my_award_txt.text = award.award
					end
				else
					if award.extra_award_desc then
						local dd = string.format("%.1f", award.extra_award_desc * 100)
						self.ui.my_award_txt.text = "" .. dd .. "%的奖池金"
					else
						self.ui.my_award_txt.text = "--"
					end
				end
			else
				self.ui.my_award_txt.text = "--"
			end
		end
		self.ui.my_num_txt.text = StringHelper.ToCash(data.my_rank.grades)
	else
		self.ui.my_not_rank_txt.gameObject:SetActive(true)
		self.ui.my_award_txt.text = "--"
		self.ui.my_num_txt.text = 0
	end 
end