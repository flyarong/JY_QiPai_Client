-- 创建时间:2020-09-25
-- Panel:LWZBCSDJPanel
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

LWZBCSDJPanel = basefunc.class()
local C = LWZBCSDJPanel
C.name = "LWZBCSDJPanel"
local M = LWZBModel

function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["lwzb_refresh_qlcf_enter_and_panel_msg"] = basefunc.handler(self,self.on_lwzb_refresh_qlcf_enter_and_panel_msg)

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

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	

	self.Back_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
       	self:MyExit()
 	end)

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	local config = M.GetQLCFConfig()
	for i=1,#config do
		self["jl"..i.."_txt"].text = config[i].type_name
		self["gl"..i.."_txt"].text = config[i].rate..".00%"
	end
	self:RefreshUI()

	self:MyRefresh()
end

function C:MyRefresh()
    
end

function C:RefreshUI()
	local all_info = M.GetAllInfo()
	local big_award_data = all_info.last_qlcf_big_award
	URLImageManager.UpdateHeadImage(big_award_data.player_info.head_image, self.playerhead_img)
	self.name_txt.text = big_award_data.player_info.player_name
	--VIPManager.set_vip_text(self.lw_vip_txt,big_award_data.player_info.vip_level)
	local str = LWZBManager.PoolFormat(all_info.status_data.qlcf_award_pool)
	if not self.cur_num then
		self.cur_num = math.floor(tonumber(str)*0.8)
	end
	self.award_pool = tonumber(str)
	self.award_txt.text = StringHelper.ToCash(big_award_data.award_value)	
	self:RunChange()
end

function C:on_lwzb_refresh_qlcf_enter_and_panel_msg()
	self:RefreshUI()
end

function C:RunChange()
	if self.is_animing then
		return
	end
	self.mb_num = self.award_pool
	GameComAnimTool.stop_number_change_anim(self.anim_tab)
	if not self.cur_num or not self.mb_num or self.cur_num == self.mb_num then
		return
	end
	self.is_animing = true
	self.anim_tab = GameComAnimTool.play_number_change_anim(self.topaward_txt, tonumber(self.cur_num), tonumber(self.mb_num), 20, function ()
		self.cur_num = self.mb_num
		self.is_animing = false
		self:RunChange()
	end)
end