-- 创建时间:2019-12-16

LHDManager = {}
local M = LHDManager
local lhd_hall_config = SysLhdManager.lhd_hall_config

local this
local m_data
local lister

-- 是否使用安全模式
M.is_use_aq_style = false
if M.is_use_aq_style then
    M.PAI_STYLE = {
        [9] = {name="飞龙在天", key="tonghuashun", img="dld_imgf_ths_old", fx="LHD_tonghuanshun_old", fx_t = 2},
        [8] = {name="炸弹", key="zhadan", img="dld_imgf_zd_old", fx="LHD_zhadan_old", fx_t = 2},
        [7] = {name="飞机", key="hulu", img="dld_imgf_fj_old", fx="LHD_hulu_old", fx_t = 2},
        [6] = {name="同色", key="tonghua", img="dld_imgf_tongse_old", fx="lHD_tonghua_old", fx_t = 2},
        [5] = {name="一条", key="shunzi", img="dld_imgf_yt_old", fx="LHD_shunzi_old", fx_t = 2},
        [4] = {name="三虎", key="santiao", img="dld_imgf_sh_old", fx="LHD_santiao_old", fx_t = 2},
        [3] = {name="双龙", key="liangdui", img="dld_imgf_shuanglong_old", fx="LHD_liangdui_old", fx_t = 2},
        [2] = {name="一对", key="yidui", img="dld_imgf_yd", fx="LHD_yidui_old", fx_t = 2},
        [1] = {name="单牌", key="danpai", img="dld_imgf_dp", fx="LHD_danpai", fx_t = 2},
    }
else
    M.PAI_STYLE = {
        [9] = {name="同花顺", key="tonghuashun", img="dld_imgf_ths", fx="LHD_tonghuanshun", fx_t = 2},
        [8] = {name="炸弹", key="zhadan", img="dld_imgf_zd", fx="LHD_zhadan", fx_t = 2},
        [7] = {name="葫芦", key="hulu", img="dld_imgf_hl", fx="LHD_hulu", fx_t = 2},
        [6] = {name="同花", key="tonghua", img="dld_imgf_th", fx="lHD_tonghua", fx_t = 2},
        [5] = {name="顺子", key="shunzi", img="dld_imgf_sz", fx="LHD_shunzi", fx_t = 2},
        [4] = {name="三条", key="santiao", img="dld_imgf_st", fx="LHD_santiao", fx_t = 2},
        [3] = {name="两对", key="liangdui", img="dld_imgf_ld", fx="LHD_liangdui", fx_t = 2},
        [2] = {name="一对", key="yidui", img="dld_imgf_yd", fx="LHD_yidui", fx_t = 2},
        [1] = {name="单牌", key="danpai", img="dld_imgf_dp", fx="LHD_danpai", fx_t = 2},
    }
end

local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end
local function MakeLister()
    lister={}
    lister["fg_lhd_get_xsyd_status_response"] = this.on_fg_lhd_get_xsyd_status
end

-- 初始化Data
local function InitMatchData()
    M.data={}
    m_data = M.data
end

function M.IsActive()
    if this.IsOnOff and MainModel.GetMarketChannel() == "normal" then
        return true
    end
end
function M.Init()
    this = M
    this.IsOnOff = true
    InitMatchData()
    MakeLister()
    AddLister()
    this.InitUIConfig()
    return this
end
function M.Exit()
    if this then
        RemoveLister()
        lister=nil
        this=nil
    end
end
function M.InitUIConfig()
    this.UIConfig={}
    this.UIConfig.hall = lhd_hall_config.config
end

function M.GetGameConfig()
	return this.UIConfig.hall
end

function M.GetGameIdByConfig(game_id)
	for k,v in ipairs(this.UIConfig.hall) do
		if v.game_id == game_id then
			return v
		end
	end
end

-- 判断是否能进入
function M.IsRoomEnter(id)
    local ui_config = M.GetGameIdByConfig(id)
    local dd = MainModel.UserInfo.jing_bi
    if ui_config.enterMin >= 0 and dd < ui_config.enterMin then
        return 1 -- 过低
    end
    if ui_config.enterMax >= 0 and dd > ui_config.enterMax then
        return 2 -- 过高
    end
    return 0
end
-- 判断是否能再次进入
function M.IsAgainRoomEnter(id)
    local ui_config = M.GetGameIdByConfig(id)

    local jing_bi = MainModel.UserInfo.jing_bi
    if ui_config then
        if ui_config.min_coin > 0 and jing_bi < ui_config.min_coin then
            return 1 -- 过低
        end
        if ui_config.max_coin > 0 and jing_bi > ui_config.max_coin then
            return 2 -- 过高
        end
    else
        dump(id, "<color=red>DdzFreeModel id</color>")
    end
    return 0
end
-- 快速开始游戏的数据
function M.GetRapidBeginGameID ()
    local dd = MainModel.UserInfo.jing_bi
    for i=1, #this.UIConfig.hall do
        local v = this.UIConfig.hall[i]
        if (v.isOnOff == 1 and (not v.isLock or v.isLock == 0)) and v.game_id ~= 5 and M.IsRoomEnter(v.game_id) == 0 then
            return {is_enter=true, cfg=v}
        end
    end
    return {is_enter=false, cfg=this.UIConfig.hall[1]}
end

-- 金蛋大乱斗新手引导
function M.IsGuide()
    if m_data.lhd_status == 0 then
        return true
    end
end
function M.QueryLHDGuideStatus()
    if m_data.lhd_status then
        Event.Brocast("model_lhd_guide_status")
    else
        Network.SendRequest("fg_lhd_get_xsyd_status", nil, "")
    end
end
function M.on_fg_lhd_get_xsyd_status(_, data)
    dump(data, "<color=red>on_fg_lhd_get_xsyd_status</color>")
    m_data.lhd_status = data.result
    Event.Brocast("model_lhd_guide_status")
end
function M.SendGuideFinish()
    m_data.lhd_status = 1
    Network.SendRequest("fg_lhd_xsyd_finish")
end