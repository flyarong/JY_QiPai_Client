MatchHallPanel = basefunc.class()
local M = MatchHallPanel
M.name = "MatchHallPanel"
local dotweenlayer = "MatchHallPanel"
local instance
local lister
local listerRegisterName = "MatchHallListerRegister"
function M.Create(parm)
    if not instance then
        DSM.PushAct({panel = M.name})
        instance = M.New(parm)
    else
        instance:MyRefresh(parm)
    end
    return instance
end

function M:ctor(parm)

	ExtPanel.ExtMsg(self)
    self.dot_del_obj = true

    self.parm = parm
    local parent = GameObject.Find("Canvas/GUIRoot").transform
    local obj = newObject(M.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    local btn_map = {}
	btn_map["top1"] = {self.btnNode}
	btn_map["top2"] = {self.btn2Node}
	btn_map["top3"] = {self.btn3Node}
	btn_map["top4"] = {self.btn4Node}
	btn_map["top5"] = {self.btn5Node}
	btn_map["top6"] = {self.btn6Node}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "match_hall")
    self:MyInit()
    self:MyRefresh()
    Event.Brocast("JBS_Created")
end

function M:MyInit()
    ExtendSoundManager.PlaySceneBGM(audio_config.match.bgm_bisai_bisaidengdai.audio_name)
    self:MakeLister()
    MatchHallLogic.setViewMsgRegister(lister, listerRegisterName)
    EventTriggerListener.Get(self.hall_back_btn.gameObject).onClick = basefunc.handler(self, self.OnClickBackMatch)
    EventTriggerListener.Get(self.shop_btn.gameObject).onClick = basefunc.handler(self, self.OnClickShoping)
    EventTriggerListener.Get(self.duihuan_btn.gameObject).onClick = basefunc.handler(self, self.OnClickStore)
    self:InitContent()
    self:InitTge()
    self:GameGlobalOnOff()
end

function M:MyRefresh()
    self:UpdateAssetInfo()
    self:OpenUIAnim()
end

function M:MyExit()
    if instance then
        DOTweenManager.KillAllLayerTween(dotweenlayer)
        MatchHallLogic.clearViewMsgRegister(listerRegisterName)
        MatchHallContent.Close()
        instance = nil
        MatchHallDetailPanel.Close()
        if self.game_btn_pre then
            self.game_btn_pre:MyExit()
        end
    end 
end

function M:MyClose()
    self:MyExit()
    DSM.PopAct()
    closePanel(M.name)
end

function M:MakeLister()
    lister = {}
    lister["AssetChange"] = basefunc.handler(self, self.UpdateAssetInfo)
end

--************方法
-- 界面打开的动画
function M:OpenUIAnim()
    local Ease = DG.Tweening.Ease.InOutQuart
    local tt = 0.2
    local tt2 = 0.15
    local tt3 = 0.15

    self.RectTop.transform.localPosition = Vector3.New(0, 150, 0)
    self.LeftNode.transform.localPosition = Vector3.New(-1200, -67.5, 0)

    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToLayer(seq, dotweenlayer)
    seq:Append(self.RectTop.transform:DOLocalMoveY(-86, tt):SetEase(Ease))
    seq:Append(self.LeftNode.transform:DOLocalMoveX(-763, tt3):SetEase(Ease))

    seq:OnComplete(
        function()
            self:OpenUIAnimFinish()
        end
    )
    seq:OnKill(
        function()
            DOTweenManager.RemoveLayerTween(tweenKey, dotweenlayer)            
        end
    )
end

function M:OpenUIAnimFinish()
    self.RectTop.transform.localPosition = Vector3.New(0, -86, 0)
    self.LeftNode.transform.localPosition = Vector3.New(-763, -67.5, 0)
    if GuideLogic then
        GuideLogic.CheckRunGuide("match_hall")
    end
end

function M.SetTgeByID(tge_id)
    dump(instance, "<color=yellow>SetTgeByID</color>")
    if instance then
        MatchHallTge.SetTgeIsOn(tge_id)
    end
end

function M:GameGlobalOnOff()
    if GameGlobalOnOff.Exchange then
        self.duihuan_btn.gameObject:SetActive(true)
    else
        self.duihuan_btn.gameObject:SetActive(false)
    end

    if GameGlobalOnOff.MatchUrgencyClose then
        HintPanel.Create(1, "比赛正在升级，请耐心等待，升级完毕后会通过邮件告知，请注意查看邮件", function ()
            MainLogic.GotoScene("game_Hall")
        end)
    end
end

-- 刷新钱
function M:UpdateAssetInfo()
    self.ticker_num_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
    self.red_packet_txt.text = StringHelper.ToRedNum(MainModel.GetHBValue())
end

function M.UpdateRightUI(cfg)
    MatchHallContent.Refresh(cfg)
end

--Tge
function M:InitTge()
    local config = MatchModel.GetHall()
    MatchHallTge.Create(self.LeftNode,config)
    local hall_type = MatchModel.GetCurHallType()
    local cfg = MatchModel.GetHallTypeCfg()
    if cfg[hall_type] and cfg[hall_type].is_on_off == 0 or cfg[hall_type].is_show == 0 then
        --此标签已关闭
        for i,v in ipairs(config) do
            if v.is_on_off == 1 and v.is_show == 1 then
                hall_type = v.hall_type
                break
            end
        end
    end
    MatchHallTge.SetTgeIsOn(hall_type)
end

--Content
function M:InitContent()
    MatchHallContent.Create(self.RightNode)
end

--OnClick**********************************
function M:OnClickBackMatch(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    MainLogic.GotoScene("game_Hall")
end

function M:OnClickShoping(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    DSM.PushAct({button = "pay_btn"})
    PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end

function M:OnClickStore(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    MainModel.OpenDH()
end

--[[
    GetPrefab("MatchHallContent")
    GetPrefab("MatchHallDHItem")
]]