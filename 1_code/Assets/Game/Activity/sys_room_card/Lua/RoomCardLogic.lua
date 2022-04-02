-- 创建时间:2018-08-06
RoomCardLogic = {}

local this  -- 单例
local hallModel

local cur_panel

local lister
local function MakeLister()
    lister = {}
end
local function AddLister()
    for msg, cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg, cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister = nil
end
function RoomCardLogic.Init()
    print("<color=red>RoomCardLogic.Init</color>")
    RoomCardLogic.Exit()
    this = RoomCardLogic
    --初始化model
    RoomCardModel.Init()
    MakeLister()
    AddLister()
end
function RoomCardLogic.Exit()
    if this then
        this = nil
        RemoveLister()
        RoomCardModel.Exit()
    end
end

-- 条件是否满足
function RoomCardLogic.IsMeetCondition()
    if not GameGlobalOnOff.IsOpenGuide or (MainModel.UserInfo.xsyd_status == 1 and not MainModel.Location) then
        return true
    end
end

--[[
    @desc: 新手引导完成,没有在游戏中，有房间号，进入房卡场
    author:{gsf}
    time:2018-08-07 16:40:16
    @return:
]]
function RoomCardLogic.JoinRoomCard(room_no)
    local call = function ()
        Network.SendRequest("friendgame_join_room", {room_no = room_no}, "请求加入房间",
            function(data)
                dump(data, "<color=red>加入房间的数据</color>")
                if data.result == 0 then
                    RoomCardModel.data.game_type = data.game_type
                    MainModel.RoomCardInfo = nil
                    RoomCardLogic.JoinRoomCardByData()
                elseif data.result == 1026 then
                    HintPanel.Create(3, "你的房卡不足，是否购买", function()
                            PayPanel.Create(GOODS_TYPE.item)
                        end
                    )
                else
                    HintPanel.ErrorMsg(data.result)
                end
            end
        )
    end
    if RoomCardLogic.IsMeetCondition() and room_no then
        HintPanel.Create(2, "您确定要进入" .. room_no .. "房间吗？", function()
            call()
            end,
            function()
                MainModel.RoomCardInfo = nil
            end
        )
    end
end

--[[
    @desc: 满足入场要求，根据数据进入房卡场
    author:{gsf}
    time:2018-08-08 19:04:58
    @return:
]]
function RoomCardLogic.JoinRoomCardByData()
    if RoomCardModel.data.game_type then
        local scene_type = RoomCardModel.RoomCardGameTypeTable[RoomCardModel.data.game_type]
        local state = gameMgr:CheckUpdate(scene_type)
        if state == "Install" or state == "Update" then
            RoomCardDown.Create(
                scene_type,
                function()
                    --进入房间
                    GameManager.GotoUI({gotoui = scene_type})
                end
            )
        else
            --进入房间
            GameManager.GotoUI({gotoui = scene_type})
        end
    else
        HintPanel.Create(1, "没有房间数据")
    end
end
