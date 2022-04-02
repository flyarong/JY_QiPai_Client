local basefunc = require "Game.Common.basefunc"

DdzTyHallPanel = basefunc.class()

DdzTyHallPanel.name = "DdzTyHallPanel"

local lister
local listerRegisterName="ddzTYFreeHallListerRegister"
local curSwitchMatch
local instance
-- 菊花Tag
local have_Jh
local jhTitle = "ddz_ty_jh"
local previousScene = "game_Hall"

function DdzTyHallPanel.Create()
	instance=DdzTyHallPanel.New()
	return createPanel(instance,DdzTyHallPanel.name)
end
function DdzTyHallPanel.Bind()
	local _in = instance
	instance = nil
	return _in
end

function DdzTyHallPanel:Awake()
	MainModel.gameHallLocation = "DdzTyHallPanel"
	ExtendSoundManager.PlaySceneBGM(audio_config.ddz.ddz_bgm_game_hall.audio_name)
	local tran = self.transform
	self.typeContent =  GetPrefab("DdzTyHallPanelTypeContent")
	self.typeItem =  GetPrefab("DdzTyHallPanelTypeItem")
	self.Content = tran:Find("DdzMatchSwitchUI/SVMatch/Viewport/Content").transform
	self.NextButton = tran:Find("NextButton")
	self.BackButton = tran:Find("ImgTop/BackButton")
	self.MoneyText = tran:Find("ImgTop/ImgTicketBG/MoneyText"):GetComponent("Text")
	self.goldBtn = tran:Find("ImgTop/ImgTicketBG")
	
	self.behaviour:AddClick(self.BackButton.gameObject, DdzTyHallPanel.OnBackClick, self)
	self.behaviour:AddClick(self.NextButton.gameObject, DdzTyHallPanel.OnNextClick, self)
	self.behaviour:AddClick(self.goldBtn.gameObject, DdzTyHallPanel.OnGoldClick, self)

	self.updateMoney = function ()
		self:RefreshMoney()
	end

	Event.AddListener("AssetChange", self.updateMoney)

end

function DdzTyHallPanel:Start()
	self:MyInit()
	self:MyRefresh()
end

function DdzTyHallPanel:OnDestroy()
	Event.RemoveListener("AssetChange", self.updateMoney)
	if have_Jh then
		FullSceneJH.RemoveByTag(have_Jh)
		have_Jh=nil
	end
end

--[[初始化功能，创建好panel后在Award中调用，只做一次]]
function DdzTyHallPanel:MyInit()
	self:MakeLister()
	DdzTyLogic.setViewMsgRegister(lister,listerRegisterName)
end

--[[刷新功能，供Logic和model调用，重复性操作]]
function DdzTyHallPanel:MyRefresh()
	self:RefreshMoney()
	self:RefreshGameList(DdzTyModel.tydfg_match_list)
end

-- 刷新钱
function DdzTyHallPanel:RefreshMoney()
	self.MoneyText.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
end

--[[退出功能，供logic和model调用，只做一次]]
function DdzTyHallPanel:MyExit()
	DdzTyLogic.clearViewMsgRegister(listerRegisterName)
	lister = nil
	--closePanel(DdzTyHallPanel.name)
	self.typeContent = nil
	self.typeItem = nil
end
function DdzTyHallPanel:MyClose()
    self:MyExit()
    closePanel(DdzTyHallPanel.name)
end

-- UI关注的事件
function DdzTyHallPanel:MakeLister()
	lister = {}
	lister["tydfgModel_tydfg_req_game_list_response"] = basefunc.handler(self, self.on_tydfg_req_game_list_response)
	lister["tydfgModel_tydfg_signup_fail_response"] = basefunc.handler(self, self.on_tydfg_signup_fail_response)
end

