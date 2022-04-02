-- 创建时间:2019-06-13
-- 挑战任务

local basefunc = require "Game/Common/basefunc"

FishingTZTaskPrefab = basefunc.class()
local C = FishingTZTaskPrefab
C.name = "FishingTZTaskPrefab"

local act_task_icon_map = {
	obj_fish_free_bullet = "by_imgf_mfzd_activity_by_task",
	obj_fish_crit_bullet = "by_imgf_bjsk1_activity_by_task",
	obj_fish_power_bullet = "by_imgf_wlts1_activity_by_task",
	obj_fish_3d_free_bullet = "by_imgf_mfzd_activity_by_task",
	obj_fish_3d_power_bullet = "by_imgf_bjsk1_activity_by_task",
	obj_fish_3d_crit_bullet = "by_imgf_wlts1_activity_by_task",
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
    self.lister["EnterForeGround"] = basefunc.handler(self, self.onEnterForeGround)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.onEnterBackGround)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    if self.update_time then
    	self.update_time:Stop()
    	self.update_time = nil
    end

	self:RemoveListener()
	destroy(self.gameObject)
end

function C:onEnterForeGround()
	
end

function C:onEnterBackGround()
	
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)

	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()


	self.Bg = tran:Find("BG")
	self.GetBG = tran:Find("GetBG")
	self.ConditionText = tran:Find("ConditionText"):GetComponent("Text")
	self.RateText = tran:Find("RateText"):GetComponent("Text")
	self.FishImage = tran:Find("FishImage"):GetComponent("Image")
	self.AwardImage = tran:Find("AwardImage"):GetComponent("Image")
	self.AwardText = tran:Find("AwardText"):GetComponent("Text")
	self.FixAwardImage = tran:Find("FixAwardImage"):GetComponent("Image")
	self.FixAwardText = tran:Find("FixAwardText"):GetComponent("Text")
	self.GetRect = tran:Find("GetRect")
	self.tzrw_huo = tran:Find("tzrw_huo")
	self.GetButton = tran:Find("GetRect/GetButton"):GetComponent("Button")
	self.GetButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        Network.SendRequest("get_task_award", {id = self.data.id})
    end)
    self.gameObject:SetActive(false)
    self.data = nil
end

function C:MyRefresh()
    if self.update_time then
    	self.update_time:Stop()
    	self.update_time = nil
    end
	if not IsEquals(self.gameObject) then
    	return
    end
	if self.data then
	    self.gameObject:SetActive(true)
	    if self.data.award_status == 1 then
	    	self.GetRect.gameObject:SetActive(true)
			self.Bg.gameObject:SetActive(false)
			self.GetBG.gameObject:SetActive(true)
	    else
	    	self.GetRect.gameObject:SetActive(false)
			self.Bg.gameObject:SetActive(true)
			self.GetBG.gameObject:SetActive(false)
	    end
	    local cfg = FishingModel.Config.fish_task_map[self.data.id]
	    local fish_cfg = FishingModel.Config.fish_map[cfg.fish_id]

	    self.time = self.data.over_time - os.time()
	    if self.data.fix_award_data then
	    	local at_key = self.data.fix_award_data[1].award_data[1].asset_type
	    	local num = self.data.fix_award_data[1].award_data[1].asset_value
	    	local item_cfg = GameItemModel.GetItemToKey(at_key)
	    	local numtxt
	    	if at_key == "shop_gold_sum" then
			    numtxt = StringHelper.ToRedNum(num / 100)
	    	else
			    numtxt = num
	    	end
	    	if act_task_icon_map[at_key] then	    		
		    	self.FixAwardText.text = numtxt
			    self.FixAwardImage.sprite = GetTexture(act_task_icon_map[at_key])
			    self.FixAwardImage:SetNativeSize()
			    self.AwardText.gameObject:SetActive(false)
			    self.AwardImage.gameObject:SetActive(false)
			    self.FixAwardText.gameObject:SetActive(false)
			    self.FixAwardImage.gameObject:SetActive(true)
	    	else
			    self.AwardText.text = numtxt
			    self.AwardImage.sprite = GetTexture(item_cfg.image)
			    self.AwardText.gameObject:SetActive(true)
			    self.AwardImage.gameObject:SetActive(true)
			    self.FixAwardText.gameObject:SetActive(false)
			    self.FixAwardImage.gameObject:SetActive(false)
	    	end
	    else
		    self.AwardText.text = cfg.award_value
		    self.AwardImage.sprite = GetTexture(cfg.award_image)
		    self.AwardText.gameObject:SetActive(true)
		    self.AwardImage.gameObject:SetActive(true)
		    self.FixAwardText.gameObject:SetActive(false)
		    self.FixAwardImage.gameObject:SetActive(false)
	    end
	    self.FishImage.sprite = GetTexture(cfg.icon_image)
	    local _scale = fish_cfg.fish_scale
	    self.FishImage.transform.localScale = Vector3.New(_scale, _scale, _scale)
	    self.FishImage:SetNativeSize()
	    self.RateText.text = "<color=#FCF280>" .. self.data.now_process .. "</color>/" .. self.data.need_process

	    if self.data.now_process >= self.data.need_process then
	    	self.ConditionText.gameObject:SetActive(false)
	    else
	    	self.ConditionText.gameObject:SetActive(true)
		    if self.time and self.time > 0 then
			    self.update_time = Timer.New(function ()
			    	self:Update()
			    end, 1, -1)
			    self.update_time:Start()
			end
		    self:RefreshTime()
	    end
	else
    	self.gameObject:SetActive(false)
	end
end
function C:RefreshTime()
	if self.time and self.time >= 0 then
		local mm = math.floor(self.time / 60)
		local ss = self.time % 60
	    self.ConditionText.text = string.format("%02d", mm) .. ":" .. string.format("%02d", ss)
	else
	    self.ConditionText.text = "00:00"
	end
end
function C:Update()
	if self.time > 0 then
		self.time = self.time - 1
		self:RefreshTime()
	end
end

function C:UpdateData(data)
	self.data = data
	self:MyRefresh()
end

