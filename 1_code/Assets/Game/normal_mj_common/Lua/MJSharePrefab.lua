-- 创建时间:2018-08-16

local basefunc = require "Game.Common.basefunc"

MJSharePrefab = basefunc.class()

local paiTypeImage = 
{
    qing_yi_se = {image="share_icon_11", score=1},
    da_dui_zi = {image="share_icon_2", score=0.6},
    qi_dui = {image="share_icon_14", score=1.1},
    long_qi_dui = {image="share_icon_7", score=1.3},
    jiang_dui= {image="share_icon_5", score=1.4},
    men_qing = {image="share_icon_13", score=0.7},
    zhong_zhang = {image="share_icon_16", score=0.8},
    jin_gou_diao = {image="share_icon_6", score=1.2},
    yao_jiu = {image="share_icon_15", score=0.9},
    ping_hu = {image="share_icon_17", score=0.5},
}
local huTypeImage = 
{
    hai_di_ly = {text="海底捞", score=0},
    hai_di_pao = {text="海底炮", score=0},
    tian_hu = {text="天胡", score=0.3},
    di_hu = {text="地胡", score=0.3},
    gang_shang_hua = {text="杠上花", score=0},
    gang_shang_pao = {text="杠上炮", score=0},
    zimo = {text="自摸", score=0},
    pao = {text="点炮胡", score=0},
    qghu = {text="抢杠胡", score=0},
}
-- 胡牌类型 pai的值
-- parm={paiType="", huType="", pai={1,2,3,...}, geng,huindex}
local instance = nil
function MJSharePrefab.Create(game_id, parm, finishcall)
    if not instance then
        instance = MJSharePrefab.New(game_id, parm, finishcall)
    end

    return instance
end

function MJSharePrefab:ctor(game_id, parm, finishcall)
    dump(parm, "<color=red>MJSharePrefab parm</color>")
    self.parm = parm
	self.game_id = game_id
    self.finishcall = finishcall
	local parent = GameObject.Find("Canvas/LayerLv4")
    self.gameObject = newObject("MJSharePrefab", parent.transform)
    self.transform = self.gameObject.transform
    local tran = self.transform

    self.HintImage = tran:Find("HintImage")
    self.HintImage.gameObject:SetActive(false)
    
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

    self.HeadImage = tran:Find("Image/HeadImage"):GetComponent("Image")
    self.HeadFrame = tran:Find("Image/HeadFrame"):GetComponent("Image")
    self.head_vip_txt = tran:Find("Image/@head_vip_txt"):GetComponent("Text")
    self.NameText = tran:Find("Image/NameText"):GetComponent("Text")
    self.EWMImage = tran:Find("Image/EWMImage"):GetComponent("Image")
    self.LogoImage = tran:Find("Image/EWMImage/LogoImage"):GetComponent("Image")

    self.CardNode = tran:Find("Image/CardNode")
    self.peng = tran:Find("Image/CardNode/peng")
    self.minggang = tran:Find("Image/CardNode/minggang")
    self.angang = tran:Find("Image/CardNode/angang")
    self.pai = tran:Find("Image/CardNode/pai")

    self.HUText = tran:Find("Image/HUText"):GetComponent("Text")
    self.TimeText = tran:Find("Image/TimeText"):GetComponent("Text")
    self.node1 = tran:Find("Image/node1"):GetComponent("RectTransform")
    self.node2 = tran:Find("Image/node2"):GetComponent("RectTransform")
    self.ImageBG = tran:Find("Image"):GetComponent("RectTransform")
    self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")

    self.GameText = tran:Find("Image/GameText"):GetComponent("Text")
    self.MoneyText = tran:Find("Image/Image/MoneyText"):GetComponent("Text")
    self.RedText = tran:Find("Image/Image/RedText"):GetComponent("Text")

    self.YQImage = tran:Find("Image/YQImage"):GetComponent("RectTransform")
    self.JSImage = tran:Find("Image/JSImage"):GetComponent("RectTransform")
    self.GYImage = tran:Find("Image/GYImage"):GetComponent("RectTransform")

    self.YQText = tran:Find("Image/YQImage/YQText"):GetComponent("Text")
    self.JSText = tran:Find("Image/JSImage/JSText"):GetComponent("Text")
    self.GYText = tran:Find("Image/GYImage/GYText"):GetComponent("Text")
    self.RankText = tran:Find("Image/Text1/RankText"):GetComponent("Text")

    if not self.parm.rank then
        self.parm.rank = 100
    end
    if not self.parm.yq then
        self.parm.yq = 10
    end
    if not self.parm.js then
        self.parm.js = 10
    end
    if not self.parm.gy then
        self.parm.gy = 10
    end
    
    self:InitUI()
    self:MakeLister()
    self:AddLister()
