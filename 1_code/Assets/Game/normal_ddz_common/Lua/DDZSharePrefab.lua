-- 创建时间:2018-08-20

local basefunc = require "Game.Common.basefunc"

DDZSharePrefab = basefunc.class()

local shareStyle=
{
    [1] = "%s倍，简直逆天啦！",
    [2] = "%s倍，牛逼不牛逼？",
    [3] = "%s倍，谁敢跟我比？",
}

-- parm={myseatno, dzseatno, bei, settlement}
function DDZSharePrefab.Create(game_id, parm, finishcall)
    return DDZSharePrefab.New(game_id, parm, finishcall)
end

function DDZSharePrefab:ctor(game_id, parm, finishcall)
    dump(parm, "<color=red>DDZSharePrefab parm</color>")
    self.parm = parm
	self.game_id = game_id
    self.finishcall = finishcall
	local parent = GameObject.Find("Canvas/LayerLv4")
    self.gameObject = newObject("DDZSharePrefab", parent.transform)
    self.transform = self.gameObject.transform
    local tran = self.transform

    self.BackButton = tran:Find("BackButton"):GetComponent("Button")
    self.BackButton.onClick:AddListener(function ()
        self:OnBackClick()
    end)
    self.HYButton = tran:Find("HYButton"):GetComponent("Button")
    self.PYQButton = tran:Find("PYQButton"):GetComponent("Button")
	self.HYButton.onClick:AddListener(function ()
        self:OnHYClick()
    end)
	self.PYQButton.onClick:AddListener(function ()
        self:OnPYQClick()
    end)
    self.HYButton.gameObject:SetActive(true)
    self.PYQButton.gameObject:SetActive(false)
    self.HYButton.transform.localPosition = Vector3.New(0, -455, 0)

    self.HintImage = tran:Find("HintImage")
    self.HintImage.gameObject:SetActive(false)
    self.BGImage = tran:Find("Image"):GetComponent("Image")
    self.HeadImage = tran:Find("Image/HeadImage"):GetComponent("Image")
    self.HeadFrame = tran:Find("Image/HeadFrame"):GetComponent("Image")
    self.head_vip_txt = tran:Find("Image/@head_vip_txt"):GetComponent("Text")
    self.NameText = tran:Find("Image/NameText"):GetComponent("Text")
    self.EWMImage = tran:Find("Image/EWMImage"):GetComponent("Image")
    self.LogoImage = tran:Find("Image/EWMImage/LogoImage"):GetComponent("Image")
	self.DescText = tran:Find("Image/Node/DescText"):GetComponent("Text")
    self.MoneyText = tran:Find("Image/Image/MoneyText"):GetComponent("Text")
    self.RedText = tran:Find("Image/Image/RedText"):GetComponent("Text")

    self.node1 = tran:Find("Image/node1"):GetComponent("RectTransform")
    self.node2 = tran:Find("Image/node2"):GetComponent("RectTransform")
    self.ImageBG = tran:Find("Image"):GetComponent("RectTransform")
    self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")

    self.GameText = tran:Find("Image/GameText"):GetComponent("Text")
    self.ExitTimeText = tran:Find("Image/ExitTimeText"):GetComponent("Text")
    self.YQImage = tran:Find("Image/YQImage"):GetComponent("RectTransform")
    self.JSImage = tran:Find("Image/JSImage"):GetComponent("RectTransform")
    self.GYImage = tran:Find("Image/GYImage"):GetComponent("RectTransform")

    self.YQText = tran:Find("Image/YQImage/YQText"):GetComponent("Text")
    self.JSText = tran:Find("Image/JSImage/JSText"):GetComponent("Text")
    self.GYText = tran:Find("Image/GYImage/GYText"):GetComponent("Text")
    self.RankText = tran:Find("Image/Text1/RankText"):GetComponent("Text")

    self:InitUI()
end
function DDZSharePrefab:ShowBack(b)
    if IsEquals(self.HYButton) then
	self.HYButton.gameObject:SetActive(b)
    end
    if IsEquals(self.BackButton) then
	self.BackButton.gameObject:SetActive(b)
    end
