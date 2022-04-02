-- 创建时间:2020-12-28
-- Panel:Act_Ty_RankPanel_Ea
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

Act_Ty_RankPanel_Ea = basefunc.class()
local C = Act_Ty_RankPanel_Ea
local M = Act_Ty_RankManager
C.name = "Act_Ty_RankPanel_Ea"

function C.Create(parent,rank_key)
	return C.New(parent,rank_key)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["act_ty_rank_base_info_get"] = basefunc.handler(self, self.on_act_ty_rank_base_info_get)
	self.lister["act_ty_rank_info_get"] = basefunc.handler(self, self.on_act_ty_rank_info_get)
	self.lister["GiftPanelClosed"] = basefunc.handler(self, self.ShowFireFX)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	self.isShowingRankLis = false
    if self.timer then
		self.timer:Stop()
		self.timer = nil
	end
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:ctor(parent,rank_key)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
    self.isShowingRankLis = false
    self.rank_key = rank_key
    self.cfg = M.GetRankCfg(self.rank_key)
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
    self:AddMsgListener()

    M.QueryRankData(self.cfg.rank_type)
    M.QueryRankBaseData(self.cfg.rank_type)
    self.bottom_node.gameObject:SetActive(false)
    self.top_node.gameObject:SetActive(false)

    self:InitUI()
    CommonTimeManager.GetCutDownTimer(self.cfg.end_time,self.cut_timer_txt)

    self.rule_btn.onClick:AddListener(function ()
        self:ViewRankInfo()
    end)
    self.goto_btn.gameObject.transform:GetComponent("Text").text = "赚取"..self.cfg.item_name
    -- local gotoImage = self.goto_btn:GetComponent("Image")
    -- SetTextureExtend(gotoImage,self.cfg.style_key.."_".."icon_2")
    self.goto_btn.onClick:AddListener(
        function()
            self:GotoGame()
        end
    )
    self.goto_btn.gameObject:SetActive(not not self.cfg.gotoUI)
    self.goto_btn_bg.gameObject:SetActive(not not self.cfg.gotoUI)

    if self.cfg.gift_key then
        self.score_buff_btn.gameObject:SetActive(true)
        self.score_buff_btn.onClick:AddListener(function()
            GameButtonManager.GotoUI({gotoui = "act_ty_gifts", goto_scene_parm = "panel", goto_type = self.cfg.gift_key})
            self:HideFireFX()
        end)
    end
end

function C:UpdateRankData()
    self.rank_data = M.GetRankData(self.rank_key)
end

function C:UpdateBaseData()
    self.base_rank_data = M.GetRankBaseData(self.rank_key)
end

function C:InitUI()
    self:LoadStyle()
    self:MyRefresh()
end

function C:MyRefresh()
	
end

function C:LoadStyle()
    SetTextureExtend(self.user_score_img,self.cfg.style_key.."_".."icon_1")
    SetTextureExtend(self.rank_bg_img,self.cfg.style_key.."_".."bg_1")
    SetTextureExtend(self.content_bg_img,self.cfg.style_key.."_".."bg_2")
    SetTextureExtend(self.top_img,self.cfg.style_key.."_".."bg_4")
    SetTextureExtend(self.buttom_img,self.cfg.style_key.."_".."bg_5")
end

function C:on_act_ty_rank_base_info_get(data)
	if data.rank_type == self.cfg.rank_type then
        self.bottom_node.gameObject:SetActive(true)
        self.top_node.gameObject:SetActive(true)
        self:UpdateBaseData()
		self:InitBaseUI()
	end
end

function C:on_act_ty_rank_info_get(data)
	if data.rank_type == self.cfg.rank_type then
		if self.isShowingRankLis then
            self:ClearRankList()
            self.isShowingRankLis = false
		end
		self:UpdateRankData()
		self:InitRankListUI()
		self.isShowingRankLis = true
	end
end


