-- 创建时间:2020-07-28
-- Panel:Act_045_DJDHPrefab
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
-- 取消按钮音效
-- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
-- 确认按钮音效
-- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
--]]

local basefunc = require "Game/Common/basefunc"

Act_045_DJDHPrefab = basefunc.class()
local C = Act_045_DJDHPrefab
C.name = "Act_045_DJDHPrefab"
local M = Act_045_DJDHManager
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
    self.lister["FishingTaskBigPrefab_ShowOrHide_Changed"] = basefunc.handler(self,self.fishing_pos_change)
    self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
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

function C:ctor()
    ExtPanel.ExtMsg(self)
    local parent = GameObject.Find("Canvas/GUIRoot").transform
    local obj = newObject(C.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self.transform.localPosition = Vector3.New(0,437,0)
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
    self:RefreshNum()
end

function C:InitUI()
    self.open_btn.onClick:AddListener(
        function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            ActivityYearPanel.Create(nil,nil,{ID = 131})        
        end
    )
    self:MyRefresh()
end

function C:MyRefresh()
end

function C:fishing_pos_change(data)
    if data then
        if data.isShow then
            self.transform.localPosition = Vector3.New(0,287,0)
        else
            self.transform.localPosition = Vector3.New(0,437,0)
        end
    end
end

function C:OnAssetChange()
    self:RefreshNum()
end

function C:RefreshNum()
    for i = 1,3 do
        local num = GameItemModel.GetItemCount(M.parm[i])
        local len = i == 1 and 3 or 2
        self["num"..i.."_txt"].text = M.MaxShowNum(num,len,self["add"..i])
    end
    self.kuang.gameObject:SetActive(M.IsCanGetAward())
end
