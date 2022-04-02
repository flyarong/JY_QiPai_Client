-- 创建时间:2019-11-04
-- 游戏相关的限时特惠礼包管理

GameFlashSaleGiftManager = {}
local M = GameFlashSaleGiftManager
M.key = "sys_xsth"

local this
local lister

-- 破产请求频繁 主要是捕鱼
local last_send_time
-- 临时值
local _buf_parm

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

    lister["EnterScene"] = this.OnEnterScene
	lister["query_send_list_fishing_msg"] = this.on_query_send_list_fishing_msg
	
	lister["finish_gift_shop"] = this.on_finish_gift_shop
	lister["main_change_gift_bag_data_msg"] = this.on_main_change_gift_bag_data_msg

    lister["ui_game_pc_msg"] = this.on_ui_game_pc_msg
end

function M.Init()
	M.Exit()

	this = GameFlashSaleGiftManager
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
	this.Config = {}
	this.Config["qql"] = { {gift_ids={36}, idx=3}, {gift_ids={37}, idx=4} }
	this.Config["by"] = { {gift_ids={10163, 10164, 10165}, idx=1}, {gift_ids={10052, 10053, 10054}, idx=2}, {gift_ids={10055, 10056, 10057}, idx=3} }
	this.Config.gift_map = {}
	for k,v in ipairs(this.Config["qql"]) do
		for k1,v1 in ipairs(v.gift_ids) do
			this.Config.gift_map[v1] = 1
		end
	end
	for k,v in ipairs(this.Config["by"]) do
		for k1,v1 in ipairs(v.gift_ids) do
			this.Config.gift_map[v1] = 1
		end
	end
end

function M.OnLoginResponse(result)
	if result == 0 then
	end
end
function M.OnReConnecteServerSucceed()
end

