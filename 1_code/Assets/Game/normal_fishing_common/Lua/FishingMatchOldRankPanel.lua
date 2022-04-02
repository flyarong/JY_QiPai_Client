-- 创建时间:2019-08-19
-- Panel:FishingMatchOldRankPanel
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
FishingMatchOldRankPanel = basefunc.class()
local C = FishingMatchOldRankPanel
C.name = "FishingMatchOldRankPanel"

local instance
function C.Create()
	if not instance then
		instance = C.New()
	end
	return instance
end
function C.Close()
	if instance then
		instance:MyExit()
	end
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["fsmg_match_rank_data_response"] = basefunc.handler(self, self.fsmg_match_rank_data_response)
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
	instance = nil

	 
end

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

    self.back_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBackClose()
    end)
    self.my_look_js_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnLookJSClose()
    end)

	self.query_index = 1
	self:InitUI()
end

function C:InitUI()
	self.sv = self.ScrollView:GetComponent("ScrollRect")
	EventTriggerListener.Get(self.sv.gameObject).onEndDrag = function()
		local VNP = self.sv.verticalNormalizedPosition
		if VNP <= 0 then
			self:RefreshRankInfo()
		end
	end
	self.my_not_rank_txt.gameObject:SetActive(true)
	self.my_ranking_img.gameObject:SetActive(false)
	self.my_ranking_img1.gameObject:SetActive(false)
	self.right_rect.gameObject:SetActive(false)
	self.my_rank_txt.text = "--"
	self.my_award_txt.text = ""
	self.my_awardImage.gameObject:SetActive(false)
	self.my_look_js_btn.gameObject:SetActive(false)

	self:MyRefresh()
end

function C:MyRefresh()
	self.my_name_txt.text = MainModel.UserInfo.name
	self.game_id = FishingManager.GetRecentlyGameID()
	if not self.game_id then
		self.game_id = FishingManager.GetFishingMatchZHGameID()
	end
	if self.game_id then
		local cfg = FishingManager.GetGameIDToConfig(self.game_id)
		if cfg then
			-- 20分钟一场比赛
			local t = cfg.over_time + 20 * 60
			self.match_time_txt.text = "比赛结束时间：" .. os.date("%Y-%m-%d %H:%M", t)
		else
			self.match_time_txt.text = "--"
		end
	else
		self.match_time_txt.text = "--"
	end

	self:RefreshRankInfo()
end
function C:ClearRankInfo()
	self.rank_data = {}
	self.query_index = 1
	destroyChildren(self.content)
end

function C:RefreshRankInfo()
	Network.SendRequest("fsmg_match_rank_data",  {index = self.query_index, id = self.game_id}, "请求数据")
end

function C:RefreshMyRank(data)
	if data.result == 0 and data.my_rank then
		self.my_rank = data.my_rank
		if data.my_rank.rank == -1 then
			self.my_not_rank_txt.gameObject:SetActive(true)
			self.my_ranking_img.gameObject:SetActive(false)
			self.my_ranking_img1.gameObject:SetActive(false)
			self.my_award_txt.text = ""
			self.my_awardImage.gameObject:SetActive(false)
		else
			if data.my_rank.award_hb and data.my_rank.award_hb > 0 then
				self.my_award_txt.text = StringHelper.ToRedNum(data.my_rank.award_hb/100) .. "元"
				self.my_awardImage.gameObject:SetActive(true)
				self.my_look_js_btn.gameObject:SetActive(true)
			else
				self.my_award_txt.text = ""
				self.my_awardImage.gameObject:SetActive(false)
			end

			self.my_not_rank_txt.gameObject:SetActive(false)
			if data.my_rank.rank < 4 then
				self.my_ranking_img.sprite = GetTexture("localpop_icon_" .. data.my_rank.rank)
				self.my_ranking_img.gameObject:SetActive(true)
				self.my_rank_txt.text = ""
			elseif data.my_rank.rank < 100 then
				self.my_rank_txt.text = data.my_rank.rank
				self.my_ranking_img.gameObject:SetActive(false)
				self.my_ranking_img1.gameObject:SetActive(true)
			else
				self.my_rank_txt.text = "99+"
				self.my_ranking_img.gameObject:SetActive(false)
				self.my_ranking_img1.gameObject:SetActive(true)
			end			
		end
	else
		self.my_not_rank_txt.gameObject:SetActive(true)
		self.my_ranking_img.gameObject:SetActive(false)
		self.my_ranking_img1.gameObject:SetActive(false)
		self.my_rank_txt.text = "--"
		self.my_award_txt.text = ""
		self.my_awardImage.gameObject:SetActive(false)
	end 
