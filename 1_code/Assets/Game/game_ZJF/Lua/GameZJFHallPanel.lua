-- 创建时间:2018-10-15
local basefunc = require "Game.Common.basefunc"

GameZJFHallPanel = basefunc.class()

GameZJFHallPanel.name = "GameZJFHallPanel"

local instance
function GameZJFHallPanel.Create(parm)
	instance = GameZJFHallPanel.New(parm)
	return instance
end

function GameZJFHallPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function GameZJFHallPanel:MakeLister()
    self.lister = {}
	self.lister["AssetChange"] = basefunc.handler(self, self.UpdateAssetInfo)
	self.lister["zjf_room_info_get"] = basefunc.handler(self,self.on_zjf_room_info_get)
end

function GameZJFHallPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end


function GameZJFHallPanel:MyExit()
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

function GameZJFHallPanel:ctor(parm)

	ExtPanel.ExtMsg(self)
	self.dot_del_obj = true

	DSM.PushAct({panel = "GameZJFHallPanel"})
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(GameZJFHallPanel.name, parent)
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
	self.AddDiamond = tran:Find("TopRect/RectTop/ZSBG"):GetComponent("Button")
	self.AddDiamond.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnAddDiamond()
	end)
	self.DuihuanButton = tran:Find("TopRect/RectTop/DuihuanButton"):GetComponent("Button")
	self.DuihuanButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnDHClick()
	end)
	if GameGlobalOnOff.Exchange and false then
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
	self.Scroll = self.ScrollViewRight:GetComponent("ScrollRect")
    EventTriggerListener.Get(self.Scroll.gameObject).onEndDrag = basefunc.handler(self, self.ScrollOnEndDrag)
    
	self.GoldText = tran:Find("TopRect/RectTop/JBBG/GoldText"):GetComponent("Text")
	self.DiamondText = tran:Find("TopRect/RectTop/ZSBG/DiamondText"):GetComponent("Text")
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
	self.history_btn.onClick:AddListener(function ()
		ZJFHistoryPanel.Create()
	end)
	self.ppc_btn.onClick:AddListener(function ()
		GameFreeModel.RapidBeginGameLevel(1)
	end)
	self.fk_btn.onClick:AddListener(function ()
		RoomCardHallPopPrefab.Create()
	end)
	self.JJImage = tran:Find("CenterRect/OperatorRect/OperatorDescRect/JJImage")
	self.BackButton = tran:Find("TopRect/RectTop/BackButton")
	EventTriggerListener.Get(self.BackButton.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
	self:InitUI()
	Event.Brocast("ZJF_Hall_Created")
end

function GameZJFHallPanel:InitUI()
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

	--[[local game_type
	dump(parm, "<color=yellow>parm</color>")
	if parm then
		parm = MainModel.GetServerToClientScene(parm)
	end

	for k,v in ipairs(self.gamelist) do
		local pre = GameZJFLeftItemPrefab.Create(self.LeftNode.transform, v, GameZJFHallPanel.OnToggleClick, self)
		pre:SetObjName(k)
		self.CellList[#self.CellList + 1] = pre
		if not parm and k == 1 then
			self:CallToggleClick(k)
		end
		local data = GameZJFModel.UIConfig.game[self.gamelist[k].id]
		
		if parm and parm == data.game_type then
			self:CallToggleClick(k)
		end
	end]]
	self.GoldText.text =  StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	self.DiamondText.text = StringHelper.ToCash(MainModel.UserInfo.diamond)
	self.RedPacketText.text = StringHelper.ToRedNum(MainModel.GetHBValue())
	self.createRoom_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			GameZJFCreateRoomPanel.Create(self.curr_game_type)
		end
	)
	self.joinRoom_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			ZJFJoin.Create(nil,1)
		end
	)
	self:InitGameList()
end