-- 更新游戏列表
function DdzTyHallPanel:RefreshGameList(data)
	if data then
		if have_Jh then
			FullSceneJH.RemoveByTag(have_Jh)
			have_Jh=nil
		end

		dump(self, "<color=yellow>gsf:</color>")
		if IsEquals(self.NextButton) then
			self.NextButton.gameObject:SetActive(false)
		end

		if #data > 6 and IsEquals(self.NextButton) then
			self.NextButton.gameObject:SetActive(true)
		end

		self:CloseCellList()
		data = MathExtend.SortList(data, "ui_order", true)

		destroyChildren(self.Content.transform)
		
		local timer = Timer.New(function ()
			for k,v in pairs(data) do
				self.CellList[#self.CellList + 1] = self:CreateItem(v)
			end
		end, 0.04,1)
		timer:Start()
	else
		if not have_Jh then
			have_Jh = jhTitle
			FullSceneJH.Create("正在请求房间数据",have_Jh)
		end
		Network.SendRequest("tydfg_req_game_list")
	end
end
-- 清空游戏列表
function DdzTyHallPanel:CloseCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			GameObject.Destroy(v)
		end
	end
	self.CellList = {}
end

-- 创建入口Item
function DdzTyHallPanel:CreateItem(data)
	local parent
	if self.Content.transform.childCount == 0 then
		parent =  GameObject.Instantiate(self.typeContent, self.Content)
	else
		parent = self.Content.transform:GetChild(self.Content.transform.childCount - 1)
		if parent.transform.childCount >= 6 then
			parent = GameObject.Instantiate(self.typeContent, self.Content)
		end
	end
	local go = GameObject.Instantiate(self.typeItem, parent.transform)
	local tran = go.transform
	go.name = data.game_id
	local v = DdzTyModel.UIConfig.entrance[data.game_id]
	local bgImage = tran:Find("BGImage"):GetComponent("Image")
	local BaseImage1 = tran:Find("BaseImage1").gameObject
	local BaseImage2 = tran:Find("BaseImage2").gameObject
	local enterText = tran:Find("EnterText"):GetComponent("Text")

	bgImage.name = "BGImage" .. data.game_id
	bgImage.sprite = GetTexture(v.bgImage)
	if v.base <= 0 then
		BaseImage1:SetActive(true)
		BaseImage2:SetActive(false)
		local baseText = tran:Find("BaseImage1/BaseText"):GetComponent("Text")
		baseText.text = "免 费"
	else
		BaseImage1:SetActive(false)
		BaseImage2:SetActive(true)
		local baseText = tran:Find("BaseImage2/BaseText"):GetComponent("Text")
		baseText.text = "x" .. StringHelper.ToCash(v.base)
	end

	if v.enterMin < 0 and v.enterMax < 0 then
		enterText.text = "入场范围：无"
	elseif v.enterMin < 0 and v.enterMax > 0 then
		enterText.text = "入场范围：" .. StringHelper.ToCash(v.enterMax) .. "以下"
	elseif v.enterMin > 0 and v.enterMax < 0 then
		enterText.text = "入场范围：" .. StringHelper.ToCash(v.enterMin) .. "以上"
	else
		enterText.text = "入场范围：" .. StringHelper.ToCash(v.enterMin) .. "~" .. StringHelper.ToCash(v.enterMax)
	end
	self.behaviour:AddClick(bgImage.gameObject, DdzTyHallPanel.OnEnterClick, self)
	return go
end

--退出
function DdzTyHallPanel:OnBackClick( go )
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	MainLogic.GotoScene(previousScene)
end

--查看更多比赛
function DdzTyHallPanel:OnNextClick( go )
	local x=self.Content.transform.localPosition.x - 1705
	local tweenKey 
	local action=self.Content.transform:DOLocalMoveX(x, 0.2):OnKill(function ()
							DOTweenManager.RemoveStopTween(tweenKey)
							if IsEquals(self.Content) then
								self.Content.transform.localPosition.x=x
							end
						end)
	tweenKey = DOTweenManager.AddTweenToStop(action)
end

function DdzTyHallPanel:OnGoldClick( go )
	PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end

-- 入口选择
function DdzTyHallPanel:OnEnterClick(go)
	local id = tonumber(go.transform.parent.name)
	local v = DdzTyModel.UIConfig.entrance[id]
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	
	local signup = function ()
		DdzTyModel.data.hallGameID = id
		if id then
			if not Network.SendRequest("tydfg_signup", {id = id}, "正在报名") then
				HintPanel.Create(1, "网络异常")
				return
			end
		else
			HintPanel.Create(1,"游戏ID= " .. id .. " 没有对应的signup_service_id")
		end
	end

	local ss = DdzTyModel.IsRoomEnter(id)
	if ss == 1 then
		PayFastFreePanel.Create(DdzTyModel.UIConfig.entrance[id], signup)
		return
	end
	if ss == 2 then
		HintPanel.Create(1, "您持有鲸币过高，无法进入该场游戏")
		return
	end
	
	signup()
end


--[[*********************
网络数据刷新
*********************--]]
-- 收到游戏列表数据
function DdzTyHallPanel:on_tydfg_req_game_list_response(result)
	print("<color=red>收到游戏列表数据</color>")
	if have_Jh then
		FullSceneJH.RemoveByTag(have_Jh)
		have_Jh=nil
	end
	if result == 0 then
		self:RefreshGameList(DdzTyModel.tydfg_match_list)
	else
		if have_Jh then
			FullSceneJH.RemoveByTag(have_Jh)
			have_Jh=nil
		end
		HintPanel.Create(1,"获取游戏列表失败\n"..result,function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			MainLogic.GotoScene("game_Hall")
		end)
	end	
end
function DdzTyHallPanel:on_tydfg_signup_fail_response(result)
	local msg = errorCode[result] or ("错误："..result)

    HintPanel.Create(1, msg, function ()
        --清除数据
        Network.SendRequest("tydfg_req_game_list", nil, "正在请求房间数据")
    end)
end
