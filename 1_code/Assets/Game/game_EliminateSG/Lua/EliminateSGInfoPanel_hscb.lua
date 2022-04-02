local basefunc = require "Game/Common/basefunc"

EliminateSGInfoPanel_hscb = basefunc.class()
local M = EliminateSGInfoPanel_hscb
M.name = "EliminateSGInfoPanel_hscb"
local instance_Info
function M.Create()
    if not instance_Info then
        instance_Info = M.New()
    end
    return instance_Info
end

function M:MakeLister()
    self.lister = {}
    self.lister["view_lottery_award"] = basefunc.handler(self, self.view_lottery_award)
    --self.lister["view_lottery_start"] = basefunc.handler(self, self.FreshList)
    self.lister["view_lottery_end"] = basefunc.handler(self, self.view_lottery_end)
	self.lister["view_lottery_error"] = basefunc.handler(self, self.view_lottery_error)
    self.lister["refresh_boat_nums_change_mag"] = basefunc.handler(self,self.on_refresh_boat_nums_change_mag)
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
    --dump(data,"<color>单次消除的信息</color>")
    if data then
		self.AllInfoList[#self.AllInfoList + 1] = data
		--对于当前的游戏规则来说，没有单独对每种元素进行押注。因此所有元素的押注都是一样的
        local rate = 1
        self:AddGold(self.BetList[1] * data.cur_rate * rate)
        data.cur_del_list = data.cur_del_map
        if table_is_null(data.cur_del_list) then return  end 
        local data2 = self:SoringData(data.cur_del_list)
        for k, v in pairs(data2) do
            self:DesPrefabInto(k, v, false)
        end
        self:PlayParticle() 
    end
end

--把信息整理成 （类型：个数）的形式
function M:SoringData(cur_del_list)
    local data = {}
    for k, v in pairs(cur_del_list) do
        for m, n in pairs(v) do
            if data[n] then
                data[n] = data[n] + 1
            else
                data[n] = 1
            end
        end
    end
    return data
end

--断线重连获取数据 或者 结束的时候 重新刷新一次数据
function M:view_lottery_end(data)
    self:MyRefresh(data)
    self:StopParticle()
    self:StopParticle_boat()
end

function M:DesPrefabInto(id, num, IsReConnect)
    local num = "x" .. num
    EliminateSGDesPrefab_hscb.Create(id, num, IsReConnect, self.Content)
end

function M:AddGold(S)
    if self.gold + S > EliminateSGModel.GetAwardMoney() then
        return
    end
    self.gold = self.gold + S
    -- if  self.gold>=EliminateSGModel.GetAwardMoney() then
    -- 	self.gold=EliminateSGModel.GetAwardMoney()
    -- end
    
    self.goldtext.text = StringHelper.ToCash(self.gold)
end

--重置各种记录数据
function M:FreshList()
    self.gold = 0
    self.goldtext.text = 0
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
    instance_Info = nil
end

function M:ctor()

	ExtPanel.ExtMsg(self)

    self.profablist = {}
    if EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_2 then
        self.gold = EliminateSGModel.data.eliminate_data.all_money - EliminateSGModel.data.eliminate_data.cur_money
    else
        self.gold = EliminateSGModel.data.eliminate_data.cur_money
    end
    
    self.BetList = EliminateSGModel.GetBet()
    self.parent = GameObject.Find("Canvas/LayerLv1").transform
    self.gameObject = newObject(M.name, self.parent)
    self.AllInfoList = {}
    self.goldtext = self.gameObject.transform:Find("bgs/GoldInfo/GoldText"):GetComponent("Text")
    if EliminateSGModel.is_all_info then
        self.goldtext.text = StringHelper.ToCash(0)
        EliminateSGModel.is_all_info = false
    else
       self.goldtext.text = StringHelper.ToCash(self.gold)
    end
    --self.goldtext.text = StringHelper.ToCash(self.gold)
    self.boatGold_txt = self.gameObject.transform:Find("bgs/GoldInfo_boat/boatGold_txt"):GetComponent("Text")
    self:RefreshBoatGold()
    self.Content = self.gameObject.transform:Find("bgs/Viewport/TaskNode")
    self.kuang2 = self.gameObject.transform:Find("kuang/kuang2"):GetComponent("ParticleSystem")
    self.kuang = self.gameObject.transform:Find("kuang/kuang"):GetComponent("ParticleSystem")
    self.xing = self.gameObject.transform:Find("kuang/xing"):GetComponent("ParticleSystem")
    self.glow = self.gameObject.transform:Find("kuang/glow"):GetComponent("ParticleSystem")
    self.kuang2_boat = self.gameObject.transform:Find("kuang_boat/kuang2_boat"):GetComponent("ParticleSystem")
    self.kuang_boat = self.gameObject.transform:Find("kuang_boat/kuang_boat"):GetComponent("ParticleSystem")
    self.xing_boat = self.gameObject.transform:Find("kuang_boat/xing_boat"):GetComponent("ParticleSystem")
    self.glow_boat = self.gameObject.transform:Find("kuang_boat/glow_boat"):GetComponent("ParticleSystem")
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
end

function M:InitUI()

end

function M:PlayParticle_boat()
    self.kuang2_boat:Stop()
    self.kuang_boat:Stop()
    self.xing_boat:Stop()
    self.glow_boat:Stop()
    self.kuang2_boat:Play()
    self.kuang_boat:Play()
    self.xing_boat:Play()
    self.glow_boat:Play()
end

function M:StopParticle_boat()
    self.kuang2_boat:Stop()
    self.kuang_boat:Stop()
    self.xing_boat:Stop()
    self.glow_boat:Stop()
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

function M:MyRefresh(data)
    dump(self.gold, "由每次累计算出的鲸币")
    local sum = 0
    if not table_is_null(self.AllInfoList) then
        for i = 1, #self.AllInfoList do
            sum = sum + self.AllInfoList[i].cur_rate
        end
    end
    dump(sum, "<color=red>由每次累计算出的倍率</color>")

    self:FreshList()
    dump(data, "<color=red>结算数据</color>")
    for i = 1, #data.all_del_list do
        local data2 = self:SoringData(data.all_del_list[i])
        for k, v in pairs(data2) do
            self:DesPrefabInto(k, v, true)
        end
    end
    self:AddGold(data.all_money - (self.score or 0))
    if EliminateSGModel.is_all_info then
        self.goldtext.text = StringHelper.ToCash(data.all_money-self.score)
        EliminateSGModel.is_all_info = false
    else
        self.goldtext.text = StringHelper.ToCash(self.gold)
    end
end

local level_tab = {{5,5},{8,10},{10,15},{12,20},{15,30},{18,50},{20,100}}

function M:on_refresh_boat_nums_change_mag(data)
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
    local bet = 0
    local tab = EliminateSGModel.GetBet()
    for k,v in pairs(tab) do
        bet = bet + v
    end
    for i=#level_tab,1,-1 do
        if num >= level_tab[i][1] then
            self.score = level_tab[i][2] * bet
            break
        end
    end
    self:RefreshBoatGold()
    self.last_score = self.last_score or 0
    self.score = self.score or 0
    if self.last_score < self.score then
        self:PlayParticle_boat()
    end
    self.last_score = self.score
end

function M:RefreshBoatGold()
    self.boatGold_txt.text = StringHelper.ToCash(self.score or 0)
end
