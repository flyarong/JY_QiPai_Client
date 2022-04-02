-- 创建时间:2020-09-08
-- 龙王争霸 管理器
--@dump(LWZBManager.CheckIsMultipleOfTen({18,3,41},3))
local basefunc = require "Game/Common/basefunc"
LWZBManager = {}
local M = LWZBManager
M.key = "sys_manager_lwzb"
-- 全局开关
LWZBManager.IsOnOff = true
LWZBManager.IsOpenGuide = false
LWZBManager.GuideBtn = false
GameButtonManager.ExtLoadLua(M.key,"LWZBGuidePanel")
M.config = GameButtonManager.ExtLoadLua(M.key,"lwzb_game_config")
M.hall_config = GameButtonManager.ExtLoadLua(M.key,"lwzb_hall_config")

local px_map = {"lwzb_imgf_l2","lwzb_imgf_l3","lwzb_imgf_l4","lwzb_imgf_l5","lwzb_imgf_l6",
"lwzb_imgf_l7","lwzb_imgf_l8","lwzb_imgf_l9","lwzb_imgf_sl","lwzb_imgf_sfss","lwzb_imgf_wzjl",}

local zhutype_map = {"lwzb_imgf_wl","lwzb_imgf_l1","lwzb_imgf_l2","lwzb_imgf_l3","lwzb_imgf_l4","lwzb_imgf_l5","lwzb_imgf_l6",
"lwzb_imgf_l7","lwzb_imgf_l8","lwzb_imgf_l9","lwzb_imgf_sl","lwzb_imgf_sfss","lwzb_imgf_wzjl",}

local ss_pre_name = {"LWZB_shayu","LWZB_jinchan","LWZB_binggui","LWZB_eryu"}

local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    else
        return true
    end
end
-- 创建入口按钮时调用
function M.CheckIsShow()
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end


local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end
local function MakeLister()
    lister = {}
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg

    lister["query_xsyd_status_response"] = this.on_query_xsyd_status_response
end

function M.Init()
	M.Exit()

	this = LWZBManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        M.QureyLwzbXsydStatus()
	end
end
function M.OnReConnecteServerSucceed()
end

--报名
function M.Sign(index)
    local sign_data = M.hall_config.sign[index]
    if MainModel.UserInfo.jing_bi < sign_data.limit_min then 
        --金币不足,弹出对应礼包
        PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
    elseif (MainModel.UserInfo.jing_bi > sign_data.limit_max) and (sign_data.limit_max ~= -1) then 
        LittleTips.Create("您太富有了，更高级的场次才适合您！")
    else
        GameManager.GotoUI({gotoui="game_LWZB", p_requset={game_id = sign_data.game_id}, goto_scene_parm={game_id = sign_data.game_id}}, function (requset)
            if requset == 0 then
                this.m_data.game_id = sign_data.game_id
            end
        end)
    end
end

function M.SetCurGame_id(id)
    this.m_data.game_id = id
end


--获取当前场次的game_id
function M.GetCurGame_id()
    return this.m_data.game_id
end

--检查牌的类型,来决定返回txt还是img
function M.CheckPaiType(type)
    if (type == 1) or (type == 2)  then--无龙或龙一返回txt
        if type == 1 then
            return "无龙"
        else
            return "龙一"
        end
    else--龙二至龙九或神龙或四方神兽或五爪金龙返回img
        return px_map[type - 2]
    end
end

