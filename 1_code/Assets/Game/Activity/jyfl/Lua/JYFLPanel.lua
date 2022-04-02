-- 创建时间:2019-09-18
-- Panel:JYFLPanel
--[[ *      ┌─┐       ┌─┐
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

JYFLPanel = basefunc.class()
local C = JYFLPanel
C.name = "JYFLPanel"

function C.Create(backcall)
    return C.New(backcall)
end

function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
    self.lister["JYFL_Refresh"] = basefunc.handler(self, self.RefreshPanel)

end

function C:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    if self.backcall then
        self.backcall()
    end
    self:ClearCell()
    self:RemoveListener()
    Event.Brocast("sys_023_exxsyd_panel_close")
    destroy(self.gameObject)

end

function C:ctor(backcall)

	ExtPanel.ExtMsg(self)

    local parent = GameObject.Find("Canvas/LayerLv3").transform
    local obj = newObject(C.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    self.backcall = backcall
    LuaHelper.GeneratingVar(self.transform, self)
    self:MakeLister()
    self:AddMsgListener()

    self.Close_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:MyExit()
    end)
    self:InitUI()
end

function C:InitUI()
    Event.Brocast("jyfl_init_ui_start")
    self:ClearCell()
    local cfg = MathExtend.SortList(JYFLManager.UIConfig.config, "order", true)
    for k,v in ipairs(cfg) do
        local pre = GameManager.GotoUI({gotoui=v.key, goto_scene_parm="jyfl_enter", condi_key=v.condi_key, parm=v.parm, parent=self.Content})
        if pre then
            self.cell_map[v.key] = {prefab = pre}
        end
    end
    
	JYFLManager.ChangeEnterOrder()
end
function C:ClearCell()
    if self.cell_map then
        for k, v in pairs(self.cell_map) do
            v.prefab:OnDestroy()
        end
    end
    self.cell_map = {}
end

function C:OnExitScene()
    self:MyExit()
end

function C:RefreshPanel()
    self:InitUI()
end