-------------------------------------------------------------------------------------
function GameZJFHallPanel:InitGameList()
	self.spaceH = 8
	local viewSubItemNum = 4
	local defaultIndex = nil
	local globalCfg = GameZJFModel.UIConfig.global
	local gameCfg = GameZJFModel.UIConfig.game
	local SMIRect = self["ListItem_tmpl"]:GetComponent("RectTransform").rect
	local gridLayout = self["RootMenuItem_tmpl"]:Find("GameList/Viewport/Content"):GetComponent("GridLayoutGroup")
	local gridMaxH = SMIRect.height * (viewSubItemNum + 0.5) + self.spaceH * (viewSubItemNum + 2)
	self.RootMenuH = self["RootMenu"]:GetComponent("RectTransform").rect.height
	self.MenuItemH = self["RootMenuItem_tmpl"]:GetComponent("RectTransform").rect.height
	gridLayout.cellSize = Vector2.New(SMIRect.width, SMIRect.height)
	gridLayout.spacing = Vector2.New(0, self.spaceH)

	local game_type
	if self.parm then
		game_type =  self.parm.game_type
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

					if game_type and game_type == g.support_game_type then
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
	local ojb_name = PlayerPrefs.GetString(MainModel.UserInfo.user_id.."zjf_hall_defIndex",1)
	for a, b in ipairs(self.GameMenu) do
		for _a, _b in ipairs(b.items) do
			if _b.name == ojb_name then
				self.defSubIndex = _a
				defaultIndex = a
			end
		end
	end
	defaultIndex = defaultIndex or 1
	self:SelectMenuItem(defaultIndex)
	self.defSubIndex = nil
end

function GameZJFHallPanel:SelectMenuItem(index)
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

function GameZJFHallPanel:UpdateMenuItemPos(selItemIndex, isFold)
	local subOffY = (isFold and 0 or (selItemIndex * self.MenuItemH + self.GameMenu[selItemIndex].viewH + self.spaceH - self.RootMenuH))
	local off = Vector3.New(0, self.GameMenu[selItemIndex].viewH, 0)
	for i, mi in ipairs(self.GameMenu) do
		local pos = Vector3.New(0, self.RootMenuH/2 - i * self.MenuItemH + self.MenuItemH/2 + (subOffY > 0 and subOffY or 0), 0)
		self.GameMenu[i].menuItem.transform.localPosition = ((i <= selItemIndex or isFold) and pos or pos - off)
	end
end

function GameZJFHallPanel:UpdateSubMenuItemPos()
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

function GameZJFHallPanel:FoldMenuList(index, isFold)
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

function GameZJFHallPanel:SelectSubMenuItem(btn)
	if btn then
		self:OnToggleClick(btn)
		btn.transform:Find("nor_img").gameObject:SetActive(false)
		btn.transform:Find("sel_img").gameObject:SetActive(true)
		self.lastSelBtn = btn
		self:UpdateSubMenuItemPos()
	end
end

function GameZJFHallPanel:UnselectSubMenuItem(btn)
	if btn then
		btn.transform:Find("nor_img").gameObject:SetActive(true)
		btn.transform:Find("sel_img").gameObject:SetActive(false)
		self.lastSelBtn = nil
	end
end

function GameZJFHallPanel:UpdateRootMenuHeight(index, isFold)
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

function GameZJFHallPanel:ScrollOnEndDrag()
    print("<color=white>分页请求</color>", self.isQuery,self.page_index)
    local VNP = self.Scroll.verticalNormalizedPosition
    if VNP <= 0 then
		if self.isQuery then
			GameZJFModel.SendQueryToGetRoomInfo(self.curr_game_type, self.page_index, self.sort_type)
		end
	end
	self.updata_list_timer = Timer.New(function()
		GameZJFModel.SendQueryToGetRoomInfo(self.curr_game_type, self.page_index, self.sort_type)
	end ,30,-1)
end
-------------------------------------------------------------------------------------

function GameZJFHallPanel:UpdateAssetInfo()
	if IsEquals(self.GoldText) and  IsEquals(self.DiamondText) and IsEquals(self.RedPacketText) then
		self.GoldText.text =  StringHelper.ToCash(MainModel.UserInfo.jing_bi)
		self.DiamondText.text = StringHelper.ToCash(MainModel.UserInfo.diamond)
		self.RedPacketText.text = StringHelper.ToRedNum(MainModel.GetHBValue())
		self:UpdateKS()
	end
end

