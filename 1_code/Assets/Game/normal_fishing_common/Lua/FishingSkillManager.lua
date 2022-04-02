-- 创建时间:2019-07-18
-- 捕鱼的技能管理

FishingSkillManager = {}
local C = FishingSkillManager

local this
local lister
local panelSelf
local cur_game_type
-- 特殊鱼死亡效果
local cache_fish_explode_dead = {}
-- 技能数据
local cache_skill_data_map = {}

-- 鱼死亡的附加属性
FishingSkillManager.FishDeadAppendType = {
    FreeBullet = 1, -- 免费子弹
    AddForce = 2, -- 超级火力
    DoubleTime = 3, -- 双倍时刻
    Boom = 4, -- 炸弹
    Lightning = 5, -- 闪电
    Red = 6, -- 福卡
    LockCard = 7, -- 锁定卡
    IceCard = 8, -- 冰冻卡
    Zongzi = 9, -- 临时活动:粽子
    ShellLottery = 10, -- 贝壳抽奖
    Gold = 11, -- 金币活动
    QP_bomb = 12, -- 全屏炸弹
    Quick_shoot = 13, -- 快速射击
    QP_min_bomb = 14, -- 次级炸弹
    QP_min_laser = 15, -- 次级闪电
    QP_laser = 16, -- 全屏闪电
    ZT_bullet = 17, -- 钻头子弹
    pierce_bullet = 18, -- 钢弹
    summon_fish = 19, -- 召唤鱼

    caibei = 21, -- 彩贝
    jbbf = 22, -- 金币爆发
    xsmfcjhl = 23, -- 限时免费超级火力子弹
    lhzp = 24, -- 连环转盘
    dcp = 25, -- 电磁炮
    ppc_cjzd = 26, -- 次级炸弹
    ppc_gjzd = 27, -- 超级炸弹
    fk6x1 = 29, -- 疯狂6选1
    szwg = 33, --骰子乌龟
    bzzy = 28,  --宝藏章鱼(原名:幸运转盘) 

    accelerate_card = 43, -- 快速射击
    wild_card = 44, -- 威力提升
    doubled_card = 45, -- 双倍奖励

    ppc_cjzd2 = 48, -- 次级炸弹
    ppc_gjzd2 = 49, -- 超级炸弹
    ppc_cjzd3 = 50, -- 次级炸弹
    ppc_gjzd3 = 51, -- 超级炸弹
    zcm_rate = 52, -- 招财猫rate
    fenghuang = 53, --凤凰

    DropTZTask = 100, -- 掉落 挑战任务
}
-- 
FishingSkillManager.FishDeadAppendMap = 
{
    [1] = {desc="免费子弹", icon="bygame_icon_danmf2", item_key = "obj_fish_free_bullet"},
    [2] = {desc="超级火力", icon="bygame_icon_cjhl", item_key = "obj_fish_power_bullet"},
    [3] = {desc="双倍时刻", icon="bygame_icon_sbsk", item_key = "obj_fish_crit_bullet"},
    [4] = {desc="炸弹", icon="bymatch_game_btn_xbz"},
    [5] = {desc="闪电", icon="bymatch_game_btn_xsd"},
    [6] = {desc="福卡", icon="com_award_icon_money"},
    [7] = {desc="锁定卡", icon="by_btn_sd", item_key = "prop_fish_lock"},
    [8] = {desc="冰冻卡", icon="by_btn_bd", item_key = "prop_fish_frozen"},
    [9] = {desc="临时活动", icon="ddz_game_ui_666"},
    [10] = {desc="贝壳抽奖", icon="bk_dh_1"},
    [11] = {desc="鲸币活动", icon="com_icon_gold"},
    [12] = {desc="全屏炸弹", icon="bymatch_game_btn_dbz", item_key = "prop_fish_super_bomb_1"},
    [13] = {desc="快速射击", icon="bygame_icon_dan_bs08"},
    [14] = {desc="次级炸弹", icon="bymatch_game_btn_xbz", item_key = "prop_fish_secondary_bomb_1"},
    [15] = {desc="次级闪电", icon="bymatch_game_btn_xsd"},
    [16] = {desc="全屏闪电", icon="bymatch_game_btn_dsd"},
    [17] = {desc="钻头子弹", icon="bytx_zt"},
    [18] = {desc="钢弹", icon="bygame_icon_ctgd", item_key = "obj_fish_pierce_bullet"},
    [19] = {desc="召唤鱼", icon="by_btn_zh", item_key = "obj_fish_summon_fish"},

    [21] = {desc="彩贝", icon="xycb_icon_cb1_normal_fishing_common"},
    [23] = {desc="限时免费超级火力子弹", icon="bygame_icon_cjhl"},
    [24] = {desc="连环转盘", icon="bygame_icon_cjhl"},
    [25] = {desc="电磁炮", icon="3dby_icon_jg"},
    [26] = {desc="次级炸弹", icon="bymatch_game_btn_xbz"},
    [27] = {desc="超级炸弹", icon="bymatch_game_btn_dbz"},

    [43] = {desc="快速射击", icon="ty_3dby_imgf_sm"},
    [44] = {desc="威力提升", icon="ty_3dby_imgf_sm"},
    [45] = {desc="双倍奖励", icon="ty_3dby_imgf_sm"},
}

function C.InitConfig()
    if cur_game_type == "by3d" then
        FishingSkillManager.FishDeadAppendMap[7] = {desc="锁定卡", icon="3dby_btn_sd", item_key = "prop_fish_lock"}
        FishingSkillManager.FishDeadAppendMap[8] = {desc="冰冻卡", icon="3dby_btn_bd", item_key = "prop_fish_frozen"}
        FishingSkillManager.FishDeadAppendMap[19] = {desc="召唤鱼", icon="3dby_btn_zh", item_key = "prop_fish_summon_fish"}
    end
end

function C.Init(_type)
    cur_game_type = _type or "by2d"
    C.InitConfig()
    cache_fish_explode_dead = {}
    cache_skill_data_map = {}
	C.MakeLister()
	C.AddMsgListener()
end
function C.SetPanelSelf(ps)
    panelSelf = ps
end
function C.MyExit()
	panelSelf = nil
	C.RemoveListener()
end

function C.AddMsgListener()
    for proto_name,func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

function C.MakeLister()
    lister = {}
    lister["model_receive_skill_data_msg"] = C.on_receive_skill_data_msg
    lister["model_dispose_skill_data"] = C.on_dispose_skill_data
    lister["model_use_skill_msg"] = C.on_use_skill_msg
    lister["model_fish_explode_dead"] = C.on_model_fish_explode_dead
end

function C.RemoveListener()
    for proto_name,func in pairs(lister) do
        Event.RemoveListener(proto_name, func)
    end
    lister = {}
end

