-- 创建时间:2020-12-28
-- Panel:Act_Ty_RankPanel
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

Act_Ty_RankPanel = basefunc.class()
local C = Act_Ty_RankPanel
local M = Act_Ty_RankManager
C.name = "Act_Ty_RankPanel"

function C.Create(parent,rank_key)
	return C.New(parent,rank_key)
end

local help_info = {
	"1.活动时间：12月14日7:30~12月20日23:59:59",
	"2.街机捕鱼中捕获朱雀BOSS鱼可获得火羽",
	"3.获得火羽=鱼倍数*炮倍/100",
	"4.购买“朱雀礼包”礼包后，可获得双倍火羽",
}

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["act_ty_rank_base_info_get"] = basefunc.handler(self, self.on_act_ty_rank_base_info_get)
	self.lister["act_ty_rank_info_get"] = basefunc.handler(self, self.on_act_ty_rank_info_get)
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

    self:InitUI()
    CommonTimeManager.GetCutDownTimer(self.cfg.end_time,self.cut_timer_txt)

    self.rule_btn.onClick:AddListener(function()
        self:ShowRule()
    end)
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
    self:LoadAwardUI(self.user_award_txt,self.base_rank_data.rank)
    self:LoadScoreUI(self.user_score_txt,self.base_rank_data.score) 
    
    self.user_name_txt.text = MainModel.UserInfo.name
    self.score_tit_txt.text = self.cfg.item_name
end

function C:InitRankListUI()
    --dump(self.rank_data,"<color=red>rank_data</color>")
    if (not self.rank_data) or #self.rank_data < 1 then
        return
    end
    local pre_name = "Act_Ty_RankItem"

    for i = 1, #self.rank_data do
        local b = newObject(pre_name, self.content)
        self:LoadRankItem(b,self.rank_data[i], i)
    end
end

function C:LoadRankItem(item, item_data, index)
    local temp_ui = {}
    LuaHelper.GeneratingVar(item.transform, temp_ui)
    local bg_img = temp_ui.bg.transform:GetComponent("Image")
    local gogame_img = temp_ui.gogame_btn.transform:GetComponent("Image")
    local mybg_img = temp_ui.m_bg.transform:GetComponent("Image")
    SetTextureExtend(bg_img,self.cfg.style_key.."_".."bg_3")
    SetTextureExtend(mybg_img,self.cfg.style_key.."_".."bg_6")
    SetTextureExtend(gogame_img,self.cfg.style_key.."_".."icon_2")
    SetTextureExtend(temp_ui.score_img,self.cfg.style_key.."_".."icon_1")

    self:LoadRankNumUI(temp_ui.rank_txt,temp_ui.champoin_img,item_data.rank)
    self:LoadAwardUI(temp_ui.award_txt,item_data.rank)
    self:LoadScoreUI(temp_ui.score_txt,item_data.score)
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

    if item_data.rank and item_data.rank <=3 and self.cfg.gotoUI then
        temp_ui.gogame_btn.gameObject:SetActive(true)
        temp_ui.gogame_btn.onClick:AddListener(function ()
            self:GotoGame()
        end)
    else
        temp_ui.gogame_btn.gameObject:SetActive(false)
    end
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


function C:LoadAwardUI(txt_obj,_rank_data)
    txt_obj.text = "- -"
    if _rank_data and M.GetAward(_rank_data) then
        txt_obj.text = M.GetAward(_rank_data)
    end
end

function C:LoadScoreUI(txt_obj,_score_data)
    if self.cfg.item_type == 2 then     --倍数类、积分类
        txt_obj.text = _score_data / 100
    else                                --收集类
        txt_obj.text = _score_data
    end
end

function C:GotoGame()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	GameManager.GotoUI({gotoui= self.cfg.gotoUI})
 end

function C:ClearRankList()
	if self.content.transform.childCount > 1 then
		for i = 1, self.content.transform.childCount - 1 do
			local item_obj = self.content.transform:GetChild(i)
			destroy(item_obj.gameObejct)
		end
	end
	self.rank_item.gameObject:SetActive(false)
end

function C:ShowRule()
    local str = help_info[1]
    for i = 2, #help_info do
        str = str .. "\n" .. help_info[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end