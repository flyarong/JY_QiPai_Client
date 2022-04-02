-- 创建时间:2020-08-12
-- CommonRankEmail 管理器

local basefunc = require "Game/Common/basefunc"
CommonRankEmail = {}
local M = CommonRankEmail
local this
local lister

local Types = {
    xiaoxiaole_024_rank = "消消乐争霸",
    true_love_026_rank = "真爱榜单",
    happy_guoqing_aster_rank = "五星收集排行榜",
    xiaoxiaolezb_032_rank = "消消乐争霸",
    treasure_crab_rank = "宝藏蟹争霸",
    wsj_035_jfdrb_rank = "积分达人榜",
    axfl_045_xxlbd_rank = "消消乐榜单",
    fkssy_037_lhsjb_rank = "礼盒搜集榜",
    xcylx_038_jfzb_rank = "积分争霸",
    xqdz_040_xqsjb_rank = "雪球收集榜",
    zhshe_041_lwbd_rank = "礼物榜单",
    dzswn_042_ygsjb_rank = "阳光收集榜",
    sdkl_043_lwdr_rank = "礼物达人",
    hqyd_044_jzdw_rank = "饺子大王",
    yclx_045_jfdr_rank = "积分达人",
    nsj_053_nsshz_rank = "女神守护者",
}


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
end

function M.Init()
	M.Exit()

	this = CommonRankEmail
	this.m_data = {}
	MakeLister()
    AddLister()
    M.InitUIConfig()
    M.AddEmailType()
    M.AddAutoShowAward()
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
	end
end

function M.OnReConnecteServerSucceed()

end

function M.AddEmailType()
    for k,v in pairs(Types) do
        EmailModel.AddRankType(k.."_email",v)
    end
end


function M.AddAutoShowAward()
    local check_func = function (type)
        for k,v in pairs(Types) do
            if type == k.."_email_award" then
                return true
            end
        end
    end
    MainModel.AddShow(check_func)
end

