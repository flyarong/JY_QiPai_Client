-- 创建时间:2018-10-15
local basefunc = require "Game.Common.basefunc"

GameFreeHallPanel = basefunc.class()

GameFreeHallPanel.name = "GameFreeHallPanel"

--用于进行变换的数额
local change_money = 500

local instance
function GameFreeHallPanel.Create(parm)
	instance = GameFreeHallPanel.New(parm)
	return instance
end

function GameFreeHallPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function GameFreeHallPanel:MakeLister()
    self.lister = {}
    self.lister["AssetChange"] = basefunc.handler(self, self.UpdateAssetInfo)
end

function GameFreeHallPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end


function GameFreeHallPanel:MyExit()
	if self.game_btn_pre then
		self.game_btn_pre:MyExit()
	end
	DSM.PopAct()
	self:RemoveListener()
	if self.get_cash_timer then
		self.get_cash_timer:Stop()
		self.get_cash_timer = nil
	end

	if self.update_timer then
		self.update_timer:Stop()
		self.update_timer = nil
	end

	 
end

function GameFreeHallPanel:ctor(parm)

	ExtPanel.ExtMsg(self)
	self.dot_del_obj = true

	DSM.PushAct({panel = "GameFreeHallPanel"})
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(GameFreeHallPanel.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self.parm = parm

	self:MakeLister()
	self:AddMsgListener()

	self.AddGold = tran:Find("TopRect/RectTop/JBBG"):GetComponent("Button")
	self.AddGold.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnAddGold()
	end)
	self.AddDiamond = tran:Find("TopRect/@not_zjf_node/ZSBG"):GetComponent("Button")
	self.AddDiamond.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnAddDiamond()
	end)
	self.DuihuanButton = tran:Find("TopRect/RectTop/DuihuanButton"):GetComponent("Button")
	self.DuihuanButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnDHClick()
	end)
	if GameGlobalOnOff.Exchange then
		self.DuihuanButton.gameObject:SetActive(true)
	else
		self.DuihuanButton.gameObject:SetActive(false)
	end


	self.KSButton = tran:Find("CenterRect/KSButton"):GetComponent("Button")
	self.KSButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnKSClick()
	end)
	self.KSText = tran:Find("CenterRect/KSButton/KSText"):GetComponent("Text")
	self.RedPacketText = tran:Find("TopRect/RectTop/DuihuanButton/red_packet/RedPacketText"):GetComponent("Text")

	self.ScrollViewRight = tran:Find("CenterRect/ScrollViewRight")
	self.GoldText = tran:Find("TopRect/RectTop/JBBG/GoldText"):GetComponent("Text")
	self.DiamondText = tran:Find("TopRect/@not_zjf_node/ZSBG/DiamondText"):GetComponent("Text")
	self.LeftNode = tran:Find("CenterRect/ScrollViewLeft/Viewport/Content")
	self.RightNode = tran:Find("CenterRect/ScrollViewRight/Viewport/Content")
	self.OperatorRect = tran:Find("CenterRect/OperatorRect")
	self.OperatorNode = tran:Find("CenterRect/OperatorRect/ScrollViewOperator/Viewport/Content")
	self.OperatorDescRect = tran:Find("CenterRect/OperatorRect/OperatorDescRect")
	self.notOpenYet = tran:Find("CenterRect/OperatorRect/OperatorDescRect/NotOpenYet"):GetComponent("Text")
	self.ODTimeText = tran:Find("CenterRect/OperatorRect/OperatorDescRect/ODTimeText"):GetComponent("Text")
	self.ODDescText = tran:Find("CenterRect/OperatorRect/OperatorDescRect/ODDescText"):GetComponent("Text")
	self.ODNameImage = tran:Find("CenterRect/OperatorRect/OperatorDescRect/ODNameImage"):GetComponent("Image")
	self.ODStateText = tran:Find("CenterRect/OperatorRect/OperatorDescRect/ODStateText"):GetComponent("Text")
	self.ODFillButton = tran:Find("CenterRect/OperatorRect/ODFillButton"):GetComponent("MyButton")
	self.ODFillButton.onClick:AddListener(function ()
		self:OnFillButton()
	end)
	self.zif_btn.onClick:AddListener(function ()
		GameManager.GotoUI({gotoui="game_ZJF",})
	end)
	-- self.fk_btn.onClick:AddListener(function ()
	-- 	RoomCardHallPopPrefab.Create()
	-- end)
	self.JJImage = tran:Find("CenterRect/OperatorRect/OperatorDescRect/JJImage")
	self.BackButton = tran:Find("TopRect/RectTop/BackButton")
	--EventTriggerListener.Get(self.BackButton.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
	self.BackButton:GetComponent("Button").onClick:AddListener(
		function()
			self:OnBackClick()
		end
	)
	self:InitUI()
	Event.Brocast("PPC_Created",{panelSelf = self})

	local btn_map = {}
	btn_map["left_top"] = {self.TLNode}
	btn_map["left_bottom"] = {self.BLNode}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "freehall_config", self.transform)

	if GameFreeHallPanel:CheakPerMiss() then
		self.zjf_node.gameObject:SetActive(true)
		self.not_zjf_node.gameObject:SetActive(false)
	else
		self.zjf_node.gameObject:SetActive(false)
		self.not_zjf_node.gameObject:SetActive(true)
	end
