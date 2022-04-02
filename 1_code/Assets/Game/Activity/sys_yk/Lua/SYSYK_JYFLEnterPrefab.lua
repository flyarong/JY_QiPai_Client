-- 创建时间:2019-10-23
-- Panel:SYSYK_JYFLEnterPrefab
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

SYSYK_JYFLEnterPrefab = basefunc.class()
local C = SYSYK_JYFLEnterPrefab

function C.CheckIsShow(cfg)
	if not cfg.is_on_off or cfg.is_on_off == 0 then
		return
	end

	return true
end

function C.Create(parent, cfg)
	return C.New(parent, cfg)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["global_hint_state_change_msg"] = basefunc.handler(self, self.on_global_hint_state_change_msg)
    self.lister["ui_button_data_change_msg"] = basefunc.handler(self, self.MyRefresh)
    
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

function C:ctor(parent, parm)
	self.parm = parm
    ExtPanel.ExtMsg(self)
	local obj = newObject("JYFLCellPrefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.get_img = self.get_btn.transform:GetComponent("Image")

	self:MakeLister()
	self:AddMsgListener()

	self:InitUI()
end

function C:InitUI()
	self.BG_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)
	self.get_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnGetClick()
	end)
	self.title_img.sprite = GetTexture("hall_btn_gift32")
	self.title_txt.text = "贵族月卡"
	self.info_txt.text = "记牌器免费用，每天最少领取6666鲸币"
	self:MyRefresh()
end

function C:MyRefresh()
	if not SYSYKManager.IsBuy or (SYSYKManager.IsBuy and not SYSYKManager.CanBuy2) then
        self.info_txt.text = "记牌器免费用，每天最少可领6666鲸币"
    else
        if not SYSYKManager.IsBuy2 and  SYSYKManager.CanBuy2 then
            self.info_txt.text = "升级黄金贵族月卡，每天可领30000鲸币"
        elseif SYSYKManager.IsBuy2 then
            self.info_txt.text = "记牌器免费使用，每天可领3万鲸币"
        else
            self.info_txt.text = "记牌器免费用，每天最少可领6666鲸币"
        end
    end

    if SYSYKManager.IsLJ == true then
        self.get_txt.text = "领  取"
        self.get_btn.transform:GetComponent("Image").sprite = GetTexture("com_btn_5")
    else
        if not SYSYKManager.IsBuy then
            self.get_txt.text = "去 购 买"
            self.get_btn.transform:GetComponent("Image").sprite = GetTexture("com_btn_5")
        else
            if not SYSYKManager.IsBuy2 and SYSYKManager.CanBuy2 then
                self.get_txt.text = "去 升 级"
                self.get_btn.transform:GetComponent("Image").sprite = GetTexture("com_btn_5")
            else
                self.get_txt.text = "已 领 取"
                self.get_btn.transform:GetComponent("Image").sprite = GetTexture("com_btn_8")
            end
        end
    end
end

function C:OnEnterClick()
	GameManager.GotoUI({gotoui = SYSYKManager.key, goto_scene_parm="panel"})
end
function C:OnGetClick()
	GameManager.GotoUI({gotoui = SYSYKManager.key, goto_scene_parm="panel"})	
end

function C:OnDestroy()
	self:MyExit()
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == SYSYKManager.key then
		self:MyRefresh()
	end
end