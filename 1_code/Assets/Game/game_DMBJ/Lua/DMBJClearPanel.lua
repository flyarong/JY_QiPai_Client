-- 创建时间:2020-12-15
-- Panel:DMBJClearPanel
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

DMBJClearPanel = basefunc.class()
local C = DMBJClearPanel
C.name = "DMBJClearPanel"
local DT_Table = {} 
local anim_names = {
	[1] = nil,
	[2] = {show = "DMBJClearPanel_@level2",hide = "DMBJClearPanel_@level2_03"},
	[3] = {show = "DMBJClearPanel_@level3",hide = "DMBJClearPanel_@level3_03"},
}


function C.Create(parm)
	return C.New(parm)
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
	for i = 1,#DT_Table do
		if DT_Table[i] then
			DT_Table[i]:Kill()
		end
	end
	DT_Table = {}
	if self.CutTimer then
		self.CutTimer:Stop()
	end
	local ext_func = function()
		Event.Brocast("dmbj_clear_closed")
		self:RemoveListener()
		destroy(self.gameObject)
		if DMBJModel.Award ~= 0 then
			--??
		end
	end
	local level = self:GetLevel()
	dump(level)
	Timer.New(function()
		if IsEquals(self.gameObject) then
			if level >= 2 then
				self.Animator:Play(anim_names[level].hide)
				Timer.New(function()
					ext_func()
				end,0.5,1,nil,true):Start()
			else
				ext_func()
			end
		end
	end,0.1,1,nil,true):Start()
end

function C:ctor(parm)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.parm = parm
	self:MakeLister()
	self:AddMsgListener()
	DT_Table = {}
	self:InitUI()
	self.Animator = self.transform:GetComponent("Animator")
	self.Animator.enabled = true
	Event.Brocast("dmbj_clear_opened")
	local t = 4
	self.cd_txt.text = "4s"
	self.CutTimer = Timer.New(
		function()
			t = t - 1
			self.cd_txt.text = t.."s"
			if t <= 0 then
				self:MyExit()
			end
		end
	,1,-1,nil,true)
	self.CutTimer:Start()
end

function C:InitUI()
	self:Show()
	self.main_btn.onClick:AddListener(function()
		for i = 1,#DT_Table do
			if DT_Table[i] then
				DT_Table[i]:Kill()
			end
		end
		DT_Table = {}
		if tonumber(self.award_txt.text) == self.parm.award then
			self:MyExit()
		else
			self.award_txt.text = self.parm.award
		end
	end)
	--self.award_txt.text = self.parm.award
	if self:GetLevel() > 1 then
		self:ToAddMoney(self.parm.award)
	else
		self.award_txt.text = self.parm.award
	end
	for i = 1,#self.parm.show do
		self["award"..i.."_img"].sprite = DMBJPrefabManager.Prefabs["item_"..self.parm.show[i]]
	end
	self:MyRefresh()
end

function C:ToAddMoney(money)
	local start = 0
    local DT = DG.Tweening.DOTween.To(
        DG.Tweening.Core.DOGetter_float(
            function(value)
                return start 
            end
        ),
        DG.Tweening.Core.DOSetter_float(
			function(value)
				if IsEquals(self.gameObject) then
					self.award_txt.text =  math.floor(value)
				end
            end
        ),
        money,
        3
    ):OnComplete(
		function()
			if IsEquals(self.gameObject) then
				
			end
        end 
	)
	DT_Table[#DT_Table + 1] = DT
end


function C:GetLevel()
	local level_data = {
		{min = 0,max = 5},{min = 5,max = 20},{min = 20,max = 100000}
	}
	local level = 1
	local rate = DMBJModel.Rate
	for i = 1,#level_data do
		if rate >= level_data[i].min and level_data[i].max > rate then
			return i
		end
	end
	return level
end

function C:MyRefresh()

end

function C:Show()
	local level = self:GetLevel()
	local audio_name  = {
		"dmbj_jiesuan1","dmbj_jiesuan2","dmbj_jiesuan3",
	}
	ExtendSoundManager.PlaySound(audio_config.dmbj[audio_name[level]].audio_name)
	self.gameObject:SetActive(false)
	for i = 1,3 do
		self["level"..i].gameObject:SetActive(false)
	end
	Timer.New(function()
		self.gameObject:SetActive(true)
		self["level"..level].gameObject:SetActive(true)
		if level >= 2 then
			self.Animator.enabled = true
			self.Animator:Play(anim_names[level].show)
		end
	end,0.1,1,nil,true):Start()
end
