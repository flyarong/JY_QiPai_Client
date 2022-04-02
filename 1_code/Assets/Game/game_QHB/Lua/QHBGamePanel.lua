local basefunc = require "Game.Common.basefunc"
QHBGamePanel = basefunc.class()
local M = QHBGamePanel
M.name = "QHBGamePanel"
local lister
local listerRegisterName = "QHBGameListerRegister"

local instance
--******************框架
function M.Create()
    instance = M.New()
    return instance
end

function M:ctor()
    ExtendSoundManager.PlaySceneBGM(audio_config.qhb.bgm_qhb_beijing.audio_name)
    local parent = GameObject.Find("Canvas/GUIRoot").transform
	self.gameObject = newObject(M.name, parent)
	self.transform = self.gameObject.transform
    LuaHelper.GeneratingVar(self.transform, self)
    self.updateTimer = Timer.New(basefunc.handler(self, self.update_callback), 1, -1, true)
    self.updateTimer:Start()
    self:MyInit()
end

function M:MyInit()
    self.hb_send_btn.gameObject:SetActive(false)
    self.num_btn.gameObject:SetActive(false)
    self:MakeLister()
    QHBLogic.setViewMsgRegister(lister, listerRegisterName)
    EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.CloseCB)
    EventTriggerListener.Get(self.help_btn.gameObject).onClick = basefunc.handler(self, self.HelpCB)
    EventTriggerListener.Get(self.hb_send_btn.gameObject).onClick = basefunc.handler(self, self.HBSendCB)
    EventTriggerListener.Get(self.hb_history_btn.gameObject).onClick = basefunc.handler(self, self.HBHistoryCB)
    EventTriggerListener.Get(self.jb_btn.gameObject).onClick = basefunc.handler(self, self.PayCB)
    EventTriggerListener.Get(self.add_btn.gameObject).onClick = basefunc.handler(self, self.PayCB)
    self.sv_sr = self.sv.transform:GetComponent("ScrollRect")
    --滑动
	EventTriggerListener.Get(self.sv_sr.gameObject).onEndDrag = function()
        local VNP = self.sv_sr.horizontalNormalizedPosition
		if VNP <= 0 then
			QHBModel.request_qhb_hb_info_first()
		end
    end
end

function M:MyRefresh()
    if QHBModel.data then
        local m_data = QHBModel.data
        if m_data.countdown then
            self.countdown = math.floor(m_data.countdown)
        end
        if QHBModel.IsSysScene() then
            QHBModel.request_qhb_get_qhb_data()
            self.num_btn.gameObject:SetActive(true)
            self.hb_send_btn.gameObject:SetActive(false)
        else
            self.num_btn.gameObject:SetActive(false)
            self.hb_send_btn.gameObject:SetActive(true)
        end
        local name_img_t = {
            [41] = "qhb_imgf_zcjb",
            [42] = "qhb_imgf_jymt",
            [43] = "qhb_imgf_fjyf",
        }
        local sp = name_img_t[m_data.game_id] or "qhb_imgf_zcjb"
        self.name_img.sprite = GetTexture(sp)
    end
    self:RefreshAsset()
end

function M:MyExit()
    if self.updateTimer then
        self.updateTimer:Stop()
        self.updateTimer = nil
    end
    QHBAwardPanel.Close()
    QHBHistoryPanel.Close()
    QHBDetailPanel.Close()
    QHBSendPanel.Close()
    QHBGetPanel.Close()
    QHBLogic.clearViewMsgRegister(listerRegisterName)
    closePanel(M.name)
end

function M:MyClose()
    self:MyExit()
end

function M:MakeLister()
    lister = {}
    lister["model_qhb_hb_send_msg"] = basefunc.handler(self, self.qhb_hb_send_msg)
    lister["model_qhb_hb_change_msg"] = basefunc.handler(self, self.qhb_hb_change_msg)
    lister["model_qhb_my_hb_change_msg"] = basefunc.handler(self, self.qhb_my_hb_change_msg)
    lister["model_qhb_hb_info_response"] = basefunc.handler(self, self.qhb_hb_info_response)
    lister["model_qhb_hb_detail_response"] = basefunc.handler(self, self.qhb_hb_detail_response)
    lister["model_qhb_hb_get_response"] = basefunc.handler(self, self.qhb_hb_get_response)
    lister["model_qhb_get_qhb_data_response"] = basefunc.handler(self, self.qhb_get_qhb_data_response)
    lister["AssetChange"] = basefunc.handler(self, self.AssetChange)
