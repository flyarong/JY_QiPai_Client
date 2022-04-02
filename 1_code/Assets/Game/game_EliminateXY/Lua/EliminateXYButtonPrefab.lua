-- 创建时间:2019-05-16
-- 创建时间:2019-05-14
local basefunc = require "Game/Common/basefunc"
EliminateXYButtonPrefab = basefunc.class()
local M = EliminateXYButtonPrefab
local ins
M.name = "EliminateXYButtonPrefab"
function M.Create(_id, _money, parent)
    ins = M.New(_id, _money, parent)
    return ins
end

--刷新单个押注
function M:SetBet(data)
    self.t.text = data
    self.shanguang:Stop()
    self.shanguang:Play()
    Event.Brocast("eliminate_refresh_yazhu", {[1] = self.icon_id, [2] = data})
end

function M:ctor(id, money, parent)
    self.parent = parent
    self.gameObject = newObject(M.name, self.parent)
    self.transform = self.gameObject.transform
    self.money = money
    self.icon_id = id
    self.img = self.transform:Find("Image"):GetComponent("Image")
    self.t = self.transform:Find("Text"):GetComponent("Text")
    self.shanguang = self.gameObject.transform:Find("shanguang"):GetComponent("ParticleSystem")
    self.img.sprite = EliminateXYObjManager.item_obj["sdbgj_icon_dj" .. self.icon_id]
    self.t.text = self.money
    self:SetBet(self.money)
    Event.AddListener("view_quit_game", basefunc.handler(self, self.Close))
end

function M:Close()
    Event.RemoveListener("view_quit_game", basefunc.handler(self, self.Close))
    GameObject.Destroy(self.gameObject)
end
