-- 创建时间:2019-03-01

local basefunc = require "Game.Common.basefunc"
PopUpFMRevive = basefunc.class()

local C = PopUpFMRevive
C.name = "PopUpFMRevive"
local instance
function C.Create(parm)
	if not instance then
		instance = C.New(parm)
	end
    return instance
end
function C.Close()
    if instance then
        instance:OnClose()
    end
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
    self.lister["fsmg_revive_response"] = basefunc.handler(self, self.fsmg_revive_response)

    self.lister["fsmg_query_total_award_pool_response"] = basefunc.handler(self, self.on_fsmg_query_total_award_pool)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:ctor(parm)
    dump(parm, "<color=yellow>PopUpFMRevive 复活界面 参数</color>")
    self.parm = parm
    -- self.cfg = FishingManager.GetGameIDToConfig(self.parm.game_id)
    self:MakeLister()
    self:AddMsgListener()

    self.parent = GameObject.Find("Canvas/LayerLv5").transform
    self.gameObject = newObject(C.name, self.parent)
    self.transform = self.gameObject.transform
    LuaHelper.GeneratingVar(self.transform, self)
    self.revive_btn.onClick:AddListener(basefunc.handler(self, self.OnReviveClicked))
    self.close_btn.onClick:AddListener(basefunc.handler(self, self.OnBackClicked))

    self.time_call_map = {}

    self.update_time = Timer.New(function ()
        self:Update()
    end, 1, -1, nil, true)
    self.update_time:Start()
    
    self.chaidai.gameObject:SetActive(false)

    self:MyRefresh()
    DOTweenManager.OpenPopupUIAnim(self.Revive)
end

function C:MyRefresh()
    if self.parm.num > 0 then
        self.revive_btn.transform.localPosition = Vector3.New(0,-138,0)
        self.hint1_txt.text = self.parm.score
        self.hint2_txt.text = self.parm.score
        self.revive_num_txt.text = string.format( "剩余 %s 次复活机会", self.parm.num)
        local is_lacky = self.parm.time > 0
        if is_lacky then
            self.hint1_rect.gameObject:SetActive(true)
            self.hint2_rect.gameObject:SetActive(false)
        else
            self.hint1_rect.gameObject:SetActive(false)
            self.hint2_rect.gameObject:SetActive(true)
        end
        self.revive_item = C.GetReviveItemByData(self.parm.assets)
        local item_data = GameItemModel.GetItemToKey(self.revive_item.item)
        GetTextureExtend(self.revive_img, item_data.image, item_data.is_local_icon)
        if self.revive_item.item == "shop_gold_sum" or self.revive_item.item == "cash" then     
            self.revive_txt.text = string.format( "x%s", self.revive_item.count / 100)
        else
            self.revive_txt.text = string.format( "x%s", StringHelper.ToCash(self.revive_item.count))
        end
        self.close_btn.gameObject:SetActive(not is_lacky)
        self.time_call_map["time"] = {time_call = self:GetCall(1), run_call = basefunc.handler(self, self.UpdateTime)}
        self:UpdateTime(true)
        self.time_call_map["quit_time"] = {time_call = self:GetCall(1), run_call = basefunc.handler(self, self.UpdateQuitTime)}
        self:UpdateQuitTime(true)

        local vv = FishingMatchModel.data.total_award_pool or 0
        self.award_pool_txt.text = math.floor(vv / 10000) .. "福卡"
    else
        self.hint1_rect.gameObject:SetActive(false)
        self.hint2_rect.gameObject:SetActive(false)
        self.close_btn.gameObject:SetActive(true)
        self.revive_num_txt.text = string.format( "剩余 %s 次复活机会", self.parm.num)
        self.time_call_map["quit_time"] = {time_call = self:GetCall(1), run_call = basefunc.handler(self, self.UpdateQuitTime)}
        self:UpdateQuitTime(true)
    end
end

function C:GetCall(t)
    local tt = t
    local cur = 0
    return function (st)
        cur = cur + st
        if cur >= tt then
            cur = cur - tt
            return true
        end
        return false
    end