function M.OnEnterScene()
	_buf_parm = nil
	if MainModel.myLocation == "game_Zjd" then
		local cfg = this.Config["qql"]
		local msg_list = {}
		for k,v in ipairs(cfg) do
			for k1, v1 in ipairs(v.gift_ids) do
				msg_list[#msg_list + 1] = {msg="query_gift_bag_status", data = {gift_bag_id = v1}}
			end
		end
		M.SendMsgList("sale_qql", msg_list)
	elseif MainModel.myLocation == "game_FishingHall" then
		local cfg = this.Config["by"]
		local msg_list = {}
		for k,v in ipairs(cfg) do
			for k1, v1 in ipairs(v.gift_ids) do
				msg_list[#msg_list + 1] = {msg="query_gift_bag_status", data = {gift_bag_id = v1}}
			end
		end
		M.SendMsgList("sale_by", msg_list)
    end
end

function M.on_ui_game_pc_msg(parm)
	if last_send_time and ( os.time() - last_send_time ) < 3 then
		return
	end
	dump(parm, "<color=red>EEE on_ui_game_pc_msg</color>")
	last_send_time = os.time()
	_buf_parm = parm
	if parm.tag == "by" then
		local cfg = this.Config["by"]
		local msg_list = {}
		for k,v in ipairs(cfg) do
			if v.idx == parm.idx then
				for k1, v1 in ipairs(v.gift_ids) do
					msg_list[#msg_list + 1] = {msg="query_gift_bag_status", data = {gift_bag_id = v1}}
				end
			end
		end
		M.SendMsgList("sale_by", msg_list)
	elseif parm.tag == "qql" then
		local cfg = this.Config["qql"]
		local msg_list = {}
		for k,v in ipairs(cfg) do
			if v.idx == parm.idx then
				for k1, v1 in ipairs(v.gift_ids) do
					msg_list[#msg_list + 1] = {msg="query_gift_bag_status", data = {gift_bag_id = v1}}
				end
			end
		end
		M.SendMsgList("sale_qql", msg_list)
	end
end
-- 获取礼包数据
function M.GetGiftData(id)
	return MainModel.GetGiftDataByID(id)
end

-- 对应需求
-- 敲敲乐： 在限时特惠消失之前，每次进入敲敲乐游戏都弹出限时特惠礼包，若玩家同时触发2个限时特惠，则只弹出价格最高的礼包
-- 捕鱼：   在限时特惠消失前，每次进入捕鱼大厅时，弹出限时特惠礼包，若玩家同时触发2个限时特惠礼包，则只弹出价格最高的礼包
function M.on_query_send_list_fishing_msg(tag)
	print("<color=red>EEE tag == " .. tag .. "</color>")
	if tag == "sale_qql" then
		local cfg = this.Config["qql"]
		-- 从最大的开始
		for i = #cfg, 1, -1 do
			for k,v in ipairs(cfg[i].gift_ids) do
				if (not _buf_parm or _buf_parm.idx == cfg[i].idx) and MainModel.IsCanBuyGiftByID(v) then
					if _buf_parm then
						GameManager.GotoUI({gotoui = "gift_shatter_golden_sale",goto_scene_parm = "panel",parm1 = _buf_parm.node, parm2 = _buf_parm.idx, parm3 = _buf_parm.call})
					else
						GameManager.GotoUI({gotoui = "gift_shatter_golden_sale",goto_scene_parm = "panel",parm1 = nil, parm2 = cfg[i].idx, parm3 = function ()
							Event.Brocast("show_gift_panel",{isduring_xsth = true})
						end})
					end
					_buf_parm = nil
					return
				end
			end
		end
		if _buf_parm and _buf_parm.is_pc then
			_buf_parm = nil
			Event.Brocast("show_gift_panel")
		end
	elseif tag == "sale_by" then
		local cfg = this.Config["by"]
		-- 从最大的开始
		for i = #cfg, 1, -1 do
			for k,v in ipairs(cfg[i].gift_ids) do
				if (not _buf_parm or _buf_parm.idx == cfg[i].idx) and MainModel.IsCanBuyGiftByID(v) then
					local config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, v)
					if MainModel.myLocation == "game_FishingHall" then
						local a = FishingManager.CheckCanEnter(tonumber(cfg[i].idx))
						if not a then
							GameManager.GotoUI({gotoui = "gift_fishing_subsidy",goto_scene_parm = "panel",parm1 = cfg[i].idx,parm2 = nil,parm3 = nil,parm4 = {is_close=true}})
						end
					else
						GameManager.GotoUI({gotoui = "gift_fishing_subsidy",goto_scene_parm = "panel",parm1 = cfg[i].idx,parm2 = function ()
							Event.Brocast("show_gift_panel",{isduring_xsth = true})
						end})
					end
					_buf_parm = nil
					return
				end
			end
		end
		if MainModel.myLocation ~= "game_FishingHall" and _buf_parm and _buf_parm.is_pc then
			_buf_parm = nil
			Event.Brocast("show_gift_panel")
		end
	end
end

function M.on_finish_gift_shop(id)
	if this.Config.gift_map[ id ] then
		Event.Brocast("model_finish_gift_bag_msg")
	end	
end
function M.on_main_change_gift_bag_data_msg(id)
	if this.Config.gift_map[ id ] then
		Event.Brocast("model_finish_gift_bag_msg")
	end	
end

function M.SendRequest(list, cur_i, tag)
	if list[cur_i] then
		Network.SendRequest(list[cur_i].msg , list[cur_i].data, "发送请求", function (data)
			Event.Brocast(list[cur_i].msg .. "_response", list[cur_i].msg, data)
			cur_i = cur_i + 1
			M.SendRequest(list, cur_i, tag)
		end)
	else
		Event.Brocast("query_send_list_fishing_msg", tag)
	end
end
function M.SendMsgList(tag, msg_list)
	if msg_list and #msg_list > 0 then
		M.SendRequest(msg_list, 1, tag)
	else
		Event.Brocast("query_send_list_fishing_msg", tag)
	end
end

