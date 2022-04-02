-- 创建时间:2022-03-09
-- Panel:ACT_074_TCXBTipPanel
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

ACT_074_TCXBTipPanel = basefunc.class()
local C = ACT_074_TCXBTipPanel
C.name = "ACT_074_TCXBTipPanel"
local M = ACT_074_TCXBManager
function C.Create(type,lottery_type,select_no,num)
	return C.New(type,lottery_type,select_no,num)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(type,lottery_type,select_no,num)
	ExtPanel.ExtMsg(self)
    self.type = type
    self.lottery_type = lottery_type
    self.select_no = select_no
    self.num = num or 1
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
    self.is_gou = false
    self.gou.gameObject:SetActive(self.is_gou)
    self.gou_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnGouClick()
        end
    )
    self.close_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnCloseClick()
        end
    )
    self.yes_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnYesClick()
        end
    )
    self.no_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnNoClick()
        end
    )
	self:MyRefresh()
end

function C:MyRefresh()
    if self.type == 1 then
        self.type1.gameObject:SetActive(true)
        self.type2.gameObject:SetActive(false)
        self.num1_txt.text = 200 * self.num
    else
        self.type1.gameObject:SetActive(false)
        self.type2.gameObject:SetActive(true)
        self.num2_txt.text = "100桃花"
    end
end

function C:OnGouClick()
    self.is_gou = not self.is_gou
    self.gou.gameObject:SetActive(self.is_gou)
end

function C:OnCloseClick()
    self:MyExit()
end

function C:OnYesClick()
    if self.type == 1 then
        M.Lottery(self.lottery_type,self.select_no)
        if self.is_gou then
            PlayerPrefs.SetInt(MainModel.UserInfo.user_id .. M.key .. "today_no_tip",tonumber(os.date("%d",os.time())))
        end
        self:MyExit()
    elseif self.type == 2 then
        M.Reset()
        self:MyExit()
    end
end

function C:OnNoClick()
    self:MyExit()
end