-- 创建时间:2019-05-29
-- Panel:FishingActivityRankPanel
local basefunc = require "Game/Common/basefunc"

FishingActivityRankPanel = basefunc.class()
local C = FishingActivityRankPanel
C.name = "FishingActivityRankPanel"
local config
local _rank_type = "jjby_bydrb_rank"

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

	PlayerPrefs.SetInt("fish_rank" .. MainModel.UserInfo.user_id, os.time())
	config = BYDRBManager.GetConfig()
	parent = parent or GameObject.Find("Canvas/LayerLv4").transform
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

	self.ui.hint_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self.ui.hint.gameObject:SetActive(true)
	end)

	self.ui.hint_close_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self.ui.hint.gameObject:SetActive(false)
	end)

	--self.ui.my_ew_award.gameObject:SetActive(false)
	--self.ui.my_ew_award_txt.text = "--"

	self:RefreshRankInfo()
	self:RefreshRankInfoMy()
end

function C:MyRefresh()

end

function C:OnBackClick()
	self:MyExit()
end

function C:onAssetChange()
	-- local zz = GameItemModel.GetItemCount("prop_zongzi")
	-- if zz == self.data.prop_zongzi then return end
	-- self:RefreshRankInfoMy()
	-- self:ClearRankInfo()
	-- self:RefreshRankInfo()
end

function C:onExitScene()
	self:MyExit()
end

