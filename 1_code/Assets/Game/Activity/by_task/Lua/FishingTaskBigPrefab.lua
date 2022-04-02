-- 创建时间:2019-05-14
-- Panel:FishingTaskBigPrefab
local basefunc = require "Game/Common/basefunc"

FishingTaskBigPrefab = basefunc.class()
local C = FishingTaskBigPrefab
C.name = "FishingTaskBigPrefab"

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
	self.AwardText = tran:Find("AwardText"):GetComponent("Text")
	self.FishImage = tran:Find("FishImage"):GetComponent("Image")
	self.AwardImage = tran:Find("AwardImage"):GetComponent("Image")
	self.GetRect = tran:Find("GetRect")
	self.GetButton = tran:Find("GetRect/GetButton"):GetComponent("Button")
	self.GetButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        Network.SendRequest("get_task_award", {id = self.data.id})
    end)
    self.gameObject:SetActive(false)
    self.data = nil
end

function C:MyRefresh()
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

	    self.ConditionText.text = cfg.desc
	    self.AwardText.text = cfg.award_value
	    self.FishImage.sprite = GetTexture(cfg.icon_image)
	    local _scale = fish_cfg.fish_scale
	    self.FishImage.transform.localScale = Vector3.New(_scale, _scale, _scale)
	    self.FishImage:SetNativeSize()
	    self.AwardImage.sprite = GetTexture(cfg.award_image)
	    self.RateText.text = "<color=#FCF280>" .. self.data.now_process .. "</color>/" .. self.data.need_process
	else
    	self.gameObject:SetActive(false)
	end
end

function C:UpdateData(data)
	self.data = data
	self:MyRefresh()
end