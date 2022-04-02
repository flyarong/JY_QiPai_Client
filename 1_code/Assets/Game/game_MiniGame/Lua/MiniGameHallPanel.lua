-- 创建时间:2019-05-30
-- Panel:MiniGameHallPanel
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 --]]

local basefunc = require "Game/Common/basefunc"

MiniGameHallPanel = basefunc.class()
local C = MiniGameHallPanel
C.name = "MiniGameHallPanel"

local instance
function C.Create()
	if not instance then
		instance = C.New()
	else
		instance:MyRefresh()
	end
	return instance
end
function C.Close()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["AssetChange"] = basefunc.handler(self, self.UpdateAssetInfo)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	if self.game_btn_pre then
		self.game_btn_pre:MyExit()
		self.game_btn_pre = nil
	end
	self:ClearCellList()
end

function C:ctor()

	ExtPanel.ExtMsg(self)
	self.dot_del_obj = true
	
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.sv = self.transform:Find("Scroll View"):GetComponent("ScrollRect")
	self:MakeLister()
	self:AddMsgListener()
    LuaHelper.GeneratingVar(obj.transform, self)

	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)
	self.duihuan_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		MainModel.OpenDH()
	end)
	
	if GameGlobalOnOff.Exchange then
		self.duihuan_btn.gameObject:SetActive(true)
	else
		self.duihuan_btn.gameObject:SetActive(false)
	end

	self.pay_gold_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
	end)

	self.pre_config = MiniGameModel.GetUIConfig()
	self.pre_list = {}
	for k,v in pairs(self.pre_config) do
		if v.is_onoff == 1 then
			self.pre_list[#self.pre_list + 1] = v
		end
	end
    if #self.pre_list < 5 then
        for i = 1, (5 - #self.pre_list) do
            self.pre_list[#self.pre_list + 1] = self.pre_config["MiniGameWaitPrefab"]
        end
    end
	
	self.pre_list = MathExtend.SortList(self.pre_list, "sort", true)
	
	self:InitUI()
	dump(MainModel.lastmyLocation,"<color=yellow>上一次的场景</color>")
	if MainModel.lastmyLocation ~= "game_Hall" then 
		Event.Brocast("show_gift_panel_once_in1day")		
	end
	EventTriggerListener.Get(self.sv.gameObject).onEndDrag = function()
		if IsEquals(self.sv) then
			local VNP = self.sv.horizontalNormalizedPosition
			if VNP <= 0.2 then 
				self.right.gameObject:SetActive(true)
				self.left.gameObject:SetActive(false)
			end
			if VNP >= 0.8 then
				self.right.gameObject:SetActive(false)
				self.left.gameObject:SetActive(true)
			end
		end
	end
	Event.Brocast("qflb_back_to_minihall")
	Event.Brocast("minigamehall_created",{panelSelf = self})
	HandleLoadChannelLua(C.name,self)
end

function C:InitUI()
	-- self.pos_list = {}
	-- for i = 1, 2 do
	-- 	for j = 1, 2 do
	-- 		self.pos_list[#self.pos_list + 1] = Vector3.New(-296 + (j-1)*510, 210 - (i-1)*500, 0)
	-- 	end
	-- end
	self:ClearCellList()
	local index = 1
	for k,v in ipairs(self.pre_list) do
		local pre
		if v.bigpre_name then 
			pre = MiniGameHallPrefab.Create(self.CenterRectBig, v, C.OnEnterClick, self)
		else
			--临时限制 需要在2.23日删除 
			if v.pre_name == "MiniGameQHBPrefab" and os.time() > 1631548800 then

			else
				pre = MiniGameHallPrefab.Create(self.Content, v, C.OnEnterClick, self, index)
				-- pre:SetPosition(self.pos_list[index])
				index = index + 1
			end			
		end
		self.CellList[#self.CellList + 1] = pre

		-- -- 最多创建4个
		-- if index > 4 then
		-- 	break
		-- end
	end
	self:MyRefresh()
	local bt1 = GameObject.Find("MiniGameSHXXLPrefab")
	if IsEquals(bt1) then
		bt1 = bt1.transform:Find("@tag_mr")
	end
	local bt2 = GameObject.Find("MiniGameSGXXLPrefab")
	if IsEquals(bt2) then
		bt2 = bt2.transform:Find("@tag_mr")
	end
	local btn_map = {}
	if IsEquals(bt1) then
		btn_map["center"] = {bt1}
	end
	if IsEquals(bt2) then
		btn_map["center1"] = {bt2}
	end
	btn_map["center2"] = {self.btn_node2}
	btn_map["center3"] = {self.btn_node3}
	btn_map["center4"] = {self.btn_node4}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "mini_game_hall")

	local bg = self.transform:Find("Image")
	MainModel.SetGameBGScale(bg)
end
function C:ClearCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:OnDestroy()
		end
	end
	self.CellList = {}
end

function C:MyRefresh()
	self:UpdateAssetInfo()
end

function C:UpdateAssetInfo()
	if IsEquals(self.gold_txt) then
		self.gold_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
		self.RedPacket_txt.text = StringHelper.ToRedNum(MainModel.GetHBValue())
	end
end

--从GameFreeHallPanel:CallEnter抄过来的
local function EnterSignGame(game_id)
	local function BuyCoin(game_id, check)
		local dd = GameFreeModel.GetGameIDToConfig(game_id)
		if dd.order == 1 then
			OneYuanGift.Create(nil, function ()
			PayFastFreePanel.Create(dd, check)
			end)
		else
			PayFastFreePanel.Create(dd, check)
		end
	end

	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="freestyle_game_"..game_id}, "CheckCondition")
	if a and not b then
		return
	end
	local xsyd_signup = function ()
		GameManager.CommonGotoScence({gotoui=GameSceneCfg[GameFreeModel.data.sceneID].SceneName, p_requset={id = game_id, xsyd = 1}})
	end
	local signup = function()
		GameManager.CommonGotoScence({gotoui=GameSceneCfg[GameFreeModel.data.sceneID].SceneName, p_requset={id = game_id}}, function ()
			GameFreeModel.SetCurrGameID(game_id)
		end)
	end
	local check
	check = function ()
		local ss = GameFreeModel.IsRoomEnter(game_id)
		if ss == 1 then
			if GameGlobalOnOff.Shop_10_gift_bag ~= nil and GameGlobalOnOff.Shop_10_gift_bag == false then
				local dd = GameFreeModel.GetGameIDToConfig(game_id)
				PayFastFreePanel.Create(dd, check)
			else
				BuyCoin(game_id, check)
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

function C:OnEnterClick(config)
	local down_style ={
		panel = self.Content:Find(config.pre_name),
		parent = self.Content:Find(config.pre_name)
	}
	GameManager.CommonGotoScence({gotoui=config.key, down_style=down_style})
end

function C:OnBackClick()
	MainLogic.GotoScene("game_Hall")
end