function C:RefreshRankInfo()
	Network.SendRequest("query_rank_data",  {page_index = self.data.query_index , rank_type = _rank_type },"请求数据",function(data)
		dump(data, "<color=white>排名数据</color>")
		if data.result == 0 then
			if not next(data.rank_data) then
				LittleTips.Create("暂无新数据")
				return
			end
			if not self.data then return end
			self.data.rank_data = self.data.rank_data or {}
			self.data.rank_data[self.data.query_index] = data.rank_data
			--self.data.query_index = self.data.query_index + 1
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
	if not data or not next(data) then
		return
	end
	if not self.ui or not next(self.ui) or not IsEquals(self.ui.info) then
		return
	end
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
		
		t.name_txt.text = v.name
		t.num_txt.text = StringHelper.ToCash(tonumber(v.score))

		if config.awards[v.rank] then
			t.award_txt.text = config.awards[v.rank].award_num
			t.ew_award_txt.text = config.awards[v.rank].award_ex_num
			if tonumber(v.score)>= config.awards[v.rank].condi then
				t.ew_award_grey.gameObject:SetActive(false)
				t.ew_award_txt:GetComponent("Outline").effectColor = Color.New(16/255,106/255,169/255)
			else
				t.ew_award_grey.gameObject:SetActive(true)
				t.ew_award_txt:GetComponent("Outline").effectColor = Color.New(45/255,50/255,43/255)
			end
		end

		-- local award = C.GetAwardByRank(config.awards,v.rank)
		-- if not award then
		-- 	t.award_txt.text = ""
		-- else
		-- 	t.ew_award.gameObject:SetActive(false)
		-- 	t.ew_award_txt.text = ""			
		-- 	for k1,v1 in ipairs(award) do
		-- 		if v1.asset_type == "shop_gold_sum" then
		-- 			t.award_txt.text = v1.value / 100
		-- 		else
		-- 			t.ew_award.gameObject:SetActive(true)
		-- 			t.ew_award_txt.text = "" .. v1.value
		-- 		end
		-- 	end
		-- end

		-- if v.rank > 20 and tonumber(v.profit_num) >= 50000000 then
		-- 	t.ew_award.gameObject:SetActive(true)
		-- 	t.ew_award_txt.text = "1"
		-- end

		if v.player_id == MainModel.UserInfo.user_id then
			t.name_txt.text = MainModel.UserInfo.name
			t.bg_img.sprite = GetTexture("bydrb_bg_zj2_activity_by_drb")
			t.num_img.sprite = GetTexture("bydrb_bg_jbzj_activity_by_drb")
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
	-- self.data.prop_zongzi = GameItemModel.GetItemCount("prop_zongzi")
	if not self.ui or not next(self.ui) then return end
	self.ui.my_name_txt.text = MainModel.UserInfo.name
	Network.SendRequest("query_rank_base_info", {rank_type = _rank_type},"请求数据",function(data)
		dump(data, "<color=yellow>我的排名</color>")
		if not self.ui or not next(self.ui) or not IsEquals(self.ui.my_ew_award) then
			return
		end
		if data.result == 0 then



			if data.rank == -1 then
				self.ui.my_not_rank_txt.gameObject:SetActive(true)
				self.ui.my_ew_award_txt.text = "--"
				self.ui.my_award_txt.text = "--"

				-- if tonumber(data.total_profit) < 1000000 then
				-- 	self.ui.my_not_rank_txt.gameObject:SetActive(true)
				-- 	self.ui.my_award_txt.text = "--"
				-- 	self.ui.my_ranking_img.gameObject:SetActive(false)
				-- else
				-- 	self.ui.my_rank_txt.text = "99+"
				-- 	self.ui.my_award_txt.text = "--"
				-- 	self.ui.my_ranking_img.gameObject:SetActive(false)
				 	self.ui.my_ranking_img1.gameObject:SetActive(false)
				-- end
			else
				self.ui.my_not_rank_txt.gameObject:SetActive(false)
				if data.rank < 4 then
					self.ui.my_ranking_img.sprite = GetTexture("localpop_icon_" .. data.rank)
					self.ui.my_ranking_img.gameObject:SetActive(true)
					self.ui.my_rank_txt.text = ""
				-- elseif data.rank < 100 then
				-- 	self.ui.my_rank_txt.text = data.rank
				-- 	self.ui.my_ranking_img.gameObject:SetActive(false)
				 	self.ui.my_ranking_img1.gameObject:SetActive(false)
				else
					self.ui.my_rank_txt.text = data.rank
					self.ui.my_ranking_img.gameObject:SetActive(false)
					self.ui.my_ranking_img1.gameObject:SetActive(true)
				end
				-------------------------
				if config.awards[data.rank] then
					self.ui.my_award_txt.text = config.awards[data.rank].award_num
					
					if tonumber(data.score) >= config.awards[data.rank].condi then
						self.ui.my_ew_award_txt.text = config.awards[data.rank].award_ex_num
						self.ui.my_ew_award_txt:GetComponent("Outline").effectColor = Color.New(16/255,106/255,169/255)
					else
						self.ui.my_ew_award_txt.text = "--"
						self.ui.my_ew_award_txt:GetComponent("Outline").effectColor = Color.New(45/255,50/255,43/255)
					end
				end

				-- local award = config
				
				-- local award = C.GetAwardByRank(config.awards,data.rank)
				-- if not award then
				-- 	self.ui.my_award_txt.text = "--"
				-- else
				-- 	for k,v in ipairs(award) do
				-- 		if v.asset_type == "shop_gold_sum" then
				-- 			self.ui.my_award_txt.text = v.value / 100
				-- 		else
				 			-- self.ui.my_ew_award.gameObject:SetActive(true)
				 			-- self.ui.my_ew_award_txt.text = "" .. v.value
				-- 		end
				-- 	end
				-- end
			end
			self.ui.my_num_txt.text = StringHelper.ToCash(tonumber(data.score))
		else
			self.ui.my_not_rank_txt.gameObject:SetActive(true)
			self.ui.my_ew_award_txt.text = "--"
			self.ui.my_award_txt.text = "--"
			self.ui.my_num_txt.text = 0
			HintPanel.ErrorMsg(data.result)
		end 
	end)
end

function C.GetAwardByRank(cfg,rank)
	if not cfg or not next(cfg) or not rank or type(rank) ~= "number" then return end
	local list = {}
	for i,v in ipairs(cfg) do
		 if rank >= v.start_rank and rank <= v.end_rank then
			 list[#list + 1] = v
		 end
	end
	return list
end