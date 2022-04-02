
local basefunc = require "Game/Common/basefunc"
RXCQXuanZhongOver = {}
local M = RXCQXuanZhongOver
local this
local lister
local Call_List = {}
local Call_Index = 0
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
    lister["model_rxcq_kaijiang"] = M.on_model_rxcq_kaijiang
    lister["rxcq_call_next_anim"] = M.on_rxcq_call_next_anim
    lister["EnterForeGround"] = M.on_EnterForeGround
end

function M.Init()
    M.Exit()
    this = RXCQXuanZhongOver
    M.Ret()	
    MakeLister()
    AddLister()
end

function M.Exit()
	if this then
		RemoveLister()
        M.Ret()
		this = nil
	end
end

function M.on_EnterForeGround()
    if RXCQModel.IsDuringMiniGame == true then
        M.Ret()
        RXCQMiniGameDie.ReSetUI()
        RXCQTRHYManager.ForceOver()
        if RXCQModel.all_award then
            RXCQClearing.Create(nil,{score = RXCQModel.all_award})
        end
    end
end

function M.on_rxcq_call_next_anim()
    Call_Index = Call_Index + 1
    if Call_Index > #RXCQModel._all_game_data then
        RXCQClearing.Create(nil,{score = RXCQModel.all_award})
    else
        RXCQModel.SetNextData(Call_Index)
        Call_List[Call_Index]()
    end
end

function M.on_model_rxcq_kaijiang()
    M.Ret()
end

function M.SaveCall(call)
    Call_List[#Call_List + 1] = call
end

function M.Ret()
    Call_Index = 0
    Call_List = {}
    RXCQLotteryAnim.ClearChangLiang()
end