end
function C:RefreshTop3(data)
	if data and data.result == 0 then
		self.right_rect.gameObject:SetActive(true)
		for i = 1, 3 do
			local rank = data.rank_list[i]
			local tran = self["top" .. i]
			if rank then
				tran.gameObject:SetActive(true)
				local head_img = tran:Find("@head_frome/@top_head_img"):GetComponent("Image")
				local name_txt = tran:Find("@top_name_txt"):GetComponent("Text")
			    URLImageManager.UpdateHeadImage(rank.head_link, head_img)

	    		name_txt.text = basefunc.deal_hide_player_name(rank.player_name)
	    		if rank.player_id and rank.player_id == MainModel.UserInfo.user_id then
				    name_txt.text = rank.player_name or "-"
				end
			else
				self["top" .. i].gameObject:SetActive(false)
			end
		end
	else
		self.right_rect.gameObject:SetActive(false)
	end
end

function C:fsmg_match_rank_data_response(_, data)
	dump(data, "<color=white>排名数据</color>")

	if data.result == 0 then
		if not next(data.rank_list) then
			LittleTips.Create("暂无新数据")
			return
		end
		FishingManager.CacheRankData(data, self.query_index)
		-- 第一分页里有my_rank
		if self.query_index == 1 then
			self:RefreshMyRank(data)
			self:RefreshTop3(data)
		end

		self.rank_data = self.rank_data or {}
		self.rank_data[self.query_index] = data.rank_list
		self.query_index = self.query_index + 1
		self:CreateRankItems(data.rank_list)
	else
		print("<color=red>EEE 缓存数据</color>")
		local data = FishingManager.GetRankData(self.query_index)
		if data then
			-- 第一分页里有my_rank
			if self.query_index == 1 then
				self:RefreshMyRank(data)
				self:RefreshTop3(data)
			end
			self.rank_data = self.rank_data or {}
			self.rank_data[self.query_index] = data.rank_list
			self.query_index = self.query_index + 1
			self:CreateRankItems(data.rank_list)
		else
			self:RefreshTop3(data)
		end
	end
end
function C:CreateRankItems(data)
	if not data or not next(data) then return end
	for i,v in ipairs(data) do
		local obj = GameObject.Instantiate(self.info, self.content)
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

		if v.player_id == MainModel.UserInfo.user_id then
			t.name_txt.text = MainModel.UserInfo.name
			t.bg_img.sprite = GetTexture("bydrb_bg_zj2")
			t.name_txt.text = string.format("<color=white>%s</color>",t.name_txt.text)
			local outLine = t.award_txt.transform:GetComponent("Outline")
			outLine.effectColor = Color.New(106/255,16/255,169/255,1)
		end
		if v.award_hb and v.award_hb > 0 then
			t.awardImage.gameObject:SetActive(true)
			t.award_txt.text = StringHelper.ToRedNum(v.award_hb/100) .. "元"
		else
			t.awardImage.gameObject:SetActive(false)
			t.award_txt.text = ""
		end

		obj.transform:SetSiblingIndex(v.rank - 1)
		obj.gameObject:SetActive(true)
	end
end
function C:OnBackClose()
	self:MyExit()
end
function C:OnLookJSClose()
	local cfg = FishingManager.GetCfgByRank(self.game_id, self.my_rank.rank)
	if cfg then
		local ew = cfg.fixed_value or 0
		ew = (self.my_rank.award_hb/100 - ew) * 100
		local reward
		if ew > 0 then
			reward = { [1]={asset_type="shop_gold_sum", value=ew} }
		end
	    local parm = {}
	    parm.game_name = "捕鱼千元赛"
	    parm.game_id = self.game_id
	    parm.fianlResult = {game_id=self.game_id, rank=self.my_rank.rank, reward=reward }
	    parm.is_old_rank = true
		parm.grades = self.my_rank.score
		if FishingMatchComRankPanel then
			FishingMatchComRankPanel.Create(parm)
		end
	else
		print("<color=red>fishingmatcholdrankpanel onlookjsclose cfg nil </color>")
	end
end