--产生一堆金币飞行
--[[
    data.type == 1从一点生成飞至多点
    data.type == 2从多点生成飞至一点
    data.num == 数量
    data.item_type == "jingbi" 飞金币
    data.item_type == "longzhu" 飞龙珠
--]]
function M.PlayTYJBFly(parent, prefab_name, beginPos, endPos, data, delta_t, call, seq_parm,finish_call,time,start_call)
    local delta_t
    local num = 8
    local item_type = "jingbi"
    if data and data.delta then
        delta_t = data.delta
    end
    if data and data.num then
        num = data.num
    end
    if data and data.item_type then
        item_type = data.item_type
    end
    local prefab = prefab_name
    if data and data.prefab then
        prefab = data.prefab
    end
    if time and start_call then
        local seq = DoTweenSequence.Create()
        seq:AppendInterval(time)
        seq:OnKill(function ()
            start_call()
        end)
    end

    local call = function ()
        local t = 0.08
        local finish_num = 0
        local _call = function ()
            finish_num = finish_num + 1
            if finish_num == 1 then
                --GameComAnimTool.PlayMoveAndHideFX(parent, prefab, beginPos, endPos, nil, 1, nil, nil, seq_parm)
            end
            if finish_num == num then
                if call then
                    call()
                end
            end
        end
  

        
        if finish_call and type(finish_call) == "function" then
            _call = finish_call
        end
        for i = 1, num do
            local x
            local y
            local xx
            local yy
            local pos
            local _endPos
            if data and data.type == 1 then
                x = beginPos.x
                y = beginPos.y
                xx = endPos.x + math.random(-100,100) --[[- 100--]]
                yy = endPos.y + math.random(-100,100) --[[- 100--]]
            else
                x = beginPos.x + math.random(-100, 100) --[[- 100--]]
                y = beginPos.y + math.random(-100, 100) --[[- 100--]]
                xx = endPos.x
                yy = endPos.y
            end
            pos = Vector3.New(x, y, beginPos.z)
            _endPos = Vector3.New(xx,yy,endPos.z)
            if item_type == "longzhu" then
                M.CreateLongzhu(parent, pos, _endPos, t * (i-1), _call, prefab, seq_parm)
            elseif item_type == "jingbi" then
                M.CreateGold(parent, pos, _endPos, t * (i-1), _call, prefab, seq_parm)
            end
        end
    end

    if delta_t and delta_t > 0 then
        local seq = DoTweenSequence.Create(seq_parm)
        seq:AppendInterval(delta_t)
        seq:OnKill(function ()
            call()
        end)
    else
        call()
    end
end

function M.CreateGold(parent, beginPos, endPos, delay, call, prefab_name, seq_parm)
    local zz = 100
    local _beginPos = Vector3.New(beginPos.x, beginPos.y, zz)
    local _endPos = Vector3.New(endPos.x, endPos.y, zz)
    local obj = GameObject.Instantiate(GetPrefab(prefab_name), parent).gameObject
    local tran = obj.transform
    tran.position = _beginPos
    tran.localScale = Vector3.New(1, 1, 1)

    local seq = DoTweenSequence.Create(seq_parm)
    local len = math.sqrt( (beginPos.x - endPos.x) * (beginPos.x - endPos.x) + (beginPos.y - endPos.y) * (beginPos.y - endPos.y) )
    local t = len / 1800
    if delay and delay > 0.00001 then       
        tran.gameObject:SetActive(false)
        seq:AppendInterval(delay)
        seq:AppendCallback(function ()
            if IsEquals(tran) then
                tran.gameObject:SetActive(true)
            end
        end)
    end
    seq:AppendInterval(1)
    seq:Append(tran:DOMove(_endPos, t))
    seq:Append(tran:DOScale(Vector3.New(1.2,1.2,1.2),0.2))
    seq:Append(tran:DOScale(Vector3.New(1,1,1),0.2))
    seq:Append(tran:GetComponent("CanvasGroup"):DOFade(0, 0.5))
    seq:OnKill(function ()
        if call then
            call()
        end
    end)
    seq:OnForceKill(function ()
        destroy(obj)
    end)
end 

function M.CreateLongzhu(parent, beginPos, endPos, delay, call, prefab_name, seq_parm)
    local zz = 100
    local _beginPos = Vector3.New(beginPos.x, beginPos.y, zz)
    local _endPos = Vector3.New(endPos.x, endPos.y, zz)
    local obj = GameObject.Instantiate(GetPrefab(prefab_name), parent).gameObject
    local tran = obj.transform
    tran.position = _beginPos
    tran.localScale = Vector3.New(1, 1, 1)

    local seq = DoTweenSequence.Create(seq_parm)
    local len = math.sqrt( (beginPos.x - endPos.x) * (beginPos.x - endPos.x) + (beginPos.y - endPos.y) * (beginPos.y - endPos.y) )
    local t = len / 900
    if delay and delay > 0.00001 then       
        tran.gameObject:SetActive(false)
        seq:AppendInterval(delay)
        seq:AppendCallback(function ()
            if IsEquals(tran) then
                tran.gameObject:SetActive(true)
            end
        end)
    end
    seq:AppendInterval(0.2)
    seq:Append(tran:DOMove(_endPos, t))
    seq:Append(tran:DOScale(Vector3.New(1.2,1.2,1.2),0.2))
    seq:Append(tran:DOScale(Vector3.New(1,1,1),0.2))
    seq:Append(tran:GetComponent("CanvasGroup"):DOFade(0, 2))
    seq:OnKill(function ()
        if call then
            call()
        end
    end)
    seq:OnForceKill(function ()
        destroy(obj)
    end)
end 

--在结算的时候,检查自己钱够不够入场条件,不够了就提示充钱,不充就退到龙王争霸的场次选择大厅
function M.CheckMoneyIsEnoughOnSettle()
    local sign_data = M.hall_config.sign[M.GetCurGame_id()]
    if MainModel.UserInfo.jing_bi < sign_data.limit_min then 
        return false
    else
        return true
    end
