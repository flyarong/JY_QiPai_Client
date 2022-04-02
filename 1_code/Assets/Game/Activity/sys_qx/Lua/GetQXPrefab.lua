-- 创建时间:2019-12-03
-- Panel:GetQXPrefab
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

GetQXPrefab = basefunc.class()
local C = GetQXPrefab
C.name = "GetQXPrefab"

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
    self.lister["model_sdk_ad_msg"] = basefunc.handler(self, self.on_model_sdk_ad_msg)
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

function C:ctor(parm)
	self.parm = parm
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject("get_prefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.xr_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnXRClick()
        if self.parm.call then
        	self.parm.call(self.parm.panelSelf)
        end
		self:MyExit()
    end)
	self.mf_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)

        local cc = function ()
			AdvertisingManager.RandPlay(self.parm.key)
	        if self.parm.call then
	        	self.parm.call(self.parm.panelSelf)
	        end
        end
		if self.parm.key == "dh" then
			if self.parm.panelSelf and self.parm.panelSelf.ext_model then
				local rr = self.parm.panelSelf.ext_model.data.exchange_hongbao.hong_bao2
				local a = GameButtonManager.RunFun({gotoui="vip", hb=rr, call = function ()
					cc()
				end}, "CheckHBLimit")
				if not a then
					cc()
				end
			end
        else
        	cc()
        end
    end)
	self.pt_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnPTClick()
        if self.parm.call then
        	self.parm.call(self.parm.panelSelf)
        end
		self:MyExit()
    end)
	self.back_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:MyExit()
    end)

	self:MyRefresh()
	DSM.ADTrigger(self.parm.key)
end

