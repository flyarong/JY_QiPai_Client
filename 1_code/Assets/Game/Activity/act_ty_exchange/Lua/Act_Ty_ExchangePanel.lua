-- 创建时间:2020-05-06
-- Panel:Act_012_LMLHPanel
--[[*      ┌─┐       ┌─┐
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
--]]
local basefunc = require "Game/Common/basefunc"

Act_Ty_ExchangePanel = basefunc.class()
local C = Act_Ty_ExchangePanel
C.name = "Act_Ty_ExchangePanel"
local M = Act_Ty_ExchangeManager
C.instance = nil

local help_info1 = {
}

function C.Create(parent, exchange_key)
    if C.instance then
        C.instance:MyRefresh()
        return
    end
    C.instance = C.New(parent, exchange_key)
    return C.instance
end

function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    -- 数据的初始化和修改
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
	self.lister["model_ty_exchange_data_change_msg"] = basefunc.handler(self, self.model_ty_exchange_data_change_msg)
    self.lister["model_ty_activity_exchange_msg"] = basefunc.handler(self, self.model_ty_activity_exchange_msg)
    self.lister["ty_exchange_toggle_set_false_msg"] = basefunc.handler(self, self.on_ty_exchange_toggle_set_false_msg)
    self.lister["ty_exchange_toggle_set_true_msg"] = basefunc.handler(self, self.on_ty_exchange_toggle_set_true_msg)

end

function C:OnDestroy()
    self:MyExit()
end


function C:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    self:ClearItemPrefab()
    self:RemoveListener()
    C.instance = nil
    destroy(self.gameObject)
end

