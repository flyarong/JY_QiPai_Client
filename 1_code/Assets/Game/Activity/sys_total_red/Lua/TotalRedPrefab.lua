-- 创建时间:2018-10-17
-- toolprefab 

local basefunc = require "Game.Common.basefunc"

TotalRedPrefab = basefunc.class()

TotalRedPrefab.name = "TotalRedPrefab"

local instance
function TotalRedPrefab.Create(parent, parm)
	--开启任务的时候福卡到任务界面领取
	if true then
		-- 屏蔽福卡
		return
	end
	if not instance then
		instance = TotalRedPrefab.New(parent, parm)
	end
	return instance
end
function TotalRedPrefab.UpdateUI()
	if instance then
		instance:InitUI()
	end
end
function TotalRedPrefab.Exit()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

function TotalRedPrefab:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function TotalRedPrefab:MakeLister()
    self.lister = {}
    self.lister["model_fg_get_hongbao_award_response"] = basefunc.handler(self, self.on_fg_get_hongbao_award_response)
end

function TotalRedPrefab:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function TotalRedPrefab:MyExit()
	self:RemoveListener()
end

function TotalRedPrefab:ctor(parent, parm)
	if not parent then
		parent = GameObject.Find("Canvas/LayerLv1").transform
	end
	self:MakeLister()
	self:AddMsgListener()
	self.parm = parm

	local obj = newObject(TotalRedPrefab.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self.IngNode = tran:Find("IngNode")
	self.RateImage = tran:Find("IngNode/RateBG/RateImage"):GetComponent("RectTransform")
	self.RateText = tran:Find("IngNode/RateText"):GetComponent("Text")
	self.BetText = tran:Find("IngNode/BetText"):GetComponent("Text")

	self.AwardHintText = tran:Find("AwardHintText"):GetComponent("Text")

	self.FillImage = tran:Find("FillImage"):GetComponent("Button")
	self.FillImage.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnRedClick()
	end)

	self.FinishNode = tran:Find("FinishNode")
	self.RedButton = tran:Find("FinishNode/RedButton"):GetComponent("Button")
	self.RedButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnRedClick()
	end)

	self:InitUI()
	self:GameGlobalOnOff()
end

function TotalRedPrefab:GameGlobalOnOff()
	self.transform.gameObject:SetActive(true)
end

function TotalRedPrefab:InitUI()
	local all_info = GameFreeModel.data.all_info
	local game_id = self.parm.game_id
	if all_info.today_game_race[game_id] == 0 and all_info.store_award > 0 then
		self.FinishNode.gameObject:SetActive(true)
		self.FillImage.gameObject:SetActive(true)
		self.AwardHintText.text = ""
	else
		self.FinishNode.gameObject:SetActive(false)
		self.FillImage.gameObject:SetActive(false)
		if all_info.today_award >= all_info.today_max_award  then
			self.AwardHintText.text = "今日领取福卡达到上限"
		else
			local mm = StringHelper.ToCash(all_info.today_hb_award[game_id] / 100)
			self.AwardHintText.text = "再玩" .. (all_info.today_hb_condition[game_id]-all_info.today_game_race[game_id]) .."局奖".. mm .. "福卡"
		end
	end

    local data = GameFreeModel.GetGameIDToConfig(game_id)
	if string.sub(data.game_type, 1, 7) == "game_Mj" then
		self.AwardHintText.transform.localPosition = Vector3.New(590, -500, 0)
	else
		self.AwardHintText.transform.localPosition = Vector3.New(21, -488, 0)
	end

	local rate = all_info.week_race / all_info.week_next_target
	if rate > 1 then
		rate = 1
	end
	self.RateImage.sizeDelta = Vector2.New(280*rate, 35)
	self.RateText.text = all_info.week_race .. "/" .. all_info.week_next_target .. "分"
	self.BetText.text = "当前瓜分" .. all_info.get_note .. "注奖金"
end

function TotalRedPrefab:on_fg_get_hongbao_award_response(award)	
    LittleTips.CreateAwardHint({awardtype = "shop_gold_sum", award = award})
    self.FinishNode.gameObject:SetActive(false)
    self.FillImage.gameObject:SetActive(false)
end

function TotalRedPrefab:OnRedClick()
	GameFreeModel.SendRedAward()
end
