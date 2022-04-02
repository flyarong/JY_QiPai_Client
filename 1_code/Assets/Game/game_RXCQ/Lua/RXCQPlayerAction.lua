-- 创建时间:2021-02-23
-- Panel:RXCQPlayerAction
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

RXCQPlayerAction = basefunc.class()
local C = RXCQPlayerAction
C.name = "RXCQPlayerAction"

function C.Create(parent,index)
	return C.New(parent,index)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["rxcq_moneyitem_fly_over"] = basefunc.handler(self,self.on_rxcq_moneyitem_fly_over)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    self.player:MyExit()
    self.wuqi:MyExit()
	self:RemoveListener()
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent,index)
    self:MakeLister()
    self.player = RXCQPlayerPrefab.Create(parent,index)
    self.wuqi = RXCQWuQiPrefab.Create(self.player.WuQiNode)
    self.player.transform.localScale = Vector3.New(0.7,0.7,0.7)
    self:Stand()
    RXCQModel.RegisterExitFunc(function()
        self:MyExit()
    end)
end

function C:Run(target_pos,backcall)
    self:SoundPlay("Run")
    self.player:Run()
    self.wuqi:Run()
    if target_pos then
        local seq = DoTweenSequence.Create({dotweenLayerKey = "rxcq"})
        seq:Append(self.player.transform:DOLocalMove(target_pos, 0.8):SetEase(DG.Tweening.Ease.Linear))
        seq:AppendCallback(function()
            if backcall then
                backcall()
            end
        end)
    end
end

function C:Hit(backcall,skill_name)
    self:SoundPlay("Hit")
    self.player:Hit(0.4 * 1/RXCQModel.GetAutoSpeed(),backcall)
    self.wuqi:Hit(0.4 * 1/RXCQModel.GetAutoSpeed(),skill_name)
end

function C:Stand()
    self:SoundPlay("Stand")
    self.player:Stand()
    self.wuqi:Stand()
end

local att_todo = {}
function C:att_ex_func(skill_name,RXCQPlayerAction)
    local get_guaiwu_money_map = RXCQNormalDie.get_guaiwu_money_map()
    local config = {
        BanYueWanDao = 3,
        CiShaJianShu = 2,
        GongShaJianShu = 1,
        LieHuoJianFa = 5,
    }
    local wake_cid = {
        3,6,8,12,15,17,21
    }
    local monster_backup = RXCQModel.game_data.monster
    local hit_times = config[skill_name]
    for i = 1,#wake_cid do
        if wake_cid[i] == RXCQModel.game_data.cid or #RXCQModel.game_data.monster == 0 then
            hit_times = 1
            break
        end
    end
    local monster_die_map = {}
    for i = 1,hit_times do
        local data = {RXCQModel.game_data.monster[i]}
        if i == hit_times then
            data = {} 
            for j = #RXCQModel.game_data.monster,i,-1 do
                data[#data + 1] = RXCQModel.game_data.monster[j]
            end
        end
        monster_die_map[#monster_die_map + 1] = data
    end
    dump(monster_die_map,"<color=red>怪物死亡顺序</color>")
    for i = 1,#monster_die_map do
        RXCQModel.DelayCall(
            function()
                self:Hit(function()
                    RXCQNormalDie.Die(RXCQPlayerAction,monster_die_map[i],get_guaiwu_money_map,i == #monster_die_map)  
                end,skill_name)
            end
        ,(i - 0.9) * 1.2)
    end
end

local curr_money = 0
function C:on_rxcq_moneyitem_fly_over(data)
    curr_money = curr_money + data.money
    
end

function C:Attack(RXCQPlayerAction,skill_name,target_pos)
    self:Run()
    local seq = DoTweenSequence.Create({dotweenLayerKey = "rxcq"})
    seq:Append(self.player.transform:DOLocalMove(target_pos or Vector3.New(39,-108,0), 0.6 * 1/RXCQModel.GetAutoSpeed()):SetEase(DG.Tweening.Ease.Linear))
    seq:AppendCallback(function ()
        --self:Hit(backcall,skill_name)
        self:att_ex_func(skill_name,RXCQPlayerAction)
    end)
   -- self:Hit(backcall,skill_name)
end

function C:ShowChuanSong()
    self.player:ShowChuanSong(function()
        self:Stand()
    end)
end

function C:SoundPlay(_type)
    if  self.play_sound_timer then
        self.play_sound_timer:Stop()
    end
    ExtendSoundManager.CloseSound(self.run_sound)
    if _type == "Run" then
        self.run_sound = ExtendSoundManager.PlaySound(audio_config.rxcq.rxcq_move.audio_name)
        self.play_sound_timer = Timer.New(
            function()
                self.run_sound = ExtendSoundManager.PlaySound(audio_config.rxcq.rxcq_move.audio_name)
            end
        ,0.392,-1,nil,true)
        self.play_sound_timer:Start()
        RXCQModel.AddTimers(self.play_sound_timer)
    elseif _type == "Hit" then
        
    elseif _type == "Stand" then

    end
end