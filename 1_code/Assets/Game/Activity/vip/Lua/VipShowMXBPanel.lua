-- 创建时间:2019-12-28
-- Panel:VipShowMXBPanel
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

VipShowMXBPanel = basefunc.class()
local C = VipShowMXBPanel
C.name = "VipShowMXBPanel"

function C.Create(parent)
	return C.New(parent)
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

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.MXBPanel = self.transform:Find("MXB")

    self.Red5 = self.transform:Find("SVSwitch/Viewport/@switch_content/Button5/Red")
    self.MXBWait = self.transform:Find("MXB/Wait")
    self.MXBRuning = self.transform:Find("MXB/Runing")
    self.MXBBtnGoto = self.transform:Find("MXB/GotoButton"):GetComponent("Button")
    self.MXBTxtTime = self.transform:Find("MXB/Wait/TimeText"):GetComponent("Text")
    self.MXBVIPText = self.transform:Find("MXB/Wait/TimeText"):GetComponent("Text")

    self.MXBBtnGoto.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            local gotoparm = {gotoui = "match_hall",goto_scene_parm = "hks"}
            GameManager.GotoUI(gotoparm)
        end
    )

    self:RefreshMXB()
end

function C:RefreshMXB(  )
    local cfg = MatchModel.GetRecentlyCFGByType("mxb")
    local is_have = MatchModel.IsTodayHaveMatchByType("mxb")
    --筛选本月的比赛
    if is_have then
        self.MXBWait.gameObject:SetActive(false)
        self.MXBRuning.gameObject:SetActive(true)
    else
        self.MXBWait.gameObject:SetActive(true)
        self.MXBRuning.gameObject:SetActive(false)
        if cfg then
            local y = tonumber(os.date("%m", cfg.start_time))
            local r = tonumber(os.date("%d", cfg.start_time))
            if y and r then
                self.MXBVIPText.text = string.format( "%s月%s日晚上8点开赛",y,r)
            end
        end
    end
end