end

function M:qhb_hb_info_response(hb_datas)
    dump(hb_datas, "<color=blue>qhb_hb_info_response</color>")
    QHBHBManager.Refresh(hb_datas)
    -- self.sv_sr.verticalNormalizedPosition = -0
end

function M:qhb_get_qhb_data_response(player_hb_data)
    if not QHBModel.IsSysScene() or not player_hb_data then return end
    self.num_txt.text = string.format( "今日可抢：%s 次",player_hb_data.total_num - player_hb_data.use_num)
end

function M:qhb_hb_get_response(data)
    dump(data, "<color=blue>qhb_hb_get_response</color>")
    if data.result == 0 then
        --抢红包成功
        QHBAwardPanel.Create(data)
    else
        --抢红包失败
        -- QHBDetailPanel.Create(data.hb_id)
        local msg = errorCode[data.result] or ("错误：".. data.result)
        LittleTips.CreateSP(msg)
    end
end

function M:qhb_hb_detail_response(detail_data)
    dump(detail_data, "<color=blue>qhb_hb_detail_response</color>")
    QHBHBManager.RefreshHB(detail_data.hb_data)
end

function M:qhb_hb_send_msg(hb_datas)
    for k,v in ipairs(hb_datas) do
        QHBHBManager.AddHB(v)
    end
end

function M:qhb_hb_change_msg(hb_data)
    QHBHBManager.RefreshHB(hb_data)
end

function M:qhb_my_hb_change_msg(get_data)
    dump(get_data, "<color=white>自己的红包改变</color>")
    local str
    if get_data.timeout and get_data.timeout == 1 then
        --过期
        str = string.format( "您的红包已过期\n共有 %s 个人抢，其中 %s 个人踩雷。\n如有未被抢的金额将自动给您退回。",get_data.geted_count,get_data.boom_num)
        LittleTips.CreateSP(str)
        return
    end

    if get_data.total_count == get_data.geted_count then
        --领取完成
        str = string.format( "您的红包已经被抢完了\n共有 %s 个人抢，其中 %s 个人踩雷。",get_data.geted_count,get_data.boom_num)
        LittleTips.CreateSP(str)
        return
    end

    local jb = get_data.award_asset.value
    local name = basefunc.deal_hide_player_name(get_data.name)
    if get_data.boom and get_data.boom == 1 then
        --踩雷
        local boom_count = get_data.boom_asset.value
        str = string.format( "<size=60>%s 在您的红包里抢到了 %s 鲸币\n但踩到了雷点，<color=red>系统奖励您 %s 鲸币</color></size>",name,jb,boom_count)
        LittleTips.CreateSP1(str)    
        return
    else
        str = string.format( "%s 在您的红包里抢到了 %s 鲸币",name,jb)
    end
    LittleTips.CreateSP(str)
end

function M:RefreshAsset()
    self.jb_txt.text = string.format( "%s",StringHelper.ToCash(MainModel.UserInfo.jing_bi))
end

function M:AssetChange(asset_data)
    if not asset_data then return end
    self:RefreshAsset()
end

function M:update_callback()
    local dt = 1
    if self.countdown and self.countdown > 0 then
        self.countdown = self.countdown - dt
    end
end

function M:HBSendCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if QHBModel.IsSysScene() then return end
    QHBSendPanel.Create()
end

function M:HBHistoryCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    QHBHistoryPanel.Create()
end

--退出
function M:CloseCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    QHBModel.request_qhb_quit_game()
end

--帮助
function M:HelpCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    QHBHelpPanel.Create()
end

--购买
function M:PayCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    PayPanel.Create(GOODS_TYPE.jing_bi)
end