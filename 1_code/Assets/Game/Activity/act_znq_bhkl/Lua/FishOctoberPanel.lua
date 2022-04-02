-- 创建时间:2019-05-29
-- Panel:FishingActivityZongziPanel
--[[ *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 --]]
local basefunc = require "Game/Common/basefunc"

FishOctoberPanel = basefunc.class()
local C = FishOctoberPanel
C.name = "FishOctoberPanel"
C.Update_Info_Time = 2
C.Info_Score = 0
C.Update_Timer = nil
local config = HotUpdateConfig("Game.Activity.act_znq_bhkl.Lua.fish_october_config")

function C.Create(parent)
    return C.New(parent)
end

function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.onExitScene)
    self.lister["AssetChange"] = basefunc.handler(self, self.onAssetChange)
    self.lister["query_activity_exchange_score_response"] = basefunc.handler(self, self.onInfoChange)
    self.lister["on_Get_fish_october_info"] = basefunc.handler(self, self.onInfoChange)
end

function C:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    self:RemoveListener()
end


function C:OnDestroy()
    self:RemoveListener()
    destroy(self.gameObject)
end

function C:ctor(parent)

	ExtPanel.ExtMsg(self)
    parent = parent or GameObject.Find("Canvas/LayerLv4").transform
    local obj = newObject(C.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj

    self:MakeLister()
    self:AddMsgListener()
    LuaHelper.GeneratingVar(obj.transform, self)

    self.back_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnBackClick()
    end)
    self.goto_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnGotoClick()
    end)
    self.help_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnHelpClick()
    end)

    self.sv = self.ScrollView:GetComponent("ScrollRect")
    self.sv.enabled = true
    self:InitUI()
    FishOctoberPanel.HeartGetScore()

end

function C:InitUI()
    if MainModel.myLocation ~= "game_Hall" then
        self.goto_btn.gameObject:SetActive(false)
    else
        self.goto_btn.gameObject:SetActive(true)
    end

	self:ClearCellList()

    for k, v in ipairs(config.config) do
        local pre = FishingOctoberPrefab.Create(self.content, v, C.OnDHClick, self)
        self.CellList[#self.CellList + 1] = pre
    end
    self:onAssetChange()
    local s1 = os.date("%m月%d日%H点", config.pram_config.begin_time)
    local e1 = os.date("%m月%d日%H点", config.pram_config.end_time)
    self.activity_time_txt.text = string.format("活动时间：%s—%s", s1, e1)
    self:query_activity_exchange()
end

function C:ClearCellList()
    if self.CellList then
        for k, v in ipairs(self.CellList) do
            v:OnDestroy()
        end
    end
    self.CellList = {}
end
function C:OnDHClick(id)
    Network.SendRequest("activity_exchange", { type = "duanwujie_fishgame_zongzi", id = id }, "请求兑换", function(data)
        dump(data)
        if data.result == 0 then
            if config.config[id] and config.config[id].is_sw == 1 then
                RealAwardPanel.Create({ text = config.config[id].award_name, image = config.config[id].award_icon })
            end
            self:query_activity_exchange()
        else
            HintPanel.ErrorMsg(data.result)
        end
        Network.SendRequest("query_activity_exchange_score",{ type = "duanwujie_fishgame_zongzi" })
    end)
end
function C:MyRefresh()
end

function C:OnBackClick()
    self:MyExit()
    destroy(self.gameObject)
end
function C:OnGotoClick()
    GameManager.GotoUI({gotoui="game_FishingHall"})
end
function C:OnHelpClick()
    IllustratePanel.Create({ self.introduce_txt })
end

function C:onAssetChange()
    self.myzz_txt.text =  FishOctoberPanel.Info_Score
end

function C:onExitScene()
    FishOctoberPanel.ClearHeart()
    self:MyExit()
end


function C:query_activity_exchange()
    Network.SendRequest("query_activity_exchange", { type = "duanwujie_fishgame_zongzi" }, "请求数据", function(data)
        dump(data, "<color=yellow>data11</color>")
        if data.result == 0 then
			for i, v in ipairs(data.data) do
                local obj = self.CellList[i]
                if obj and IsEquals(obj.gameObject) then
                    local l_txt = obj.transform:Find("@award_num_txt"):GetComponent("Text")
                    if v == -1 then
                        l_txt.text = string.format("不限兑换次数")
                    else
                        l_txt.text = string.format("剩余兑换%s次", v)
                    end
                    local btn = obj.transform:Find("@dh_not_btn")
                    local btn_sw = obj.transform:Find("@sw_not_btn")
                    btn.gameObject:SetActive(v == 0)
                    if config.config[i].is_sw ==1 then
                        btn_sw.gameObject:SetActive(v == 0)
                    else
                        btn_sw.gameObject:SetActive(false)
                    end
                end
            end
        else
            HintPanel.ErrorMsg(data.result)
        end
    end)
end

function C.CheckActivityState()

end

function C.HeartGetScore(backcall)
    local _Score = C.Info_Score
    if C.Update_Timer == nil then 
        _Score = FishOctoberPanel.GetScore()    
        C.Update_Timer = Timer.New(function ()
            C.Update_Info_Time = C.Update_Info_Time - 1
            if C.Update_Info_Time < 0 then
                _Score = FishOctoberPanel.GetScore()                
                C.Update_Info_Time = 6          
                if  backcall then
                    backcall()
                end 
            end  
        end,1,-1)
        C.Update_Timer:Start()
    end 
    if  backcall then
        backcall()
    end   
    return _Score       
end

function C.GetScore()
    Network.SendRequest("query_activity_exchange_score",{ type = "duanwujie_fishgame_zongzi" },"",function (data)
        --dump(data,"<color=red>捕鱼快乐.....当前积分</color>")
        if data and data.result == 0 then 
            C.Info_Score = data.score   
            Event.Brocast("on_Get_fish_october_info","on_Get_fish_october_info",data)   
        end 
    end)
    return  C.Info_Score
end


function C.ClearHeart()
    if C.Update_Timer then 
        C.Update_Timer:Stop()
    end
    C.Update_Timer = nil  
end

function C.Cheak_IsActive()
    if os.time() > config.pram_config[4].value and os.time() < config.pram_config[5].value and MainModel.UserInfo.ui_config_id == 1 then
        return true 
    else
        return false
    end 
end

function C:onInfoChange(_,data)
    if data and data.result == 0 then 
        C.Info_Score = data.score
        self.myzz_txt.text =  C.Info_Score   
    end 
end