end

function GameFreeHallPanel:InitUI()
	ExtendSoundManager.PlaySceneBGM(audio_config.game.bgm_pipeichangbeijing.audio_name)
	local parm = self.parm

	self:ClearCellList()
	self.gamelist = {}
	for k,v in ipairs(GameFreeModel.UIConfig.gamelist) do
		self.gamelist[#self.gamelist + 1] = {id=v, isOpen = true}
	end
	if GameFreeModel.UIConfig.closegamelist then
		for k,v in ipairs(GameFreeModel.UIConfig.closegamelist) do
			self.gamelist[#self.gamelist + 1] = {id=v, isOpen = false}
		end
	end

	--[[local game_type
	dump(parm, "<color=yellow>parm</color>")
	if parm then
		parm = MainModel.GetServerToClientScene(parm)
	end

	for k,v in ipairs(self.gamelist) do
		local pre = GameFreeLeftItemPrefab.Create(self.LeftNode.transform, v, GameFreeHallPanel.OnToggleClick, self)
		pre:SetObjName(k)
		self.CellList[#self.CellList + 1] = pre
		if not parm and k == 1 then
			self:CallToggleClick(k)
		end
		local data = GameFreeModel.UIConfig.game[self.gamelist[k].id]
		
		if parm and parm == data.game_type then
			self:CallToggleClick(k)
		end
	end]]
	self.GoldText.text =  StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	self.DiamondText.text = StringHelper.ToCash(MainModel.UserInfo.diamond)
	self.RedPacketText.text = StringHelper.ToRedNum(MainModel.GetHBValue())
	self:InitGameList()

	Event.Brocast("gamefreehallpanel_open_finish")
end

-------------------------------------------------------------------------------------
function GameFreeHallPanel:InitGameList()
	self.spaceH = 8
	local viewSubItemNum = 4
	local defaultIndex = 1
	local globalCfg = GameFreeModel.UIConfig.global
	local gameCfg = GameFreeModel.UIConfig.game
	local SMIRect = self["ListItem_tmpl"]:GetComponent("RectTransform").rect
	local gridLayout = self["RootMenuItem_tmpl"]:Find("GameList/Viewport/Content"):GetComponent("GridLayoutGroup")
	local gridMaxH = SMIRect.height * (viewSubItemNum + 0.5) + self.spaceH * (viewSubItemNum + 2)
	self.RootMenuH = self["RootMenu"]:GetComponent("RectTransform").rect.height
	self.MenuItemH = self["RootMenuItem_tmpl"]:GetComponent("RectTransform").rect.height
	gridLayout.cellSize = Vector2.New(SMIRect.width, SMIRect.height)
	gridLayout.spacing = Vector2.New(0, self.spaceH)

	dump(self.parm, "<color=yellow>parm</color>")
	if self.parm then
		self.parm = MainModel.GetServerToClientScene(self.parm)
	end

	self.GameMenu = {}
	for k, v in ipairs(globalCfg) do
		local count = #v.ids
		local menuItem = GameObject.Instantiate(self["RootMenuItem_tmpl"], self["RootMenu"])
		local normalBtn = menuItem.transform:Find("normal_btn").gameObject
		local clickedBtn = menuItem.transform:Find("clicked_btn").gameObject
		local gList = menuItem.transform:Find("GameList")
		local viewRect = gList:GetComponent("RectTransform")
		local viewList = menuItem.transform:Find("GameList/Viewport/Content")
		local subTotalH = math.min(gridMaxH, count * (SMIRect.height + self.spaceH) + self.spaceH * 2)
		menuItem.gameObject:SetActive(true)
		menuItem.gameObject.name = k
		menuItem.transform.localPosition = Vector3.New(0, self.RootMenuH/2 - k * self.MenuItemH + self.MenuItemH/2, 0)
		gList.gameObject:SetActive(false)
		viewRect.sizeDelta = Vector2.New(viewRect.rect.width, subTotalH)
		gList.transform.localPosition = Vector3.New(0, -(self.MenuItemH + subTotalH + self.spaceH)/2, 0)

		normalBtn:GetComponent("Image").sprite = GetTexture(v.nor_icon)
		clickedBtn:GetComponent("Image").sprite = GetTexture(v.sel_icon)

		self.GameMenu[k] = {menuItem = menuItem, gameList = gList, viewH = subTotalH, items = {}}
		for i, id in ipairs(v.ids) do
			for _, g in ipairs(gameCfg) do
				if g.id == id then
					local listItem = GameObject.Instantiate(self["ListItem_tmpl"], viewList)
					local norTitle = listItem.transform:Find("nor_img/nor_title"):GetComponent("Image")
					local selTitle = listItem.transform:Find("sel_img/sel_title"):GetComponent("Image")
					local ej_tag_img = listItem.transform:Find("ej_tag_img"):GetComponent("Image")
					norTitle.sprite = GetTexture(g.noimage)
					norTitle:SetNativeSize()
					selTitle.sprite = GetTexture(g.hiimage)
					selTitle:SetNativeSize()
					if g.tag then
						ej_tag_img.gameObject:SetActive(true)
						ej_tag_img.sprite = GetTexture(g.tag)
						ej_tag_img:SetNativeSize()
					else
						ej_tag_img.gameObject:SetActive(false)
					end
					listItem.gameObject:SetActive(true)
					self.GameMenu[k].items[i] = listItem.gameObject

					for index, gl in ipairs(self.gamelist) do
						if gl.id == id then
							listItem.name = index
							break
						end
					end
					
					--dont use EventTriggerListener to make the list scrollable
					listItem.gameObject:GetComponent("Button").onClick:AddListener(function ()
						self:UnselectSubMenuItem(self.lastSelBtn)
						self:SelectSubMenuItem(listItem.gameObject)
					end)

					if self.parm and self.parm == g.game_type then
						defaultIndex = k
						self.defSubIndex = i
					end
					break
				end
			end
		end

		if #globalCfg == 1 then
			if IsEquals(normalBtn) then
				normalBtn.gameObject:GetComponent("Button").enabled = false
			end
			if IsEquals(clickedBtn) then
				clickedBtn.gameObject:GetComponent("Button").enabled = false
			end
		else
			normalBtn.gameObject:GetComponent("Button").onClick:AddListener(function ()
				self:SelectMenuItem(tonumber(normalBtn.transform.parent.name))
			end)

			clickedBtn.gameObject:GetComponent("Button").onClick:AddListener(function ()
				self:SelectMenuItem(tonumber(normalBtn.transform.parent.name))
			end)
		end
	end

	self:SelectMenuItem(defaultIndex)
	self.defSubIndex = nil
end

function GameFreeHallPanel:SelectMenuItem(index)
	local isFold = (self.CurRootMenuIndex and self.CurRootMenuIndex == index)
	if self.CurRootMenuIndex then
		self:FoldMenuList(self.CurRootMenuIndex, true)
		self.CurRootMenuIndex = nil
	end
	
	if not isFold then
		self.CurRootMenuIndex = index
		self:FoldMenuList(index, false)
	end
	
	--self:UpdateMenuItemPos(index, isFold)
end

function GameFreeHallPanel:UpdateMenuItemPos(selItemIndex, isFold)
	local subOffY = (isFold and 0 or (selItemIndex * self.MenuItemH + self.GameMenu[selItemIndex].viewH + self.spaceH - self.RootMenuH))
	local off = Vector3.New(0, self.GameMenu[selItemIndex].viewH, 0)
	for i, mi in ipairs(self.GameMenu) do
		local pos = Vector3.New(0, self.RootMenuH/2 - i * self.MenuItemH + self.MenuItemH/2 + (subOffY > 0 and subOffY or 0), 0)
		self.GameMenu[i].menuItem.transform.localPosition = ((i <= selItemIndex or isFold) and pos or pos - off)
	end
end

function GameFreeHallPanel:UpdateSubMenuItemPos()
	if self.lastSelBtn then
		local subIdx = tonumber(self.lastSelBtn.name)
		local rootMenuItem = self.GameMenu[self.CurRootMenuIndex]
		local viewH = rootMenuItem.viewH
		local subItem = rootMenuItem.items[1]
		local index = 0

		for _, it in ipairs(rootMenuItem.items) do
			index = index + 1
			if it.name == self.lastSelBtn.name then
				subItem = it
				break
			end
		end

		local parent = subItem.transform.parent
		local rect = subItem.gameObject:GetComponent("RectTransform").rect
		local parentY = parent.localPosition.y
		local posY = -((index - 1) * (rect.height + self.spaceH) + rect.height/2)--subItem.transform.localPosition.y

		--log("<color=yellow>subIdx:" .. subIdx .. ", viewH:" .. viewH .. ", posY:" .. posY .. ", parentY:" .. parentY .. "</color>")
		if (posY + rect.height/2 + parentY) > 1 then
			parent.localPosition = Vector3.New(0, -(posY + rect.height/2), 0)
		elseif (posY - rect.height/2 + parentY) < -(viewH + 1) then
			parent.localPosition = Vector3.New(0, -(viewH + posY - rect.height/2), 0)
		end
	end
end

function GameFreeHallPanel:FoldMenuList(index, isFold)
	if self.GameMenu and self.GameMenu[index] then
		local item = self.GameMenu[index].menuItem
		item:Find("normal_btn").gameObject:SetActive(isFold)
		item:Find("clicked_btn").gameObject:SetActive(not isFold)
		self.GameMenu[index].gameList.gameObject:SetActive(not isFold)

		if isFold then
			self:UnselectSubMenuItem(self.lastSelBtn)
		elseif #self.GameMenu[index].items > 0 then
			self:SelectSubMenuItem(self.GameMenu[index].items[self.defSubIndex or 1])
		end

		self:UpdateRootMenuHeight(index, isFold)
	end
end

function GameFreeHallPanel:SelectSubMenuItem(btn)
	if btn then
		self:OnToggleClick(btn)
		btn.transform:Find("nor_img").gameObject:SetActive(false)
		btn.transform:Find("sel_img").gameObject:SetActive(true)
		self.lastSelBtn = btn
		self:UpdateSubMenuItemPos()
	end
end

function GameFreeHallPanel:UnselectSubMenuItem(btn)
	if btn then
		btn.transform:Find("nor_img").gameObject:SetActive(true)
		btn.transform:Find("sel_img").gameObject:SetActive(false)
		self.lastSelBtn = nil
	end
end

function GameFreeHallPanel:UpdateRootMenuHeight(index, isFold)
	if self.GameMenu and self.GameMenu[index] then
		local height = self.MenuItemH
		local viewH = self.GameMenu[index].viewH
		local rect = self.GameMenu[index].menuItem:GetComponent("RectTransform")
		rect.sizeDelta = Vector2.New(rect.rect.width, isFold and height or (height + viewH))

		--force update
		local csf = self.RootMenu.gameObject:GetComponent("ContentSizeFitter")
		csf.enabled = false
		csf.enabled = true
	end
end
-------------------------------------------------------------------------------------

function GameFreeHallPanel:UpdateAssetInfo()
	if IsEquals(self.GoldText) and  IsEquals(self.DiamondText) and IsEquals(self.RedPacketText) then
		self.GoldText.text =  StringHelper.ToCash(MainModel.UserInfo.jing_bi)
		self.DiamondText.text = StringHelper.ToCash(MainModel.UserInfo.diamond)
		self.RedPacketText.text = StringHelper.ToRedNum(MainModel.GetHBValue())
		self:UpdateKS()
	end
end


-- 刷新运营活动
function GameFreeHallPanel:UpdateOperator()

	local gameId = self.gamedata[self.selectGameIndex].game_id
	Event.Brocast("free_hall_select_index_change",{game_id = gameId})
	dump(gameId,"<color=red>当前选中游戏的ID</color>")
	local a,b = GameButtonManager.RunFun({gotoui="sys_act_operator"}, "CheckIsShow")
	-----vivo------------------
	if a or  b then return end
	self:ClearOperatorCellList()
	local a,b = GameButtonManager.RunFun({gotoui="sys_act_operator",game_id = gameId}, "GetActivityStateByFreeID")
	if a and not table_is_null(b) then
		self.operator_data = b
	end
	if not IsEquals(self.OperatorRect) then
		self.OperatorRect = tran:Find("CenterRect/OperatorRect")
	end
	local a,b = GameButtonManager.RunFun({gotoui="sys_act_operator",game_id = gameId}, "IsNotShowID")
	local is_show = a and b
	if self.operator_data and not is_show then
		if IsEquals(self.OperatorRect) then
			self.OperatorRect.gameObject:SetActive(true)
		end
		for k,v in ipairs(self.operator_data) do
			local pre = FreeOperatorPrefab.Create(self.OperatorNode.transform, v, GameFreeHallPanel.OnOperatorClick, self, k, gameId)
			self.OperatorCellList[#self.OperatorCellList + 1] = pre
		end
	else
		if IsEquals(self.OperatorRect) then
		self.OperatorRect.gameObject:SetActive(false)
		end
	end

	self.select_operator_index = nil
	self.OperatorDescRect.gameObject:SetActive(false)
end
function GameFreeHallPanel:ClearOperatorCellList()
	if self.OperatorCellList then
		for k,v in ipairs(self.OperatorCellList) do
			v:OnDestroy()
		end
	end
	self.OperatorCellList = {}
end

function GameFreeHallPanel:OnOperatorClick(index)

	if not self.gamedata then return end
	self.operator_data = nil
	local a,b = GameButtonManager.RunFun({gotoui="sys_act_operator",game_id = self.gamedata[self.selectGameIndex].game_id}, "GetActivityStateByFreeID")

	-------------vivo关闭 
	if a and table_is_null(b) then
		self.operator_data = b
	end
	if not self.operator_data then return end
	if self.select_operator_index and self.select_operator_index == index then
		self.select_operator_index = nil
		self.OperatorDescRect.gameObject:SetActive(false)
	else
		self.OperatorDescRect.gameObject:SetActive(true)
		self.select_operator_index = index
		local cfg = self.operator_data[self.select_operator_index]
		self.ODTimeText.text = cfg.time_desc
		self.ODDescText.text = cfg.activity_config.desc
		self.ODNameImage.sprite = GetTexture("pp_imgf_" .. cfg.activity_config.activity_icon .. "_b")
		self.ODNameImage:SetNativeSize()
		if cfg.state == "yes" then
			self.ODStateText.text = "进行中..."
			self.notOpenYet.text = ""
		elseif cfg.state == "no" then
			self.ODStateText.text = "未开始"
			self.notOpenYet.text = ""
		else
			self.ODStateText.text = "已关闭"
			self.notOpenYet.text = ""
		end

		local obj = self.OperatorCellList[self.select_operator_index]:GetIconTransform()
		local pp1 = obj:TransformPoint(self.JJImage.transform.localPosition)
        local lp = self.JJImage.transform:InverseTransformPoint(pp1)
		self.JJImage.transform.localPosition = Vector3.New(lp.x, -66.5, 0)
	end
end

-- 刷新快速开始
function GameFreeHallPanel:UpdateKS()
	if not self.gamelist or not self.selectIndex then
		return
	end
	local data = GameFreeModel.UIConfig.game[self.gamelist[self.selectIndex].id]

	local _,ksdata = GameFreeModel.GetRapidBeginGameID(data.game_type)
	if ksdata then
		self.ksdata = ksdata
		if IsEquals(self.KSText) then
			self.KSText.text = ksdata.game_name
		end
		self:SetSelectGame(ksdata.imageIndex)
		DSM.PushAct({info = {fg_cfg = ksdata,is_auto = true}})
	else
		print("<color=red>快速开始游戏无数据</color>")
	end
end

-- 设置选中的游戏
function GameFreeHallPanel:SetSelectGame(index, isanim)
	if not self.selectGameIndex or self.selectGameIndex ~= index then
		self.selectGameIndex = index
	end
	if self.RightCellList then
		for k,v in ipairs(self.RightCellList) do
			v:SetSelectFX(self.selectGameIndex, isanim)
		end
		self:UpdateOperator()
	end
end

function GameFreeHallPanel:UpdateLeftDownHint()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:UpdateDownHint()			
		end
	end
end

function GameFreeHallPanel:ClearCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:OnDestroy()
		end
	end
	self.CellList = {}
end

function GameFreeHallPanel:OnToggleClick(obj)
	local i = tonumber(obj.name)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	if not self.gamelist[i].isOpen then
		HintPanel.Create(1, "敬请期待")
		return
	end
	local data = GameFreeModel.UIConfig.game[self.gamelist[i].id]
	if GameSceneCfg[data.sceneID] then
		local sceneName = GameSceneCfg[data.sceneID].SceneName
		local state = gameMgr:CheckUpdate(sceneName)
		if state == "Install" or state == "Update" then
			RoomCardDown.Create(sceneName, function ()
				self:CallToggleClick(i)
			end)
			return
		end
	else
	end

    self:CallToggleClick(i)
end
function GameFreeHallPanel:CallToggleClick(i)
	if self.selectIndex and self.selectIndex == i then
		return
	end
	--[[if self.selectIndex then
		self.CellList[self.selectIndex]:SetSelect(false)
	end]]

	self.selectIndex = i
	--self.CellList[self.selectIndex]:SetSelect(true)

	self:UpdateRight()
	self:UpdateLeftDownHint()

	self:RightAnim()
	if GuideLogic then
		GuideLogic.CheckRunGuide("free_hall")
	end
end
function GameFreeHallPanel:RightAnim()
	if self.RightCellList then
		local i = 0
		local tt = 0.1
		for k,v in ipairs(self.RightCellList) do
			v:PlayAnim(i * tt)
			i = i + 1			
		end
	end
end
function GameFreeHallPanel:OpenUIAnimFinish()
	self.ScrollViewRight.transform.localPosition = Vector3.New(340, 106, 0)
	self.seq = nil
end

function GameFreeHallPanel:UpdateRight()
	self:ClearRightCell()
	if not self.gamelist then return end
	local data = GameFreeModel.UIConfig.game[self.gamelist[self.selectIndex].id]
	local gamedata = GameFreeModel.GetGameConfig(data.game_type)
	GameFreeModel.SetCurrGameConfig(gamedata)
	GameFreeModel.SetCurrSceneID(data.sceneID)
	
	if gamedata then
		self.gamedata = MathExtend.SortList(gamedata, "order", true)
		for k,v in ipairs(self.gamedata) do
			if not IsEquals(self.RightNode) then
				self.RightNode = self.transform:Find("CenterRect/ScrollViewRight/Viewport/Content")
			end
			local pre = GameFreeRightItemPrefab.Create(self.RightNode.transform, v, GameFreeHallPanel.OnEnterClick, self, k)
			pre:SetObjName("free_hall_game_" .. k)
			self.RightCellList[#self.RightCellList + 1] = pre
		end

		self.RightNode.localPosition = Vector3.zero
		self:UpdateKS()
	else
		HintPanel.Create(1, "敬请期待")
	end
end

-- 入口选择
function GameFreeHallPanel:OnEnterClick(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	if not self.gamedata then return end
    local id = go
	local v = self.gamedata[id]
    if v.isLock and v.isLock == 1 then
    	HintPanel.Create(1, "敬请期待")
    	return
    end
	if not self.selectGameIndex or self.selectGameIndex ~= id then
		self:SetSelectGame(id, true)
		DSM.PushAct({info = {fg_cfg = v}})
	else
		self:CallEnter(v.game_id)
	end
end
function GameFreeHallPanel:CallEnter(game_id)
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="freestyle_game_"..game_id,vip_hint_type = 2, cw_btn_desc = "确定"}, "CheckCondition")
    if a and not b then
    	return
    end
	local xsyd_signup = function ()
        print("<color=red>匹配场新手引导 报名 》》》》》 </color>")
		GameManager.CommonGotoScence({gotoui=GameSceneCfg[GameFreeModel.data.sceneID].SceneName, p_requset={id = game_id, xsyd = 1}})
    end
    local signup = function()   	
		if not GameFreeModel or not GameFreeModel.data or not GameFreeModel.data.sceneID or not GameSceneCfg[GameFreeModel.data.sceneID] then
			LittleTips.Create("数据错误")
			return
		end
		GameManager.CommonGotoScence({gotoui=GameSceneCfg[GameFreeModel.data.sceneID].SceneName, p_requset={id = game_id}})
    end
    local check
    check = function ()
		local ss = GameFreeModel.IsRoomEnter(game_id)
		if ss == 1 then
			LittleTips.Create("当前鲸币不足")
			if GameGlobalOnOff.Shop_10_gift_bag ~= nil and GameGlobalOnOff.Shop_10_gift_bag == false then
				local dd = GameFreeModel.GetGameIDToConfig(game_id)
				PayFastFreePanel.Create(dd, check)
			else
				self:BuyCoin(game_id, check)
			end
	        return
	    end
	    if ss == 2 then
			local pre = HintPanel.Create(2, "您太富有了，更高级的场次才适合您！", function ()
				self:UpdateKS()
	        	self:OnKSClick()
	        end)
	        pre:SetButtonText(nil, "前 往")
	        return
	    end
        if GuideLogic and GuideLogic.IsFreeBattle() then
            xsyd_signup()
        else
            signup()
        end
    end
    check()
end

-- 快速选择
function GameFreeHallPanel:OnKSClick()
	dump(self.ksdata, "<color=yellow>快速选择</color>")
	if self.ksdata then
		self:CallEnter(self.ksdata.game_id)
	end
end

function GameFreeHallPanel:ClearRightCell()
	if self.RightCellList then
		for k,v in ipairs(self.RightCellList) do
			v:OnDestroy()
		end
	end
	self.RightCellList = {}
end

-- 关闭
function GameFreeHallPanel:OnBackClick()
	--[[local c,d = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="minigame_guide", is_on_hint = true}, "CheckCondition")
    if c and d then
		GameFreeMiniGameGuidePanel.Create()
	else
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		MainLogic.GotoScene("game_Hall")
	end--]]
	MainLogic.GotoScene("game_Hall")
end

function GameFreeHallPanel:OnAddGold()
	PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end

function GameFreeHallPanel:OnAddDiamond()
	PayPanel.Create(GOODS_TYPE.goods, "normal")
end

function GameFreeHallPanel:OnDHClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    MainModel.OpenDH()
end

function GameFreeHallPanel:OnFillButton()
	self.select_operator_index = nil
	if not IsEquals(self.transform) then return end
	if not IsEquals(self.OperatorDescRec) then
		self.OperatorDescRect = self.transform:Find("CenterRect/OperatorRect/OperatorDescRect")
	end
	self.OperatorDescRect.gameObject:SetActive(false)
end

function GameFreeHallPanel:BuyCoin(game_id, check)
	local dd = GameFreeModel.GetGameIDToConfig(game_id)
	-- if dd.order == 1 then
	-- 	OneYuanGift.Create(nil, function ()
	-- 		PayFastFreePanel.Create(dd, check)
	-- 	end)
	-- else
		PayFastFreePanel.Create(dd, check)
	-- end
end

function GameFreeHallPanel:CheakPerMiss()
	-- local _permission_key = "zijianfang"
	-- if _permission_key then
	-- 	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
	-- 	if a and not b then
	-- 		return false
	-- 	end
	-- 	return true
	-- else
	-- 	return true
	-- end
	return false
end