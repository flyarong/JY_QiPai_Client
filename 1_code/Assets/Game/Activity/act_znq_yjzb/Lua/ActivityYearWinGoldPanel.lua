local basefunc = require "Game/Common/basefunc"
package.loaded["Game.CommonPrefab.Lua.ActivityYearWinGoldRankPanel"] = nil
require "Game.CommonPrefab.Lua.ActivityYearWinGoldRankPanel"
ActivityYearWinGoldPanel = basefunc.class()
local M = ActivityYearWinGoldPanel
M.name = "ActivityYearWinGoldPanel"
local config = HotUpdateConfig("Game.CommonPrefab.Lua.activity_year_win_gold")
local rank_type = "zhounianqing_yingjing_rank"
function M.Create(parent)
	return M.New(parent)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.onExitScene)
    self.lister["AssetChange"] = basefunc.handler(self, self.onAssetChange)
    self.lister["query_znq_yingjing_rank_stage_data_response"] = basefunc.handler(self, self.RefreshLevel)
    self.lister["query_rank_base_info_response"] = basefunc.handler(self, self.RefreshLevelMy)
    self.lister["query_znq_yingjing_rank_stage_details_response"] = basefunc.handler(self, self.RefreshLevelOther)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
	destroy(self.gameObject)
	self.data = nil
	self.ui = nil
	self:RemoveListener()

	 
end

function M:ctor(parent)

	ExtPanel.ExtMsg(self)

	parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(M.name, parent)
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

function M:InitUI()
	LuaHelper.GeneratingVar(self.ui.transform, self.ui)
	self.ui.hint_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self.ui.hint.gameObject:SetActive(true)
	end)

	self.ui.hint_close_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self.ui.hint.gameObject:SetActive(false)
	end)
	self.ui.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)
	self:InitLevel()
	self:InitLevelMy()
	Network.SendRequest("query_rank_base_info",{rank_type = rank_type},"请求数据")
	Network.SendRequest("query_znq_yingjing_rank_stage_details",{stage_id = 1,page_index = 1},"请求数据")
	Network.SendRequest("query_znq_yingjing_rank_stage_data",  nil,"请求数据")
end

function M:MyRefresh()

end

function M:OnBackClick()
	self:MyExit()
end

function M:onAssetChange()

end

function M:onExitScene()
	self:MyExit()
end

function M:RefreshLevel(_,data)
	if not self.ui or not next(self.ui) then return end
	dump(data, "<color=white>排名数据</color>")
	if data.result == 0 then
		for k,v in pairs(data.stage_data) do
			local t = {}
			LuaHelper.GeneratingVar(self.ui["level" .. v.stage_id].transform,t)
			t.cur_txt.text = v.player_num 
		end
	else
		HintPanel.ErrorMsg(data.result)
	end
end

function M:InitLevel()
	for i,v in ipairs(config.awards) do
		local obj = GameObject.Instantiate(self.ui.level_item,self.ui.content.transform)
		self.ui["level" .. i] = obj.transform
		local t = {}
		LuaHelper.GeneratingVar(self.ui["level" .. i].transform,t)
		local cfg = config.awards[i]
		t.level_img.sprite = GetTexture(cfg.icon)
		t.level_txt.text = cfg.name
		t.need_txt.text = StringHelper.ToCash(tonumber(cfg.need))
		t.gold_txt.text = cfg.award_type == "shop_gold_sum" and cfg.value / 100 or StringHelper.ToCash(cfg.value)
		t.gold_img.sprite = GetTexture(cfg.award_icon)
		if v.level < 4 then
			t.level_txt.gameObject:SetActive(false)
			t.level_name_img.sprite = GetTexture("gy_53_1" .. v.level)
			t.level_name_img.gameObject:SetActive(true)
		end
		t.wh_img.gameObject:SetActive(i < 6)
		-- local btn = t.cur_txt.transform:GetComponent("Button")
		t.inf_btn.onClick:AddListener(function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			if i > 5 then
				LittleTips.Create("此段位不可查看，请查看黄金段位以上段位详情")
			else
				ActivityYearWinGoldRankPanel.Create({level = cfg.level})
			end
		end)
		obj.gameObject:SetActive(true)
	end
end

function M:InitLevelMy()
	self.ui.one_award_img.sprite = GetTexture(config.awards[1].real_award_icon[1])
	self.ui.two_award_img.sprite = GetTexture(config.awards[2].real_award_icon[1])
end

