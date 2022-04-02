-- 创建时间:2018-12-12

local basefunc = require "Game.Common.basefunc"

SevenDayTaskPrefab = basefunc.class()

local C = SevenDayTaskPrefab

C.name = "SevenDayTaskPrefab"

function C.Create(parent_transform, config)
    -- dump(config, "<color=white>config:</color>")
	return C.New(parent_transform, config)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_stepstep_money_task_change_msg"] = basefunc.handler(self, self.on_model_stepstep_money_task_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:ctor(parent_transform, config)
    self.config = config
    self.cur_index = 0
	local obj = newObject(C.name, parent_transform)
	self.gameObject = obj
	self.transform = obj.transform
	self:MakeLister()
    self:AddMsgListener()

    LuaHelper.GeneratingVar(obj.transform, self)
    self:RefreshCurIndex(true)
    self:InitUI()
    self:RefreshUI()
end

function C:InitUI()
    self.icon_btn = self.item_icon_img.transform:GetComponent("Button")
    PointerEventListener.Get(self.icon_btn.gameObject).onDown = function ()
        local pos = UnityEngine.Input.mousePosition
        local tips = self.cur_config and self.cur_config.tips or ""
        GameTipsPrefab.ShowDesc(tips, pos, GameTipsPrefab.TipsShowStyle.TSS_34)
    end
    PointerEventListener.Get(self.icon_btn.gameObject).onUp = function ()
        GameTipsPrefab.Hide()
    end
    
    self.more_btn.onClick:AddListener(
        function()
            self:RefreshCurIndex()
            self:RefreshUI()
            self:PlayAnimRefresh(0.02)
        end
    )
    self.goto_btn.onClick:AddListener(
        function()
            dump(self.cur_config, "<color=yellow>self.cut_config</color>")
            self:OnClickGoto(self.cur_config.gotoUI)
        end
    )
    self.get_btn.onClick:AddListener(
        function()
            self:OnClickGet(self.config[self.cur_index])
        end
    )
end

function C:RefreshUI()
    -- dump(self.cur_config, "<color=yellow>cur_config::>>>>>>>>>>>>>></color>")
    if not self.cur_config then return end
    self.item_icon_img.sprite = GetTexture(self.cur_config.icon_image)
    if ActivitySevenDayModel.IsNewVersion() then

	local v = self.cur_config.award_num - math.floor(self.cur_config.award_num)
	if v > 0 then
		self.item_icon_txt.text = string.format( "%3.1f", self.cur_config.award_num)
	else
		self.item_icon_txt.text = string.format( "%d", self.cur_config.award_num)
	end
    else
	self.item_icon_txt.text = string.format( "%.2f元", self.cur_config.award_num)
    end
    if IsEquals(self.task_info_txt) then
        self.task_info_txt.text = self.cur_config.desc
    end
    if self.cur_config.award_status == 2 then
        self.progress_txt.text = ""
    else
        self.progress_txt.text = string.format( "%s/%s", StringHelper.ToCash(self.cur_config.now_process),StringHelper.ToCash(self.cur_config.need_process))
    end
    self.goto_btn.gameObject:SetActive(false)
    self.get_btn.gameObject:SetActive(false)
    self.over.gameObject:SetActive(false)
    self.not_on_btn.gameObject:SetActive(false)
    if self.cur_config.award_status == 0 then
        self.goto_btn.gameObject:SetActive(true)
    elseif self.cur_config.award_status == 1 then
        self.get_btn.gameObject:SetActive(true)
    elseif self.cur_config.award_status == 2 then
        self.over.gameObject:SetActive(true)
    elseif self.cur_config.award_status == 3 then
        self.not_on_btn.gameObject:SetActive(true)
    end
    self.more_btn.gameObject:SetActive(self.show_more_btn)
end