function C:MyRefresh()
	local tag_vec_map = SYSQXManager.m_data.tag_vec_map
	dump(tag_vec_map, "<color=red>EEE tag_vec_map</color>")
	local model = self.parm.panelSelf.ext_model
	self.back_btn.gameObject:SetActive(false)
	self.ls_top_node.gameObject:SetActive(false)
	if self.parm.key == "dh" then
		self.jiahao.gameObject:SetActive(false)
		self.ew_Cell.gameObject:SetActive(false)

		local rr = StringHelper.ToRedNum(model.data.exchange_hongbao.hong_bao / 100)
		local rr2 = StringHelper.ToRedNum(model.data.exchange_hongbao.hong_bao2 / 100)
        local jb = 0
        if MainModel.myLocation == "game_Mj3D" then
        	jb = self.parm.panelSelf.my_score
        elseif MainModel.myLocation == "game_DdzFree" then
        	jb = model.data.settlement_info.award[model.GetPlayerSeat()]
        elseif MainModel.myLocation == "game_DdzPDK" then
        	jb = model.data.settlement_info.score_data[model.GetPlayerSeat()].score
        end
        local str = string.format("为您将本局赢得的%s鲸币兑换成%s福卡", jb, rr)
		self.title_txt.text = str
		self.mf_txt.text = "双倍领取"

		self.icon_img.sprite = GetTexture("com_award_icon_money")
		self.tag_img.sprite = GetTexture("ggxt_icon_2")
		self.award_txt.text = rr2
		self.desc_txt.text = "单笔充值6元以上(不包含礼包),免视频领取双倍奖励"
	elseif self.parm.key == "djhb" then
		self.jiahao.gameObject:SetActive(true)
		self.ew_Cell.gameObject:SetActive(true)

		local panelSelf = self.parm.panelSelf
		local award = panelSelf.activity_data.activity_award[panelSelf.selectIndex][1]
		local nor_key = award.asset_type
		local nor_val = award.value
		self.nor_award = {{asset_type=nor_key, value=nor_val}}
		local buf_nor_award = AwardManager.GetAwardList(self.nor_award)
		
		local item = GameItemModel.GetItemToKey(nor_key)
		self.icon_img.sprite = GetTexture(item.image)
		self.tag_img.gameObject:SetActive(false)
		if nor_key == "shop_gold_sum" then
			self.award_txt.text = StringHelper.ToRedNum(nor_val / 100)
		else
			self.award_txt.text = StringHelper.ToCash(nor_val)
		end

		local round = panelSelf.data_map["round"]
		local ext_award = panelSelf.activity_data.ext_award[round]
        local str = string.format("恭喜你,本次抽奖获得了%s奖励!", buf_nor_award[1].desc)
		self.title_txt.text = str
		self.mf_txt.text = "全部领取"

		local ew_item = GameItemModel.GetItemToKey(ext_award[1].asset_type)
		self.ew_icon_img.sprite = GetTexture(ew_item.image)
		self.ew_tag_img.sprite = GetTexture("ggxt_icon_1")
		self.ew_tag_img.gameObject:SetActive(true)

	    -- 所有看广告后的额外鲸币奖励砍半
	    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="drt_cpl_half_ad_award", is_on_hint = true}, "CheckCondition")
	    if a and b then
	    	ext_award[1].value = math.floor( ext_award[1].value / 2 )
	    end

		if ext_award[1].asset_type == "shop_gold_sum" then
			self.ew_award_txt.text = StringHelper.ToRedNum(ext_award[1].value / 100)
		else
			self.ew_award_txt.text = StringHelper.ToCash(ext_award[1].value)
		end
		local award_map = {}
		for k,v in ipairs(self.nor_award) do
			award_map[v.asset_type] = tonumber(v.value)
		end
		for k,v in ipairs(ext_award) do
			if award_map[v.asset_type] then
				award_map[v.asset_type] = award_map[v.asset_type] + tonumber(v.value)
			else
				award_map[v.asset_type] = tonumber(v.value)
			end
		end
		self.award_list = {}
		for k,v in pairs(award_map) do
			self.award_list[#self.award_list + 1] = {asset_type=k, value=v}
		end
		self.desc_txt.text = "单笔充值6元以上(不包含礼包),免视频领取额外奖励"

		-- 除了免费用户，其它不需要额外操作即可领取额外奖励
		if not SYSQXManager.IsNeedWatchAD() then
			self:OnXRClick()
	        if self.parm.call then
	        	self.parm.call(self.parm.panelSelf)
	        end
			self:MyExit()
		end
	elseif self.parm.key == "ls" then
		local panelSelf = self.parm.panelSelf
		dump(panelSelf.data, "<color=red>EEE panelSelf.data</color>")
		self.jiahao.gameObject:SetActive(true)
		self.back_btn.gameObject:SetActive(true)
		self.ls_top_node.gameObject:SetActive(true)
		self.ew_Cell.gameObject:SetActive(true)

		local index = panelSelf.data.cur_process - panelSelf.data.min_process + 1
		local round = panelSelf.data.round + 1
		self.nor_award = {panelSelf.awardCfg[index]}
		local buf_nor_award = AwardManager.GetAwardList(self.nor_award)
		if not buf_nor_award or #buf_nor_award <= 0 then
			return
		end
		local item = GameItemModel.GetItemToKey(self.nor_award[1].asset_type)
		self.icon_img.sprite = GetTexture(item.image)
		self.tag_img.gameObject:SetActive(false)
		if self.nor_award[1].asset_type == "shop_gold_sum" then
			self.award_txt.text = StringHelper.ToRedNum(self.nor_award[1].value / 100)
		else
			self.award_txt.text = StringHelper.ToCash(self.nor_award[1].value)
		end

        local str = string.format("恭喜你,连胜挑战成功,获得了%s奖励!", buf_nor_award[1].desc)
		self.title_txt.text = str
		self.title_txt.text = ""
		self.mf_txt.text = "全部领取"

		local ext_award = panelSelf.activity_data.ext_award[round]
		dump(ext_award, "<color=red>EEE ext_award</color>")
		local ew_item = GameItemModel.GetItemToKey(ext_award[1].asset_type)
		self.ew_icon_img.sprite = GetTexture(ew_item.image)
		self.ew_tag_img.sprite = GetTexture("ggxt_icon_1")
		self.ew_tag_img.gameObject:SetActive(true)

	    -- 所有看广告后的额外鲸币奖励砍半
	    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="drt_cpl_half_ad_award", is_on_hint = true}, "CheckCondition")
	    if a and b then
	    	ext_award[1].value = math.floor( ext_award[1].value / 2 )
	    end

		if ext_award[1].asset_type == "shop_gold_sum" then
			self.ew_award_txt.text = StringHelper.ToRedNum(ext_award[1].value / 100)
		else
			self.ew_award_txt.text = StringHelper.ToCash(ext_award[1].value)
		end
		local award_map = {}
		for k,v in ipairs(self.nor_award) do
			award_map[v.asset_type] = tonumber(v.value)
		end
		for k,v in ipairs(ext_award) do
			if award_map[v.asset_type] then
				award_map[v.asset_type] = award_map[v.asset_type] + tonumber(v.value)
			else
				award_map[v.asset_type] = tonumber(v.value)
			end
		end
		self.award_list = {}
		for k,v in pairs(award_map) do
			self.award_list[#self.award_list + 1] = {asset_type=k, value=v}
		end
		self.desc_txt.text = "单笔充值6元以上(不包含礼包),免视频领取额外奖励"

		-- 除了免费用户，其它不需要额外操作即可领取额外奖励
		if not SYSQXManager.IsNeedWatchAD() then
			self:OnXRClick()
	        if self.parm.call then
	        	self.parm.call(self.parm.panelSelf)
	        end
			self:MyExit()
		end
	end

	self.xr_btn.gameObject:SetActive(false)
	self.mf_btn.gameObject:SetActive(true)
	self.pt_btn.gameObject:SetActive(true)
	self.desc_txt.gameObject:SetActive(false)
end

function C:on_model_sdk_ad_msg(data)
	if data.result == 0 and data.isVerify then
        self:OnMFClick(1)
	else
		self:OnMFClick(0)
	end
	self:MyExit()
end

function C:OnXRClick()
	if self.parm.key == "dh" then
		local rr = self.parm.panelSelf.ext_model.data.exchange_hongbao.hong_bao2
		local a = GameButtonManager.RunFun({gotoui="vip", hb=rr, call = function ()
			Network.SendRequest("fg_settle_exchange_hongbao", {ext_get=1}, "")
		end}, "CheckHBLimit")
		if not a then
			Network.SendRequest("fg_settle_exchange_hongbao", {ext_get=1}, "")
		end
	elseif self.parm.key == "djhb" then
		Network.SendRequest("fg_get_ext_activity_award", nil, "", function (data)
			dump(data, "<color=red>fg_get_ext_activity_award</color>")
			if data.result == 0 then
			    Event.Brocast("AssetGet",{data = self.award_list})
			else
			    Event.Brocast("AssetGet",{data = self.nor_award})
			end
		end)
	elseif self.parm.key == "ls" then
		Network.SendRequest("fg_get_activity_award", nil, "", function (data)
			Network.SendRequest("fg_get_ext_activity_award", nil, "", function (data)
				if not IsEquals(self.parm.panelSelf.gameObject) then return end
				self.parm.panelSelf:HideDescHint()
				self.parm.panelSelf:MyRefresh()
			    Event.Brocast("AssetGet",{data = self.award_list})
			end)
		end)
	end
end
function C:OnMFClick(ext_get)
	if self.parm.key == "dh" then
		Network.SendRequest("fg_settle_exchange_hongbao", {ext_get=ext_get}, "")
	elseif self.parm.key == "djhb" then
		if ext_get == 1 then
			Network.SendRequest("fg_get_ext_activity_award", nil, "", function (data)
				dump(data, "<color=red>fg_get_ext_activity_award</color>")
				if data.result == 0 then
				    Event.Brocast("AssetGet",{data = self.award_list})
				else
				    Event.Brocast("AssetGet",{data = self.nor_award})
				end
			end)
		else
		    Event.Brocast("AssetGet",{data = self.nor_award})
		end
	elseif self.parm.key == "ls" then
		if ext_get == 1 then
			Network.SendRequest("fg_get_activity_award", nil, "", function (data)
				Network.SendRequest("fg_get_ext_activity_award", nil, "", function (data)
					self.parm.panelSelf:HideDescHint()
					self.parm.panelSelf:MyRefresh()
				    Event.Brocast("AssetGet",{data = self.award_list})
				end)
			end)
		else
			Network.SendRequest("fg_get_activity_award", nil, "", function (data)
				self.parm.panelSelf:HideDescHint()
				self.parm.panelSelf:MyRefresh()
			    Event.Brocast("AssetGet",{data = self.nor_award})
			end)
		end
	end
end
function C:OnPTClick()
	if self.parm.key == "dh" then
		if self.parm.panelSelf and self.parm.panelSelf.ext_model then
			local rr = self.parm.panelSelf.ext_model.data.exchange_hongbao.hong_bao
			local a = GameButtonManager.RunFun({gotoui="vip", hb=rr, call = function ()
				Network.SendRequest("fg_settle_exchange_hongbao", {ext_get=0}, "")
			end}, "CheckHBLimit")
			if not a then
				Network.SendRequest("fg_settle_exchange_hongbao", {ext_get=0}, "")
			end
		end
	elseif self.parm.key == "djhb" then
		Event.Brocast("AssetGet",{data = self.nor_award})
	elseif self.parm.key == "ls" then
		Network.SendRequest("fg_get_activity_award", nil, "", function (data)
			self.parm.panelSelf:HideDescHint()
			self.parm.panelSelf:MyRefresh()
		    Event.Brocast("AssetGet",{data = self.nor_award})
		end)
	end
end