-- 创建时间:2019-03-11
local basefunc = require "Game.Common.basefunc"
FishingActivityBK = basefunc.class()

local M = FishingActivityBK
M.name = "FishingActivityBK"
local Manager = FishingActivityManager

local s_time = 3
local e_time = 3
local min_scale = 0.1

FishingActivityBK.FABKState = 
{
    FABKS_Nor = "常态",
    FABKS_Zh = "最后10秒",
}

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    self.lister["ui_begin_anim"] = basefunc.handler(self, self.on_ui_begin_anim)
    self.lister["ui_bk_activity_refresh_data_bk_id"] = basefunc.handler(self, self.on_refresh_data_bk_id)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:ctor(data,config)
	ExtPanel.ExtMsg(self)

    if not data.msg_type or not data.seat_num then return end
    self:MakeLister()
    self:AddMsgListener()

    self.data = data
    self.config = config
    self.panelSelf = FishingLogic.GetPanel()
    self.parent = GameObject.Find("Canvas/LayerLv5")
    self.gameObject = newObject(M.name, self.parent.transform)
    self.transform = self.gameObject.transform
	self.gameObject:SetActive(true)

    self.actbk_state = FishingActivityBK.FABKState.FABKS_Nor

    LuaHelper.GeneratingVar(self.transform, self)
    local uipos = FishingModel.GetSeatnoToPos(data.seat_num)
    self.uipos = uipos
    self.player_node.position = self.panelSelf.PlayerClass[uipos]:GetPlayerPos()
    if uipos == 1 or uipos == 2 then
        self.player_node.rotation = Quaternion.Euler(0, 0, 0)
    else
        self.player_node.rotation = Quaternion.Euler(0, 0, 180)
    end
    self.time_txt.gameObject:SetActive(false)

    self.bknode = {}
    self.bknode_pos = {}
    for i = 1, 4 do
        self.bknode[#self.bknode + 1] = self["bknode"..i]
        self.bknode_pos[#self.bknode_pos + 1] = FishingModel.GetUITo2DPoint(self["bknode"..i].transform.position)
    end

    local status = M.CheckActivityStatus(self.data)
    if status == FISHING_ACTIVITY_STATUS_ENUM.begin then
        self:InitUI()
    elseif status == FISHING_ACTIVITY_STATUS_ENUM.running then
        self:Refresh(data)
    end
end

function M:Exit(data)
    if self.update then self.update:Stop() end
    if self.xh_audio then
        soundMgr:CloseLoopSound(self.xh_audio)
        self.xh_audio = nil
    end
    if self.data.data then
        if not FishingModel.IsRecoverRet then
            if self.all_time and self.cur_time then
                local tt = self.all_time - self.cur_time
                if tt <= 0 then
                    ExtendSoundManager.PlaySound(audio_config.by.bgm_by_beikexiaoshi.audio_name)
                end
            end
        end
        for k,v in ipairs(self.data.data) do
            local fish = FishManager.GetFishByID(v)
            if fish then
                if FishingModel.IsRecoverRet then
                    fish:MyExit()
                else
                    if not data then
                        fish:MyExit()
                    else
                        fish:Flee()
                        local pos = FishingModel.Get2DToUIPoint(fish:GetPos())
                        FishingAnimManager.PlayBKFleeFX(self.panelSelf.fish_node_tran, pos)
                    end
                end
            end
        end
    end

    destroy(self.gameObject)
    self:RemoveListener()
end
function M:InitUI()
    self.is_nor = true
end

function M:Refresh(data)
    self.data = data
    self:StartUpdate()
    if self.data.seat_num == FishingModel.GetPlayerSeat() then
        self.time_txt.gameObject:SetActive(true)
    else
        self.time_txt.gameObject:SetActive(false)
    end

    if self.data.status == 1 and self.data.data then
        for k,v in ipairs(self.data.data) do
            local fish = FishManager.GetFishByID(v)
            if fish and fish.CreateFinish then
                fish:CreateFinish()
            end
        end
    end
end

function M:StartUpdate()
    local b_time = tonumber(self.data.begin_time)
    local time = tonumber(self.data.time)
    local s_time = tonumber(FishingModel.GetSystemTime())
    local sb_time = tonumber(FishingModel.GetFirstSystemTime())
    if s_time and sb_time and b_time and time then
        self.all_time = time
        self.cur_time = s_time - sb_time - b_time
    end
    if self.update then self.update:Stop() end
    self.update = Timer.New(function(  )
        self:Update()
    end,1,-1,false,false)
    self.update:Start()
    self:SetTimeText()
end

function M:SetTimeText()
    if self.cur_time < self.all_time then
        if self.data.seat_num == FishingModel.GetPlayerSeat() then
            local tt = self.all_time - self.cur_time
            self.time_txt.text = tt .. "s"
            if tt <= 10 and self.actbk_state == FishingActivityBK.FABKState.FABKS_Nor then
                self.actbk_state = FishingActivityBK.FABKState.FABKS_Zh
                self.xh_audio = ExtendSoundManager.PlaySound(audio_config.by.bgm_by_beikedaojishi.audio_name, -1)
            end
        end
    end
end
function M:Update()
    self.cur_time = self.cur_time + 1
    self:SetTimeText()
    if self.cur_time >= self.all_time then
        -- 时间到 关闭
        if self.update then self.update:Stop() end
    end
end

function M:AriseAnimFinish()
    self.arise_num = self.arise_num + 1
    if self.arise_num == 4 then
        FishingModel.SendActivity(self.data)
    end
end
-- 出现动画
function M:AriseAnim(prefab, index, pos)
    pos = pos or Vector3.zero
    prefab.transform.position = pos
    local move_pos = Vector3.New(pos.x, pos.y, pos.z) -- + math.random(0, 4)-2
    local end_pos = self.bknode_pos[index]

    local seq = DoTweenSequence.Create()
    seq:Append(prefab.transform:DOMove(move_pos, 1))
    seq:AppendInterval(0.4)
    seq:Append(prefab.transform:DOMove(end_pos, 1))
    seq:OnKill(function ()
        self:AriseAnimFinish()
    end)
end

-- 鱼的坐标点 pos
function M:on_ui_begin_anim(data)
    ExtendSoundManager.PlaySound(audio_config.by.bgm_by_beikechuxian.audio_name)
    if data.seat_num == self.data.seat_num then
        local endPos = self.panelSelf.PlayerClass[data.seat_num]:GetPlayerPos()
        FishingAnimManager.PlayMoveAndHideFX(self.panelSelf.FXNode, "bk_siwang", data.pos, endPos, 0.2, 0.4, function ()
            FishingModel.SendActivity(self.data)            
        end)
    end
end
function M:on_refresh_data_bk_id(seat_num, data)
    if self.data.seat_num and self.data.seat_num == seat_num then
        self.data.data = data
        if self.data.status == 1 then
            for k,v in ipairs(self.data.data) do
                local fish = FishManager.GetFishByID(v)
                if fish and fish.CreateFinish then
                    fish:CreateFinish()
                end
            end
        end
    end
end

------------------------------------------外部使用数据
function M:GetDropAwardRate()
    if not self.data then return nil end
    if not self:CheckIsRunning() then return nil end
    return self.data.rate    
end

function M:CheckIsGanChangeGun(  )
    if not self.config then return nil end
    if not self:CheckIsRunning() then return nil end
    return self.config.change_gun
end

function M:GetBulletType(  )
    if not self.config or not self.data then return nil end
    if not self:CheckIsRunning() then return nil end
    if self.data.num <= 0 then return nil end
    return self.config.bullet_type
end

function M:GetFishNetType(  )
    if not self.config or not self.data then return nil end
    if not self:CheckIsRunning() then return nil end
    if self.data.num <= 0 then return nil end
    return self.config.net_type
end

function M:activity_get_gold(data)
    -- dump(data, "<color=green>activity_get_gold</color>")
    if true then return nil end
    if not self:CheckIsRunning() then return nil end
    if data and data.seat_num == self.data.seat_num and data.score then
        self.data.all_score = self.data.all_score or 0
        self.data.all_score = self.data.all_score + data.score
    end
end

function M:activity_kill_fish(data)
    if not self:CheckIsRunning() then return nil end
    -- dump(data, "<color=green>activity_kill_fish</color>")
end

function M:activity_shoot(data)
    if not self:CheckIsRunning() then return nil end
    -- dump(data, "<color=green>activity_shoot</color>")
    if self.data and self.data.num and self.data.num > 0 then
        self.data.num = self.data.num - 1
    end
end

function M:activity_fish_gun_rotation(data)
end

function M.CheckIsActivityTime(data)
    if data then return false end
    if data and data.num then
        return data.num > 0
    end
    return false
end

function M.CheckActivityStatus(data)
    if not data then return false end
    local function check_time(_data)
        if _data.status == 0 then
            return FISHING_ACTIVITY_STATUS_ENUM.begin
        elseif _data.status == 1 then
            return FISHING_ACTIVITY_STATUS_ENUM.running
        end
        return FISHING_ACTIVITY_STATUS_ENUM.over
    end
    if data and data.status then
        return check_time(data)
    end
    return FISHING_ACTIVITY_STATUS_ENUM.over
end

function M:CheckHaveBullet()
    if self.data and self.data.num then
        return self.data.num > 0
    end
    return false
end

function M:CheckIsRunning()
    if self.data and self.data.status and self.data.status == 1 then
        return true
    end
    return false
end