function M:RefreshLevelMy(_,data)
	if not self.ui or not next(self.ui) then return end
	dump(data, "<color=yellow>我的排名</color>")
	if data.result == 0 then
		data.score = tonumber(data.score)
		local ld = M.GetLevelDataByScore(data.score)
		if ld then
			if ld.level > 3 then
				self.ui.my_head_img.sprite = GetTexture(ld.icon)
				self.ui.my_level_txt.text = ld.name
				self.ui.my_gold_txt.text = StringHelper.ToCash(data.score)
				if SYSACTBASEManager.HorizontalWrapMode_Overflow then
					self.ui.my_gold_txt.horizontalOverflow= SYSACTBASEManager.HorizontalWrapMode_Overflow
				end
				self.ui.my_rank_img.gameObject:SetActive(false)
				self.ui.my_level_txt.gameObject:SetActive(true)
			else
				self.ui.my_head_img.sprite = GetTexture(ld.icon)
				self.ui.my_level_txt.text = ld.name
				self.ui.my_gold_txt.text = StringHelper.ToCash(data.score)
				if SYSACTBASEManager.HorizontalWrapMode_Overflow then
					self.ui.my_gold_txt.horizontalOverflow= SYSACTBASEManager.HorizontalWrapMode_Overflow
				end
				self.ui.my_rank_img.sprite = GetTexture("gy_53_1"..ld.level)
				self.ui.my_level_txt.gameObject:SetActive(false)
				self.ui.my_rank_img.gameObject:SetActive(true)
			end

			local t = {}
			for i,v in ipairs(config.awards) do
				t = {}
				LuaHelper.GeneratingVar(self.ui["level" .. v.level].transform,t)
				t.level_hight.gameObject:SetActive(v.level == ld.level)
			end
			self.ui.my_head_img.gameObject:SetActive(true)
		else
			self.ui.my_head_img.gameObject:SetActive(false)
			self.ui.my_rank_img.gameObject:SetActive(false)
			self.ui.my_level_txt.text = "未上榜"
			self.ui.my_gold_txt.text = StringHelper.ToCash(data.score)
			if SYSACTBASEManager.HorizontalWrapMode_Overflow then
				self.ui.my_gold_txt.horizontalOverflow= SYSACTBASEManager.HorizontalWrapMode_Overflow
			end

			local t = {}
			for i,v in ipairs(config.awards) do
				t = {}
				LuaHelper.GeneratingVar(self.ui["level" .. v.level].transform,t)
				t.level_hight.gameObject:SetActive(false)
			end
		end
	else
		self.ui.my_head_img.gameObject:SetActive(false)
		self.ui.my_rank_img.gameObject:SetActive(false)
		self.ui.my_level_txt.text = ""
		self.ui.my_gold_txt.text = ""
		if SYSACTBASEManager.HorizontalWrapMode_Overflow then
			self.ui.my_gold_txt.horizontalOverflow= SYSACTBASEManager.HorizontalWrapMode_Overflow
		end
		HintPanel.ErrorMsg(data.result)
	end 
end

function M:RefreshLevelOther(_,data)
	if not self.ui or not next(self.ui) then return end
	dump(data, "<color=yellow>其他玩家排名</color>")
	if data.result == 0 then
		local d = data.rank_data[1]
		if d then
			URLImageManager.UpdateHeadImage(d.head_image, self.ui.one_head_img)
			self.ui.one_head_img.gameObject:SetActive(true)
			-- local name = ""
			-- if #d.name > 4 then
			-- 	name = string.sub( d.name, 1,2 )
			-- 	name = name .. "*"
			-- 	name = name .. string.sub( d.name, -1)
			-- end
			d.score = d.score * 10
			self.ui.one_txt.text = d.name .. "\n" .. StringHelper.ToCash(d.score)
		else
			self.ui.one_head_img.sprite = GetTexture("com_head")
			self.ui.one_head_img.gameObject:SetActive(false)
			self.ui.one_txt.text = "虚位以待"
		end
		d = data.rank_data[2]
		if d then
			URLImageManager.UpdateHeadImage(d.head_image, self.ui.two_head_img)
			self.ui.two_head_img.gameObject:SetActive(true)
			-- local name = ""
			-- if #d.name > 4 then
			-- 	name = string.sub( d.name, 1,2 )
			-- 	name = name .. "*"
			-- 	name = name .. string.sub( d.name, -1)
			-- end
			d.score = d.score * 10
			self.ui.two_txt.text = d.name .. "\n" .. StringHelper.ToCash(d.score)
		else
			self.ui.two_head_img.sprite = GetTexture("com_head")
			self.ui.two_head_img.gameObject:SetActive(false)
			self.ui.two_txt.text = "虚位以待"
		end
	else
		self.ui.one_head_img.sprite = GetTexture("com_head")
		self.ui.one_head_img.gameObject:SetActive(false)
		self.ui.one_txt.text = "虚位以待"
		self.ui.two_head_img.sprite = GetTexture("com_head")
		self.ui.two_head_img.gameObject:SetActive(false)
		self.ui.two_txt.text = "虚位以待"
		HintPanel.ErrorMsg(data.result)
	end 
end

function M.GetLevelByScore(score)
	for i,v in ipairs(config.awards) do
		if score >= v.need then
			return v.level
		end
	end
end

function M.GetLevelDataByScore(score)
	for i,v in ipairs(config.awards) do
		if score >= v.need then
			return v
		end
	end
end