end
function DDZSharePrefab:InitUI()
	self:ShowBack(false)
    self.NameText.text = MainModel.UserInfo.name
    URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.HeadImage)

    PersonalInfoManager.SetHeadFarme(self.HeadFrame)
    VIPManager.set_vip_text(self.head_vip_txt)

    local v = GameFreeModel.GetGameIDToConfig(self.game_id)
    if v.game_type == "game_DdzFree" then
        self.GameText.text = "经典斗地主" .. v.game_name
    elseif v.game_type == "game_DdzLaizi" then
        self.GameText.text = "癞子斗地主" .. v.game_name
    elseif v.game_type == "game_DdzTy" then
        self.GameText.text = "听用斗地主" .. v.game_name
    elseif v.game_type == "game_DdzFreeER" then
        self.GameText.text = "经典斗地主二人场" .. v.game_name
    else
        self.GameText.text = ""
    end
    self.ExitTimeText.text = os.date("%Y.%m.%d %H:%M", self.parm.gameExitTime)
    self:RandomShareStyle()

    if self.parm.settlement.award and self.parm.myseatno and self.parm.settlement.award[self.parm.myseatno] then
        local mm = self.parm.settlement.award[self.parm.myseatno]
        self.MoneyText.text = StringHelper.ToCashSymbol(mm)
        self.RedText.text = StringHelper.ToRedNum(mm/10000) .. "元"
    else
        self.MoneyText.text = "+0"
        self.RedText.text = "0元"
    end
    self:InitShare()
    self:CalcScore()
    self:RunAnim()
    self:MakeLister()
    self:AddLister()
    HandleLoadChannelLua("DDZSharePrefab", self)
    Event.Brocast("ddz_free_clearing_close_share",{panel_self = self})
end

function DDZSharePrefab:MakeLister()
    self.lister = {}
    self.lister["screen_shot_end"] = basefunc.handler(self, self.screen_shot_end)
    self.lister["screen_shot_begin"] = basefunc.handler(self, self.screen_shot_begin)
    self.lister["query_everyday_shared_award_response"] = basefunc.handler(self, self.query_everyday_shared_award_response)
end

function DDZSharePrefab:AddLister()
	for proto_name,func in pairs(self.lister or {}) do
        Event.AddListener(proto_name, func)
    end
end

function DDZSharePrefab:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = nil
end

function DDZSharePrefab:RandomShareStyle()
    local t = 1
    self.DescText.text = string.format(shareStyle[t], tostring(self.parm.bei))
end
function DDZSharePrefab:ChangeUIFinish()
    if self.animTime then
        self.animTime:Stop()
    end
    self.animTime = nil
    if self.rankanimTime then
        self.rankanimTime:Stop()
    end
    self.rankanimTime = nil

    if IsEquals(self.YQImage) and  IsEquals(self.JSImage) and IsEquals(self.GYImage) and
        IsEquals(self.RankText) and IsEquals(self.YQText) and IsEquals(self.JSText) and IsEquals(self.GYText) then
        self.YQImage.sizeDelta = {x = 300 * self.shareScore.yq/10, y = 20}
        self.JSImage.sizeDelta = {x = 300 * self.shareScore.js/10, y = 20}
        self.GYImage.sizeDelta = {x = 300 * self.shareScore.gy/10, y = 20}

        self.RankText.text = math.floor(self.shareScore.rank) .. "%"
        self.YQText.text = StringHelper.ToCash(self.shareScore.yq)
        self.JSText.text = StringHelper.ToCash(self.shareScore.js)
        self.GYText.text = StringHelper.ToCash(self.shareScore.gy)
    end
end
function DDZSharePrefab:ChangeUIValue(v)
    local yq = self.shareScore.yq * v
    local js = self.shareScore.js * v
    local gy = self.shareScore.gy * v

    self.YQImage.sizeDelta = {x = 300 * yq/10, y = 20}
    self.JSImage.sizeDelta = {x = 300 * js/10, y = 20}
    self.GYImage.sizeDelta = {x = 300 * gy/10, y = 20}

    self.YQText.text = StringHelper.ToCash(yq)
    self.JSText.text = StringHelper.ToCash(js)
    self.GYText.text = StringHelper.ToCash(gy)
    if v > (self.maxtime - 0.001) then
        if self.animTime then
            self.animTime:Stop()
        end
        self.animTime = nil
        self:RunAnimRank()
    end
end
-- 变化的表现
function DDZSharePrefab:RunAnim()
    self.maxtime = 1 -- 1秒
    self.runtime = 0
    self.steptime = 1/30
    self.animTime = Timer.New(function ()
        self.runtime = self.runtime + self.steptime
        self:ChangeUIValue(self.runtime / self.maxtime)
    end, self.steptime, -1)
    self.animTime:Start()
end

function DDZSharePrefab:ChangeUIValueRank(v)
    local rank = self.shareScore.rank * v

    if IsEquals(self.RankText) then
        self.RankText.text = math.floor(rank) .. "%"
    end
    if v > (self.rankmaxtime - 0.001) then
        if self.rankanimTime then
            self.rankanimTime:Stop()
        end
        self.rankanimTime = nil
        self:ChangeUIFinish()
    end