-- 刷新运营活动
function GameZJFHallPanel:UpdateOperator()
	local gameId = self.gamedata[self.selectGameIndex].game_id
	self:ClearOperatorCellList()
	local a,b = GameButtonManager.RunFun({gotoui="sys_act_operator",game_id = self.gamedata[self.selectGameIndex].game_id}, "GetActivityStateByFreeID")
	if a and not table_is_null(b) then
		self.operator_data = b
	end
	if not IsEquals(self.OperatorRect) then
		self.OperatorRect = tran:Find("CenterRect/OperatorRect")
	end
	if self.operator_data then
		if IsEquals(self.OperatorRect) then
		self.OperatorRect.gameObject:SetActive(true)
		end
		for k,v in ipairs(self.operator_data) do
			local pre = FreeOperatorPrefab.Create(self.OperatorNode.transform, v, GameZJFHallPanel.OnOperatorClick, self, k, gameId)
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

function GameZJFHallPanel:ClearOperatorCellList()
	if self.OperatorCellList then
		for k,v in ipairs(self.OperatorCellList) do
			v:OnDestroy()
		end
	end
	self.OperatorCellList = {}
end

function GameZJFHallPanel:OnOperatorClick(index)
	self.operator_data = nil
	local a,b = GameButtonManager.RunFun({gotoui="sys_act_operator",game_id = self.gamedata[self.selectGameIndex].game_id}, "GetActivityStateByFreeID")
	if a and not table_is_null(b) then
		self.operator_data = b
	end

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
function GameZJFHallPanel:UpdateKS()
	
end

-- 设置选中的游戏
function GameZJFHallPanel:SetSelectGame(index, isanim)
	if not self.selectGameIndex or self.selectGameIndex ~= index then
		self.selectGameIndex = index
	end
	if self.RightCellList then
		for k,v in ipairs(self.RightCellList) do
			v:SetSelectFX(self.selectGameIndex, isanim)
		end
		--self:UpdateOperator()
	end
end

function GameZJFHallPanel:UpdateLeftDownHint()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:UpdateDownHint()			
		end
	end
end

function GameZJFHallPanel:ClearCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:OnDestroy()
		end
	end
	self.CellList = {}
end

function GameZJFHallPanel:OnToggleClick(obj)
	local i = tonumber(obj.name)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	PlayerPrefs.SetString(MainModel.UserInfo.user_id.."zjf_hall_defIndex",obj.name)
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
function GameZJFHallPanel:CallToggleClick(i)
	if self.selectIndex and self.selectIndex == i then
		return
	end
	--[[if self.selectIndex then
		self.CellList[self.selectIndex]:SetSelect(false)
	end]]

	-- 分页请求
    self.page_index = 1
    self.sort_type = 8
    self.isQuery = true

	self.selectIndex = i
	--self.CellList[self.selectIndex]:SetSelect(true)
	self:ClearRightCell()
	self.curr_game_type = GameZJFModel.GetGameTypeByID(i)
	GameZJFModel.SendQueryToGetRoomInfo(self.curr_game_type, self.page_index, self.sort_type)
	self:UpdateLeftDownHint()
	--self:RightAnim()
end

function GameZJFHallPanel:RightAnim()
	if self.RightCellList then
		local i = 0
		local tt = 0.1
		for k,v in ipairs(self.RightCellList) do
			v:PlayAnim(i * tt)
			i = i + 1			
		end
	end
end


function GameZJFHallPanel:OpenUIAnimFinish()
	self.ScrollViewRight.transform.localPosition = Vector3.New(340, 106, 0)
	self.seq = nil
end

