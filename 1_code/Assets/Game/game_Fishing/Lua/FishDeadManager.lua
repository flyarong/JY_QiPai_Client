-- 创建时间:2019-03-28
-- 鱼的死亡管理器
-- 播放死亡效果，价钱动画

-- 胖胖鱼不能带技能

FishDeadManager = {}
local C = FishDeadManager
local lister
local panelSelf
local fish_dead

function C.Init(ps)
    panelSelf = ps
    C.panelSelf = panelSelf
	C.MakeLister()
	C.AddMsgListener()
end
function C.MyExit()
	C.RemoveListener()
end

function C.AddMsgListener()
    for proto_name,func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

function C.MakeLister()
    lister = {}
    lister["model_fish_dead_msg"] = fish_dead
end

function C.RemoveListener()
    for proto_name,func in pairs(lister) do
        Event.RemoveListener(proto_name, func)
    end
    lister = {}
end

-- 鱼的死亡
function fish_dead(data, type)
    local uipos = FishingModel.GetSeatnoToPos(data.seat_num)
    local userdata = FishingModel.GetSeatnoToUser(data.seat_num)
    if userdata and userdata.base then
        for k,v in ipairs(data.moneys) do
            userdata.wait_add_score = userdata.wait_add_score + v
        end
        userdata.last_wait_add_score_time = os.time()
        local endPos = panelSelf.PlayerClass[uipos]:GetFlyGoldPos()
        local playerPos = panelSelf.PlayerClass[uipos]:GetPlayerFXPos()
        local mbPos = panelSelf.PlayerClass[uipos]:GetMBPos()
        local my_seat_num = FishingModel.GetPlayerSeat()
        local jg = 2
        local attrI = 1
        
        for k,v in ipairs(data.fish_ids) do
            local score = data.moneys[k]
            local fish_id = v
            local II, skill_data = FishingSkillManager.getSkill(data.data, attrI, fish_id, data.seat_num)
            attrI = II
            if score == 0 then
                
                if skill_data then
                    local pp
                    local beginPos = Vector3.zero
                    local fish = FishManager.GetFishByID(fish_id)
                    if fish then
                        pp = fish.gameObject
                        beginPos = FishingModel.Get2DToUIPoint(fish:GetPos())
                    end
                    --粽子鱼（以及衍生出的活动）
                    if skill_data.type == 9 then
                        --skill_data.act_type = 0 是boss鱼 skill_data.act_type == 10 是话费鱼
                        if skill_data.act_type and skill_data.act_type > 0 and skill_data.act_type ~= 10 and skill_data.act_type ~= 8 then
                            Event.Brocast("model_dispose_skill_data", skill_data)
                        else
                            if my_seat_num == data.seat_num  then
                                FishingAnimManager.PlayXGYFishDead({score = skill_data.num,act_type = skill_data.act_type},panelSelf.FlyGoldNode.transform,function ()                                
                                    Event.Brocast("model_dispose_skill_data", skill_data)
                                end,endPos)
                            end
                        end                    
                        FishManager.S2CFishDead(fish_id)
                    else
                        FishingAnimManager.PlayTSFishDeadHint(panelSelf.FXNode, beginPos, pp, function ()
                            FishManager.S2CFishDead(fish_id)
                            Event.Brocast("model_dispose_skill_data", skill_data)
                        end)
                    end                    
                end


            else
                local buf1 = {}
                buf1.seat_num = data.seat_num
                buf1.score = score
                Event.Brocast("activity_get_gold",{seat_num = data.seat_num, score = score})

                -- 是否不播加钱
                local is_bubojiaqian = false
                if type and (type == FishingSkillManager.FishDeadAppendType.QP_bomb
                    or type == FishingSkillManager.FishDeadAppendType.QP_min_bomb
                    or type == FishingSkillManager.FishDeadAppendType.QP_min_laser
                    or type == FishingSkillManager.FishDeadAppendType.QP_laser
                    or type == FishingSkillManager.FishDeadAppendType.ppc_gjzd
                    or type == FishingSkillManager.FishDeadAppendType.fenghuang
                    or type == FishingSkillManager.FishDeadAppendType.ppc_cjzd) then
                    is_bubojiaqian = true
                end
                if skill_data and (skill_data.type == FishingSkillManager.FishDeadAppendType.lhzp 
                                   or skill_data.type == FishingSkillManager.FishDeadAppendType.fenghuang)then
                    --　第一次加这个代码是为了3D捕鱼转盘抽奖动画结束后把钱加上
                    skill_data.add_score = score
                    is_bubojiaqian = true
                end

                local beginPos
                local name_img
                -- if data.rate then
                --     buf1.fish_dead_rate = buf1.score / data.rate
                -- end

                if skill_data and skill_data.type == FishingSkillManager.FishDeadAppendType.zcm_rate then
                    -- dump(skill_data.gun_rate, "<color=white>EEE 招财猫 eeeeeeeeeeeeeeeeee </color>")
                    buf1.gun_rate = skill_data.gun_rate
                end

                
                local fish = FishManager.GetFishByID(fish_id)
                if fish then
                    beginPos = FishingModel.Get2DToUIPoint(fish:GetPos())
                    local fish_rate = fish:GetFishRate()
                    buf1.rate = fish_rate
                    name_img = fish:GetFishNameToSprite()
                    buf1.fish = fish

                    local hit_count = 100000
                    --dump(fish,"<color=red>+++++++fish++++++++</color>")
                    if fish.data and fish.data.player_hit_map and fish.data.player_hit_map[data.seat_num] then
                        hit_count = fish.data.player_hit_map[data.seat_num]
                    end
                    --dump({rate = fish.fish_cfg.rate,hit = hit_count},"<color=red>+++++++data++++++++</color>")
                    if fish.fish_cfg and fish.fish_cfg.rate >= 50 and hit_count < fish.fish_cfg.rate/10 then
                        --dump("<color=red>+++++++秒杀++++++++</color>")
                        GameComAnimTool.PlayShowAndHideAndCall(panelSelf.transform,"fishing3D_miaosha",beginPos,1.5)
                    end

                    if fish.fish_cfg and fish.fish_cfg.id == 61 then
                        dump(skill_data, "<color=white>11111111111111111</color>")
                    end

                else
                    FishManager.RemoveCacheFish(fish_id)
                    local x = math.random(0, 5)
                    if math.random(0, 100) % 2 == 0 then x = x + 10
                    else x = -x - 10 end
                    local y = math.random(0, 5)
                    if math.random(0, 100) % 2 == 0 then y = y + 10
                    else y = -y - 10 end
                    buf1.rate = 10
                    beginPos = FishingModel.Get2DToUIPoint( Vector3.New(x, y, 0) )
                    name_img = "by_imgf_zp6"
                end
                if fish and fish.fish_cfg then
                    buf1.cfg_fish_id = fish.fish_cfg.id
                end
                if not skill_data then
                    local delta_t
                    if type and (type == FishingSkillManager.FishDeadAppendType.Lightning or type == FishingSkillManager.FishDeadAppendType.Boom) then
                        delta_t = jg
                    else
                        -- 敢死队
                        if fish and fish:GetFishTeam() then
                            delta_t = jg
                        end
                    end
                    if not is_bubojiaqian then
                        if score == 0 then
                            FishingAnimManager.PlayFlyGrades(buf1, panelSelf.FlyGoldNode.transform, beginPos, lj_endPos, delta_t)
                        else
                            FishingAnimManager.PlayDeadFX(buf1, panelSelf.FlyGoldNode.transform, beginPos, endPos, playerPos, mbPos, name_img, delta_t)                        
                        end
                    end
                    FishManager.S2CFishDead(fish_id)
                else
                    if fish then
                        fish:SetFeignDead(true)
                    end
                    VehicleManager.RemoveVehicle(fish_id)
                    if FishingSkillManager.IsSkillAndShake(skill_data) then
                        local pp
                        if fish then
                            pp = fish.gameObject
                        end
                        FishingAnimManager.PlayTSFishDeadHint(panelSelf.FXNode, beginPos, pp, function ()
                            userdata.last_wait_add_score_time = os.time()
                            FishManager.S2CFishDead(fish_id)
                            if not is_bubojiaqian then
                                FishingAnimManager.PlayDeadFX(buf1, panelSelf.FlyGoldNode.transform, beginPos, endPos, playerPos, mbPos, name_img, 1.5)
                            end
                            Event.Brocast("model_dispose_skill_data", skill_data)
                        end)
                    else
                        Event.Brocast("model_dispose_skill_data", skill_data)
                        if not is_bubojiaqian then
                            if score == 0 then
                                FishingAnimManager.PlayFlyGrades(buf1, panelSelf.FlyGoldNode.transform, beginPos, lj_endPos, delta_t)
                            else
                                FishingAnimManager.PlayDeadFX(buf1, panelSelf.FlyGoldNode.transform, beginPos, endPos, playerPos, mbPos, name_img, delta_t)                        
                            end
                        end
                        FishManager.S2CFishDead(fish_id)
                    end
                end
                
            end
        end
    else
        print("<color=yellow>捕中鱼，但是玩家离开了</color>")
    end
