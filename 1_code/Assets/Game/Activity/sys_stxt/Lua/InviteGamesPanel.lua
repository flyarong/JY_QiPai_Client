-- 创建时间:2019-11-29
-- Panel:InviteGamesPnael
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

InviteGamesPanel = basefunc.class()
local C = InviteGamesPanel
C.name = "InviteGamesPanel"
local config = SYSSTXTManager.invite_game_config
local curr_gotoui
local button_list 
function C.Create(parent,cfg)
	return C.New(parent,cfg)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(parent,cfg)

	ExtPanel.ExtMsg(self)

	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.cfg = cfg
	curr_gotoui = nil 
	button_list = {}
	LuaHelper.GeneratingVar(self.transform, self)
	local item =  GameItemModel.GetItemToKey("jing_bi")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.confirm_btn.onClick:AddListener(
		function ()
			self:GoToUI(curr_gotoui)
			Network.SendRequest("invite_apprentice_play",{game_type = self.curr_id,apprentice_id = self.cfg})
		end
	)
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	local CC = self:InitConfig()
	for i = 1, #CC do
		local b = GameObject.Instantiate(self.Game_Item,self.Content)
		b.gameObject:SetActive(true)
		button_list[#button_list + 1] = b
		local temp_ui = {}
		LuaHelper.GeneratingVar(b.transform, temp_ui)
		temp_ui.game_bg_txt.text = CC[i].gamename
		temp_ui.game_mask_txt.text = CC[i].gamename
		temp_ui.gotoui_btn.onClick:AddListener(
			function ()
				self:OnClickIndex(CC,i)
			end
		)
	end
	self:OnClickIndex(CC,1)
end

function C:MyRefresh()

end

function C:GoToUI(parm)
	self:MyExit()
	GameManager.GotoUI({gotoui = parm[1],goto_scene_parm = parm[2]})
end

function C:InitConfig()
	local _config = {}
	for i = 1, #config.info do
		if config.info[i].isonoff == 1 then 
			_config[#_config + 1] = config.info[i]
		end 
	end
	_config = MathExtend.SortList(_config,"order", true)
	return _config
end

function C:OnClickIndex(CC,index)
	local temp_ui = {}
	for i=1,#button_list do
		LuaHelper.GeneratingVar(button_list[i].transform, temp_ui)
		temp_ui.mask.gameObject:SetActive(false)
	end
	curr_gotoui = CC[index].gotoui
	self.curr_id = CC[index].id
	LuaHelper.GeneratingVar(button_list[index].transform, temp_ui)
	temp_ui.mask.gameObject:SetActive(true)
end