-- 创建时间:2019-05-13
-- Panel:New Lua
local basefunc = require "Game/Common/basefunc"

EliminateSHInfoPanel = basefunc.class()
local M = EliminateSHInfoPanel
M.name = "EliminateSHInfoPanel"
local instance_Info
local ws_rate = 2
--武松时间
local is_during_ws_time = false
--得分表--
function M.Create()
    instance_Info = M.New()
    return instance_Info
end

function M:MakeLister()
    self.lister = {}
    self.lister["view_lottery_award"] = basefunc.handler(self, self.view_lottery_award)
    self.lister["eliminate_refresh_yazhu"] = basefunc.handler(self, self.eliminate_refresh_yazhu)
    self.lister["view_quit_game"] = basefunc.handler(self, self.Close)
    self.lister["view_lottery_start"] = basefunc.handler(self, self.FreshList)
    self.lister["view_lottery_end"] = basefunc.handler(self, self.view_lottery_end)
	self.lister["view_add_hero"] = basefunc.handler(self, self.view_add_hero)
	self.lister["view_lottery_error"] = basefunc.handler(self, self.view_lottery_error)
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end

function M:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

--开奖错误
function M:view_lottery_error()
    self:FreshList()
end

--一个一个消灭
function M:view_lottery_award(data)
    -- dump(data,"<color>单次消除的信息</color>")
    if data then
		self.AllInfoList[#self.AllInfoList + 1] = data
		--对于当前的游戏规则来说，没有单独对每种元素进行押注。因此所有元素的押注都是一样的
        local rate = 1
        if is_during_ws_time and data.hero_id == nil then
            rate = ws_rate
        end
		self:AddGold(self.BetList[1] * data.cur_rate * rate)
        if table_is_null(data.cur_del_list) then return  end 
        local hero_del = data.cur_del_list.hero_del
        local data2 = self:SoringData(data.cur_del_list)
        for k, v in pairs(data2) do
            self:DesPrefabInto(k, v, false,hero_del)
        end
        self:PlayParticle() 
    end
end

function M:view_add_hero(data)
    if data and data.hero_id == 1 then
        self:On_WS_Skill()
    else
    end
end

--当武松技能触发了
--1,播放相关特效，2，将武松技能触发前，非鲁智深消灭 ， 获得鲸币乘以2
function M:On_WS_Skill()
    if is_during_ws_time == false then
        is_during_ws_time = true
        local sum = 0
        for i = 1, #self.AllInfoList do
            if self.AllInfoList[i].hero_id == nil then
                sum = sum + self.BetList[1] * self.AllInfoList[i].cur_rate * (ws_rate - 1)
            end
        end
        self:AddGold(sum)
    end
end

--把信息整理成 （类型：个数）的形式
function M:SoringData(cur_del_list)
    local data = {}
    for k, v in pairs(cur_del_list) do
        if k ~= "hero_del" then
            for m, n in pairs(v) do
                if data[n] then
                    data[n] = data[n] + 1
                else
                    data[n] = 1
                end
            end
        end
    end
    return data
end

function M:PlayParticle()
    self.kuang2:Stop()
    self.kuang:Stop()
    self.xing:Stop()
    self.glow:Stop()
    self.kuang2:Play()
    self.xing:Play()
    self.glow:Play()
    self.kuang:Play()
end

function M:StopParticle()
    self.kuang2:Stop()
    self.kuang:Stop()
    self.xing:Stop()
    self.glow:Stop()
end

--断线重连获取数据 或者 结束的时候 重新刷新一次数据
function M:view_lottery_end(data)
    dump(self.gold, "由每次累计算出的数据")
    dump(self.AllInfoList, "<color=red>..............数据</color>")
    local sum = 0
    if not table_is_null(self.AllInfoList) then
        for i = 1, #self.AllInfoList do
            sum = sum + self.AllInfoList[i].cur_rate
        end
    end
    dump(sum, "<color=red>结算的总倍率数据</color>")
    self:FreshList()
    dump(data, "<color=red>结算数据</color>")
    for i = 1, #data.all_del_list do
        local hero_del = data.all_del_list[i].hero_del
        local data2 = self:SoringData(data.all_del_list[i])
        for k, v in pairs(data2) do
            self:DesPrefabInto(k, v, true,hero_del)
        end
    end
    self:AddGold(data.award_money)
    self:StopParticle()

    --刷新自己
end

function M:DesPrefabInto(id, num, IsReConnect,hero_del)
    local num = "x" .. num
    EliminateSHDesPrefab.Create(id, num, IsReConnect, self.Content,hero_del)
end

function M:AddGold(S)
    if self.gold + S > EliminateSHModel.GetAwardMoney() then
        return
    end
    self.gold = self.gold + S
    -- if  self.gold>=EliminateSHModel.GetAwardMoney() then
    -- 	self.gold=EliminateSHModel.GetAwardMoney()
    -- end
    self.goldtext.text = StringHelper.ToCash(self.gold)
end

--重置各种记录数据
function M:FreshList()
    self.gold = 0
    self.goldtext.text = 0
    is_during_ws_time = false
    self.AllInfoList = {}
    destroyChildren(self.Content)
end

function M:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
    self:RemoveListener()
    if self.WS_Timer then
        self.WS_Timer:Stop()
    end
    self.WS_Timer = nil
    destroy(self.gameObject)
end

function M:Close()
    self:MyExit()
end

function M:ctor()

	ExtPanel.ExtMsg(self)

    self.profablist = {}
    self.gold = 0
    self.BetList = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 0,
        [5] = 0
    }
    self.parent = GameObject.Find("Canvas/LayerLv1").transform
    self.gameObject = newObject(M.name, self.parent)
    self.gold = 0
    self.AllInfoList = {}
    self.goldtext = self.gameObject.transform:Find("bgs/GoldInfo/GoldText"):GetComponent("Text")
    self.goldtext.text = 0
    self.kuang2 = self.gameObject.transform:Find("kuang/kuang2"):GetComponent("ParticleSystem")
    self.kuang = self.gameObject.transform:Find("kuang/kuang"):GetComponent("ParticleSystem")
    self.xing = self.gameObject.transform:Find("kuang/xing"):GetComponent("ParticleSystem")
    self.glow = self.gameObject.transform:Find("kuang/glow"):GetComponent("ParticleSystem")
    self.TestButton = self.gameObject.transform:Find("TestButton"):GetComponent("Button")
    self.Content = self.gameObject.transform:Find("bgs/Viewport/TaskNode")
    self.TestButton.onClick:AddListener(
        function()
            Event.Brocast("view_lottery_award")
        end
    )
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
    if not XXLSHPHBManager or not XXLSHPHBManager.CheckIsShow() then 
        --self.gameObject.transform:Find("Help").transform.localPosition = Vector2.New(5.099998,-550)
        self.gameObject.transform:Find("Help").transform.localPosition = Vector2.New(-65,-550)
    end
end

function M:InitUI()
    self.gameObject.transform:Find("Help"):GetComponent("Button").onClick:AddListener(
        function()
            EliminateSHHelpPanel.Create()
        end
    )
end

function M:eliminate_refresh_yazhu(data)
    self.BetList[data[1]] = data[2]
    EliminateSHModel.SetBet(self.BetList)
end