function GameZJFHallPanel:UpdateRight(data)
	-- self:ClearRightCell()
	-- local data = GameZJFModel.GetRoomInfo(self.curr_game_type)
	local temp_ui = {}
	dump(data,"<color=red>面板的拿到的房间数据---</color>")
	if data and data.table_list then 
		for i = 1 ,#data.table_list do
			local b = GameObject.Instantiate(self.room_item,self.RightNode)
			LuaHelper.GeneratingVar(b.gameObject.transform, temp_ui)
			temp_ui.Node.transform.localPosition = Vector3.New(1241, 0, 0)
			b.gameObject:SetActive(true)
			temp_ui.name_txt.text = GameZJFModel.GetGameNameByID(self.selectIndex)
			temp_ui.fzb_txt.text = data.table_list[i].fangzhu_pay == 1 and "房主包" or "AA制"
			temp_ui.p_txt.text = data.table_list[i].player_num.."/"..data.table_list[i].room_max_player
			temp_ui.df_txt.text = data.table_list[i].init_stake
			temp_ui.fd_txt.text = data.table_list[i].yingfengding
			temp_ui.rc_txt.text = "≥"..data.table_list[i].enter_limit
			temp_ui.lock.gameObject:SetActive(data.table_list[i].password == 1)
			temp_ui.join_btn.onClick:AddListener(
				function ()
					if MainModel.UserInfo.jing_bi >= data.table_list[i].enter_limit then
						if data.table_list[i].password == 0 then 
							Network.SendRequest("zijianfang_join_room",{
								room_no = data.table_list[i].room_no,
								password = data.table_list[i].password == 1 and data.table_list[i].room_no or nil
							},"正在进入房间",function (_data)
								if _data.result == 0 then
									GameManager.GotoUI({gotoui = GameZJFModel.game_type2scence[data.game_type]})
								else
									HintPanel.ErrorMsg(_data.result)
								end
							end)			
						else
							ZJFJoin.Create(data.table_list[i].room_no,2)
						end 
					else
						Event.Brocast("show_gift_panel")
					end
				end
			)
			local seq = DoTweenSequence.Create()
			seq:AppendInterval(0.05 * (i-1))
			seq:Append(temp_ui.Node:DOLocalMoveX(0, 0.2):SetEase(DG.Tweening.Ease.Linear))--OutBack
		end
	end 
end

-- 入口选择
function GameZJFHallPanel:OnEnterClick(go)
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
function GameZJFHallPanel:CallEnter(game_id)
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="freestyle_game_"..game_id}, "CheckCondition")
    if a and not b then
    	return
    end
    local xsyd_signup = function ()
		GameManager.CommonGotoScence({gotoui=GameSceneCfg[GameZJFModel.data.sceneID].SceneName, p_requset={id = game_id, xsyd = 1}})
    end
    local signup = function()
		GameManager.CommonGotoScence({gotoui=GameSceneCfg[GameZJFModel.data.sceneID].SceneName, p_requset={id = game_id}}, function ()
			GameZJFModel.SetCurrGameID(game_id)
		end)
    end
    local check
    check = function ()
		local ss = GameZJFModel.IsRoomEnter(game_id)
		if ss == 1 then
			if GameGlobalOnOff.Shop_10_gift_bag ~= nil and GameGlobalOnOff.Shop_10_gift_bag == false then
				local dd = GameZJFModel.GetGameCfg(game_id)
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
function GameZJFHallPanel:OnKSClick()
	dump(self.ksdata, "<color=yellow>快速选择</color>")
	if self.ksdata then
		self:CallEnter(self.ksdata.game_id)
	end
end

function GameZJFHallPanel:ClearRightCell()
	destroyChildren(self.RightNode)
	self.RightCellList = {}
end

-- 关闭
function GameZJFHallPanel:OnBackClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	MainLogic.GotoScene("game_Hall")
end

function GameZJFHallPanel:OnAddGold()
	PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end

function GameZJFHallPanel:OnAddDiamond()
	PayPanel.Create(GOODS_TYPE.goods, "normal")
end

function GameZJFHallPanel:OnDHClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    MainModel.OpenDH()
end

function GameZJFHallPanel:OnFillButton()
	self.select_operator_index = nil
	self.OperatorDescRect.gameObject:SetActive(false)
end

function GameZJFHallPanel:BuyCoin(game_id, check)
	local dd = GameZJFModel.GetGameCfg(game_id)
	if dd.order == 1 then
		OneYuanGift.Create(nil, function ()
			PayFastFreePanel.Create(dd, check)
		end)
	else
		PayFastFreePanel.Create(dd, check)
	end
end

function GameZJFHallPanel:on_zjf_room_info_get(data, is_clear_old_data)
	if is_clear_old_data then
		self:ClearRightCell()
        self.page_index = 1
	end
	if data and data.table_list and next(data.table_list) then
		self.page_index = self.page_index + 1
		self:UpdateRight(data)
	else
		self.isQuery = false
	end
end

