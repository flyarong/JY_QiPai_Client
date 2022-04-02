-- 创建时间:2022-03-09
-- Panel:ACT_074_TCXBPanel
--[[
 *      ┌─┐       ┌─┐
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

ACT_074_TCXBPanel = basefunc.class()
local C = ACT_074_TCXBPanel
C.name = "ACT_074_TCXBPanel"
local M = ACT_074_TCXBManager
local DESCRIBE_TEXT = {
    [1] = "1.活动时间：3月22日7:30~3月28日23:59:59",
    [2] = "2.每轮游戏有15张卡，全部翻开后重置所有卡，也可消耗少量桃花道具手动重置所有卡",
    [3] = "3.选择“寻宝1次”或“全部寻宝”进行抽奖，每次抽奖需消耗200桃花道具，随机获得道具奖励或者稀有“春”字",
    [4] = "4.每轮结束后结算“春”字奖励，根据当轮获得春字数量领取奖励",
    [5] = "5.请及时抽奖，活动结束后，所有未使用的道具和未领取的奖励都将视为自动放弃",
    [6] = "6.实物奖励请联系客服QQ公众号4008882620领取",
    [7] = "7.实物图片仅供参考，请以实际收到的奖励为准",
}
function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["on_get_spring_activity_data_msg"] = basefunc.handler(self,self.on_on_get_spring_activity_data_msg)
    self.lister["on_spring_activity_lottery_msg"] = basefunc.handler(self,self.on_on_spring_activity_lottery_msg)
    self.lister["on_spring_activity_reset_awards_msg"] = basefunc.handler(self,self.on_on_spring_activity_reset_awards_msg)
    self.lister["AssetChange"] = basefunc.handler(self,self.on_AssetChange)
    self.lister["ACT_074_TCXB_need_xp_msg"] = basefunc.handler(self,self.on_ACT_074_TCXB_need_xp_msg)
    self.lister["ACT_074_TCXBItemBase_new_msg"] = basefunc.handler(self,self.on_ACT_074_TCXBItemBase_new_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    self:ClearItem()
    self:ClearPhaseItem()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
    self.ck_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnCKClick()
        end
    )
    self.cz_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            if M.GetRemain() ~= 15 then
                self:OnCZClick()
            end   
        end
    )
    self.wh_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnWHClick()
        end
    )
    self.one_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            if (M.CheckNeedXP() or not self.in_xp) and not self.fp then
                self:OnOneClick()
            end
        end
    )
    self.all_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            if (M.CheckNeedXP() or not self.in_xp) and not self.fp then
               self:OnAllClick()
            end
        end
    )
    CommonTimeManager.GetCutDownTimer(M.end_time,self.time_txt)
    M.QueryData()
end

function C:MyRefresh()
    if IsEquals(self.num_txt) then
        self.num_txt.text = GameItemModel.GetItemCount(M.item_key)
    end
    if IsEquals(self.cost_txt) then
        self.cost_txt.text = "消耗 " .. M.GetRemain() * 200 .. " 桃花"
    end
    self:CreateItem()
    self:CreatePhaseItem()
end

function C:OnCKClick()
    ACT_074_TCXBPreviewPanel.Create()
end

function C:OnCZClick()
    ACT_074_TCXBTipPanel.Create(2)
end

function C:OnWHClick()
    self:OpenHelpPanel()
end

function C:OnOneClick()
    if GameItemModel.GetItemCount(M.item_key) >= 200 then
        M.Lottery(1,1)
    else
        LittleTips.Create("您的" .. GameItemModel.GetItemToKey(M.item_key).name .. "不足!")
    end
end

function C:OnAllClick()
    if GameItemModel.GetItemCount(M.item_key) >= 200 * M.GetRemain() then
        if PlayerPrefs.GetInt(MainModel.UserInfo.user_id .. M.key .. "today_no_tip",0) == tonumber(os.date("%d",os.time())) then
            M.Lottery(1,-1)
        else
            ACT_074_TCXBTipPanel.Create(1,1,-1,M.GetRemain())
        end
    else
        LittleTips.Create("您的" .. GameItemModel.GetItemToKey(M.item_key).name .. "不足!")
    end
end

