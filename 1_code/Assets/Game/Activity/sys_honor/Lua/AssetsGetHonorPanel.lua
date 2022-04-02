-- 创建时间:2018-06-06
local basefunc = require "Game.Common.basefunc"
AssetsGetHonorPanel = basefunc.class()
AssetsGetHonorPanel.name = "AssetsGetHonorPanel"

local threshold_value = 4
local ChangePos = {
	min_change_honor_pos = Vector2.New(0,-164),
	max_change_honor_pos = Vector2.zero,
	min_confirm_btn_pos = Vector2.New(0,-290),
	max_confirm_btn_pos = Vector2.New(0,-454),
}

local instance
function AssetsGetHonorPanel.Create(data,parent)
	dump(data, "<color=green>荣誉升级获得物品</color>")
	ExtendSoundManager.PlaySound(audio_config.game.bgm_hall_up_level.audio_name)
	if GameGlobalOnOff.Honor == false then
		return
	end
	if not instance then
		instance = AssetsGetHonorPanel.New(data,parent)
	else
		AssetsGetHonorPanel.Close()
		instance = AssetsGetHonorPanel.New(data,parent)
	end
	return instance
end

function AssetsGetHonorPanel.Close()
	if instance then
		instance.data = nil
		instance:RemoveListener()
		GameObject.Destroy(instance.transform.gameObject)
		instance = nil
	end
end

function AssetsGetHonorPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function AssetsGetHonorPanel:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function AssetsGetHonorPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function AssetsGetHonorPanel:ctor(data,parent)
	self.data = data
	parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	self:MakeLister()
	self:AddMsgListener()
	local obj = newObject(AssetsGetHonorPanel.name, parent)
	self.transform = obj.transform
	LuaHelper.GeneratingVar(self.transform,self)
	self.AwardCellList = {}
	self:InitRect()
	DOTweenManager.OpenPopupUIAnim(self.transform)
end

function AssetsGetHonorPanel:InitRect()
	local func_back = function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		GameHonorModel.data.HonorLevelChangeData[self.data.level] = nil
		if not next(GameHonorModel.data.HonorLevelChangeData) then
			GameHonorModel.data.HonorLevelChangeData = nil
		end

		if GameHonorModel.data.HonorLevelChangeData then
			local next_honor_data = GameHonorModel.data.HonorLevelChangeData[self.data.level + 1]
			if next_honor_data then
				Event.Brocast("AssetsGetHonorPanel",next_honor_data)
			end
		else
			if MainLogic.AssetsGetCallback then
				MainLogic.AssetsGetCallback ()
			end
			local callback = self.data.callback
			if callback ~= nil then
				callback()
			end
			self.data.callback = nil
	
			self:OnExitScene()
		end
	end

	self.confirm_btn.onClick:AddListener(func_back)
	self.BG_btn.onClick:AddListener(func_back)

	local change_type = self.data.change_type
	if change_type then
		local title = ""
		if change_type == ASSET_CHANGE_TYPE.GLORY_AWARD then
			title = "com_imgf_sjjl"
		else
			title = "com_imgf_gxhd"
		end
		self:ChangeTitle(title)
	end

	local using_max = #self.data.data > threshold_value
	local item_parent = using_max and self.MaxAwardNode or self.MinAwardNode
	self.MaxBGImage.transform.gameObject:SetActive(using_max)
	self.MinBGImage.transform.gameObject:SetActive(not using_max)
	self.max_sv.transform.gameObject:SetActive(using_max)
	self.min_sv.transform.gameObject:SetActive(not using_max)
	self.confirm_btn.transform.localPosition = using_max and ChangePos.max_confirm_btn_pos or ChangePos.min_confirm_btn_pos
	self.honor_change.transform.localPosition = using_max and ChangePos.max_change_honor_pos or ChangePos.min_change_honor_pos

	local data = self.data.data
	local skip_data = self.data.skip_data or false
	if not skip_data then
		data = AwardManager.GetHonorAssetsList(data)
	end
	self:CloseAwardCell()
	for i=1,#data do
		local v = data[i]
		self.AwardCellList[#self.AwardCellList + 1] = self:CreateItem(v,item_parent)
	end

	self:SetChangeHonorUI()

	local animation = self.data.animation or false
	if animation then
		self:AnimationList(self.AwardCellList)
	end
end

function AssetsGetHonorPanel:CloseAwardCell()
	for i,v in ipairs(self.AwardCellList) do
		GameObject.Destroy(v.gameObject)
	end
	self.AwardCellList = {}
end

function AssetsGetHonorPanel:CreateItem(data,parent)
	local obj = GameObject.Instantiate(self.AwardPrefab)
	obj.transform:SetParent(parent)
	obj.transform.localScale = Vector3.one
	local obj_t = {}
	LuaHelper.GeneratingVar(obj.transform,obj_t)
	obj_t.DescText_txt.text = data.desc
	GetTextureExtend(obj_t.AwardIcon_img, data.image, data.is_local_icon)
	if string.find(tostring(data.type), "frame") then
		obj_t.AwardIcon_img:SetNativeSize()
	end
	if data.type == "shop_gold_sum" then		
		obj_t.NameText_txt.text = data.value
		obj_t.NameText_txt.gameObject:SetActive(true)
	end
	obj.gameObject:SetActive(true)
	return obj
end

function AssetsGetHonorPanel:OnExitScene()
	MainLogic.AssetsGetCallback = nil
	AssetsGetHonorPanel.Close()
end

function AssetsGetHonorPanel:ChangeTitle(titleFile)
	if self.title_img == nil then return end
	self.title_img.sprite = GetTexture(titleFile)
	self.title_img:SetNativeSize()
end

function AssetsGetHonorPanel:AnimationList(list)
	for k, v in pairs(list) do
		v.gameObject:SetActive(false)
	end

	local interval = 0.5
	local loop = #list

	local cursor = 0
	Timer.New(function()
		cursor = cursor + 1
		local ui = list[cursor]

		local tween1 = ui.transform:DOScale(0.3, 0.3):OnComplete(function()
			if IsEquals(ui.gameObject) then
				ui.gameObject:SetActive(true)
			end
		end)
		local tween2 = ui.transform:DOScale(1.3, 0.3)
		local tween3 = ui.transform:DOScale(1.0, 0.3)
		local seq = DG.Tweening.DOTween.Sequence()
		local tweenKey = DOTweenManager.AddTweenToStop(seq)
		seq:Append(tween1):Append(tween2):Append(tween3):OnKill(function()
			DOTweenManager.RemoveStopTween(tweenKey)
			if IsEquals(ui.gameObject) then
				ui.transform.localScale = Vector3.one
				ui.gameObject:SetActive(true)
			end
		end)
	end, interval, loop):Start()
end

function AssetsGetHonorPanel:SetChangeHonorUI()
	local cur_config = GameHonorModel.GetHonorDataByID(self.data.level)
	local prev_config = GameHonorModel.GetHonorDataByID(self.data.level - 1)
	local honor_type = self.data.honor_type
	if prev_config then
		self.prev_level_txt.text = string.format( "LV.%d",prev_config.level)
		self.prev_level_txt.gameObject:SetActive(true)
	else
		self.prev_level_txt.gameObject:SetActive(false)
	end
	self.cur_level_txt.text = string.format( "LV.%d",cur_config.level)
end