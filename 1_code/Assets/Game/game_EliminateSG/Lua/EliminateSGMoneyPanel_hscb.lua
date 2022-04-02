-- 创建时间:2019-05-16
-- Panel:New Lua
local basefunc = require "Game/Common/basefunc"
EliminateSGMoneyPanel_hscb = basefunc.class()
local C = EliminateSGMoneyPanel_hscb
C.name = "EliminateSGMoneyPanel_hscb"
local instance
local level_tab = {{5,5},{8,10},{10,15},{12,20},{15,30},{18,50},{20,100}}


function C:MakeLister()
    self.lister = {}
    self.lister["view_lottery_error"] = basefunc.handler(self, self.view_lottery_error)
    self.lister["view_lottery_sucess"] = basefunc.handler(self, self.view_lottery_sucess)
    self.lister["free_game_times_change_msg"] = basefunc.handler(self,self.on_free_game_times_change_msg)
    self.lister["refresh_boat_nums_change_mag"] = basefunc.handler(self,self.on_refresh_boat_nums_change_mag)
end

function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C.Create()
    if not instance then
        instance = C.New()
    end
    return instance
end

function C:ctor()

	ExtPanel.ExtMsg(self)

    local parent = GameObject.Find("Canvas/LayerLv1").transform
    local obj = newObject(C.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
    self:InitChildButton()
end

function C:MyExit()
    self:CloseChildButton()
    self:RemoveListener()
    destroy(self.gameObject)
    instance = nil
end

function C:Close()
    self:MyExit()
end

function C:InitUI()
    self.times_txt.text = 6
    self.cur_score_txt.text = 0
end

--初始化子物体
function C:InitChildButton()
    self:CloseChildButton()
    for i = #level_tab,1,-1  do
        local child = EliminateSGButtonPrefab_hscb.Create(i, level_tab[i], self.layoutgroup)
        self.childs[#self.childs + 1] = child
    end
end

function C:CloseChildButton()
    if self.childs then
        for k,v in pairs(self.childs) do
            v:Close()
        end
    end
    self.childs = {}
end

--开奖成功
function C:view_lottery_sucess()
	
end

--开奖错误
function C:view_lottery_error()
end


function C:on_free_game_times_change_msg(times)
    self:RefreshFreeGameTimes(times)
end

function C:RefreshFreeGameTimes(times)
    self.times_txt.text = times or 0
end

function C:on_refresh_boat_nums_change_mag(data)
    local num = 0
    if type(data) == "table" then
        for k,v in pairs(data) do
            for kk,vv in pairs(v) do
                if vv >= 100 then
                    num = num + 1
                end
            end
        end
    elseif type(data) == "number" then
        num = data
    end
    self.cur_score_txt.text = num
    self:RefreshSelect()
end

function C:RefreshSelect()
    for k,v in pairs(self.childs) do
        v:RefreshSelet(false)
    end
    for i=1,#self.childs do
        if tonumber(self.cur_score_txt.text) >= self.childs[i]:GetTarget() then
            self.childs[i]:RefreshSelet(true)
            break
        end
    end
end