function C:InitBaseUI()
    self:LoadRankNumUI(self.user_rank_txt,self.user_rank_img,self.base_rank_data.rank)
    self:LoadBaseAwardUI(self.user_award_txt,self.base_rank_data.rank)
    self:LoadExtAwardUI(self.user_award_ext1_txt,self.user_award_ext1_grey_img ,self.base_rank_data.rank,self.base_rank_data.score,1)
    self:LoadExtAwardUI(self.user_award_ext2_txt,self.user_award_ext2_grey_img ,self.base_rank_data.rank,self.base_rank_data.score,2,self.user_award_ext2_img)
    self:LoadExt2AwardTip(self.base_rank_data.rank, self.user_award_ext2_img, self.user_award_ext2_grey_img)
    self:LoadScoreUI(self.user_score_txt,self.base_rank_data.score) 
    
    self.user_name_txt.text = MainModel.UserInfo.name
    self.score_tit_txt.text = self.cfg.item_name
end

function C:InitRankListUI()
    ---- dump(self.rank_data,"<color=red>rank_data</color>")
    if (not self.rank_data) or #self.rank_data < 1 then
        return
    end
    local pre_name = "Act_Ty_RankItem_Ea"
    self.preItems = {}

    for i = 1, #self.rank_data do
        local b = newObject(pre_name, self.content)
        local b_ui = self:LoadRankItem(b,self.rank_data[i], i)
        self.preItems[#self.preItems + 1] = b_ui
    end

    self.timer = Timer.New(function()
        self:CheckOnDrag()
    end, 0.016, -1)
    self.timer:Start()
end

function C:LoadRankItem(item, item_data, index)
    local temp_ui = {}
    LuaHelper.GeneratingVar(item.transform, temp_ui)
    local bg_img = temp_ui.bg.transform:GetComponent("Image")
    local mybg_img = temp_ui.m_bg.transform:GetComponent("Image")
    SetTextureExtend(bg_img,self.cfg.style_key.."_".."bg_3")
    SetTextureExtend(mybg_img,self.cfg.style_key.."_".."bg_6")
    SetTextureExtend(temp_ui.score_img,self.cfg.style_key.."_".."icon_1")

    self:LoadRankNumUI(temp_ui.rank_txt,temp_ui.champoin_img,item_data.rank)
    self:LoadBaseAwardUI(temp_ui.award_txt,item_data.rank)                            --基础奖励
    self:LoadExtAwardUI(temp_ui.award_ext1_txt, temp_ui.award_ext1_grey_img, item_data.rank, item_data.score, 1)         --额外奖励1
    self:LoadExtAwardUI(temp_ui.award_ext2_txt, temp_ui.award_ext2_grey_img, item_data.rank, item_data.score, 2, temp_ui.award_ext2_img)         --额外奖励2
    self:LoadExt2AwardTip(item_data.rank, temp_ui.award_ext2_img, temp_ui.award_ext2_grey_img)
    self:LoadScoreUI(temp_ui.score_txt,item_data.score)
    temp_ui.scorePart = {temp_ui.part1, temp_ui.part2, temp_ui.part3}
    -- item_data.other_data = {}
    -- item_data.other_data.extra_score = 1000
    -- item_data.other_data.extra_today_percent  = 0.1
    self:LoadScoreBuff(temp_ui.scorePart, temp_ui.score_btn, item_data.other_data, item_data.score, item_data.name)
    
    temp_ui.name_txt.text = item_data.name
    if item_data.player_id == MainModel.UserInfo.user_id then
		temp_ui.m_bg.gameObject:SetActive(true)
    else
        if index % 2 == 0 then
            temp_ui.bg.gameObject:SetActive(false)
        else
            temp_ui.bg.gameObject:SetActive(true)
        end
    end
    temp_ui.gameObject = item.gameObject
    return temp_ui
end


function C:LoadRankNumUI(txt_obj,img_obj,_rank_data)

    if _rank_data > 0 then
        txt_obj.text = _rank_data
    else
        txt_obj.text = "未上榜"
    end

    if _rank_data >= 1 and  _rank_data <=3 then
        img_obj.gameObject:SetActive(true)
        txt_obj.gameObject:SetActive(false)
        img_obj.sprite = GetTexture(M.GetWinIcon(_rank_data))
        txt_obj.text = ""
    else
        img_obj.gameObject:SetActive(false)
        txt_obj.gameObject:SetActive(true)
    end
end


function C:LoadBaseAwardUI(txt_obj,_rank_data)
    txt_obj.text = "- -"
    if _rank_data and M.GetBaseAward(_rank_data) then
        txt_obj.text = M.GetBaseAward(_rank_data)
    end
end

function C:LoadExtAwardUI(txt_obj,img_grey_obj,_rank_data,_score_data,extIndex,image_obj)
    txt_obj.text = "- -"
    if _rank_data and M.GetExtAwardCfg(_rank_data) then
        txt_obj.text = M.GetExtAwardCfg(_rank_data).ext_award_num[extIndex]
    end
    
    if not M.GetExtAwardCondi(_rank_data) then
        return 
    end
    -- dump(_score_data,"<color=white>_score_data</color>")
    -- dump(M.GetExtAwardCondi(_rank_data),"<color=white>M.GetExtAwardCondi(_rank_data)</color>")
    if extIndex == 2 then
        image_obj.sprite = GetTexture(GameItemModel.GetItemToKey(M.GetExtAwardCfg(_rank_data).ext_award[2]).image)
        --img_grey_obj.sprite = GetTexture(GameItemModel.GetItemToKey(M.GetExtAwardCfg(_rank_data).ext_award[2]).image)
    end
    if M.TransformScore(tonumber(_score_data), self.cfg.item_type)  < M.GetExtAwardCondi(_rank_data) then
        txt_obj.transform:GetComponent("Outline").effectColor = Color.New(82 / 255, 74 / 255, 74 / 255)
        img_grey_obj.gameObject:SetActive(true)
    else
        img_grey_obj.gameObject:SetActive(false)
    end
end

function C:LoadExt2AwardTip(_rank_data, objImg, objGreyImg)
    if not M.GetExtAwardCondi(_rank_data) then
        return 
    end
    local btn1 = objImg.gameObject:GetComponent("Button")
    local btn2 = objGreyImg.gameObject:GetComponent("Button")
    local item = GameItemModel.GetItemToKey(M.GetExtAwardCfg(_rank_data).ext_award[2])

    btn1.onClick:AddListener(function()
        LTTipsPrefab.Show2(btn1.transform, item.name, item.desc)
    end)
    btn2.onClick:AddListener(function()
        LTTipsPrefab.Show2(btn2.transform, item.name, item.desc)
    end)
end

function C:LoadScoreUI(txt_obj,_score_data)
    txt_obj.text = M.TransformScore(_score_data, self.cfg.item_type)
end

function C:LoadScoreBuff(partBuff, score_btn, other_data, _score_data, name)
    local other_data = json2lua(other_data)
    if other_data then
        if other_data.extra_score and other_data.extra_today_percent then
            local score = M.TransformScore(_score_data, self.cfg.item_type)
            score_btn.gameObject:SetActive(true)
            score_btn.onClick:AddListener(function()
                Act_Ty_RankTips.Create(score_btn.transform.position, other_data, score, self.cfg, name)
            end)
            local part
            if other_data.extra_today_percent == 10 then
                part = partBuff[1]
            elseif other_data.extra_today_percent == 30 then
                part = partBuff[2]
            elseif other_data.extra_today_percent == 50 then
                part = partBuff[3]
            end
            if part then
                part.gameObject:SetActive(true)
                --local nScaleX = (#tostring(math.floor(score)) / 6) * 100
                local len
                local str = tostring(score)
                if math.floor(score) < score then
                    len = #str - 1
                else
                    len = #str
                end
                local nScaleX = (len / 6) * 100
                part.transform.localScale = Vector3.New(nScaleX, part.transform.localScale.y,part.transform.localScale.z)
                local rectTransW = part:GetComponent("RectTransform").rect.width
                local nPosX = rectTransW * nScaleX / 2 - 10
                part.transform.localPosition = Vector3.New(nPosX, part.transform.localPosition.y, part.transform.localPosition.z)
            end
        else
            local score = M.TransformScore(_score_data, self.cfg.item_type)
            score_btn.gameObject:SetActive(true)
            local _other_data = { extra_score = 0,  extra_today_percent = 0}
            score_btn.onClick:AddListener(function()
                Act_Ty_RankTips.Create(score_btn.transform.position, _other_data, score, self.cfg, name)
            end)
        end
    end
end

-- function C:TransformScore(_score_data)
--     if self.cfg.item_type == 2 then     --倍数类、积分类
--         _score_data = _score_data / 100
--     elseif self.cfg.item_type == 3 then 
--         _score_data = _score_data / 10000 - (_score_data / 10000) % 0.01
--     else                                --收集类
--         _score_data = _score_data
--     end
--     return _score_data
-- end

function C:GotoGame()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if self.cfg.gotoUI then
	    GameManager.GotoUI({gotoui= self.cfg.gotoUI})
    end
 end

function C:ClearRankList()
    if not IsEquals(self.gameObject) then return end
	if self.content.transform.childCount > 1 then
		for i = 1, self.content.transform.childCount - 1 do
			local item_obj = self.content.transform:GetChild(i)
            if item_obj then
			    destroy(item_obj.gameObject)
            end
		end
	end
	--self.rank_item.gameObject:SetActive(false)
end

function C:ViewRankInfo()
    local parent = GameObject.Find("Canvas/LayerLv4").transform
    local rank_info_obj = newObject("Act_Ty_RankInfo_Ea",parent)
    self.rank_info_ui = {}
    self.rank_info_ui.transform = rank_info_obj.transform
    self.rank_info_ui.gameObject = rank_info_obj

    LuaHelper.GeneratingVar(rank_info_obj.transform, self.rank_info_ui)
    local info_data = M.GetExtCfg()

    for i = 1, #info_data do
        local b = GameObject.Instantiate(self.rank_info_ui.info_item,self.rank_info_ui.Content)
        b.gameObject:SetActive(true)
        local temp_ui = {}
        LuaHelper.GeneratingVar(b.transform, temp_ui)
        temp_ui.arward_ext_txt.text = info_data[i].ext_award_num[1] .. " 福卡"
        temp_ui.arward_ext2_txt.text = info_data[i].ext_award_num[2] .. " ".. GameItemModel.GetItemToKey(info_data[i].ext_award[2]).name
        temp_ui.arward_ext_condi_txt.text = info_data[i].ext_award_condi_txt
        self:LoadRankNumUI(temp_ui.rank_txt,temp_ui.rank_icon_img,i)
    end
    self.rank_info_ui.back_btn.onClick:AddListener(function ()
        if self.rank_info_ui then
            -- dump("<color=white>-------------------------</color>")
            destroy(self.rank_info_ui.gameObject)
        else
            local my_panel = GameObject.Find("Act_Ty_RankInfo_Ea")
            if my_panel then
                destroy(my_panel.gameObject)
            end 
        end
    end)
end

function C:CheckOnDrag()
    for i = 1, #self.preItems do
		if self.preItems[i].gameObject.transform.position.y > 115 or self.preItems[i].gameObject.transform.position.y < -225 then
			self.preItems[i].rankFX.gameObject:SetActive(false)
		else
			self.preItems[i].rankFX.gameObject:SetActive(true)
		end
	end
end

function C:ShowFireFX()
    if self.timer then
        self.timer:Start()
    end
end

function C:HideFireFX()
    if table_is_null(self.preItems) then
        return
    end
    for i = 1, #self.preItems do
        self.preItems[i].rankFX.gameObject:SetActive(false)
    end

    if self.timer then
        self.timer:Stop()
    end
end