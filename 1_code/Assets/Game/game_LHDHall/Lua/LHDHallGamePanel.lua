-- 创建时间:2019-12-04
-- Panel:LHDHallGamePanel
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

LHDHallGamePanel = basefunc.class()
local C = LHDHallGamePanel
C.name = "LHDHallGamePanel"

local desk_cfg = {
	[1] = {title="dld_imgf_xsc"},
	[2] = {title="dld_imgf_zjc"},
	[3] = {title="dld_imgf_gjc"},
	[4] = {title="dld_imgf_ldc"},
}
function C.Create(parm)
	return C.New(parm)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["AssetChange"] = basefunc.handler(self, self.UpdateAssetInfo)
    self.lister["model_lhd_guide_status"] = basefunc.handler(self, self.on_model_lhd_guide_status)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.dh_pre then
		self.dh_pre:MyExit()
	end
	if self.desk_pre then
		self.desk_pre:MyExit()
	end
	self:ClearCellList()
	self:RemoveListener()

	 
end

function C:ctor(parm)

	ExtPanel.ExtMsg(self)
	self.dot_del_obj = true

	self.parm = parm
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self.cur_ui = "hall"
	self:InitUI()
end

function C:InitUI()
	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnBackClick()
	end)
	self.set_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		GameManager.GotoUI({gotoui = "sys_setting",goto_scene_parm = "panel"})
	end)
	self.help_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		LHDHelpPanel.Create()
	end)
	self.JBBG_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
	end)
	self.ZSBG_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		PayPanel.Create(GOODS_TYPE.goods, "normal")
	end)

	self.config = LHDManager.GetGameConfig()
	self.dh_pre = GameManager.GotoUI({gotoui = "sys_dui_huan",goto_scene_parm = "panel",node = self.dh_node})

	self:ClearCellList()
	for k=1, 4 do
		local v = self.config[k]
		local pre = LHDCCPrefab.Create(self["lhd_hall_prefab"..k], v, C.OnEnterClick, self, k)
		self.CellList[#self.CellList + 1] = pre
		if k == 4 then
			pre:SetActive(false)
		end
	end
	self:MyRefresh()

	LHDManager.QueryLHDGuideStatus()
end
function C:on_model_lhd_guide_status()
	if LHDManager.IsGuide() then
		LHDHallGuidePanel.Create()
	end	
end
function C:MyRefresh()
	self:UpdateAssetInfo()
	if self.cur_ui == "hall" then
		self.title_img.sprite = GetTexture("dld_ccbtn_jddld")
		self.title_img:SetNativeSize()
		self.JBBG_btn.gameObject:SetActive(true)
		self.ZSBG_btn.gameObject:SetActive(true)
		self.dh_node.gameObject:SetActive(true)
		self.help_btn.gameObject:SetActive(true)
		self.cell_node.gameObject:SetActive(true)
	else
		local cfg = LHDManager.GetGameIdByConfig(self.cur_game_id)
		self.title_img.sprite = GetTexture(desk_cfg[cfg.order].title)
		self.title_img:SetNativeSize()
		self.JBBG_btn.gameObject:SetActive(false)
		self.ZSBG_btn.gameObject:SetActive(false)
		self.dh_node.gameObject:SetActive(false)
		self.help_btn.gameObject:SetActive(false)
		self.cell_node.gameObject:SetActive(false)
		self.desk_pre = LHDHallDeskPanel.Create({game_id=self.cur_game_id, parent=self.center, panelSelf=self})
	end
end

function C:ClearCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:OnDestroy()
		end
	end
	self.CellList = {}
end

function C:UpdateAssetInfo()
	self.jb_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	self.zs_txt.text = StringHelper.ToCash(MainModel.UserInfo.diamond)
end

function C:OnEnterClick(parm)
	local game_id = self.config[parm.index].game_id
    
    local dd = LHDManager.GetGameIdByConfig(game_id)
    if dd.isLock == 1 then
    	LittleTips.Create("场次暂未开放")
    	return
    end

	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="freestyle_game_lhd_"..game_id}, "CheckCondition")
    if a and not b then
    	return
    end

	if parm.type == "enter" then
        self:CallSignup({game_id = game_id})
	else
		self.cur_game_id = game_id
		self.cur_ui = "desk"
		self:MyRefresh()
	end
end

function C:OnKSClick()
	local dd = LHDManager.GetRapidBeginGameID ()
	if dd.is_enter then
		self:Signup({game_id = dd.cfg.game_id})
	else
		dump(dd, "<color=red>没有满足条件的场次</color>")
	end
end

function C:OnBackClick()
	if self.cur_ui == "hall" then
		GameManager.GotoUI({gotoui = "game_MiniGame"})
	else
		self.cur_ui = "hall"
		if self.desk_pre then
			self.desk_pre:MyExit()
		end
		self:MyRefresh()
	end
end
function C:CallSignup(data)
	local ss = LHDManager.IsRoomEnter(data.game_id)
	if ss == 1 then
		if GameGlobalOnOff.Shop_10_gift_bag ~= nil and GameGlobalOnOff.Shop_10_gift_bag == false then
			local dd = LHDManager.GetGameIdByConfig(data.game_id)
			PayFastFreePanel.Create(dd, check)
		else
			self:BuyCoin(data.game_id, check)
		end
        return
    end
    if ss == 2 then
		local pre = HintPanel.Create(2, "您太富有了，更高级的场次才适合您！", function ()
        	self:OnKSClick()
        end)
        pre:SetButtonText(nil, "前 往")
        return
    end
    self:Signup(data)
end
function C:Signup(data)
	GameManager.CommonGotoScence({gotoui="game_LHD", p_requset=data}, function (requset)
	end)
end

function C:BuyCoin(game_id, check)
	local dd = LHDManager.GetGameIdByConfig(game_id)
	if dd.order == 1 then
		OneYuanGift.Create(nil, function ()
			PayFastFreePanel.Create(dd, check)
		end)
	else
		PayFastFreePanel.Create(dd, check)
	end
end


