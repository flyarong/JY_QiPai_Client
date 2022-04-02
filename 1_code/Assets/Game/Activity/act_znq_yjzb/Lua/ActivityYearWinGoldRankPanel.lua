-- 创建时间:2019-05-29
-- Panel:ActivityYearWinGoldRankPanel
local basefunc = require "Game/Common/basefunc"

ActivityYearWinGoldRankPanel = basefunc.class()
local C = ActivityYearWinGoldRankPanel
C.name = "ActivityYearWinGoldRankPanel"
local rank_type = "zhounianqing_yingjing_rank"
function C.Create(pram,parent)
	return C.New(pram,parent)
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

function C:ctor(pram,parent)

	ExtPanel.ExtMsg(self)

	self.pram = pram
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

	self:RefreshRankInfo()
	-- self:RefreshRankInfoMy()
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
	Network.SendRequest("query_znq_yingjing_rank_stage_details",  {stage_id = self.pram.level, page_index = self.data.query_index},"请求数据",function(data)
		dump(data, "<color=white>排名数据</color>")
		if data.result == 0 then
			if not next(data.rank_data) then
				LittleTips.Create("暂无新数据")
				return
			end
			if not self.data then return end
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
			t.ranking_img1.gameObject:SetActive(false)
			t.rank_txt.text = ""
		else
			t.ranking_img.gameObject:SetActive(false)
			t.ranking_img1.gameObject:SetActive(true)
			t.rank_txt.text = v.rank
		end
		
		t.name_txt.text = v.name
		t.num_txt.text = StringHelper.ToCash(tonumber(v.score))

		if v.player_id == MainModel.UserInfo.user_id then
			t.name_txt.text = MainModel.UserInfo.name
			t.bg_img.sprite = GetTexture("gy_53_19")
			t.num_img.sprite = GetTexture("gy_53_21")
			-- local outLine = t.num_txt.transform:GetComponent("Outline")
			-- outLine.effectColor = Color.New(106/255,16/255,169/255,1)
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
	Network.SendRequest("query_rank_base_info", {rank_type = rank_type},"请求数据",function(data)
		dump(data, "<color=yellow>我的排名</color>")
		if data.result == 0 then
			if data.rank == -1 then
				if tonumber(data.total_profit) < 1000000 then
					self.ui.my_not_rank_txt.gameObject:SetActive(true)
					self.ui.my_ranking_img.gameObject:SetActive(false)
				else
					self.ui.my_rank_txt.text = "99+"
					self.ui.my_ranking_img.gameObject:SetActive(false)
					self.ui.my_ranking_img1.gameObject:SetActive(true)
				end
			else
				self.ui.my_not_rank_txt.gameObject:SetActive(false)
				if data.rank < 4 then
					self.ui.my_ranking_img.sprite = GetTexture("localpop_icon_" .. data.rank)
					self.ui.my_ranking_img.gameObject:SetActive(true)
					self.ui.my_rank_txt.text = ""
				elseif data.rank < 100 then
					self.ui.my_rank_txt.text = data.rank
					self.ui.my_ranking_img.gameObject:SetActive(false)
					self.ui.my_ranking_img1.gameObject:SetActive(true)
				else
					self.ui.my_rank_txt.text = "99+"
					self.ui.my_ranking_img.gameObject:SetActive(false)
					self.ui.my_ranking_img1.gameObject:SetActive(true)
				end
			end
			self.ui.my_num_txt.text = StringHelper.ToCash(tonumber(data.total_profit))
		else
			self.ui.my_not_rank_txt.gameObject:SetActive(true)
			self.ui.my_num_txt.text = 0
			HintPanel.ErrorMsg(data.result)
		end 
	end)
end