function C:CreateItem()
    self:ClearItem()
    if IsEquals(self.Content_left) then
        for i=1,15 do
            local pre = ACT_074_TCXBItemBase.Create(self.Content_left.transform,i)
            self.pre_cell[#self.pre_cell + 1] = pre
        end
    end
end

function C:CreatePhaseItem()
    self:ClearPhaseItem()
    local config = M.GetConfig().phase
    if IsEquals(self.Content_right) then
        for i=1,#config do
            local pre = ACT_074_TCXBPhaseItemBase.Create(self.Content_right.transform,config[i],i,self.transform)
            self.phase_cell[#self.phase_cell + 1] = pre
        end
    end
end

function C:ClearItem()
    if self.pre_cell then
        for k,v in pairs(self.pre_cell) do
            v:MyExit()
        end
    end
    self.pre_cell = {}
end

function C:ClearPhaseItem()
    if self.phase_cell then
        for k,v in pairs(self.phase_cell) do
            v:MyExit()
        end
    end
    self.phase_cell = {}
end

function C:OpenHelpPanel()
    local str = DESCRIBE_TEXT[1]
    for i = 2, #DESCRIBE_TEXT do
        str = str .. "\n" .. DESCRIBE_TEXT[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:on_on_get_spring_activity_data_msg()
    self:MyRefresh()
end

function C:on_on_spring_activity_lottery_msg()
    self:MyRefresh()
end

function C:on_on_spring_activity_reset_awards_msg()
    M.SetXP(false)
    self.Content_left.gameObject:SetActive(false)
    self.in_xp = true
    if not table_is_null(self.Award_Data) and #self.Award_Data.data ~= 2 then
        Event.Brocast("AssetGet",self.Award_Data)
        self.Award_Data = nil
    end
    if not table_is_null(self.Award_Data_Spring) then
        Event.Brocast("AssetGet",self.Award_Data_Spring)
        self.Award_Data_Spring = nil
    end
    M.ShowSWAward()
    GameComAnimTool.PlayShowAndHideAndCall(self.transform,"HD_TC_xpdh",Vector3.New(62,-53,0),4.2,nil,function ()
        self.in_xp = false
        if IsEquals(self.Content_left) then
            self:MyRefresh()
            self.Content_left.gameObject:SetActive(true)
        end
    end,nil,nil,nil,function ()
        self.in_xp = false
        if IsEquals(self.Content_left) then
            self:MyRefresh()
            self.Content_left.gameObject:SetActive(true)
            if not table_is_null(self.Award_Data) and #self.Award_Data.data ~= 2 then
                Event.Brocast("AssetGet",self.Award_Data)
                self.Award_Data = nil
            end
            if not table_is_null(self.Award_Data_Spring) then
                Event.Brocast("AssetGet",self.Award_Data_Spring)
                self.Award_Data_Spring = nil
            end
            M.ShowSWAward()
        end
    end)
end

function C:on_AssetChange(data)
    if data then
        if string.sub(data.change_type,1,15) == "spring_lottery_" then
            self.num_txt.text = GameItemModel.GetItemCount(M.item_key)
            self.Award_Data = data
        end
        if data.change_type == "prop_word_spring" then
            self.Award_Data_Spring = data
        end
    end
end

function C:on_ACT_074_TCXB_need_xp_msg()
    local fun = function ()
        GameComAnimTool.PlayShowAndHideAndCall(self.transform,"HD_TC_xpdh",Vector3.New(62,-53,0),4.2,nil,function ()
            self.in_xp = false
            if IsEquals(self.Content_left) then
                self:MyRefresh()
                self.Content_left.gameObject:SetActive(true)
            end
        end,nil,nil,nil,function ()
            self.in_xp = false
            if IsEquals(self.Content_left) then
                self:MyRefresh()
                self.Content_left.gameObject:SetActive(true)
                if not table_is_null(self.Award_Data) and #self.Award_Data.data ~= 2 then
                    Event.Brocast("AssetGet",self.Award_Data)
                    self.Award_Data = nil
                end
                if not table_is_null(self.Award_Data_Spring) then
                    Event.Brocast("AssetGet",self.Award_Data_Spring)
                    self.Award_Data_Spring = nil
                end
                M.ShowSWAward()
            end
        end)
    end
    M.SetXP(false)
    M.ClearData()
    M.ClearNew()
    self.in_xp = true
    self.Content_left.gameObject:SetActive(false)
    if not table_is_null(self.Award_Data) and #self.Award_Data.data ~= 2 then
        if table_is_null(self.Award_Data_Spring) and not M.NeedShowSWAward() then
            self.Award_Data.callback = fun
        end
        Event.Brocast("AssetGet",self.Award_Data)
        self.Award_Data = nil
    end
    if not table_is_null(self.Award_Data_Spring) then
        if not M.NeedShowSWAward() then
            self.Award_Data_Spring.callback = fun
        end
        Event.Brocast("AssetGet",self.Award_Data_Spring)
        self.Award_Data_Spring = nil
    end
    M.ShowSWAward(fun)
end

function C:on_ACT_074_TCXBItemBase_new_msg(b)
    self.fp = b
end