end
function C:Update()
    for k,v in pairs(self.time_call_map) do
        if v.time_call(1) then
            v.run_call()
        end
    end
end
function C:UpdateTime(b)
    if not b then
        if self.parm.time then
            self.parm.time = self.parm.time - 1
        end
        if self.parm.time <= 0 then
            self.time_call_map["time"] = nil
            self.close_btn.gameObject:SetActive(true)
            self.hint1_rect.gameObject:SetActive(false)
            self.hint2_rect.gameObject:SetActive(true)
        end
    end
    if not self.parm.time then
        self.hint_quit_time_txt.text = "--"
    else
        self.hint_time_txt.text = self.parm.time .. "s"
    end
end
function C:UpdateQuitTime(b)
    if not b then
        if self.parm.quit_time then
            self.parm.quit_time = self.parm.quit_time - 1
        end
        if self.parm.quit_time <= 0 then
            self.time_call_map["quit_time"] = nil
            self.close_btn.gameObject:SetActive(true)
        end
    end
    if not self.parm.quit_time then
        self.hint_quit_time_txt.text = "--"
    else
        local ff = math.floor(self.parm.quit_time / 60)
        local mm = self.parm.quit_time % 60
        self.hint_quit_time_txt.text = string.format("%02d:%02d", ff, mm)
    end
end

function C:OnAssetChange()
    if instance then
        self:MyRefresh()
    end
end
function C:OnExitScene()
    self:OnClose()
end

function C:fsmg_revive_response(_, data)
    dump(data, "<color=red>fsmg_revive_response</color>")
    if data.result == 0 then
        local pp = {}
        pp.score = data.score
        pp.luck = data.luck
        Event.Brocast("model_fsmg_match_finish_revive_msg", pp)
        self:OnClose()
    else
        HintFMPanel.ErrorMsg(data.result)
    end
end

function C:OnClose()
    self:RemoveListener()
	instance = nil
    if self.update_time then
        self.update_time:Stop()
        self.update_time = nil
    end
    destroy(self.gameObject)
end

function C:OnReviveClicked()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self:OnRevive()
end

function C:OnRevive()
    if not self.revive_item then
        HintFMPanel.Create(1,"复活数据错误")
        return
    end
    if GameItemModel.GetItemCount(self.revive_item.item) >= self.revive_item.count then
        Network.SendRequest("fsmg_revive", {type = self.revive_item.item}, "请求复活")
    else
        PayPanel.Create(GOODS_TYPE.jing_bi)
    end
end

function C:OnBackClicked()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if os.time() > self.parm.quit_time_table then
        HintPanel.Create(2, "确认要退出捕鱼比赛吗？", function ()
            FishingMatchLogic.quit_game()
            self:OnClose()
        end)
    else
        local desc = string.format("还有需等待%s秒可以退出", self.parm.quit_time)
        LittleTips.Create(desc)
    end
end

function C.GetReviveItemByData(data)
    if not data then
        print("<color=red>复活数据里面没有消耗数据</color>")
        return
    end
    local revive_item
    for i,v in ipairs(data) do
        if GameItemModel.GetItemCount(v.asset_type) >= v.value then
            revive_item = {}
            revive_item.item = v.asset_type
            revive_item.count = v.value
            revive_item.index = i
            return revive_item
        end
    end
    if not revive_item then
        for i,v in ipairs(data) do
            if v.asset_type == "jing_bi" then
                revive_item = {}
                revive_item.item = v.asset_type
                revive_item.count = v.value
                revive_item.index = i
                return revive_item
            end
        end
    end
    if not revive_item then
        dump(data, "<color=red>复活数据里面没有金币消耗</color>")
    end
    return revive_item
end

function C:on_fsmg_query_total_award_pool(_, data)
    if data.result == 0 then
        local vv = tonumber(data.value)
        self.award_pool_txt.text = math.floor(vv / 10000) .. "福卡"
    end
end