function C:RefreshCurIndex(is_check_process)
    -- self.more_btn.gameObject:SetActive(#self.config > 1)
    self.show_more_btn = #self.config > 1
    if self.show_more_btn then
        local pre_process = 0
        local cur_process = 0
        for i,v in ipairs(self.config) do
            local cur_config = ActivitySevenDayModel.GetTaskToID(v)
            if cur_config.award_status == 1 or cur_config.award_status == 2 then
                self.show_more_btn = false
                self.cur_index = i - 1
                break
            end
            if is_check_process then
                --未完成
                if cur_config.award_status == 0 then
                    if cur_config.now_process and cur_config.now_process ~= 0 and cur_config.need_process then
                        cur_process = cur_config.now_process / cur_config.need_process
                        if cur_process > pre_process then
                            self.cur_index = i - 1
                        end
                        pre_process = cur_process
                    end
                end
            end
        end
    end
    self:RefreshCurConfig()
end

function C:RefreshCurConfig()
    self.cur_index = self.cur_index + 1
    if self.cur_index > #self.config then
        self.cur_index = 1
    end
    self.cur_config = ActivitySevenDayModel.GetTaskToID(self.config[self.cur_index])
    self.cur_index = self.cur_index
end

function C:MyExit()
    self:RemoveListener()
end

function C:OnDestroy()
	self:MyExit()
	GameObject.Destroy(self.gameObject)
end

function C:PlayAnimIn(t)
    self.UINode.transform.localPosition = Vector3.New(1600, 0, 0)
    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:AppendInterval(t)
    -- self.UINode.gameObject:SetActive(true)
    seq:Append(self.UINode.transform:DOLocalMoveX(0, 0.2):SetEase(DG.Tweening.Ease.Linear))--OutBack

    seq:OnKill(
        function()
            DOTweenManager.RemoveStopTween(tweenKey)
            if IsEquals(self.UINode) then
                self.UINode.transform.localPosition = Vector3.New(0, 0, 0)
                self.UINode.gameObject:SetActive(true)
            end
        end
    )

end

function C:PlayAnimOut(t)
    self.UINode.transform.localPosition = Vector3.New(0, 0, 0)
    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:AppendInterval(t)
    seq:Append(self.UINode.transform:DOLocalMoveX(1600, 0.2):SetEase(DG.Tweening.Ease.Linear))--OutBack

    seq:OnComplete(
        function()
            if IsEquals(self.UINode) then
                self.UINode.transform.localPosition = Vector3.New(1600, 0, 0)
                self:OnDestroy()
            end
        end
    )

    seq:OnKill(
        function()
            DOTweenManager.RemoveStopTween(tweenKey)
            if IsEquals(self.UINode) then
                self.UINode.transform.localPosition = Vector3.New(1600, 0, 0)
                self:OnDestroy()
            end
        end
    )
end

function C:PlayAnimRefresh(t)
    self.UINode.transform.localPosition = Vector3.New(0, 0, 0)
    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:AppendInterval(t)
    seq:Append(self.UINode.transform:DOLocalMoveX(1600, 0.2):SetEase(DG.Tweening.Ease.Linear))--OutBack
    seq:Append(self.UINode.transform:DOLocalMoveX(0, 0.2):SetEase(DG.Tweening.Ease.Linear))--OutBack

    seq:OnComplete(
        function()
            if IsEquals(self.UINode) then
                self.UINode.transform.localPosition = Vector3.New(0, 0, 0)
            end
        end
    )

    seq:OnKill(
        function()
            DOTweenManager.RemoveStopTween(tweenKey)
            if IsEquals(self.UINode) then
                self.UINode.transform.localPosition = Vector3.New(0, 0, 0)
            end
        end
    )
end

-- 点击goto
function C:OnClickGoto(gotoUI)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    dump(gotoUI, "<color=yellow>goto ui</color>")
    if gotoUI then
        local goto_pos = gotoUI[1]
        local goto_parm  = gotoUI[2]
        GameManager.GotoUI({gotoui=goto_pos, goto_scene_parm=goto_parm})
    end
end

-- 点击Get
function C:OnClickGet(id)
    print("<color=green>领取奖励</color>",id)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    Network.SendRequest("get_stepstep_money_task_award", {id = id},"领取奖励")
end

function C:SetItemIconTxtVisible(v)
	if IsEquals(self.item_icon_txt) then
		self.item_icon_txt.gameObject:SetActive(v)
	end
end

function C:on_model_stepstep_money_task_change_msg(id)
    print("<color=yellow>id : </color>",id)
    for i,v in ipairs(self.config) do
        if v == id then
            self.cur_config = ActivitySevenDayModel.GetTaskToID(id)
            self:RefreshCurIndex()
            self:RefreshUI()
            self:PlayAnimRefresh(0.02)
        end
    end
end