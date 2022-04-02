-- 创建时间:2019-05-16
-- 创建时间:2019-05-14
local basefunc = require "Game/Common/basefunc"
EliminateSGButtonPrefab_hscb = basefunc.class()
local M = EliminateSGButtonPrefab_hscb
local ins
M.name = "EliminateSGButtonPrefab_hscb"
function M.Create(id, data, parent)
    ins = M.New(id, data, parent)
    return ins
end

function M:ctor(id, data, parent)
    self.parent = parent
    self.gameObject = newObject(M.name, self.parent)
    self.transform = self.gameObject.transform
    LuaHelper.GeneratingVar(self.transform, self)
    self.data = data
    self.icon_id = id
    self.target_txt.text = self.data[1]
    local num = 0
    local tab = EliminateSGModel.GetBet()
    for k,v in pairs(tab) do
        num = num + v
    end
    self.award_txt.text =  StringHelper.ToCash(self.data[2] * num)
    Event.AddListener("ExitScene", basefunc.handler(self, self.Close))
end

function M:Close()
    Event.RemoveListener("ExitScene", basefunc.handler(self, self.Close))
    GameObject.Destroy(self.gameObject)
end

function M:RefreshSelet(b)
    self.select.gameObject:SetActive(b)
end

function M:GetTarget()
    return self.data[1]
end