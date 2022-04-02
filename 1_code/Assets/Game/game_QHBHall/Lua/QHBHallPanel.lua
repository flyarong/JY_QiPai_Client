local basefunc = require "Game/Common/basefunc"
QHBHallPanel = basefunc.class()
local M = QHBHallPanel
M.name = "QHBHallPanel"
local config = QHBHallModel.GetUICfg()
local instance
local net_data = {}
function M.Create()
    if instance then
        instance:MyExit()
    end
    instance = M.New()
	return instance
end

function M.Close()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    self.lister["qhb_hb_all_award_response"] = basefunc.handler(self, self.qhb_hb_all_award_response)
    self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
    if self.hb_timer then
        self.hb_timer:Stop()
        self.hb_timer = nil
    end
    if self.cd_timer then
        self.cd_timer:Stop()
        self.cd_timer = nil
    end
    if self.up_timer then 
        self.up_timer:Stop() 
        self.up_timer = nil
    end
    self:RemoveListener()
    GameObject.Destroy(self.gameObject)
    self = nil

	 
end

function M:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform,self)
    self.ui_config = M:InitConfig()
	self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
    self:Refresh_JingBi()
end

function M:InitConfig()
    local cfg_order = MathExtend.SortList(config.game, "order", true)
    local cfg = {}
    for i=1,#cfg_order do
        if cfg_order[i].is_on == 1 then
            cfg[#cfg + 1] = cfg_order[i] 
        end
    end
    return cfg
end

function M:InitUI()
    self.back_btn.onClick:AddListener(function(  )
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        M.Close()
        local parm = {gotoui = "game_MiniGame"}
        GameManager.GotoUI(parm)
    end)

    self.help_btn.onClick:AddListener(function(  )
        QHBHelpPanel.Create()
    end)
    self.AddGold_btn.onClick:AddListener(function(  )
        PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
    end)
    local temp_ui = {}
    local now_time  = os.time()
    for i=1,#self.ui_config do
        LuaHelper.GeneratingVar(self[self.ui_config[i].prefab_name].gameObject.transform,temp_ui)
        temp_ui.bg_btn.onClick:AddListener(function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if not self.ui_config then return end
            if self.ui_config[i].xz_type then
                for j,v in ipairs(self.ui_config[i].xz_type) do
                    local c = self.ui_config[i].xz_count[j]
                    local val = GameItemModel.GetItemCount(v)
                    local item = GameItemModel.GetItemToKey(v)
                    if not val or c > val then
                        if v == "jing_bi" then
                            HintPanel.Create(2,string.format( "需要携带%s鲸币才可入场\n是否前往商城",StringHelper.ToCash(c)),function(  )
                                PayPanel.Create(GOODS_TYPE.jing_bi)
                            end)
                        elseif v == "shop_gold_sum" then
                            HintPanel.Create(2,string.format( "需要携带%s红包才可入场\n是否前往商城",c / 100),function(  )
                                PayPanel.Create(GOODS_TYPE.jing_bi)
                            end)
                        elseif v == "cash" then
                            HintPanel.Create(2,string.format( "需要携带%s现金才可入场\n是否前往商城",c / 100),function(  )
                                PayPanel.Create(GOODS_TYPE.jing_bi)
                            end)
                        else
                            HintPanel.Create(2,string.format( "需要携带%s%s才可入场\n是否前往商城",c,item.name),function(  )
                                PayPanel.Create(GOODS_TYPE.jing_bi)
                            end)
                        end
                        return
                    end
                end
            end

            if self.ui_config[i].permission then
                local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key= self.ui_config[i].permission, is_on_hint = false}, "CheckCondition")
                if a and not b then
                    return
                end
            end
            dump({id = self.ui_config[i].game_id}, "<color=white>报名</color>")
            GameManager.CommonGotoScence({gotoui="qhb", p_requset={id = self.ui_config[i].game_id}}, function ()
                M.Close()
            end)
        end)

        if (self.ui_config[i].s_time == -1 or now_time > self.ui_config[i].s_time) and (self.ui_config[i].e_time == -1 or now_time < self.ui_config[i].e_time) then 
            self[self.ui_config[i].prefab_name].gameObject:SetActive(true)
        else
            self[self.ui_config[i].prefab_name].gameObject:SetActive(false)
        end
    end

    if self.hb_timer then
        self.hb_timer:Stop()
    end
    self.hb_timer = Timer.New(function ()
        Network.SendRequest("qhb_hb_all_award", nil, "")
        local now_time  = os.time()
        for i=1,#self.ui_config do    
            if (self.ui_config[i].s_time == -1 or now_time > self.ui_config[i].s_time) and (self.ui_config[i].e_time == -1 or now_time < self.ui_config[i].e_time) then 
                self[self.ui_config[i].prefab_name].gameObject:SetActive(true)
            else
                self[self.ui_config[i].prefab_name].gameObject:SetActive(false)
            end
        end
    end,3,-1,true)

    if self.cd_timer then
        self.cd_timer:Stop()
    end
    self.cd_timer = Timer.New(function ()
        if self.timeout then
            local countdown = self.timeout - os.time()
            if countdown >= 0 then
                self.time_txt.text = StringHelper.formatTimeDHMS(countdown)
            else
                self.time_txt.text = "--"
            end
        end
    end,1,-1,true)

    if QHBHallLogic.switch.hby then
        self.hb_timer:Start()
        Network.SendRequest("qhb_hb_all_award", nil, "")
        self.cd_timer:Start()
        self.hby.gameObject:SetActive(true)
    else
        self.hby.gameObject:SetActive(false)
    end
end

function M:qhb_hb_all_award_response(_,data)
    -- dump(data, "<color=yellow>qhb_hb_all_award_response</color>")
    if data.result ~= 0 then
        HintPanel.ErrorMsg(data.result)
        return
    end
    if not data.award then data.award = 0 end
    if data.award < 999999999 then
        if not self.award then self.award = data.award end
        if self.award < data.award then
            if self.up_timer then 
                self.up_timer:Stop() 
                self.up_timer = nil
            end
            local cur_award = self.award
            self.up_timer = Timer.New(function(  )
                cur_award = cur_award + 1
                self.award_txt.text = cur_award
                if cur_award == data.award then
                    if self.up_timer then 
                        self.up_timer:Stop() 
                        self.up_timer = nil
                    end
                end
            end,0.001,-1)
            self.up_timer:Start()
            self.up_timer:SetStopCallBack(function(  )
                self.award_txt.text = data.award
            end)
        else
            self.award_txt.text = data.award
        end
    else
        if self.up_timer then 
            self.up_timer:Stop() 
            self.up_timer = nil
        end
        self.award_txt.text = "999999999"
        self.award_add.gameObject:SetActive(true)
    end
    self.award = data.award
    self.timeout = data.time
    -- if data.time then
    --     self.time_txt.text = StringHelper.formatTimeDHMS(data.time - os.time())
    -- end
end

function M:OnAssetChange()
    self:Refresh_JingBi()
end

function M:OnExitScene()
    M.Close()
end

function M:Refresh_JingBi()
    self.shop_gold_txt.text =  StringHelper.ToCash(MainModel.UserInfo.jing_bi)
end

function M.IsSysScene(game_id)
    if game_id then
        return game_id == 41
    end
end