function C:ctor(parent, exchange_key)
    local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
    local obj = newObject(C.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    self.exchange_key = exchange_key
    self.cfg = M.GetExchangeCfg(self.exchange_key)
    help_info1 = self.cfg.help_info
    LuaHelper.GeneratingVar(self.transform, self)

    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()

    self.transform.anchorMin = Vector2.New(0, 0)
    self.transform.anchorMax = Vector2.New(1, 1)
    self.transform.offsetMax = Vector2.New(0, 0)
    self.transform.offsetMin = Vector2.New(0, 0)
    --self:MyRefresh()
end

function C:InitUI()
    EventTriggerListener.Get(self.gain_item_btn.gameObject).onClick = basefunc.handler(self, self.GainItem)
    EventTriggerListener.Get(self.help_btn.gameObject).onClick = basefunc.handler(self, self.OpenHelpPanel)
	self:InitPanelUI()
	
	if self.cfg.type == 1 then
		M.QueryExchangeData(self.cfg.exchange_type)
	else
		M.QueryGiftData(self.cfg.exchange_key)
    end
    
    if not self.cfg.help_info then 
        self.help_btn.gameObject:SetActive(false)
    end

	CommonTimeManager.GetCutDownTimer(self.cfg.end_time,self.act_time_txt)
end

function C:InitPanelUI()
    --self.gain_item_btn.gameObject:SetActive(false)
    -- self.gain_btn_img = self.gain_item_btn.transform:GetComponent("Image")
    -- SetTextureExtend(self.gain_btn_img,self.cfg.style_key.."_".."icon_2")

    if self.cfg.help_info then
        self.help_btn.gameObject:SetActive(true)
        self.help_btn_img = self.help_btn.transform:GetComponent("Image")
        SetTextureExtend(self.help_btn_img,self.cfg.style_key.."_".."icon_3")
        self.help_btn_img:SetNativeSize()
    end
    SetTextureExtend(self.bg_img,self.cfg.style_key.."_".."bg_1")
    SetTextureExtend(self.item_img,self.cfg.style_key.."_".."icon_1")
	if #self.cfg.item_name <= 9 then
        self.item_now_txt.text = "当前" .. self.cfg.item_name .. ":"
    else
        self.item_now_txt.text = self.cfg.item_name .. ":"
    end
	self:SetTxt(self.item_now_txt.transform,self.cfg.panel_txt_fmt)
	self:SetTxt(self.user_has_item_txt.transform,self.cfg.panel_txt_fmt)
end

function C:GainItem()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    local gotoUI = self.cfg.gotoUI and self.cfg.gotoUI or "game_MiniGame"
	GameManager.GotoUI({gotoui = gotoUI})
end

function C:OpenHelpPanel()
    local str
    str = help_info1[1]
    for i = 2, #help_info1 do
        str = str .. "\n" .. help_info1[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:model_ty_exchange_data_change_msg(data)
    if data.exchange_key ~= self.exchange_key then
        return
    end
    self:MyRefresh()
end

function C:model_ty_activity_exchange_msg(data)
	if data.exchange_key ~= self.exchange_key then
        return
	end
	
	for i = 1, #self.cfg.exchanges do
		local _exchange = self.cfg.exchanges[i]
		if _exchange.ID == data.id then
			if _exchange.is_real ~= 1 then
				return 
			end
			local real = {}
			real.text = _exchange.award_name
			real.image = _exchange.award_image
			RealAwardPanel.Create(real)
		end
	end
end

function C:on_ty_exchange_toggle_set_false_msg(is_tog_save)
    if self.Toggle_tge.isOn and is_tog_save then
        local d = os.date("%Y/%m/%d", now)
        local strs = {}
        string.gsub(d, "[^-/]+", function(s)
            strs[#strs + 1] = s
        end)
        local et = os.time({ year = strs[1], month = strs[2], day = strs[3], hour = "23", min = "59", sec = "59" })
        et = et + 1
        PlayerPrefs.SetInt(MainModel.UserInfo.user_id .. self.exchange_key, et)
    end
    self.Toggle_tge.gameObject:SetActive(false)
end

function C:on_ty_exchange_toggle_set_true_msg()
    self.Toggle_tge.gameObject:SetActive(true)
end

function C:MyRefresh()
	--dump("<color=red>Panel刷新~~~~~~~~~~~~~~~~~~~~~~~~~~~~~</color>")
    self.user_has_item_txt.text = M.GetItemCount(self.exchange_key) or 0
    if self.cfg.exchanges then
        self:CreateItemPrefab()
    end
end

local m_sort = function(v1, v2)
    if v1.remain_time == 0 and (v2.remain_time > 0 or v2.remain_time == -1) then--前无次数后有次数
        return true
    elseif (v1.remain_time > 0 or v1.remain_time == -1) and v2.remain_time == 0 then--前有次数后无次数
        return false
    else--都有次数 或者 都无次数
        if v1.ID < v2.ID then
            return false
        elseif v1.ID > v2.ID then
            return true
        end
    end
end

function C:CreateItemPrefab()
	local sort_data = {}
	for i = 1, #self.cfg.exchanges do
		local data = {}
		data.ID = self.cfg.exchanges[i].ID
		data.remain_time = M.GetRemainTime(self.exchange_key,self.cfg.exchanges[i].ID) or 0
		sort_data[i] = data
		data = nil
    end
	MathExtend.SortListCom(sort_data, m_sort)
    self:ClearItemPrefab()
    for i = 1, #sort_data do
		local pre = Act_Ty_ExchangeItemBase.Create(self.Content.transform, self.exchange_key, sort_data[i].ID,self.cfg)
        if pre then
            self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
        end
    end
end

function C:ClearItemPrefab()
    if self.spawn_cell_list then
        for k, v in ipairs(self.spawn_cell_list) do
            v:MyExit()
        end
    end
    self.spawn_cell_list = {}
end

function C:SetTxt(txt_trans, fmt_cfg)
	if #fmt_cfg >= 1 then
		txt_trans:GetComponent("Text").color = M.ColorToRGB(fmt_cfg[1])
	end

	local outline_com = txt_trans:GetComponent("Outline")
	if #fmt_cfg == 1 then
		if outline_com then
			destroy(outline_com)
		end
	end

	if #fmt_cfg == 2 then
		if not outline_com then
			outline_com =  txt_trans.gameObject:AddComponent(typeof(UnityEngine.UI.Outline))
		end
		outline_com.effectColor = M.ColorToRGB(fmt_cfg[2])
    end
end