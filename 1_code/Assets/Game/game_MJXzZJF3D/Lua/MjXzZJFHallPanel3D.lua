--ganshuangfeng 比赛场界面
--2018-04-17
local basefunc = require "Game.Common.basefunc"
MjXzFKHallPanel = basefunc.class()

MjXzFKHallPanel.name = "MjXzFKHallPanel3D"
local lister
local listerRegisterName="MjXzFKFreeHallListerRegister"
local curSwitchMatch
local instance

function MjXzFKHallPanel.Create()
	instance=MjXzFKHallPanel.New()
	return createPanel(instance,MjXzFKHallPanel.name)
end
function MjXzFKHallPanel.Bind()
	local _in = instance
	instance = nil
	return _in
end

function MjXzFKHallPanel:Awake()
	MainModel.gameHallLocation = "MjXzFKHallPanel"
	ExtendSoundManager.PlaySceneBGM(audio_config.mj.majiang_bgm_hall.audio_name)
	local tran = self.transform
	self.typeContent =  GetPrefab("MjXzFKHallPanelTypeContent")
	self.typeItem =  GetPrefab("MjXzFKHallPanelTypeItem")
	self.Content = tran:Find("DdzMatchSwitchUI/SVMatch/Viewport/Content").transform
	self.NextButton = tran:Find("NextButton")
	self.BackButton = tran:Find("ImgTop/BackButton")
	self.MoneyText = tran:Find("ImgTop/ImgTicketBG/MoneyText"):GetComponent("Text")
	self.goldBtn = tran:Find("ImgTop/ImgTicketBG")

	--- 动态创建场景
	self.majiang_fj = GameObject.Instantiate( GetPrefab( "majiang_fj" ) , self.transform.parent.parent.parent )
	self.majiang_fj.name = "majiang_fj"
	self.lights = GameObject.Instantiate( GetPrefab( "Lights" ) , self.transform.parent.parent.parent )
	self.lights.name = "Lights"


	self.behaviour:AddClick(self.BackButton.gameObject, MjXzFKHallPanel.OnBackClick, self)
	self.behaviour:AddClick(self.NextButton.gameObject, MjXzFKHallPanel.OnNextClick, self)
	self.behaviour:AddClick(self.goldBtn.gameObject, MjXzFKHallPanel.OnGlodClick, self)

	self.updateMoney = function ()
		self:RefreshMoney()
	end

	Event.AddListener("AssetChange", self.updateMoney)

end

function MjXzFKHallPanel:Start()
	self:MyInit()
	self:MyRefresh()
end

function MjXzFKHallPanel:OnDestroy()
	Event.RemoveListener("AssetChange", self.updateMoney)
end

--[[初始化功能，创建好panel后在Award中调用，只做一次]]
function MjXzFKHallPanel:MyInit()
	self:MakeLister()
	MjXzFKLogic.setViewMsgRegister(lister,listerRegisterName)
end

--[[刷新功能，供Logic和model调用，重复性操作]]
function MjXzFKHallPanel:MyRefresh()
	self:RefreshMoney()
	self:RefreshGameList(MjXzFKModel.gameList)
end

-- 刷新钱
function MjXzFKHallPanel:RefreshMoney()
	self.MoneyText.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
end

--[[退出功能，供logic和model调用，只做一次]]
function MjXzFKHallPanel:MyExit()
	MjXzFKLogic.clearViewMsgRegister(listerRegisterName)
	lister = nil
	--closePanel(MjXzFKHallPanel.name)
	self.typeContent = nil
	self.typeItem = nil
end
function MjXzFKHallPanel:MyClose()
    self:MyExit()
    closePanel(MjXzFKHallPanel.name)
end

-- UI关注的事件
function MjXzFKHallPanel:MakeLister()
	lister = {}
	lister["model_nor_mj_xzdd_req_game_list_response"] = basefunc.handler(self, self.RecGameList)
	lister["model_nor_mj_xzdd_signup_fail_response"] = basefunc.handler(self, self.RecSignup)
end

-- 更新游戏列表
function MjXzFKHallPanel:RefreshGameList(data)
	if data then
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
		Network.SendRequest("nor_mj_xzdd_req_game_list", nil, "正在请求房间数据")
	end
end

-- 创建入口Item
function MjXzFKHallPanel:CreateItem(data)
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
	local v = MjXzFKModel.UIConfig.entrance[data.game_id]
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
	self.behaviour:AddClick(bgImage.gameObject, MjXzFKHallPanel.OnEnterClick, self)
	return go
end

--退出
function MjXzFKHallPanel:OnBackClick( go )
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	MainLogic.GotoScene("game_Hall")
end

--查看更多比赛
function MjXzFKHallPanel:OnNextClick( go )
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

function MjXzFKHallPanel:OnGlodClick( go )
	PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end

-- 清空游戏列表
function MjXzFKHallPanel:CloseCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			GameObject.Destroy(v)
		end
	end
	self.CellList = {}
end
-- 入口选择
function MjXzFKHallPanel:OnEnterClick(go)
	if MjXzFKModel.gameList then
		local id = tonumber(go.transform.parent.name)
		local v = MjXzFKModel.UIConfig.entrance[id]
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		
		local ss = MjXzFKModel.IsRoomEnter(id)
		if ss == 1 then
			HintPanel.Create(3, "当前场次入场要求为" .. StringHelper.ToCash(v.enterMin) .. "鲸币以上\n您鲸币不足，请前往购买", function ()
			PayPanel.Create(GOODS_TYPE.jing_bi)
		end)
			return
		end
		if ss == 2 then
			HintPanel.Create(1, "您的鲸币持有量过高，请选择更高级别场次")
			return
		end
	
		MjXzFKModel.data.hallGameID = id
		
		if id then
			if not Network.SendRequest("nor_mj_xzdd_signup", {id = id}, "正在报名") then
				HintPanel.Create(1, "网络异常")
			end
		else
			HintPanel.Create(1,"游戏ID= " .. id .. " 没有对应的signup_service_id")
		end
	else
		Network.SendRequest("nor_mj_xzdd_req_game_list", nil, "正在请求房间数据")
	end
end


--[[*********************
网络数据刷新
*********************--]]
-- 收到游戏列表数据
function MjXzFKHallPanel:RecGameList(result)
	if result == 0 then
		self:RefreshGameList(MjXzFKModel.gameList)
	else
		HintPanel.Create(1,"获取游戏列表失败\n"..result,function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			MainLogic.GotoScene("game_Hall")
		end)
	end	
end
function MjXzFKHallPanel:RecSignup(result)
	HintPanel.ErrorMsg(result,function (  )
		--清除数据
		Network.SendRequest("nor_mj_xzdd_req_game_list", nil, "正在请求房间数据")
	end)
end