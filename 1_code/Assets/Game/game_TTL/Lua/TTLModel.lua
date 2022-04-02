-- 创建时间:2020-03-19

TTLModel = {}
local M = TTLModel

--被撞物坐标配置👇
package.loaded["Game.game_TTL.Lua.TTLItem_config"] = nil
local Item_config = require "Game.game_TTL.Lua.TTLItem_config"
--档位配置👇
package.loaded["Game.game_TTL.Lua.TTLDW_config"] = nil
local DW_config = require "Game.game_TTL.Lua.TTLDW_config"

TTLModel.Defines = {
    BulletSpeed_max = 1100, -- 子弹初始(最大)速度
    BulletSpeed_min	= 850,--子弹最小速度
    BulletAcceleration = -1100, --子弹加速度
    BulletRadius = 42,

    quicken=10,


    bets=0.5,

    game_power={
        --[[500,
        1000,
        2000,
        4000,
        10000,
        20000,
        40000,
        100000,
        200000,
        500000,   --]]
    },

    --[[auto = {
        [1]=
		{
			line = 1,
			dw = 1,
			min = 500,
			max = 1000,
		},
		[2]=
		{
			line = 2,
			dw = 2,
			min = 1000,
			max = 2000,
		},
		[3]=
		{
			line = 3,
			dw = 3,
			min = 2000,
			max = 4000,
		},
		[4]=
		{
			line = 4,
			dw = 4,
			min = 4000,
			max = 10000,
		},
		[5]=
		{
			line = 5,
			dw = 5,
			min = 10000,
			max = 20000,
		},
		[6]=
		{
			line = 6,
			dw = 6,
			min = 20000,
			max = 40000,
		},
		[7]=
		{
			line = 7,
			dw = 7,
			min = 40000,
			max = 100000,
		},
		[8]=
		{
			line = 8,
			dw = 8,
			min = 100000,
			max = 200000,
		},
		[9]=
		{
			line = 9,
			dw = 9,
			min = 200000,
			max = 500000,
		},
		[10]=
		{
			line = 10,
			dw = 10,
			min = 500000,
			max = 500000,
		},
    }   --]]
}


local this
local lister
local m_data

local still_live = {
    data={},
    index={},
    award_txt={},
}



function M.MakeLister()
    lister = {}
    --lister["ItemBase_switch_TTL"]=this.changeSwitch
    lister["tantanle_all_info_response"] = this.on_all_info
    lister["tantanle_enter_game_response"] = this.on_tantanle_enter_game_response

    lister["tantanle_quit_game_response"] = M.on_tantanle_quit_game
end

function M.AddMsgListener()
    dump(lister)
    for proto_name, fun in pairs(lister) do
        Event.AddListener(proto_name, fun)
    end
end

function M.RemoveMsgListener()
    dump(lister)
    for proto_name, fun in pairs(lister) do
        Event.RemoveListener(proto_name, fun)
    end
end
function M.Init()
	this = TTLModel
    M.MakeLister()
    M.AddMsgListener()


    M.Item_config = Item_config   
    M.DW_config = DW_config
    M.InitGamePower()
    M.data = {}
    m_data = M.data
    M.still_live=still_live
    return this
end

function M.Exit()
	if this then
		M.RemoveMsgListener()
	end
end

function M.InitGamePower()
    for i=1,#DW_config.auto do
        TTLModel.Defines.game_power[i] = DW_config.auto[i].min
    end
end

--按位左移
local function leftmove(t,v)
    return math.floor(t * MathExtend.Pow(2,v))
    -- body
end

--按位右移
local function rightmove(t,v)
    return math.floor(t / MathExtend.Pow(2,v))
    -- body
end

--解压服务器给我的数据
function M.unzip(path)
  local res = {}
  for i, v in ipairs(path) do
    local t = tonumber(v)
    local f1, f2 = 0, 0
    res[#res + 1] = rightmove(t,22)
    if (rightmove(t,21)) ~= leftmove(res[#res],1) then
      res[#res] = -res[#res]
      f1 = 1
    end
    res[#res + 1] =rightmove((t - (leftmove(math.abs(res[#res]),22)) - leftmove(f1,21) ),9)
    if ( rightmove((t - leftmove(math.abs(res[#res - 1]),22)  -   leftmove(f1,21)),8) ) ~=leftmove(res[#res],1) then
      res[#res] = -res[#res]
      f2 = 1
    end
    res[#res + 1] = t - leftmove(math.abs(res[#res - 1]),22)  - leftmove(f1,21) - leftmove(math.abs(res[#res]),9) - leftmove(f2,8)
  end
  return res
end


function M.on_all_info(_,data)
    if data.result == 0 then
        m_data.js_data = {}
        m_data.js_data.index = data.index
        m_data.js_data.all_money = data.all_money
        m_data.js_data.all_rate = data.all_rate
        m_data.js_data.path = data.path
        m_data.js_data.random_award = data.random_award
        Event.Brocast("model_all_info_msg")    
    else
        m_data.js_data = nil
        MainLogic.GotoScene("game_Hall")
    end
end

function M.on_tantanle_enter_game_response(_, data)
    if data.result == 0 then
        Event.Brocast("model_tantanle_enter_game_response")
    else
        MainLogic.GotoScene("game_Hall")
    end
end

function M.on_tantanle_quit_game(_, data)
    if data.result == 0 then
        Event.Brocast("model_tantanle_quit_game_response")

        Event.Brocast("quit_game_success")
    else
        HintPanel.ErrorMsg(data.result)
    end
end

--存储活着的bigAward的信息
function M.Still_live_bigAward(data,index,award_text)
    M.still_live.data[#M.still_live.data+1]=data
    M.still_live.index[#M.still_live.index+1]=index
    M.still_live.award_txt[#M.still_live.award_txt+1]=award_text
    dump(M.still_live,"<color=red>++++++++++++++++++++活的++++++++++++++++++++++++++</color>")
    -- body
end

--根据用户的鲸币数量获得一个初始档位
function M.GetUserBet()
    local data= DW_config.auto
    local qx_max = #TTLModel.Defines.game_power
    for i=#data,1,-1 do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="tantanle_dc_".. i, is_on_hint=true}, "CheckCondition")
        if not a or b then
            qx_max = i
            break
        end 
    end
    for i = qx_max,1,-1 do
        if not data[i].min or MainModel.UserInfo.jing_bi/20 >= data[i].min then
            return i
        end 
    end
    return 1
end