end
function MJSharePrefab:ShowBack(b)
    if IsEquals(self.gameObject) then 
        self.HYButton.gameObject:SetActive(b)
        self.BackButton.gameObject:SetActive(b)
    end 
end
function MJSharePrefab:InitUI()
	self:ShowBack(false)
    self.TimeText.text = os.date("%Y.%m.%d %H:%M", self.parm.time)

    local v = GameFreeModel.GetGameIDToConfig(self.game_id)
    if v.game_type == "game_Mj3D" then
        self.GameText.text = "麻将血战到底"
    elseif v.game_type == "game_MjXzER3D" then
        self.GameText.text = "麻将血战二人场"
    elseif v.game_type == "game_MjXl3D" then
        self.GameText.text = "麻将血流成河"
    else
        self.GameText.text = ""
    end

	local pai = self.parm.pai
    self.NameText.text = MainModel.UserInfo.name
    URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.HeadImage)

    PersonalInfoManager.SetHeadFarme(self.HeadFrame)
    VIPManager.set_vip_text(self.head_vip_txt)
    self:ClearCellList()
    if pai.pg_pai then
        for k,v in ipairs(pai.pg_pai) do
            if v.pg_type == MjCard.PaiType.ag then
                local obj = GameObject.Instantiate(self.angang, self.CardNode)
                obj.gameObject:SetActive(true)
                self.CellList[#self.CellList + 1] = obj
                obj.transform:Find("Cell4/Image"):GetComponent("Image").sprite = GetTexture("majiang_" .. v.pai)
            elseif v.pg_type == MjCard.PaiType.zg or v.pg_type == MjCard.PaiType.wg then
                local obj = GameObject.Instantiate(self.minggang, self.CardNode)
                obj.gameObject:SetActive(true)
                self.CellList[#self.CellList + 1] = obj
                for i = 1,4 do
                    obj.transform:Find("Cell"..i.."/Image"):GetComponent("Image").sprite = GetTexture("majiang_" .. v.pai)
                end
            else
                local obj = GameObject.Instantiate(self.peng, self.CardNode)
                obj.gameObject:SetActive(true)
                self.CellList[#self.CellList + 1] = obj
                for i = 1,3 do
                    obj.transform:Find("Cell"..i.."/Image"):GetComponent("Image").sprite = GetTexture("majiang_" .. v.pai)
                end
            end
        end
    end
    if pai.shou_pai then
        local shou_pai = MathExtend.SortList(pai.shou_pai, nil, true)
        for k,v in ipairs(shou_pai) do
            local obj = GameObject.Instantiate(self.pai, self.CardNode)
            obj.gameObject:SetActive(true)
            self.CellList[#self.CellList + 1] = obj
            obj.transform:Find("Cell/Image"):GetComponent("Image").sprite = GetTexture("majiang_" .. v)
        end
    end

    local huPaiType = ""
    local dai_geng_str = ""
    local geng = 0
    if self.parm.multi and next(self.parm.multi) then
        dump(self.parm, "<color=green>self.parm.multi:</color>")
        if self.parm.pai and self.parm.pai.settle_data and self.parm.pai.settle_data.hu_type and self.parm.pai.settle_data.hu_type == "pao" then
            huPaiType = NOR_MAJIANG_HU_TYPE.pao
        end
        if self.parm.multi then
            local multi = self.parm.multi
            if multi["zimo"] then
                huPaiType = NOR_MAJIANG_MULTI_TYPE["zimo"]
            elseif multi["qiangganghu"] then
                huPaiType = NOR_MAJIANG_MULTI_TYPE["qiangganghu"]
            elseif multi["ping_hu"] then
                huPaiType = NOR_MAJIANG_MULTI_TYPE["ping_hu"]
            elseif multi["tian_hu"] then
                huPaiType = NOR_MAJIANG_MULTI_TYPE["tian_hu"]
            elseif multi["di_hu"] then
                huPaiType = NOR_MAJIANG_MULTI_TYPE["di_hu"]
            elseif multi["gang_shang_hua"] then
                huPaiType = NOR_MAJIANG_MULTI_TYPE["gang_shang_hua"]
            elseif multi["gang_shang_pao"] then
                huPaiType = NOR_MAJIANG_MULTI_TYPE["gang_shang_pao"]
            elseif multi["hai_di_ly"] then
                huPaiType = NOR_MAJIANG_MULTI_TYPE["hai_di_ly"]
            elseif multi["hai_di_pao"] then
                huPaiType = NOR_MAJIANG_MULTI_TYPE["hai_di_pao"]
            end

            for k,v in pairs(self.parm.multi) do
                if v then
                    if k == "dai_geng" then
                        geng = v
                        dai_geng_str = NOR_MAJIANG_MULTI_TYPE[k] .. "*" .. math.pow(2, v)
                    else
                        if k ~= "zimo" and k ~= "qiangganghu" and k ~= "ping_hu" and k ~= "tian_hu" and k ~= "di_hu" and 
                            k ~= "gang_shang_hua" and k ~= "gang_shang_pao" and k ~= "hai_di_ly" and k ~= "hai_di_pao" then
                            if huPaiType ~= "" then
                                huPaiType = huPaiType .. "+" .. NOR_MAJIANG_MULTI_TYPE[k]
                            else
                                huPaiType = NOR_MAJIANG_MULTI_TYPE[k]
                            end
                        end
                    end
                end
            end
        end
    else
        huPaiType = NOR_MAJIANG_MULTI_TYPE.ping_hu
    end 
    if geng > 0 then
        if geng > 1 then
            if huPaiType ~= "" then
                huPaiType = huPaiType .. "+带根*" .. geng
            else
                huPaiType = "带根*" .. geng
            end
        else
            if huPaiType ~= "" then
                huPaiType = huPaiType .. "+带根"
            else
                huPaiType = "带根"
            end
        end
    end
    self.HUText.text = huPaiType

    self.MoneyText.text = StringHelper.ToCashSymbol(self.parm.my_score)
    self.RedText.text = StringHelper.ToRedNum(self.parm.my_score/10000) .. "元"

	self:InitShare()
    self:CalcScore()
    self:RunAnim()

    HandleLoadChannelLua("MJSharePrefab", self)
end

function MJSharePrefab:MakeLister()
    self.lister = {}
    self.lister["screen_shot_end"] = basefunc.handler(self, self.screen_shot_end)
    self.lister["screen_shot_begin"] = basefunc.handler(self, self.screen_shot_begin)
    self.lister["query_everyday_shared_award_response"] = basefunc.handler(self, self.query_everyday_shared_award_response)
end

function MJSharePrefab:AddLister()
	for proto_name,func in pairs(self.lister or {}) do
        Event.AddListener(proto_name, func)
    end
end

function MJSharePrefab:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = nil
end

function MJSharePrefab:ClearCellList()
    if self.CellList then
        for k,v in ipairs(self.CellList) do
            GameObject.Destroy(v.gameObject)
        end
    end
    self.CellList = {}
end

function MJSharePrefab:ChangeUIFinish()
    if self.animTime then
        self.animTime:Stop()
    end
    self.animTime = nil
    if self.rankanimTime then
        self.rankanimTime:Stop()
    end
    self.rankanimTime = nil

    self.YQImage.sizeDelta = {x = 300 * self.shareScore.yq/10, y = 20}
    self.JSImage.sizeDelta = {x = 300 * self.shareScore.js/10, y = 20}
    self.GYImage.sizeDelta = {x = 300 * self.shareScore.gy/10, y = 20}

    self.RankText.text = math.floor(self.shareScore.rank) .. "%"
    self.YQText.text = StringHelper.ToCash(self.shareScore.yq)
    self.JSText.text = StringHelper.ToCash(self.shareScore.js)
    self.GYText.text = StringHelper.ToCash(self.shareScore.gy)
end
function MJSharePrefab:ChangeUIValue(v)
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
function MJSharePrefab:RunAnim()
    self.maxtime = 1 -- 1秒
    self.runtime = 0
    self.steptime = 1/30
    self.animTime = Timer.New(function ()
        self.runtime = self.runtime + self.steptime
        self:ChangeUIValue(self.runtime / self.maxtime)
    end, self.steptime, -1)
    self.animTime:Start()
end

function MJSharePrefab:ChangeUIValueRank(v)
    local rank = self.parm.rank * v

    self.RankText.text = math.floor(rank) .. "%"
    if v > (self.rankmaxtime - 0.001) then
        if self.rankanimTime then
            self.rankanimTime:Stop()
        end
        self.rankanimTime = nil
        self:ChangeUIFinish()
    end
end
-- 变化的排名
function MJSharePrefab:RunAnimRank()
    self.rankmaxtime = 1 -- 1秒
    self.rankruntime = 0
    self.ranksteptime = 1/30
    self.rankanimTime = Timer.New(function ()
        self.rankruntime = self.rankruntime + self.ranksteptime
        self:ChangeUIValueRank(self.rankruntime / self.rankmaxtime)
    end, self.ranksteptime, -1)
    self.rankanimTime:Start()
end

function MJSharePrefab:UpdateUI()
	self:EWM(self.EWMImage.mainTexture, ewmTools.getEwmDataWithPixel(self.url, self.size))
end

function MJSharePrefab.Close()
    if instance then
        instance:RemoveListener()
        instance:ClearCellList()
        if instance.animTime then
            instance.animTime:Stop()
        end
        instance.animTime = nil
        if instance.rankanimTime then
            instance.rankanimTime:Stop()
        end
        instance.rankanimTime = nil

        GameObject.Destroy(instance.gameObject)
        instance = nil
    end
end

function MJSharePrefab:OnBackClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)

    MJSharePrefab.Close()
end
function MJSharePrefab:OnHYClick()
	self:WeChatShareImage(false)
end
function MJSharePrefab:OnPYQClick()
	self:WeChatShareImage(true)
end
function MJSharePrefab:WeChatShareImage(isCircleOfFriends)
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

function MJSharePrefab:CalcScore()
    if self.shareScore then
        return
    end
    self.shareScore = {}
    local data = {}
    -- 运气指数
    data.yq = 8
    if huTypeImage[self.parm.huType] then
        data.yq = data.yq + huTypeImage[self.parm.huType].score
    end
    if paiTypeImage[self.parm.paiType] then
        data.yq = data.yq + paiTypeImage[self.parm.paiType].score
    else
        data.yq = data.yq + paiTypeImage["ping_hu"].score
    end
    if data.yq > 10 then
        data.yq = 10
    end
    local hu = {1, 0.7, 0.5}
    local hunum = 0
    if hu[self.parm.huindex] then
        hunum = hu[self.parm.huindex]
    end
    -- 技术指数
    if not self.parm.geng then
        self.parm.geng = 0
    end
    data.js = 7 + 0.5 * self.parm.geng + hunum
    if data.js > 10 then
        data.js = 10
    end

    -- 公益指数
    data.gy = 10 - (20 - data.yq - data.js)/2
    -- 领先比例
    data.rank = 100 - 2 * (30 - data.yq - data.js - data.gy)
    self.shareScore = data
end

function MJSharePrefab:InitShare()
    self.share_cfg = basefunc.deepcopy(share_link_config.img_free_mj)
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

function MJSharePrefab:screen_shot_begin(  )
    AddCanvasAndSetSort(self.gameObject, 100)
    self:ShowBack(false)
end

function MJSharePrefab:screen_shot_end(  )
    RemoveCanvas(self.gameObject)
    self:ShowBack(true)
end

function MJSharePrefab:query_everyday_shared_award_response(data)
    if not data or not self.share_cfg or not self.share_cfg.finish_type ~= data.type or not IsEquals(self.HintImage) then return end
    if data.status and data.status >= 1 then
        self.HintImage.gameObject:SetActive(true)
    else
        self.HintImage.gameObject:SetActive(false)
    end
end