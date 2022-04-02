MatchHallContent = basefunc.class()
local M = MatchHallContent

M.name = "MatchHallContent"
local dotweenlayer = "MatchHallContent_1"
local instance
function M.Create(parent)
    if instance then
        instance:Exit()
    end
    instance = M.New(parent)
	return instance
end

function M.Close()
    if instance then
        instance:Exit()
    end
end

function M.Refresh(cfg)
    if instance then
        instance:Update(cfg)
    end
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:ctor(parent)
	local obj = newObject(M.name, parent)
    self.gameObject = obj
    self.transform = obj.transform
	self:MakeLister()
    self:AddMsgListener()
    LuaHelper.GeneratingVar(obj.transform, self)
    self:Init()
end

function M:Exit()
    self:RemoveListener()
    self:ClearMatchList()
    GameObject.Destroy(self.gameObject)
end

function M:Init()
    
end

--刷新游戏列表
function M:ClearMatchList()
    if self.MatchList then
        for k,v in ipairs(self.MatchList) do
            v:OnDestroy()
        end
    end
    self.MatchList = {}
    self.MatchHash = {}
end

--清除兑换
function M:ClearDhList()
    
end

function M:Update(hall_cfg)
    self:ClearMatchList()
    self:ClearDhList()

    if hall_cfg.hall_type == MatchModel.HallType.bydjs then
        --捕鱼大奖赛
        FishingMatchSignupPanel.Create({parent = self.transform,name = "MatchHallFishingMatchSignupPanel"})
        return
    else
        FishingMatchSignupPanel.Close()
    end

    local match_cfg = MatchModel.GetMatchToShow(hall_cfg.hall_type)
    if not table_is_null(match_cfg) then
        if match_cfg[1].start_type == 2 then
            table.sort(match_cfg,function(a, b)
                return a.start_time < b.start_time
            end)    
        else
            table.sort(match_cfg,function(a, b)
                return a.ui_order < b.ui_order
            end)    
        end
        for k,v in ipairs(match_cfg) do
            if v.is_on_off == 1 then
                local item = MatchHallMatchItem.Create(self.match_sv_content, v)
                item:SetObjName(v.game_id)
                table.insert( self.MatchList, item)
                self.MatchHash = self.MatchHash or {}
                self.MatchHash[v.game_id] = item
            end
        end
    end

    --金条巡回赛
    if hall_cfg.hall_type == MatchModel.HallType.jtxhs then
        self.dh_sv.gameObject:SetActive(true)
    else
        self.dh_sv.gameObject:SetActive(false)
    end
    self:OpenRightUIAnim()
end

function M:OpenRightUIAnim()
    if self.MatchList then
        local i = 0
        local tt = 0.1
        for k,v in ipairs(self.MatchList) do
            v:PlayAnim(i * tt)
            i = i + 1			
        end
    end
end