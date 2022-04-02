-- 创建时间:2018-06-06
local basefunc = require "Game.Common.basefunc"
AssetsExtraGetPanel = basefunc.class()
AssetsExtraGetPanel.name = "AssetsExtraGetPanel"

local dotweenLayerKey = "AssetsExtraGetPanel"
local instance
function AssetsExtraGetPanel.Create(data)
	ExtendSoundManager.PlaySound(audio_config.game.bgm_hall_huodewupin.audio_name)
	if MainLogic.IsHideAssetsExtraGetPanel then
		dump(data, "<color=red>AssetsExtraGetPanel XXXXX</color>")
		MainLogic.IsHideAssetsExtraGetPanel = nil
	else
		if not instance then
			instance = AssetsExtraGetPanel.New(data)
		end
		return instance
	end
end

function AssetsExtraGetPanel:MyExit()
	self.data = nil
	self:RemoveListener()
	destroy(self.gameObject)
end

function AssetsExtraGetPanel.Close()
	if instance then
		instance:MyExit()
		instance = nil
	end
end

function AssetsExtraGetPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function AssetsExtraGetPanel:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
    self.lister["OnLoginResponse"] = basefunc.handler(self, self.OnExitScene)
    self.lister["will_kick_reason"] = basefunc.handler(self, self.OnExitScene)
    self.lister["DisconnectServerConnect"] = basefunc.handler(self, self.OnExitScene)

    self.lister["AssetGet"] = basefunc.handler(self, self.OnSmoothExitScene)
    self.lister["CloseAssetsPanel"] = basefunc.handler(self, self.OnSmoothExitScene)
end

function AssetsExtraGetPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function AssetsExtraGetPanel:ctor(data)

	ExtPanel.ExtMsg(self)

	self.data = data
	local parent = GameObject.Find("Canvas/LayerLv50").transform
	self:MakeLister()
	self:AddMsgListener()
	local obj = newObject(AssetsExtraGetPanel.name, parent)
	self.transform = obj.transform
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform,self)
	self.AwardCellList = {}
	self:InitRect()
	DOTweenManager.OpenPopupUIAnim(self.UINode.transform)
end