end

-- 激光
function C.on_model_fish_dead_laser(data)
    if data.fish_ids and next(data.fish_ids) then
        local bullet_cfg = FishingModel.GetGunCfg(data.index)
        data.rate = bullet_cfg.gun_rate
        fish_dead(data)
    end
end
-- 核弹
function C.on_model_fish_dead_missile(data)
    if data.fish_ids and next(data.fish_ids) then
        fish_dead(data)
    end
end
-- 子弹
function C.on_model_fish_dead(data)
    local bullet = BulletManager.GetIDToBullet(data.id)
    if not bullet then
        dump(data, "<color=red>子弹不存在</color>")
        return
    end

    data.index = bullet.index
    data.seat_num = bullet.seat_num
    if bullet.type and bullet.type == 3 then
        data.active_rate = 2
    else
        data.active_rate = 1
    end
    local bullet_cfg = FishingModel.GetGunCfg(data.index)
    data.rate = bullet_cfg.gun_rate
    -- 鱼被打死了
    if data.fish_ids and next(data.fish_ids) then
        fish_dead(data)
    end

    if bullet.bulletSpr.type == 5 then
        -- 钻头弹 碰撞次数不定 最后还有一个爆炸状态
    else
        BulletManager.S2CBulletCrash(data.id)
    end
end

