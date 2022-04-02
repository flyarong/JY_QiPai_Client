-- 创建时间:2019-05-16
-- Panel:New Lua
local basefunc = require "Game/Common/basefunc"
EliminateSGMoneyPanel_ccjj = basefunc.class()
local C = EliminateSGMoneyPanel_ccjj
C.name = "EliminateSGMoneyPanel_ccjj"
local instance
local level_tab = {{20,5},{30,10},{50,15},{70,20},{80,30},{90,50},{100,100}}


function C:MakeLister()
    self.lister = {}
    self.lister["view_lottery_error"] = basefunc.handler(self, self.view_lottery_error)
    self.lister["view_lottery_sucess"] = basefunc.handler(self, self.view_lottery_sucess)
    self.lister["add_free_game_times_msg"] = basefunc.handler(self,self.add_free_game_times_msg)
    self.lister["refresh_collect_arrows_nums_change_mag"] = basefunc.handler(self,self.refresh_collect_arrows_nums_change_mag)
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
    self.times_txt.text = 0
    self.cur_score_txt.text = 0
end

--初始化子物体
function C:InitChildButton()
    self:CloseChildButton()
    for i = #level_tab,1,-1  do
        local child = EliminateSGButtonPrefab_ccjj.Create(i, level_tab[i], self.layoutgroup)
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


function C:add_free_game_times_msg(data)
    self:RefreshFreeGameTimes(data)
end

function C:RefreshFreeGameTimes(data)
    if data then
        self.times_txt.text = tonumber(data)
    else        
        self.times_txt.text = tonumber(self.times_txt.text) + 1
    end
end

function C:refresh_collect_arrows_nums_change_mag(data,all)
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
    if all then
        self.cur_score_txt.text =num
    else
        self.cur_score_txt.text = self.cur_score_txt.text+num
    end
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