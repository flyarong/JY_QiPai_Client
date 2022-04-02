-- 创建时间:2020-02-25
-- Panel:Fishing3DActXYCBHelpPanel
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
 --]]

local basefunc = require "Game/Common/basefunc"

Fishing3DActXYCBHelpPanel = basefunc.class()
local C = Fishing3DActXYCBHelpPanel
C.name = "Fishing3DActXYCBHelpPanel"

function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
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

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv3").transform
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
	self.back_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnBackClick()
    end)
    self.cbbz_L_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnTopClick("jl")
    end)
    self.cbbz_R_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnTopClick("gz")
    end)
    local desc = "1、捕获彩金鱼有几率获得彩贝，彩贝位满后不再获得\n" .. 
    "2、每人最多同时拥有四个彩贝，VIP3以上的玩家则有五个\n" .. 
    "3、点击彩贝即可开启，开启海贝需要等待时间\n" .. 
    "4、一次仅可同时开启一个彩贝，VIP5以上的玩家则可同时开启两个\n" ..
    "5、当彩贝完成倒计时，点击即可获得奖励\n" ..
    "6、彩贝的品质越高，所需的开启时间越长，获得的奖励也越好\n" ..
    "7、海贝开启可花费鲸币立即开启\n" ..
    "8、每日可以免费领取彩贝，一天可以领取三次，每次领取有冷却时间\n" ..
    "9、每日早晨6点重置领取次数。"
    self.help_desc_txt.text = desc

    local jl_info = {
    	[1] = {"鱼币", "中等", "中等", "中等", "中等", "中等"},
    	[2] = {"锁定卡", "低", "低", "低", "低", "低"},
    	[3] = {"冰冻卡", "低", "低", "低", "低", "低"},
    	[4] = {"召唤卡", "低", "低", "低", "低", "低"},
    	[5] = {"钻头弹", "无", "无", "无", "无", "无"},
    }
    for k,v in ipairs(jl_info) do
    	local obj = GameObject.Instantiate(self.help1_prefab, self.bk_node)
    	obj.gameObject:SetActive(true)
    	local ui = {}
    	LuaHelper.GeneratingVar(obj.transform, ui)
    	ui.name_txt.text = v[1]
    	for i = 1, 5 do
    		ui["bk" .. i .. "_txt"].text = v[i+1]
    	end
    end
    -- 默认
    self.tag = "jl"
	self:MyRefresh()
end

function C:MyRefresh()
	if self.tag == "jl" then
		self.cbbz_L_btn.gameObject:SetActive(false)
		self.cbbz_L_not.gameObject:SetActive(true)
		self.cbbz_R_btn.gameObject:SetActive(true)
		self.cbbz_R_not.gameObject:SetActive(false)
		self.ScrollViewL.gameObject:SetActive(true)
		self.ScrollViewR.gameObject:SetActive(false)
		self.ContentL.localPosition = Vector3.zero
	else
		self.cbbz_L_btn.gameObject:SetActive(true)
		self.cbbz_L_not.gameObject:SetActive(false)
		self.cbbz_R_btn.gameObject:SetActive(false)
		self.cbbz_R_not.gameObject:SetActive(true)
		self.ScrollViewL.gameObject:SetActive(false)
		self.ScrollViewR.gameObject:SetActive(true)
		self.ContentR.localPosition = Vector3.zero
	end
end

function C:OnBackClick()
	self:MyExit()
end
function C:OnTopClick(tag)
	self.tag = tag
	self:MyRefresh()
end