function AssetsExtraGetPanel:InitRect()
	local func_back = function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		--if MainLogic.AssetsGetCallback then
		--	MainLogic.AssetsGetCallback ()
		--end
		self:OnExitScene()
	end

	local func_pay_again = function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		--if MainLogic.AssetsGetCallback then
		--	MainLogic.AssetsGetCallback ()
		--end

		local params = self.data.params or {}
		if params.host ~= nil then
			if PayPanel.CheckExpressionCondition(params.host) then
				Network.SendRequest("pay_lottery",
				{type = params.host.group, time = params.host.num, tag = params.host.id},"购买表情")
				print("[debug] goods_expression buy again:" .. params.host.group .. ", " .. params.host.num)

				self.confirm_btn.gameObject:SetActive(false)
				self.pay_again_btn.gameObject:SetActive(false)

				return
			end
		end

		self:OnExitScene()
	end

	self.confirm_btn.onClick:AddListener(func_back)
	self.pay_again_btn.onClick:AddListener(func_pay_again)
	--self.BG_btn.onClick:AddListener(func_back)

	local title = self.data.title or ""
	if title ~= "" then
		self:ChangeTitle(title)
	end

	local data = self.data.data
	self:CloseAwardCell()

	local data_count = #data
	local gridLayout = self.AwardNode.transform:GetComponent("GridLayoutGroup")
	print(gridLayout.childAlignment)
	if data_count > 1 then
		gridLayout.childAlignment = UnityEngine.TextAnchor.UpperLeft
	else
		gridLayout.childAlignment = UnityEngine.TextAnchor.UpperCenter
	end

	for i=1,#data do
		local v = data[i]
		self.AwardCellList[#self.AwardCellList + 1] = self:CreateItem(v)
	end

	local animation = self.data.animation or false
	if animation then
		self.confirm_btn.gameObject:SetActive(false)
		self.pay_again_btn.gameObject:SetActive(false)

		self:AnimationList(self.AwardCellList, function()
			self.confirm_btn.gameObject:SetActive(true)
			self.pay_again_btn.gameObject:SetActive(true)
		end)
	end

	local notice = ""
	local params = self.data.params or {}
	if params.host ~= nil then
		local goodsData = MainModel.GetShopingConfig(GOODS_TYPE.item, params.host.id, ITEM_TYPE.expression)
		dump(goodsData, "<color=green>goodsData</color>")
		if goodsData == nil then
			print("[lottery] exception: goodsData is empty, id:" .. params.host.id)
		else
			local detail = PayPanel.map_lottery_detail(goodsData)

			local max_cnt = goodsData.max or 0
			local item_data = PersonalInfoManager.GetDressDataToID(goodsData.item_id)
			local item_data_num = item_data.num or 0

			--debug
			print("itemid: " .. goodsData.item_id .. ", max: " .. max_cnt .. ", item_num:" .. item_data_num)

			if item_data_num >= max_cnt then
				notice = string.format("%s 已经超过 %d 个了，无法再增加", detail["title"], max_cnt)
			else
				notice = string.format("%s 已获得，%s", detail["title_extra"], detail["desc"])
			end

			local use_count = goodsData.use_count or 0
			local v1, v2 = math.modf(use_count * 0.0001)
			if v2 < 0.05 then
				self.pay_gold_txt.text = string.format("%d 万", v1)
			else
				self.pay_gold_txt.text = string.format("%d.%d 万", v1, math.floor((v2 + 0.05) * 10))
			end
		end
	end
	self.pay_notice_txt.text = notice
end

function AssetsExtraGetPanel:CloseAwardCell()
	for i,v in ipairs(self.AwardCellList) do
		GameObject.Destroy(v.gameObject)
	end
	self.AwardCellList = {}
end

function AssetsExtraGetPanel:CreateItem(data)
	local obj = GameObject.Instantiate(self.AwardPrefab)
	obj.transform:SetParent(self.AwardNode)
	obj.transform.localScale = Vector3.one
	local obj_t = {}
	LuaHelper.GeneratingVar(obj.transform,obj_t)
	obj_t.AwardIcon_img.sprite = GetTexture(data.image)

	if data.type == "shop_gold_sum" then
		obj_t.DescText_txt.text = string.format("%5.2f 福卡", data.value * 0.01)
	else
		obj_t.DescText_txt.text = string.format("%s x %s", data.desc, data.value)
	end

	obj.gameObject:SetActive(true)
	return obj
end

function AssetsExtraGetPanel:OnExitScene()
	--MainLogic.AssetsGetCallback = nil
	DOTweenManager.KillLayerKeyTween(dotweenLayerKey)
	if self.animationTimer ~= nil then
		self.animationTimer:Stop()
		self.animationTimer = nil
	end
	AssetsExtraGetPanel.Close()
end

function AssetsExtraGetPanel:OnSmoothExitScene()
	coroutine.start(function ()
		Yield(0)
		self:OnExitScene()
	end)
end

function AssetsExtraGetPanel:ChangeTitle(titleFile)
	local trans = self.transform
	local imageNode = trans:Find("BGImage (2)/genter (2)"):GetComponent("Image")
	if imageNode == nil then return end
	imageNode.sprite = GetTexture(titleFile)
	imageNode:SetNativeSize()
end

function AssetsExtraGetPanel:AnimationList(list, callback)
	for k, v in pairs(list) do
		v.gameObject:SetActive(false)
	end

	local interval = 0.2
	local loop = #list

	local cursor = 0
	self.animationTimer = Timer.New(function()
		cursor = cursor + 1
		local ui = list[cursor]

		local tween1 = ui.transform:DOScale(0.3, 0.1):OnComplete(function()
			if IsEquals(ui.gameObject) then
				ui.gameObject:SetActive(true)
				ExtendSoundManager.PlaySound(audio_config.game.bgm_hall_choubiaoqing.audio_name)
			end
		end)
		local tween2 = ui.transform:DOScale(1.2, 0.2)
		local tween3 = ui.transform:DOScale(1.0, 0.1):OnComplete(function()
		end)

		local seq = DG.Tweening.DOTween.Sequence()
		local tweenKey = DOTweenManager.AddTweenToLayer(seq, dotweenLayerKey)
		seq:Append(tween1):Append(tween2):Append(tween3):OnKill(function()
			DOTweenManager.RemoveLayerTween(tweenKey)
			if IsEquals(ui.gameObject) then
				ui.transform.localScale = Vector3.one
				ui.gameObject:SetActive(true)
			end
			if cursor >= loop and callback then
				callback()
			end
		end)
	end, interval, loop)
	self.animationTimer:Start()
end