-- 解析鱼死亡时带的技能数据
-- 
function C.getSkill(data, attrI, fish_id, seat_num)
    local attr = data[attrI]
    attrI = attrI + 1
    if not attr then
        dump(data, "<color=red>EEE data  attr nil </color>")
        return attrI,nil
    end
    if attr == 0 then
        return attrI,nil
    else
        local skill = {}
        skill.fish_id = fish_id
        skill.type = attr
        skill.seat_num = seat_num
        skill.msg_type = "activity"
        if data[attrI] then
            skill.status = data[attrI]
            attrI = attrI + 1
        else
            -- 必须要的值
            skill.status = 0
            dump(data, "<color=red>EEE data  status nil </color>")
            dump(skill)
        end
        if attr == FishingSkillManager.FishDeadAppendType.Boom or
            attr == FishingSkillManager.FishDeadAppendType.ppc_cjzd or
            attr == FishingSkillManager.FishDeadAppendType.ppc_cjzd2 or
            attr == FishingSkillManager.FishDeadAppendType.ppc_cjzd3 or
            attr == FishingSkillManager.FishDeadAppendType.ppc_gjzd or
            attr == FishingSkillManager.FishDeadAppendType.ppc_gjzd2 or
            attr == FishingSkillManager.FishDeadAppendType.ppc_gjzd3 or
           attr == FishingSkillManager.FishDeadAppendType.QP_bomb or
           attr == FishingSkillManager.FishDeadAppendType.QP_min_bomb then
            if skill.status == 0 then
                skill.id = data[attrI]
                attrI = attrI + 1
            else
                skill.num = data[attrI]
                attrI = attrI + 1
            end
        elseif attr == FishingSkillManager.FishDeadAppendType.LockCard or
               attr == FishingSkillManager.FishDeadAppendType.IceCard or 
               attr == FishingSkillManager.FishDeadAppendType.accelerate_card or 
               attr == FishingSkillManager.FishDeadAppendType.wild_card or 
               attr == FishingSkillManager.FishDeadAppendType.doubled_card or 
               attr == FishingSkillManager.FishDeadAppendType.FreeBullet or
               attr == FishingSkillManager.FishDeadAppendType.AddForce or
               attr == FishingSkillManager.FishDeadAppendType.pierce_bullet or
               attr == FishingSkillManager.FishDeadAppendType.DoubleTime or
               attr == FishingSkillManager.FishDeadAppendType.summon_fish then
            if skill.status == 0 then
                -- 不需要处理
                dump(skill, "<color=red>死亡的鱼 引发道具使用</color>")
            else
                skill.num = data[attrI]
                attrI = attrI + 1
            end
        elseif attr == FishingSkillManager.FishDeadAppendType.Lightning or
               attr == FishingSkillManager.FishDeadAppendType.QP_min_laser or
               attr == FishingSkillManager.FishDeadAppendType.QP_laser then
            if skill.status == 0 then
                skill.id = data[attrI]
                attrI = attrI + 1
                skill.max_rate = data[attrI]
                attrI = attrI + 1
            else
                skill.num = data[attrI]
                attrI = attrI + 1                
            end
        elseif attr == FishingSkillManager.FishDeadAppendType.DropTZTask then
            dump(data, "<color=red>EEE 挑战任务 </color>")
        elseif attr == FishingSkillManager.FishDeadAppendType.ShellLottery then
            dump(data, "<color=red>EEE 贝壳活动 </color>")
        elseif attr == FishingSkillManager.FishDeadAppendType.Zongzi or
               attr == FishingSkillManager.FishDeadAppendType.Red then
            if skill.status == 0 then
                dump(skill, "<color=red>EEE skill </color>")
            else
                skill.num = data[attrI]
                attrI = attrI + 1
                skill.act_type = data[attrI]
                attrI = attrI + 1
            end
        elseif attr == FishingSkillManager.FishDeadAppendType.ZT_bullet then
            dump(data, "<color=red>EEE 钻头子弹 </color>")
        elseif attr == FishingSkillManager.FishDeadAppendType.caibei then
            dump(data, "<color=red>EEE 彩贝 </color>")
            skill.num = data[attrI]
            attrI = attrI + 1
            skill.list = {}
            for ii=1, skill.num do
                skill.list[#skill.list + 1] = data[attrI]
                attrI = attrI + 1
            end
            dump(skill)
        elseif attr == FishingSkillManager.FishDeadAppendType.lhzp then
            dump(data, "<color=red>EEE 幸运转盘抽奖 </color>")
        
            skill.bs_list = {}
            for ii=1, 3 do
                skill.bs_list[#skill.bs_list + 1] = data[attrI]
                attrI = attrI + 1
            end
            if fish then
                skill.fish_pos = FishingModel.Get2DToUIPoint( fish:GetPos() )
            else
                skill.fish_pos = Vector3.New(-300, 300, 0)
            end
        elseif attr == FishingSkillManager.FishDeadAppendType.fk6x1 then
            dump(data, "<color=red>EEE Fish_pos </color>")
            if fish then
                skill.fish_pos = FishingModel.Get2DToUIPoint( fish:GetPos() )
            else
                skill.fish_pos = Vector3.New(-300, 300, 0)
            end

        elseif attr == FishingSkillManager.FishDeadAppendType.szwg then
            dump(data, "<color=red>EEE 骰子乌龟技能 </color>")
            skill.score = data[attrI]
            attrI = attrI + 1
            if fish then
                skill.fish_pos = FishingModel.Get2DToUIPoint( fish:GetPos() )
            else
                skill.fish_pos = Vector3.New(-300, 300, 0)
            end
        elseif attr == FishingSkillManager.FishDeadAppendType.bzzy then
            dump(data, "<color=red>EEE 宝藏章鱼:幸运转盘技能 </color>")
            skill.bullet_stake = data[attrI]
            attrI = attrI + 1
            if fish then
                skill.fish_pos = FishingModel.Get2DToUIPoint( fish:GetPos() )
            else
                skill.fish_pos = Vector3.New(-300, 300, 0)
            end
        elseif attr == FishingSkillManager.FishDeadAppendType.zcm_rate then
            dump(data, "<color=white>EEE 招财猫  </color>")
            skill.gun_rate = data[attrI]
            attrI = attrI + 1
        elseif attr == FishingSkillManager.FishDeadAppendType.fenghuang then
            dump(data, "<color=red>EEE 凤凰技能 </color>")
            local num = data[attrI]
            -- attrI = attrI + 1
            skill.time = num 
            -- skill.score_list = {}
            -- for ii=1, num do
            --     skill.score_list[#skill.score_list + 1] = data[attrI]
            --     attrI = attrI + 1
            -- end
            if fish then
                skill.fish_pos = FishingModel.Get2DToUIPoint( fish:GetPos() )
            else
                skill.fish_pos = Vector3.New(-300, 300, 0)
            end
        else
            dump(attr, "<color=red>EEE attr </color>")
            dump(data)
        end
        return attrI,skill
    end
end
-- 技能是否带前摇
-- 鱼死亡时要震一下
function C.IsSkillAndShake(data)
    if data.type == FishingSkillManager.FishDeadAppendType.Boom or
    data.type == FishingSkillManager.FishDeadAppendType.FreeBullet or
    data.type == FishingSkillManager.FishDeadAppendType.AddForce or
    data.type == FishingSkillManager.FishDeadAppendType.DoubleTime or
    data.type == FishingSkillManager.FishDeadAppendType.LockCard or
    data.type == FishingSkillManager.FishDeadAppendType.IceCard or
    data.type == FishingSkillManager.FishDeadAppendType.accelerate_card or
    data.type == FishingSkillManager.FishDeadAppendType.wild_card or
    data.type == FishingSkillManager.FishDeadAppendType.doubled_card or
    data.type == FishingSkillManager.FishDeadAppendType.ShellLottery or
    data.type == FishingSkillManager.FishDeadAppendType.DropTZTask or
    data.type == FishingSkillManager.FishDeadAppendType.Lightning or
    data.type == FishingSkillManager.FishDeadAppendType.QP_bomb or
    data.type == FishingSkillManager.FishDeadAppendType.ppc_cjzd or
    data.type == FishingSkillManager.FishDeadAppendType.ppc_gjzd or
    data.type == FishingSkillManager.FishDeadAppendType.ppc_cjzd2 or
    data.type == FishingSkillManager.FishDeadAppendType.ppc_gjzd2 or
    data.type == FishingSkillManager.FishDeadAppendType.ppc_cjzd3 or
    data.type == FishingSkillManager.FishDeadAppendType.ppc_gjzd3 or
    data.type == FishingSkillManager.FishDeadAppendType.ZT_bullet or
    data.type == FishingSkillManager.FishDeadAppendType.pierce_bullet or
    data.type == FishingSkillManager.FishDeadAppendType.Red or
    data.type == FishingSkillManager.FishDeadAppendType.caibei or
    data.type == FishingSkillManager.FishDeadAppendType.xyzp or 
    data.type == FishingSkillManager.FishDeadAppendType.fk6x1 or
    data.type == FishingSkillManager.FishDeadAppendType.szwg or 
    data.type == FishingSkillManager.FishDeadAppendType.bzzy or 
    data.type == FishingSkillManager.FishDeadAppendType.fenghuang or 
    data.type == FishingSkillManager.FishDeadAppendType.summon_fish
    then
    	return true
    end
    dump(data, "<color=red>IsSkillAndShake</color>")
end
-- 鱼死亡时要变红变大
function C.IsSkillAndBD(data)
    if data.type == FishingSkillManager.FishDeadAppendType.Boom and data.fish_id then
        local fish = FishManager.GetFishByID(data.fish_id)
        if fish and (fish.fish_cfg.id == 18 or fish.fish_cfg.id == 35) then
            return true
        end
    end
end
-- ********************************
-- 主动使用
-- 使用技能的前奏表现在这里做，没有就直接使用(发送给服务器)
-- ********************************
function C.on_use_skill_msg(data)
    if data.msg_type == "lock" or data.msg_type == "prop_fish_lock" then
        dump(data, "<color=red><size=20>EEEEEEEEEEEE</size></color>")
        print(debug.traceback())
        -- local b = FishingModel.UseSkill("prop_fish_lock")
        -- if data.call then
        --     data.call(b)
        -- end
    elseif data.msg_type == "frozen" or data.msg_type == "prop_fish_frozen" then
        dump(data, "<color=red><size=20>EEEEEEEEEEEE</size></color>")
        print(debug.traceback())
        -- local b = FishingModel.UseSkill("prop_fish_frozen")
        -- if data.call then
        --     data.call(b)
        -- end
    elseif data.msg_type == "gun_skill" then
        C.UseGunSkill(data)
    elseif data.msg_type == "laser" then
        C.LaserShoot(data)
    elseif data.msg_type == "laser_bullet" then
        C.DCPShoot(data)
    elseif data.msg_type == "buy_activity" then
        local b = FishingModel.UseSkill(data.msg_type, data.id)
        if data.call then
            data.call(b)
        end
    elseif data.msg_type == "tool_obj" then
        FishingModel.UseObjProp(data.item_key, data.call)
        if data.call then
            data.call()
        end
    elseif data.msg_type == "tool" then
        FishingModel.UseItem(data.item_key, data.call)
        if data.call then
            data.call()
        end
    else
        dump(data, "<color=red>使用技能失败</color>")
    end
end
function C.UseGunSkill(data)
    local gun_id = FishingModel.GetGunSkinID(data.seat_num)
    local cfg = FishingModel.Config.gun_skill_map[gun_id]
    
    dump(data)
    dump(cfg, "<color=red><size=20>11111111111111 cfg </size></color>")

    if cfg then
        if cfg.id == 1 then
            C.LaserShoot(data)
        else
            panelSelf.oper_prefab:SetLaserHide()
            local userdata = FishingModel.GetSeatnoToUser(data.seat_num)
            local x = math.floor(data.vec.x * 100)
            local y = math.floor(data.vec.y * 100)
            Network.SendRequest("nor_fishing_3d_nor_gun_skill", {seat_num=data.seat_num, index=userdata.index , gun_id=gun_id , data={x,y}})

            FishingModel.SetPlayerLaserState(data.seat_num, "nor")
            Event.Brocast("ui_laser_state_change", data.seat_num)
            dump(gun_id, "<color=red><size=20>11111111111111 gun_id </size></color>")
            if gun_id == 6 then
                FishingAnimManager.PlayShowAndHideFX(panelSelf.FXNode, "Fishing3D_slzg_ui", Vector3.zero, 1.74)
            elseif gun_id == 7 then
                FishingAnimManager.PlayShowAndHideFX(panelSelf.FXNode, "Fishing3D_sls_ui", Vector3.zero, 1.74)
            end
        end
    else
        print("<color=red>Error  UseGunSkill </color>")
        dump(gun_id)
        dump(FishingModel.Config.gun_skill_map)
    end
end
-- 使用激光
function C.LaserShoot(data)
    if data.vec then
        data.vec.z = 0
    end

    local laser = FishingModel.GetPlayerLaserState(data.seat_num)
    if laser and laser == "inuse" then
        return
    end
    if cur_game_type == "by3d" then
        ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_jiguang2.audio_name)
    else
        ExtendSoundManager.PlaySound(audio_config.by.bgm_by_jiguang2.audio_name)
    end

    local userdata = FishingModel.GetSeatnoToUser(data.seat_num)
    if not userdata.base then
        return
    end
    local uipos = FishingModel.GetSeatnoToPos(data.seat_num)
    local gunP = panelSelf.PlayerClass[uipos]:GetLaserFXPos()
    local p =(data.vec - gunP).normalized
    local r = Vec2DAngle({x=p.x, y=p.y})

    FishingModel.SetPlayerLaserState(data.seat_num, "inuse")

    panelSelf.PlayerClass[uipos]:RotateTo(r)
    FishingAnimManager.PlayLaser(panelSelf.FXNode, data.seat_num, FishingModel.Get2DToUIPoint(gunP), r-90)
    local boom_fishs = FishManager.CalcLaserFishHarm(gunP, {x=p.x, y=p.y}, data.seat_num)
    FishManager.PlayFishSuffer(boom_fishs)

    FishingModel.SendSkill({seat_num=data.seat_num, fish_ids=boom_fishs, index=userdata.index , msg_type="laser"})

    local my_seat_num = FishingModel.GetPlayerSeat()
    if data.seat_num == my_seat_num then
        if cur_game_type == "by3d" then
            panelSelf.oper_prefab:SetLaserHide()
        else
            panelSelf.nor_skill_prefab:SetLaserHide()
        end
    end
end
-- 使用电磁炮
function C.DCPShoot(data)
    local userdata = FishingModel.GetSeatnoToUser(data.seatno)
    if not userdata.base then
        return
    end
    ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_diancipao2.audio_name)
    local uipos = FishingModel.GetSeatnoToPos(data.seatno)
    local gunP = panelSelf.PlayerClass[uipos]:GetLaserFXPos()
    local r = Vec2DAngle({x=data.vec.x, y=data.vec.y})
    panelSelf.PlayerClass[uipos]:RotateTo(r)
    FishingAnimManager.PlayBY3D_FSDCP(panelSelf.FXNode, data.seatno, FishingModel.Get2DToUIPoint(gunP), r-90)
    local boom_fishs = FishManager.CalcLaserFishHarm(gunP, {x=data.vec.x, y=data.vec.y}, data.seatno)
    FishManager.PlayFishSuffer(boom_fishs)
    FishingModel.SendSkill({seat_num=data.seatno, fish_ids=boom_fishs, index=userdata.index , msg_type=data.msg_type})
end
-- 使用核弹
function C.MissileShoot(data)
    local laser = FishingModel.GetPlayerMissileState(data.seat_num)
    if laser and laser == "inuse" then
        return
    end
    local userdata = FishingModel.GetSeatnoToUser(data.seat_num)
    if not userdata.base then
        return
    end
    local uipos = FishingModel.GetSeatnoToPos(data.seat_num)
    local gunP = panelSelf.PlayerClass[uipos]:GetLaserFXPos()
    local p =(data.vec - gunP).normalized
    local r = Vec2DAngle({x=p.x, y=p.y})

    FishingModel.SetPlayerMissileState(data.seat_num, "inuse")

    panelSelf.PlayerClass[uipos]:RotateTo(r)

    FishingAnimManager.PlayMissile(panelSelf.FXNode, data.seat_num, FishingModel.Get2DToUIPoint(gunP), {x=data.vec.x, y=data.vec.y})
    local boom_fishs = FishManager.CalcMissileFishHarm(data.vec, 4, data.seat_num)
    FishManager.PlayFishSuffer(boom_fishs)

    FishingModel.SendSkill({seat_num=data.seat_num, fish_ids=boom_fishs , msg_type="missile"})
    panelSelf.nor_skill_prefab:SetMissileHide()
end
-- ********************************
-- 主动使用
-- ********************************


function C.GetSkillAnimPos(data)
	local beginPos
	if data.fish_id then
		local fish = FishManager.GetFishByID(data.fish_id)
		if fish then
			beginPos = FishingModel.Get2DToUIPoint(fish:GetPos())
		else
			beginPos = Vector3.zero
		end
    elseif data.bullet_id then
        local fish = BulletManager.GetIDToBullet(data.bullet_id)
        if fish then
            beginPos = FishingModel.Get2DToUIPoint(fish.bulletSpr.transform.position)
        else
            beginPos = Vector3.zero
        end
	else
        beginPos = Vector3.zero
        if data.rates then
            if #data.rates ~= 2 then
                dump(data, "<color=red>EEE 技能定位参数不全</color>")
            else
                local ww = 140
                local ii = data.rates[1]
                local mm = data.rates[2]
                local x  = ww * ( (1 - mm) / 2 + ii - 1 )
                beginPos = Vector3.New(x, 0, 0)
            end
        end
	end
	return beginPos
end

function C.GetSkillByID(id)
    if cache_skill_data_map[id] then
        return cache_skill_data_map[id]
    end
    print(id)
    dump(cache_skill_data_map, "<color=red>cache_skill_data_map</color>")
end
function C.RemoveSkillByID(id)
    cache_skill_data_map[id] = nil
end

-- 接受到技能数据
function C.on_receive_skill_data_msg(data)
    local list = {}
	for k,v in ipairs(data) do
        if v.msg_type == "activity" and v.rates then
            list[#list + 1] = v
        else
            C.on_dispose_skill_data(v)
        end
	end
    if #list > 0 then
        for k,v in ipairs(list) do
            v.rates[1] = k
            v.rates[2] = #list
            C.on_dispose_skill_data(v)
        end
    end
end
-- 处理数据
function C.on_dispose_skill_data(data)

    if data.msg_type ~= "laser" and not data.status then
        if data.seat_num == FishingModel.GetPlayerSeat() then
            if FishingModel.TimeSkillMap[data.msg_type] then
                local userdata = FishingModel.GetPlayerData()
                if userdata then
                    userdata[data.msg_type .. "_state"] = "nor"
                end
            else
                dump(data, "<color=red><size=20>查看是否正常</size></color>")
            end
        end
        return
    end
    
    local m_data = FishingModel.data
    local userdata = FishingModel.GetSeatnoToUser(m_data.seat_num)
    if data.msg_type == "laser" then
        if data.status == 0 then
            C.UseLaser(data)
        else
            C.AddLaser(data)
        end
    elseif FishingModel.TimeSkillMap[data.msg_type] then
        if data.status == 0 then
            C.UseTimeSkill(data, data.msg_type)
        else
            C.AddTimeSkill(data, data.msg_type)
        end
    elseif data.msg_type == "missile" then
        if data.status == 0 then
            C.UseMissile(data)
        else
            print("<color=red>询问策划处理方式</color>")
        end
    elseif data.msg_type == "score" then
        if data.status == 0 then
            print("<color=red>询问策划处理方式</color>")
        else
            C.AddScore(data)
        end
    elseif data.msg_type == "grades" then
        if data.status == 0 then
            print("<color=red>询问策划处理方式</color>")
        else
            C.AddGrades(data)
        end
    elseif data.msg_type == "quick_shoot" then
        if data.status == 0 then
            C.UseQuickShoot(data)
        else
            print("<color=red>询问策划处理方式</color>")
        end
    elseif data.msg_type == "laser_bullet" then
        if data.status == 0 then
            C.UseDCP(data)
        else
            data.type = FishingSkillManager.FishDeadAppendType.dct
            C.AddSkill(data)
        end
    elseif data.msg_type == "buy_activity" then
        dump(data, "<color=red>购买技能 buy_activity</color>")
        Event.Brocast("model_buy_activity_msg", data)
    elseif data.msg_type == "activity" then
        dump(data, "<color=red>on_dispose_skill_data</color>")
        if data.type == FishingSkillManager.FishDeadAppendType.Boom then
            dump(data, "<color=white>BBBBBBBBBBBBBBBBBBBBBBBBB</color>")
            if data.status == 0 then
                C.UseBomb(data)
            else
                C.AddSkill(data)
            end
        elseif data.type == FishingSkillManager.FishDeadAppendType.ZT_bullet then
            if data.status == 0 then
                print("<color=red>动画在活动那边处理</color>")
            else
                C.AddSkill(data)
            end
        elseif data.type == FishingSkillManager.FishDeadAppendType.Lightning then
            if data.status == 0 then
                C.UseLightning(data)
            else
                C.AddSkill(data)
            end
        elseif data.type == FishingSkillManager.FishDeadAppendType.FreeBullet then
            if data.status == 0 then
                print("<color=red>询问策划处理方式</color>")
            else
                C.AddSkill(data)
            end
        elseif data.type == FishingSkillManager.FishDeadAppendType.AddForce then
            if data.status == 0 then
                print("<color=red>询问策划处理方式</color>")
            else
                C.AddSkill(data)
            end
        elseif data.type == FishingSkillManager.FishDeadAppendType.DoubleTime then
            if data.status == 0 then
                print("<color=red>询问策划处理方式</color>")
            else
                C.AddSkill(data)
            end
        elseif data.type == FishingSkillManager.FishDeadAppendType.pierce_bullet then
            if data.status == 0 then
                print("<color=red>询问策划处理方式</color>")
            else
                C.AddSkill(data)
            end
        elseif data.type == FishingSkillManager.FishDeadAppendType.LockCard then
            if data.status == 0 then
                C.UseTimeSkill(data, "lock")
            else
                C.AddTimeSkill(data, "lock")
            end
        elseif data.type == FishingSkillManager.FishDeadAppendType.IceCard then
            if data.status == 0 then
                C.UseTimeSkill(data, "frozen")
            else
                C.AddTimeSkill(data, "frozen")
            end
        elseif data.type == FishingSkillManager.FishDeadAppendType.accelerate_card then
            if data.status == 0 then
                C.UseTimeSkill(data, "accelerate")
            else
                C.AddTimeSkill(data, "accelerate")
            end
        elseif data.type == FishingSkillManager.FishDeadAppendType.wild_card then
            if data.status == 0 then
                C.UseTimeSkill(data, "wild")
            else
                C.AddTimeSkill(data, "wild")
            end
        elseif data.type == FishingSkillManager.FishDeadAppendType.doubled_card then
            if data.status == 0 then
                C.UseTimeSkill(data, "doubled")
            else
                C.AddTimeSkill(data, "doubled")
            end
        elseif data.type == FishingSkillManager.FishDeadAppendType.fk6x1 then
            if data.status == 0 then
                C.UseFK6X1(data)
            else
                dump(data, "<color=red>询问策划处理方式</color>")
            end
        elseif data.type == FishingSkillManager.FishDeadAppendType.szwg then
            if data.status == 0 then
                C.UseSZWG(data)
            else
                dump(data, "<color=red>询问策划处理方式</color>")
            end
        elseif data.type == FishingSkillManager.FishDeadAppendType.bzzy then
            if data.status == 0 then
                C.UseBZZY(data)
            else
                dump(data, "<color=red>询问策划处理方式</color>")
            end
        elseif data.type == FishingSkillManager.FishDeadAppendType.xyzp then
            if data.status == 0 then
                C.UseXYZP(data)
            else
                dump(data, "<color=red>询问策划处理方式</color>")
            end
        elseif data.type == FishingSkillManager.FishDeadAppendType.summon_fish then
            if data.status == 0 then
                print("<color=red>询问策划处理方式</color>")
            else
                C.AddZH(data)
            end
        elseif data.type == FishingSkillManager.FishDeadAppendType.Zongzi then
            if data.status == 0 then
                print("<color=red>询问策划处理方式</color>")
            else
                C.AddActTool(data)
            end
        elseif data.type == FishingSkillManager.FishDeadAppendType.ShellLottery then
            if data.status == 0 then
                local beginPos = C.GetSkillAnimPos(data)
                FishingAnimManager.PlayFishHitTS(panelSelf.FXNode, beginPos)
                Event.Brocast("ui_begin_anim", {pos=beginPos, seat_num=data.seat_num})
            else

            end
        elseif data.type == FishingSkillManager.FishDeadAppendType.DropTZTask then
            C.UseTZTask(data)
        elseif data.type == FishingSkillManager.FishDeadAppendType.QP_bomb
            or data.type == FishingSkillManager.FishDeadAppendType.ppc_gjzd
            or data.type == FishingSkillManager.FishDeadAppendType.ppc_gjzd2
            or data.type == FishingSkillManager.FishDeadAppendType.ppc_gjzd3 then
            if data.status == 0 then
                C.UseQPBomb(data)
            else
                C.AddSkill(data)
            end
        elseif data.type == FishingSkillManager.FishDeadAppendType.QP_laser then
            if data.status == 0 then
                C.UseQPLaser(data)
            else
                C.AddSkill(data)
            end
        elseif data.type == FishingSkillManager.FishDeadAppendType.QP_min_bomb
            or data.type == FishingSkillManager.FishDeadAppendType.ppc_cjzd
            or data.type == FishingSkillManager.FishDeadAppendType.ppc_cjzd2
            or data.type == FishingSkillManager.FishDeadAppendType.ppc_cjzd3 then
            if data.status == 0 then
                C.UseQPMinBomb(data)
            else
                C.AddSkill(data)
            end
        elseif data.type == FishingSkillManager.FishDeadAppendType.QP_min_laser then
            if data.status == 0 then
                C.UseQPMinLaser(data)
            else
                C.AddSkill(data)
            end
        elseif data.type == FishingSkillManager.FishDeadAppendType.lhzp then
            if data.status == 0 then
                C.UseZPXJ(data)
            else
                dump(data, "<color=red>询问策划处理方式</color>")
            end
        elseif data.type == FishingSkillManager.FishDeadAppendType.fenghuang then
            if data.status == 0 then
                C.UseFengHuang(data)
            else
                dump(data, "<color=red>询问策划处理方式</color>")
            end
        elseif data.type == FishingSkillManager.FishDeadAppendType.dcp then
            if data.status == 0 then
                C.UseDCP(data)
            else
                C.AddSkill(data)
            end
        else
            dump(data, "<color=red>技能处理 数据异常 AAA</color>")
        end
    else
        dump(data, "<color=red>技能处理 数据异常 BBB</color>")
    end
end

-- 处理特殊死亡的鱼
function C.on_model_fish_explode_dead(data)
    dump(data, "<color=yellow>接收 一条特殊鱼死亡</color>")
    local local_data = cache_fish_explode_dead[data.id]
    if local_data then
        -- 爆炸鱼的表现
        if local_data.type == FishingSkillManager.FishDeadAppendType.Boom then
            local all_fish_list = FishManager.CalcBoomAllFish(local_data.fish_pos)
            local fish_dead_map = {}
            if data.fish_ids and next(data.fish_ids) then
                for k,v in ipairs(data.fish_ids) do
                    fish_dead_map[v] = 1
                    local fish = FishManager.GetFishByID(v)
                    if fish then
                        fish:SetFeignDead(true)
                    end
                end
            end
            for k,v in ipairs(all_fish_list) do
                if not fish_dead_map[v] then
                    local fish = FishManager.GetFishByID(v)
                    if fish then
                        fish:BoomHit(local_data.fish_pos)
                    end
                end
            end
        end
        if not data.fish_ids or not next(data.fish_ids) then
            if local_data.type == FishingSkillManager.FishDeadAppendType.ppc_cjzd or
                local_data.type == FishingSkillManager.FishDeadAppendType.ppc_cjzd2 or
                local_data.type == FishingSkillManager.FishDeadAppendType.ppc_cjzd3 or
                local_data.type == FishingSkillManager.FishDeadAppendType.ppc_gjzd or
                local_data.type == FishingSkillManager.FishDeadAppendType.ppc_gjzd2 or
                local_data.type == FishingSkillManager.FishDeadAppendType.ppc_gjzd3 then
                    FishingAnimManager.PlayYZD_Null(data, panelSelf.FXNode)
            end

            cache_fish_explode_dead[data.id] = nil
            return
        end
        data.seat_num = local_data.seat_num
        Event.Brocast("model_fish_dead_msg", data, local_data.type)

        -- 汇总这几个技能的总金币值
        if local_data.type == FishingSkillManager.FishDeadAppendType.ppc_cjzd or
            local_data.type == FishingSkillManager.FishDeadAppendType.ppc_cjzd2 or
            local_data.type == FishingSkillManager.FishDeadAppendType.ppc_cjzd3 or
            local_data.type == FishingSkillManager.FishDeadAppendType.ppc_gjzd or
            local_data.type == FishingSkillManager.FishDeadAppendType.ppc_gjzd2 or
            local_data.type == FishingSkillManager.FishDeadAppendType.ppc_gjzd3 or
            local_data.type == FishingSkillManager.FishDeadAppendType.QP_bomb or
            local_data.type == FishingSkillManager.FishDeadAppendType.QP_min_bomb or
            local_data.type == FishingSkillManager.FishDeadAppendType.QP_min_laser or
            local_data.type == FishingSkillManager.FishDeadAppendType.QP_laser or
            (local_data.type == FishingSkillManager.FishDeadAppendType.Boom and cur_game_type == "by3d") then
            local score = 0
            local grades = 0
            if MainModel.myLocation == "game_FishingMatch" then
                -- 副炮只加累计赢金没有积分
                if data.seat_num == 1 then
                    for k,v in ipairs(data.moneys) do
                        score = score + v
                    end
                end

                if data.grades then
                    for k,v in ipairs(data.grades) do
                        grades = grades + v
                    end
                end
            else
                for k,v in ipairs(data.moneys) do
                    score = score + v
                end
                if data.grades then
                    for k,v in ipairs(data.grades) do
                        grades = grades + v
                    end
                end                
            end

            local endPos = panelSelf.PlayerClass[data.seat_num]:GetPlayerFXPos()
            local panel = panelSelf.FXNode
            if IsEquals(panelSelf.FXNode_GJ) then
                panel = panelSelf.FXNode_GJ
            end
            local_data.score = score
            local_data.moneys = data.moneys
            local_data.fish_ids = data.fish_ids
            dump(local_data, "<color=white>FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF</color>")
            if local_data.parm and local_data.parm == "fenghuang" then
                Event.Brocast("skill_fish_explode_dead_msg", local_data)
            else
                if score > 0 then
                    FishingAnimManager.PlaySkillAllGold(panel, data.seat_num, Vector3.zero, endPos, score, grades, nil, 1)
                else
                    FishingAnimManager.PlaySkillAllGold(panel, data.seat_num, Vector3.zero, endPos, score, grades, "grades", 1)
                end
            end
        end
        if local_data.type == FishingSkillManager.FishDeadAppendType.Lightning then
            local pos_list = {}
            if local_data.fish_id then
                pos_list[#pos_list + 1] = FishingModel.Get2DToUIPoint(local_data.fish_pos)
            end
            for k,v in ipairs(data.fish_ids) do
                local position = Vector3.zero
                local fish = FishManager.GetFishByID(v)
                if fish then
                    position = fish:GetPos()
                    position = FishingModel.Get2DToUIPoint(position)    
                end

                pos_list[#pos_list + 1] = position
            end

            FishingAnimManager.PlayLinesFX(panelSelf.FXNode, pos_list, 0.1, 1.5)
        elseif local_data.type == FishingSkillManager.FishDeadAppendType.QP_laser or
               local_data.type == FishingSkillManager.FishDeadAppendType.QP_min_laser then
            local pos_list = {}
            for k,v in ipairs(data.fish_ids) do
                local position = Vector3.zero
                local fish = FishManager.GetFishByID(v)
                if fish then
                    position = fish:GetPos()
                    position = FishingModel.Get2DToUIPoint(position)    
                end

                pos_list[#pos_list + 1] = position
            end
            local beginPos = Vector3.zero
            if local_data.type == FishingSkillManager.FishDeadAppendType.QP_laser then
                FishingAnimManager.PlayMaxLinesFX_FS(panelSelf.FXNode, Vector3.zero, pos_list, 0.1, 1.5, "by_sd_Line", "by_sd_Point")
            else
                FishingAnimManager.PlayMinLinesFX_FS(panelSelf.FXNode, Vector3.zero, pos_list, 0.1, 1.5, "by_sd_Line", "by_sd_Point")
            end
        end
        cache_fish_explode_dead[data.id] = nil
    end
end

--- 使用后，得到数据，后续处理
-- 使用时间技能
function C.UseTimeSkill(data, skill_type)
    local cfg = FishingModel.TimeSkillMap[skill_type]
    if not cfg then
        print("<color=red>UseTimeSkill EEEE </color>")
        dump(data)
        dump(skill_type)
        return
    end
    local m_data = FishingModel.data
    local userdata = FishingModel.GetSeatnoToUser(m_data.seat_num)
    if data.time then
        if data.status and data.seat_num == m_data.seat_num then
            if userdata["prop_fish_" .. skill_type] > 0 then
                userdata["prop_fish_" .. skill_type] = userdata["prop_fish_" .. skill_type] - 1
            elseif userdata["prop_fish_" .. skill_type] == 0 then
                --使用金币使用的技能
                userdata.base.score = userdata.base.score - FishingModel.GetSkillMoney(cfg.tool_type)
                Event.Brocast("model_refresh_money")
            end
        end
        m_data.players_info[data.seat_num][skill_type .. "_cd"] = data.time
        m_data.players_info[data.seat_num][skill_type .. "_max_cd"] = data.time
        m_data.players_info[data.seat_num][skill_type .. "_state"] = "inuse"

        if skill_type == "frozen" then
            m_data.scene_frozen_state = "inuse"
            m_data.use_frozen_seat_num = data.seat_num
            m_data.scene_frozen_cd = data.time
        end
        if skill_type == "lock" then
            m_data.players_info[data.seat_num].is_first_lock = true-- 首次锁定标志，播放动画用
        end

        Event.Brocast("model_time_skill_change_msg", data.seat_num, skill_type, false, data.time)
    else
        m_data.players_info[data.seat_num][skill_type .. "_state"] = "nor"

        Event.Brocast("model_time_skill_change_msg", data.seat_num, skill_type, true)
    end
end

-- 使用电磁炮
function C.UseDCP(data)
    if data.fish_ids and next(data.fish_ids) then
        Event.Brocast("model_fish_dead_laser", data)
    end
end
-- 使用激光
function C.UseLaser(data)
    if not data.time then
        return
    end

    local m_data = FishingModel.data
    local userdata = FishingModel.GetSeatnoToUser(m_data.seat_num)
    m_data.players_info[data.seat_num].laser_rate = data.time or 0
    Event.Brocast("model_fish_laser_rate_change", data.seat_num)
    if data.fish_ids and next(data.fish_ids) then
        Event.Brocast("model_fish_dead_laser", data)
    end
end
-- 使用核弹
function C.UseMissile(data)
    local m_data = FishingModel.data
    local userdata = FishingModel.GetSeatnoToUser(m_data.seat_num)
    m_data.players_info[data.seat_num].missile_index = 0
    m_data.players_info[data.seat_num].missile_list = {0, 0, 0, 0}
    Event.Brocast("model_fish_missile_rate_change", data.seat_num)
    if data.fish_ids and next(data.fish_ids) then
        Event.Brocast("model_fish_dead_missile", data)
    end
end
-- 使用(鱼)的炸弹
function C.UseBomb(data)
    local fish = FishManager.GetFishByID(data.fish_id)

    local beginPos = C.GetSkillAnimPos(data)
    local key = data.id
    local pos = FishingModel.GetUITo2DPoint(beginPos)
    local boom_fishs

    if cur_game_type == "by3d" then
        if fish and (fish.fish_cfg.id == 18 or fish.fish_cfg.id == 35) then
            if fish.fish_cfg.id == 18 then
                boom_fishs = FishManager.CalcBoomFishHarm(data.fish_id, data.seat_num, pos, 4.4)
            else
                boom_fishs = FishManager.CalcBoomFishHarm(data.fish_id, data.seat_num, pos, 6.6)
            end
            FishingAnimManager.PlayBY3D_ZDFishDead(panelSelf.FXNode, beginPos, fish.fish_cfg.id)
        else
            boom_fishs = FishManager.CalcBoomFishHarm(data.fish_id, data.seat_num, pos)
            if data.parm == "zt" then
                FishingAnimManager.PlayBY3D_ZTBomb(panelSelf.FXNode, beginPos)
            else
                FishingAnimManager.PlayFishBoom(panelSelf.FXNode, beginPos)
            end
        end
    else
        if data.parm == "fenghuang" then
            boom_fishs = FishManager.CalcBoomFishHarm(data.fish_id, data.seat_num, pos, 8)
        else
            boom_fishs = FishManager.CalcBoomFishHarm(data.fish_id, data.seat_num, pos)
            FishingAnimManager.PlayFishBoom(panelSelf.FXNode, beginPos)
        end
    end

    local sd = {}
    sd.id = key
    sd.fish_id = data.fish_id
    sd.fish_ids = boom_fishs
    sd.type = data.type
    sd.fish_pos = FishingModel.GetUITo2DPoint(beginPos)
    cache_fish_explode_dead[key] = sd
    cache_fish_explode_dead[key].seat_num = data.seat_num
    FishingModel.SendBoomFishHarm(sd)
    dump(sd, "<color=yellow>发送 一条特殊鱼死亡</color>")
end
-- 使用(鱼)的闪电
function C.UseLightning(data)
	local beginPos = C.GetSkillAnimPos(data)
    local max_rate = data.max_rate or data.data[1]
	local fish_id, seat_num = data.fish_id, data.seat_num
	local key = data.id
    local boom_fishs = FishManager.CalcLightningFishHarm(fish_id, max_rate, seat_num)

    local sd = {}
    sd.id = key
    sd.fish_id = data.fish_id
    sd.fish_ids = boom_fishs
    sd.type = data.type
    sd.fish_pos = FishingModel.GetUITo2DPoint(beginPos)
    cache_fish_explode_dead[key] = sd
    cache_fish_explode_dead[key].seat_num = data.seat_num
    FishingModel.SendBoomFishHarm(sd)
end
-- 使用(鱼)的活动类道具
-- 如：西瓜，粽子
function C.AddActTool(data)
    local uipos = FishingModel.GetSeatnoToPos(data.seat_num)
    local beginPos = C.GetSkillAnimPos(data)
    local playerPos = panelSelf.PlayerClass[uipos]:GetPlayerFXPos()
    local num = data.num
    local lvl = FishingModel.GetGunIdToIndex(data.index)
    if data.seat_num == my_seat_num then
        FishingAnimManager.PlayZongzi(data.seat_num, num, panelSelf.FXNode, beginPos,panelSelf.ZZAddMoneyNode.transform.position, 0,data)
    else
        FishingAnimManager.PlayZongzi(data.seat_num, num, panelSelf.FXNode, beginPos, playerPos, 0, data)
    end
end
-- 使用挑战任务
function C.UseTZTask(data)
    dump(data, "<color=red>使用挑战任务 </color>")
	local beginPos = C.GetSkillAnimPos(data)
	local seat_num = data.seat_num
	Event.Brocast("ui_appearTZ_task_msg", {pos=beginPos, seat_num=seat_num})
end
-- 使用全屏炸弹
function C.UseQPBomb(data)
    local beginPos = Vector3.zero
    local key = data.id
    local pos = FishingModel.GetUITo2DPoint(beginPos)

    FishingAnimManager.PlayShowAndHideFX(panelSelf.LayerLv2, "by_zi_cjyzd", beginPos, 2)
    FishingAnimManager.PlayQPMaxBoom(panelSelf.FXNode, nil, function ()
        local boom_fishs = FishManager.CalcQPBoomHarm(data.seat_num)
        local sd = {}
        sd.id = key
        sd.fish_ids = boom_fishs
        sd.type = data.type
        sd.fish_pos = FishingModel.GetUITo2DPoint(beginPos)
        cache_fish_explode_dead[key] = sd
        cache_fish_explode_dead[key].seat_num = data.seat_num
        FishingModel.SendBoomFishHarm(sd)
        dump(sd, "<color=yellow>发送 一条特殊鱼死亡</color>")
    end)
end
-- 使用全屏闪电
function C.UseQPLaser(data)
    local beginPos = Vector3.zero
    local key = data.id
    local pos = FishingModel.GetUITo2DPoint(beginPos)
    local max_rate = data.max_rate or data.data[1]
    local boom_fishs = FishManager.CalcQPLaserHarm(data.fish_id, max_rate, data.seat_num)

    FishingAnimManager.PlayShowAndHideFXAndCall(panelSelf.LayerLv2, "by_zi_cjldfb", beginPos, 2, false, function ()
        local sd = {}
        sd.id = key
        sd.fish_ids = boom_fishs
        sd.type = data.type
        sd.fish_pos = FishingModel.GetUITo2DPoint(beginPos)
        cache_fish_explode_dead[key] = sd
        cache_fish_explode_dead[key].seat_num = data.seat_num
        FishingModel.SendBoomFishHarm(sd)
        dump(sd, "<color=yellow>发送 一条特殊鱼死亡</color>")        
    end, 1)
end
-- 使用全屏小炸弹
function C.UseQPMinBomb(data)
    local beginPos = Vector3.zero
    local key = data.id
    local pos = FishingModel.GetUITo2DPoint(beginPos)
    local boom_fishs = FishManager.CalcQPMinBoomHarm(data.seat_num)

    FishingAnimManager.PlayShowAndHideFX(panelSelf.LayerLv2, "by_zi_yzd", beginPos, 2)
    FishingAnimManager.PlayQPMinBoom(panelSelf.FXNode, nil, function()
        local sd = {}
        sd.id = key
        sd.fish_ids = boom_fishs
        sd.type = data.type
        sd.fish_pos = FishingModel.GetUITo2DPoint(beginPos)
        cache_fish_explode_dead[key] = sd
        cache_fish_explode_dead[key].seat_num = data.seat_num
        FishingModel.SendBoomFishHarm(sd)
        dump(sd, "<color=yellow>发送 一条特殊鱼死亡</color>")        
    end)
end
-- 使用全屏小闪电
function C.UseQPMinLaser(data)
    local beginPos = Vector3.zero
    local key = data.id
    local pos = FishingModel.GetUITo2DPoint(beginPos)
    local max_rate = data.max_rate or data.data[1]
    local boom_fishs = FishManager.CalcQPLaserHarm(data.fish_id, max_rate, data.seat_num)

    FishingAnimManager.PlayShowAndHideFXAndCall(panelSelf.LayerLv2, "by_zi_ldfb", beginPos, 2, false, function ()
        local sd = {}
        sd.id = key
        sd.fish_ids = boom_fishs
        sd.type = data.type
        sd.fish_pos = FishingModel.GetUITo2DPoint(beginPos)
        cache_fish_explode_dead[key] = sd
        cache_fish_explode_dead[key].seat_num = data.seat_num
        FishingModel.SendBoomFishHarm(sd)
        dump(sd, "<color=yellow>发送 一条特殊鱼死亡</color>")
    end, 1)
end
-- 使用转盘抽奖:幸运转盘，3个"连环转盘"那种
function C.UseZPXJ(data)
    FishingAnimManager.PlayMoveAndHideFX(panelSelf.LayerLv2, "Fish3D_huodongyu_glow1", data.fish_pos, Vector3.zero, 0.1, 1, function()
        FishingAnimManager.PlayShowAndHideFXAndCall(panelSelf.LayerLv2, "Fish3D_huodongyu_glow2", Vector3.zero, 1, false, function()
            local m_data = FishingModel.data
            local beginPos = C.GetSkillAnimPos(data)
            local _parm = {}
            if data.seat_num == m_data.seat_num then
                _parm.anim_type = 1
            else
                _parm.anim_type = 2
            end
            _parm.beginPos = beginPos
            _parm.playerPos = panelSelf:GetPlayerPos(data.seat_num)
            _parm.jn_data = data
            GameManager.GotoUI({ gotoui = "by3d_act_xyzp", goto_scene_parm = "panel",parent = panelSelf.transform, data = _parm })

        end, 0.2)    
    end, nil)
end

-- ********************************
-- 获得
-- 获得技能的表现
-- ********************************
function C.AddLaser(data)
    if not data.time then
        return
    end
    local m_data = FishingModel.data
    local userdata = FishingModel.GetSeatnoToUser(m_data.seat_num)
    if m_data.players_info[data.seat_num].laser_rate then
        if m_data.players_info[data.seat_num].laser_rate > data.time then
            dump(data, "<color=red>激光值变小了，检查一下</color>")
        end
    end
    m_data.players_info[data.seat_num].laser_rate = data.time or 0
    Event.Brocast("model_fish_laser_rate_change", data.seat_num)
end

function C.AddTimeSkill(data, tool_type)
    if not panelSelf.GetTimeSkillPos then
        print("<color=red>是不是捕鱼比赛出现时间道具</color>")
        dump(data)
        dump(tool_type)
        return
    end
    local endPos = panelSelf:GetTimeSkillPos(tool_type)
    if data.seat_num ~= 1 then
        endPos = panelSelf:GetPlayerPos(data.seat_num)
    end
    local beginPos = C.GetSkillAnimPos(data)
    local type = data.type
    local num = data.num or data.data[1]
    FishingAnimManager.PlayToolSP(panelSelf.FlyGoldNode, data.seat_num, beginPos, endPos, type, num, function (v)
        Event.Brocast("ui_timeskill_fly_finish_msg", data.seat_num, v, tool_type)
        ExtendSoundManager.PlaySound(audio_config.by.bgm_by_huodejineng.audio_name)
    end)

end

--- 获得召唤
function C.AddZH(data)
    local endPos = panelSelf:GetZHPos()
    if data.seat_num ~= FishingModel.GetPlayerSeat() then
        endPos = panelSelf:GetPlayerPos(data.seat_num)
    end
    local beginPos = C.GetSkillAnimPos(data)
    local type = FishingSkillManager.FishDeadAppendType.summon_fish
    local num = data.num or data.data[1]
    FishingAnimManager.PlayToolSP(panelSelf.FlyGoldNode, data.seat_num, beginPos, endPos, type, num, function (v)
        Event.Brocast("ui_zh_fly_finish_msg", data.seat_num, v)
        ExtendSoundManager.PlaySound(audio_config.by.bgm_by_huodejineng.audio_name)
    end)
end
-- 比赛场 加分
function C.AddScore(data)
    ExtendSoundManager.PlaySound(audio_config.by.bgm_bymatch_zhupaohuodejifen.audio_name)
    local m_data = FishingModel.data
    local userdata = FishingModel.GetSeatnoToUser(m_data.seat_num)

    local value = data.data[1]
    m_data.score = m_data.score + value
    Event.Brocast("model_player_money_msg", {seat_num=1})
end
-- 比赛场 加累计赢金
function C.AddGrades(data)
    ExtendSoundManager.PlaySound(audio_config.by.bgm_bymatch_zhupaohuodejifen.audio_name)
    local m_data = FishingModel.data
    local userdata = FishingModel.GetSeatnoToUser(m_data.seat_num)

    local value = data.data[1]
    m_data.grades = m_data.grades + value
    Event.Brocast("model_player_money_msg", {seat_num=1})
end
-- 加快速射击
function C.UseQuickShoot(data)
    local endPos = panelSelf.PlayerClass[data.seat_num]:GetPlayerPos()
    local beginPos = C.GetSkillAnimPos(data)
    FishingAnimManager.PlayKSSJFX(panelSelf.FlyGoldNode, beginPos, endPos, function ()
        Event.Brocast("model_barbette_info_change_msg")
        local pos = FishingModel.Get2DToUIPoint( panelSelf.PlayerClass[data.seat_num]:GetGunPos() )
        FishingAnimManager.PlayGunChangeFX(panelSelf.FlyGoldNode, pos)
    end)
end
-- 获得添加技能
function C.AddSkill(data)
    local endPos = panelSelf:GetSkillNode()
    if data.seat_num ~= 1 then
        if panelSelf.GetPlayerPos and type(panelSelf.GetPlayerPos) == "function" then
            endPos = panelSelf:GetPlayerPos(data.seat_num)
        end
    end
    local beginPos = C.GetSkillAnimPos(data)
    local type = data.type
    local num = data.num
    if not num then
        if data.data then
            num = data.data[1]
        else
            num = 1
        end
    end
    if data.type == FishingSkillManager.FishDeadAppendType.Boom then
        data.item_key = "obj_fish_secondary_bomb"
    elseif data.type == FishingSkillManager.FishDeadAppendType.FreeBullet then
        data.item_key = "obj_fish_free_bullet"
    elseif data.type == FishingSkillManager.FishDeadAppendType.AddForce then
        data.item_key = "obj_fish_power_bullet"
    elseif data.type == FishingSkillManager.FishDeadAppendType.DoubleTime then
        data.item_key = "obj_fish_crit_bullet"
    elseif data.type == FishingSkillManager.FishDeadAppendType.Lightning then
        data.item_key = "obj_fish_secondary_bolt"
    elseif data.type == FishingSkillManager.FishDeadAppendType.QP_bomb then
        data.item_key = "obj_fish_super_bomb"
    elseif data.type == FishingSkillManager.FishDeadAppendType.QP_laser then
        data.item_key = "obj_fish_super_bolt"
    elseif data.type == FishingSkillManager.FishDeadAppendType.QP_min_bomb then
        data.item_key = "obj_fish_secondary_bomb"
    elseif data.type == FishingSkillManager.FishDeadAppendType.QP_min_laser then
        data.item_key = "obj_fish_secondary_bolt"
    elseif data.type == FishingSkillManager.FishDeadAppendType.ZT_bullet then
        data.item_key = "obj_fish_drill_bullet"
    elseif data.type == FishingSkillManager.FishDeadAppendType.summon_fish then
        data.item_key = "obj_fish_summon_fish"
    elseif data.type == FishingSkillManager.FishDeadAppendType.ppc_cjzd
        or data.type == FishingSkillManager.FishDeadAppendType.ppc_cjzd2
        or data.type == FishingSkillManager.FishDeadAppendType.ppc_cjzd3 then
        data.item_key = "obj_fish_super_bomb"
    elseif data.type == FishingSkillManager.FishDeadAppendType.ppc_gjzd
        or data.type == FishingSkillManager.FishDeadAppendType.ppc_gjzd2
        or data.type == FishingSkillManager.FishDeadAppendType.ppc_gjzd3 then
        data.item_key = "obj_fish_super_bomb"
    else
        dump(data, "<color=red>获得的道具没有处理</color>")
    end

    if data.rates then
        FishingAnimManager.PlayLuckToolFX(panelSelf.FlyGoldNode, data.seat_num, beginPos, endPos, type, num, function (v)
            ExtendSoundManager.PlaySound(audio_config.by.bgm_by_huodejineng.audio_name)
            Event.Brocast("ui_get_skill_msg", data)
        end)
    else
        FishingAnimManager.PlayToolSP(panelSelf.FlyGoldNode, data.seat_num, beginPos, endPos, type, num, function (v)
            if data.type == FishingSkillManager.FishDeadAppendType.ZT_bullet then
                ExtendSoundManager.PlaySound(audio_config.by.bgm_by_zuantoudan1.audio_name)
            else
                ExtendSoundManager.PlaySound(audio_config.by.bgm_by_huodejineng.audio_name)
            end
            Event.Brocast("ui_get_skill_msg", data)
        end)
    end
end

--凤凰的技能
function C.UseFengHuang(data)
    -- local data = FishingModel.data
    FishingFHDeadPrefab.Create(data)
end

-- 疯狂6选1
function C.UseFK6X1(data)
    FishingAnimManager.PlayMoveAndHideFX(panelSelf.LayerLv2, "Fish3D_huodongyu_glow1", data.fish_pos, Vector3.zero, 0.1, 1, function ()
        FishingAnimManager.PlayShowAndHideFXAndCall(panelSelf.LayerLv2, "Fish3D_huodongyu_glow2", Vector3.zero, 1, false, function ()
            GameManager.GotoUI({gotoui = "by3d_act_6in1",goto_scene_parm = "panel", data=data})
        end, 0.2)        
    end, nil)
end


--筛子乌龟
function C.UseSZWG(data)
    FishingAnimManager.PlayMoveAndHideFX(panelSelf.LayerLv2, "Fish3D_huodongyu_glow1", data.fish_pos, Vector3.zero, 0.1, 1, function ()
        FishingAnimManager.PlayShowAndHideFXAndCall(panelSelf.LayerLv2, "Fish3D_huodongyu_glow2", Vector3.zero, 1, false, function ()
            GameManager.GotoUI({gotoui = "by3d_act_szwg",goto_scene_parm = "panel", data = data})
        end, 0.2)        
    end, nil)
end

--宝藏章鱼
function C.UseBZZY(data)
    FishingAnimManager.PlayMoveAndHideFX(panelSelf.LayerLv2, "Fish3D_huodongyu_glow1", data.fish_pos, Vector3.zero, 0.1, 1, function ()
        FishingAnimManager.PlayShowAndHideFXAndCall(panelSelf.LayerLv2, "Fish3D_huodongyu_glow2", Vector3.zero, 1, false, function ()
            GameManager.GotoUI({gotoui = "by3d_act_zhuanpan",goto_scene_parm = "panel", data = data})
        end, 0.2)           
    end, nil)
end

-- ********************************
-- 获得
-- ********************************




