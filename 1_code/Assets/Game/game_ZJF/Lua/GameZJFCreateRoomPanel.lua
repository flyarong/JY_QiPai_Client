-- 创建时间:2018-10-15
local basefunc = require "Game.Common.basefunc"

GameZJFCreateRoomPanel = basefunc.class()

GameZJFCreateRoomPanel.name = "GameZJFCreateRoomPanel"

local instance
function GameZJFCreateRoomPanel.Create(parm)
	instance = GameZJFCreateRoomPanel.New(parm)
	return instance
end

function GameZJFCreateRoomPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function GameZJFCreateRoomPanel:MakeLister()
    self.lister = {}
end

function GameZJFCreateRoomPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end


function GameZJFCreateRoomPanel:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function GameZJFCreateRoomPanel:ctor(parm)

	ExtPanel.ExtMsg(self)

	DSM.PushAct({panel = "GameZJFCreateRoomPanel"})
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(GameZJFCreateRoomPanel.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self.parm = parm

	self:MakeLister()
	self:AddMsgListener()

	-- self.ScrollViewRight = tran:Find("CenterRect/ScrollViewRight")
	-- self.LeftNode = tran:Find("CenterRect/ScrollViewLeft/Viewport/Content")
	-- self.RightNode = tran:Find("CenterRect/ScrollViewRight/Viewport/Content")


	self:InitUI()
end

function GameZJFCreateRoomPanel:InitUI()
	ExtendSoundManager.PlaySceneBGM(audio_config.game.bgm_pipeichangbeijing.audio_name)
	local parm = self.parm

	self:ClearCellList()
	self.gamelist = {}
	for k,v in ipairs(GameZJFModel.UIConfig.gamelist) do
		self.gamelist[#self.gamelist + 1] = {id=v, isOpen = true}
	end
	if GameZJFModel.UIConfig.closegamelist then
		for k,v in ipairs(GameZJFModel.UIConfig.closegamelist) do
			self.gamelist[#self.gamelist + 1] = {id=v, isOpen = false}
		end
	end
	self.close_btn.onClick:AddListener(function ()
		self:MyExit()
	end)

	self:InitGameList()
	
end

-------------------------------------------------------------------------------------
function GameZJFCreateRoomPanel:InitGameList()
	self.spaceH = 8
	local viewSubItemNum = 4
	local defaultIndex = 1
	local globalCfg = GameZJFModel.UIConfig.global
	local gameCfg = GameZJFModel.UIConfig.game
	local SMIRect = self["ListItem_tmpl"]:GetComponent("RectTransform").rect
	local gridLayout = self["RootMenuItem_tmpl"]:Find("GameList/Viewport/Content"):GetComponent("GridLayoutGroup")
	local gridMaxH = SMIRect.height * (viewSubItemNum + 0.5) + self.spaceH * (viewSubItemNum + 2)
	self.RootMenuH = self["RootMenu"]:GetComponent("RectTransform").rect.height
	self.MenuItemH = self["RootMenuItem_tmpl"]:GetComponent("RectTransform").rect.height
	gridLayout.cellSize = Vector2.New(SMIRect.width, SMIRect.height)
	gridLayout.spacing = Vector2.New(0, self.spaceH)

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

					if self.parm and self.parm == g.support_game_type then
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

function GameZJFCreateRoomPanel:SelectMenuItem(index)
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

function GameZJFCreateRoomPanel:UpdateMenuItemPos(selItemIndex, isFold)
	local subOffY = (isFold and 0 or (selItemIndex * self.MenuItemH + self.GameMenu[selItemIndex].viewH + self.spaceH - self.RootMenuH))
	local off = Vector3.New(0, self.GameMenu[selItemIndex].viewH, 0)
	for i, mi in ipairs(self.GameMenu) do
		local pos = Vector3.New(0, self.RootMenuH/2 - i * self.MenuItemH + self.MenuItemH/2 + (subOffY > 0 and subOffY or 0), 0)
		self.GameMenu[i].menuItem.transform.localPosition = ((i <= selItemIndex or isFold) and pos or pos - off)
	end
end

function GameZJFCreateRoomPanel:UpdateSubMenuItemPos()
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

function GameZJFCreateRoomPanel:FoldMenuList(index, isFold)
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

function GameZJFCreateRoomPanel:SelectSubMenuItem(btn)
	if btn then
		self:OnToggleClick(btn)
		btn.transform:Find("nor_img").gameObject:SetActive(false)
		btn.transform:Find("sel_img").gameObject:SetActive(true)
		self.lastSelBtn = btn
		self:UpdateSubMenuItemPos()
	end
end

function GameZJFCreateRoomPanel:UnselectSubMenuItem(btn)
	if btn then
		btn.transform:Find("nor_img").gameObject:SetActive(true)
		btn.transform:Find("sel_img").gameObject:SetActive(false)
		self.lastSelBtn = nil
	end
end

function GameZJFCreateRoomPanel:UpdateRootMenuHeight(index, isFold)
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
------------------------------------------------------------------------------------

function GameZJFCreateRoomPanel:ClearOperatorCellList()
	if self.OperatorCellList then
		for k,v in ipairs(self.OperatorCellList) do
			v:OnDestroy()
		end
	end
	self.OperatorCellList = {}
end

function GameZJFCreateRoomPanel:UpdateLeftDownHint()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:UpdateDownHint()			
		end
	end
end

function GameZJFCreateRoomPanel:ClearCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:OnDestroy()
		end
	end
	self.CellList = {}
end

function GameZJFCreateRoomPanel:OnToggleClick(obj)
	local i = tonumber(obj.name)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	dump(obj)
	dump(self.gamelist)
	if not self.gamelist[i].isOpen then
		HintPanel.Create(1, "敬请期待")
		return
	end
	local data = GameZJFModel.UIConfig.game[self.gamelist[i].id]
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
function GameZJFCreateRoomPanel:CallToggleClick(i)
	if self.selectIndex and self.selectIndex == i then
		return
	end
	--[[if self.selectIndex then
		self.CellList[self.selectIndex]:SetSelect(false)
	end]]

	self.selectIndex = i
	--self.CellList[self.selectIndex]:SetSelect(true)
	self.curr_game_type = GameZJFModel.GetGameTypeByID(i)
	self:UpdateRight()
end


function GameZJFCreateRoomPanel:UpdateRight()
	self:ClearRightCell()
	if self.curr_game_type == "nor_pdk_nor" then 

	elseif self.curr_game_type == "nor_ddz_lz" then 
		self.Curr_Prefab = ZJFDdzPrefab.Create(self.Node,2)
	elseif self.curr_game_type == "nor_ddz_nor" then 
		self.Curr_Prefab = ZJFDdzPrefab.Create(self.Node,1)
	elseif self.curr_game_type == "nor_ddz_er" then 
		self.Curr_Prefab = ZJFDdzPrefab.Create(self.Node,3)
	elseif self.curr_game_type == "nor_ddz_boom" then 
		self.Curr_Prefab = ZJFDdzPrefab.Create(self.Node,4)
	elseif self.curr_game_type == "nor_mj_xzdd" then 
		self.Curr_Prefab = ZJFMj3DPrefab.Create(self.Node,2)
	elseif self.curr_game_type == "nor_mj_xzdd_er_7" then 
		self.Curr_Prefab = ZJFMj3DPrefab.Create(self.Node,1)
	end 
	--ZJFDdzPrefab.Create(self.Node,1)
end

-- 入口选择
function GameZJFCreateRoomPanel:OnEnterClick(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
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


-- 快速选择
function GameZJFCreateRoomPanel:OnKSClick()
	dump(self.ksdata, "<color=yellow>快速选择</color>")
	if self.ksdata then
		self:CallEnter(self.ksdata.game_id)
	end
end

function GameZJFCreateRoomPanel:ClearRightCell()
	if self.Curr_Prefab then
		self.Curr_Prefab:MyExit()
	end
	destroyChildren(self.Node)
end

-- 关闭
function GameZJFCreateRoomPanel:OnBackClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	MainLogic.GotoScene("game_Hall")
end


function GameZJFCreateRoomPanel:OnDHClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    MainModel.OpenDH()
end

function GameZJFCreateRoomPanel:OnFillButton()
	self.select_operator_index = nil
	self.OperatorDescRect.gameObject:SetActive(false)
end