-- 创建时间:2019-03-28
-- 鱼的死亡管理器
-- 播放死亡效果，价钱动画

FishDeadManager = {}
local C = FishDeadManager
local lister
local panelSelf
local fish_dead
function C.Init(ps)
	panelSelf = ps
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
function fish_dead(data, attr)
    local uipos = FishingModel.GetSeatnoToPos(data.seat_num)

    if data.seat_num == 1 then
        for k,v in ipairs(data.moneys) do
            FishingMatchModel.data.wait_add_score = FishingMatchModel.data.wait_add_score + v
        end
    end
    -- 副炮只加累计赢金
    if data.seat_num ~= 1 then
        for k,v in ipairs(data.moneys) do
            data.moneys[k] = 0
        end
    end
    for k,v in ipairs(data.grades) do
        FishingMatchModel.data.wait_add_grades = FishingMatchModel.data.wait_add_grades + v
    end
    local endPos = panelSelf.PlayerClass[uipos]:GetFlyGoldPos()
    local lj_endPos = panelSelf.PlayerClass[uipos]:GetFlyGradesPos()
    local playerPos = panelSelf.PlayerClass[uipos]:GetPlayerFXPos()
    local mbPos = panelSelf.PlayerClass[uipos]:GetMBPos()
    local my_seat_num = FishingMatchModel.GetPlayerSeat()
    local jg = 2
    local attrI = 1

    for k,v in ipairs(data.fish_ids) do
        local score = data.moneys[k]
        local grades = data.grades[k]
        local skill_id = data.data[k]
        local fish_id = v
        local II, skill_data = FishingSkillManager.getSkill(data.data, attrI, fish_id, data.seat_num)
        attrI = II

        if score == 0 and grades == 0 and not skill_data then
            dump(v, "<color=red>EEE 钱和累计赢金都为0且没有活动</color>")
        else
            local buf1 = {}
            buf1.seat_num = data.seat_num
            buf1.score = score
            buf1.grades = grades
            buf1.grades_rate = data.rates[k]
            buf1.style = "match"
            Event.Brocast("activity_get_gold",{seat_num = data.seat_num, score = score})

            -- 是否不播加钱
            local is_bubojiaqian = false
            if attr and (attr == FishingSkillManager.FishDeadAppendType.QP_bomb
                or attr == FishingSkillManager.FishDeadAppendType.QP_min_bomb
                or attr == FishingSkillManager.FishDeadAppendType.QP_min_laser
                or attr == FishingSkillManager.FishDeadAppendType.QP_laser
                or attr == FishingSkillManager.FishDeadAppendType.ppc_gjzd
                or attr == FishingSkillManager.FishDeadAppendType.ppc_cjzd) then
                is_bubojiaqian = true
            end

            local beginPos
            local name_img

            local fish = FishManager.GetFishByID(v)
            if fish then
                beginPos = FishingMatchModel.Get2DToUIPoint(fish:GetPos())
                local fish_rate = fish:GetFishRate()
                buf1.rate = fish_rate
                name_img = fish:GetFishNameToSprite()
            else
                FishManager.RemoveCacheFish(v)
                local x = math.random(0, 5)
                if math.random(0, 100) % 2 == 0 then x = x + 10
                else x = -x - 10 end
                local y = math.random(0, 5)
                if math.random(0, 100) % 2 == 0 then y = y + 10
                else y = -y - 10 end
                buf1.rate = 10
                beginPos = FishingMatchModel.Get2DToUIPoint( Vector3.New(x, y, 0) )
                name_img = "by_imgf_zp6"
            end
            if not skill_data then
                local delta_t
                if attr and (attr == FishingSkillManager.FishDeadAppendType.Lightning or attr == FishingSkillManager.FishDeadAppendType.Boom) then
                    delta_t = jg
                else
                    -- 敢死队
                    if fish and fish:GetFishTeam() then
                        delta_t = jg
                    end
                end

                if not is_bubojiaqian then
                    if score > 0 then
                        FishingAnimManager.PlayDeadFX(buf1, panelSelf.FlyGoldNode.transform, beginPos, endPos, playerPos, mbPos, name_img, delta_t)                        
                    elseif grades > 0 then
                        FishingAnimManager.PlayFlyGrades(buf1, panelSelf.FlyGoldNode.transform, beginPos, lj_endPos, playerPos, mbPos, name_img, delta_t)
                    end
                end
                FishManager.S2CFishDead(fish_id)
            else
                if fish then
                    fish:SetFeignDead(true)
                end
                VehicleManager.RemoveVehicle(fish_id)
                if fish and not fish.fish_cfg then
                    dump(fish, "<color=red>EEE 鱼的配置为空</color>")
                end
                -- 幸运宝箱死亡不带挣扎效果
                if FishingSkillManager.IsSkillAndShake(skill_data) and (not fish or (fish.fish_cfg and fish.fish_cfg.id ~= 27)) then
                    local pp
                    if fish then
                        pp = fish.gameObject
                    end
                    FishingAnimManager.PlayTSFishDeadHint(panelSelf.FXNode, beginPos, pp, function ()
                        FishManager.S2CFishDead(fish_id)
                        if not is_bubojiaqian then
                            if score > 0 then
                                FishingAnimManager.PlayDeadFX(buf1, panelSelf.FlyGoldNode.transform, beginPos, endPos, playerPos, mbPos, name_img, 1.5)
                            elseif grades > 0 then
                                FishingAnimManager.PlayFlyGrades(buf1, panelSelf.FlyGoldNode.transform, beginPos, lj_endPos, playerPos, mbPos, name_img, 1.5)
                            end
                        end
                        Event.Brocast("model_dispose_skill_data", skill_data)
                    end)
                else
                    -- 幸运宝箱 死亡优化
                    if fish and fish.fish_cfg and fish.fish_cfg.id == 27 then
                        FishingAnimManager.PlayXYBXDeadQZ(panelSelf.FlyGoldNode.transform, beginPos, skill_data)
                    end
                    Event.Brocast("model_dispose_skill_data", skill_data)
                    if not is_bubojiaqian then
                        if score > 0 then
                            FishingAnimManager.PlayDeadFX(buf1, panelSelf.FlyGoldNode.transform, beginPos, endPos, playerPos, mbPos, name_img, delta_t)                        
                        elseif grades > 0 then
                            FishingAnimManager.PlayFlyGrades(buf1, panelSelf.FlyGoldNode.transform, beginPos, lj_endPos, playerPos, mbPos, name_img, delta_t)
                        end
                    end
                    FishManager.S2CFishDead(fish_id)
                end
            end
        end
    end
end

-- 激光
function C.on_model_fish_dead_laser(data)
    if data.fish_ids and next(data.fish_ids) then
        local bullet_cfg = FishingMatchModel.GetGunCfg(data.index, data.seat_num)
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
    local bullet_cfg = FishingMatchModel.GetGunCfg(data.index, data.seat_num)
    data.rate = bullet_cfg.gun_rate
    -- 鱼被打死了
    if data.fish_ids and next(data.fish_ids) then
        fish_dead(data)
    end
    BulletManager.S2CBulletCrash(data.id)
end

-- 全屏炸弹
function C.on_qp_bomb_dead(data)
    
end
-- 全屏炸弹
function C.on_qp_laser_dead(data)
    
end