end


--当幸运星下注时,幸运星要从幸运星头像位置飞出去,飞到幸运星下注的神兽位置
function M.LuckyStarFlytoSS(parent, prefab_name, beginPos, endPos, finish_call)
    local obj = GameObject.Instantiate(GetPrefab(prefab_name), parent).gameObject
    local path = {}
    local a = beginPos
    local b = endPos
    obj.transform.position = beginPos
    path[0] = a
    path[1] = Vector3.New((a.x > b.x and math.random(a.x,b.x) or math.random(b.x,a.x)) + 60,(a.y > b.y and math.random(a.y,b.y) or math.random(b.y,a.y)) + 60,0)
    path[2] = Vector3.New(b.x,b.y,0)
    local seq = DoTweenSequence.Create()
    seq:Append(obj.transform:DOPath(path,0.5,DG.Tweening.PathType.CatmullRom))
    seq:OnKill(function ()
        if finish_call and type(finish_call) == "function" then
            finish_call()
        end
    end)
    seq:OnForceKill(function ()
        destroy(obj)
    end)
end

--翻译牌(虽然没有区分花色,但是服务器发来的牌的数据还是1到52,而不是1到13)
function M.TranslatePai(pai)
    local x = math.ceil(pai / 4) 
    if x > 10 then
        x = 10
    end
    return x
end

--麒麟赐福奖池格式处理
function M.PoolFormat(num)
    local str = num
    return str
end

function M.GetSSPreName(index)
    return ss_pre_name[index]
end

--播放鱼网
function M.PlayGunNet(parent,rate_index, finish_call)
    local pre_name = "lwzb_net_pre_"..rate_index
    local obj = GameObject.Instantiate(GetPrefab(pre_name), parent).gameObject
    obj.transform.localScale = Vector3.New(0,0,0)
    obj.transform.localPosition = Vector3.New(-10,0,0)
    local seq = DoTweenSequence.Create()
    seq:Append(obj.transform:DOScale(Vector3.New(1,1,1), 0.4))
    seq:Append(obj.transform:DOScale(Vector3.New(0.6,0.6,0.6), 0.2))
    seq:AppendInterval(0.8)
    seq:OnKill(function ()
        if finish_call and type(finish_call) == "function" then
            finish_call()
        end
    end)
    seq:OnForceKill(function ()
        destroy(obj)
    end)
end


function M.GetLwzbGuideOnOff()
    return LWZBManager.IsOpenGuide
end

function M.SetLwzbGuideOnOff()
    if this.m_data.xsyd == 0 then
        LWZBManager.IsOpenGuide = true
    else
        LWZBManager.IsOpenGuide = false
    end
end

function M.GuideBtnCanUse()
    LWZBManager.GuideBtn = true
end

function M.QureyLwzbXsydStatus()
    Network.SendRequest("query_xsyd_status",{xsyd_type = "xsyd_lwzb"})
end

function M.on_query_xsyd_status_response(_,data)
    dump(data,"<color=yellow>+++++++++on_query_xsyd_status_response++++++++</color>")
    if data and data.result == 0 then
        if data.xsyd_type == "xsyd_lwzb" then
            this.m_data.xsyd = 1--data.status
            M.SetLwzbGuideOnOff()
        end
    end
end

function M.SetXsydSataus(status)
    this.m_data.xsyd = status
end

--判断任意3张牌之和是否为10的倍数
function M.CheckIsMultipleOfTen(tab,num)
    local count = 0
    local len = num or #tab
    for i=1,len do
        for j=1,len do
            if i ~= j then
                for k=1,len do
                    if k ~= i and k ~= j then
                        if (M.TranslatePai(tab[i]) + M.TranslatePai(tab[j]) + M.TranslatePai(tab[k])) % 10 == 0 then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

function M.TranslatePai_New(pai)
    local x = math.ceil(pai / 4) 
    if x >= 10 then
        x = "lp"
    end
    return x
end

--检查牌的类型
function M.CheckPaiType_New(type)
    return zhutype_map[type]
end

--判断任意3张牌之和是否为10的倍数
function M.CheckIsMultipleOfTen_New(tab,start_index,end_index)
    local count = 0
    local start_index = start_index or 1
    local end_index = end_index or #tab
    for i=start_index,end_index do
        for j=start_index,end_index do
            if i ~= j then
                for k=start_index,end_index do
                    if k ~= i and k ~= j then
                        if (M.TranslatePai(tab[i]) + M.TranslatePai(tab[j]) + M.TranslatePai(tab[k])) % 10 == 0 then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end