end
-- 变化的排名
function DDZSharePrefab:RunAnimRank()
    self.rankmaxtime = 1 -- 1秒
    self.rankruntime = 0
    self.ranksteptime = 1/30
    self.rankanimTime = Timer.New(function ()
        self.rankruntime = self.rankruntime + self.ranksteptime
        self:ChangeUIValueRank(self.rankruntime / self.rankmaxtime)
    end, self.ranksteptime, -1)
    self.rankanimTime:Start()
end

function DDZSharePrefab:Close()
    self:RemoveListener()
    if self.animTime then
        self.animTime:Stop()
    end
    self.animTime = nil

    if self.rankanimTime then
        self.rankanimTime:Start()
    end
    self.rankanimTime = nil
	GameObject.Destroy(self.gameObject)
end

function DDZSharePrefab:OnBackClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)

	self:Close()
end
function DDZSharePrefab:OnHYClick()
	self:WeChatShareImage(false)
end
function DDZSharePrefab:OnPYQClick()
	self:WeChatShareImage(true)
end

function DDZSharePrefab:InitShare()
    self.share_cfg = basefunc.deepcopy(share_link_config.img_free_ddz)
    self.qr_code_img = self.EWMImage
    self.head_img = self.LogoImage
    self.icon_img = self.transform:Find("Image/Logo"):GetComponent("Image")
    self.invite_txt = self.transform:Find("Image/@invite_txt"):GetComponent("Text")
    ShareHelper.RefreshQRCode(self.qr_code_img,self.share_cfg)
    ShareHelper.RefreshImage(self.head_img,self.icon_img,self.invite_txt)

    local status = ShareModel.GetQueryEverydaySharedAward(self.share_cfg.finish_type)
    if not status then
        ShareModel.ReqQueryEverydaySharedAward(self.share_cfg.finish_type)
    else
        if IsEquals(self.HintImage) then
            if status >= 1 then
                self.HintImage.gameObject:SetActive(true)
            else
                self.HintImage.gameObject:SetActive(false)
            end                
        end
    end
    self:ShowBack(true)
end

function DDZSharePrefab:WeChatShareImage(isCircleOfFriends)
    self:ChangeUIFinish()
    self.share_cfg.isCircleOfFriends = isCircleOfFriends
    local p1 = self.camera:WorldToScreenPoint(self.node1.position)
    local p2 = self.camera:WorldToScreenPoint(self.node2.position)
    local x = p1.x
    local y = p1.y
    local w = p2.x - p1.x
    local h = p2.y - p1.y
    self.share_cfg.rect = UnityEngine.Rect.New(x, y, w, h)
    GameManager.GotoUI({gotoui = "sys_fx",goto_scene_parm = "image",share_cfg = self.share_cfg})
end

function DDZSharePrefab:CalcScore()
    if self.shareScore then
        return
    end

    local settlement = self.parm.settlement
    dump(settlement, "<color=red>CalcScore</color>")
    local boom = settlement.bomb_count
    if not boom then
        boom = 0
    end
    local chuntian = 0
    if settlement.chuntian > 0 then
        chuntian = 1
    end

    local dzpainum = 0
    local nmpainum = 0
    if settlement.remain_pai then
        for k,v in pairs(settlement.remain_pai) do
            --其他玩家的牌
            if v.p == self.parm.dzseatno then
                dzpainum = dzpainum + #v.pai
            else
                nmpainum = nmpainum + #v.pai
            end
        end
    end
    local num = 0
    if self.parm.myseatno == self.parm.dzseatno then
        num = nmpainum * 0.1
    else
        num = dzpainum * 0.2
    end

    self.shareScore = {}
    local data = {}
    -- 运气指数
    data.yq = 8 + 0.2 * boom + 1 * chuntian
    if data.yq > 10 then
        data.yq = 10
    end

    -- 技术指数
    data.js = 7 + num
    if data.js > 10 then
        data.js = 10
    end

    -- 公益指数
    data.gy = 10 - (20 - data.yq - data.js)/2
    -- 领先比例
    data.rank = 100 - 2 * (30 - data.yq - data.js - data.gy)
    self.shareScore = data
end

function DDZSharePrefab:screen_shot_begin(  )
    AddCanvasAndSetSort(self.gameObject, 100)
    self:ShowBack(false)
end

function DDZSharePrefab:screen_shot_end(  )
    RemoveCanvas(self.gameObject)
    self:ShowBack(true)
end

function DDZSharePrefab:query_everyday_shared_award_response(data)
    if not data or not self.share_cfg or not self.share_cfg.finish_type ~= data.type or not IsEquals(self.HintImage) then return end
    if data.status and data.status >= 1 then
        self.HintImage.gameObject:SetActive(true)
    else
        self.HintImage.gameObject:SetActive(false)
    end
end