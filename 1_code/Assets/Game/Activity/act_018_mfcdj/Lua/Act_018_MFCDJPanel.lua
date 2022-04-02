-- 创建时间:2020-06-18
-- Panel:Act_018_MFCDJPanel
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

Act_018_MFCDJPanel = basefunc.class()
local C = Act_018_MFCDJPanel
C.name = "Act_018_MFCDJPanel"
local M = Act_018_MFCDJManager
--spcae + 物体宽度的一半 * 2
local item_space = 100 + 106.2
local head_space = 140
local process_W = 14 * item_space + head_space * 2
local Content_W = process_W + 60
local process_offset = (139.3 - 129.53)/2
local off_set = {}

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
	self.lister["close_act_018_mfcdj"] = basefunc.handler(self,self.MyExit)
	self.lister["AssetChange"] = basefunc.handler(self,self.OnAssetChange)
	self.lister["act_018_mfcd_refresh"] = basefunc.handler(self,self.MyRefresh)
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
	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.Camera = GameObject.Find("Canvas/Camera").transform
	self.SV = self.transform:Find("Scroll View"):GetComponent("ScrollRect")

	self:MakeLister()
	self:AddMsgListener()
	off_set = {}
	Network.SendRequest("query_one_task_data",{task_id = M.task_id})
	self.CameraPosition = self.Camera.position
	self.Camera.position = Vector3.New(0,0,-200 * 0.84629)
	for i = 1,15 do
		if i == 1 then
			local data = {}
			data.min = 0
			data.max = 129
			off_set[#off_set + 1] = data
		elseif i >= 2 and i <= 14 then
			local data = {}
			data.min = off_set[i - 1].max
			data.max = off_set[i - 1].max + item_space
			off_set[#off_set + 1] = data
		else
			local data = {}
			data.min = off_set[i - 1].max
			data.max = off_set[i - 1].max + item_space
			off_set[#off_set + 1] = data
		end
	end
	self:InitUI()
	local AwardIndex = M.CanGetAwardIndex()
	if AwardIndex and AwardIndex < 16 then
		self:AutoGoCanGetAwardItem(AwardIndex)
	end
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self.Content.transform.sizeDelta = {x = Content_W,y = 368}
	self.bg_process.transform.sizeDelta = {x = process_W,y = 56}
	self.temp_uis = {}
	for i = 1,15 do
		local temp_ui = {}
		local b = GameObject.Instantiate(self.a_item,self.a_node)
		LuaHelper.GeneratingVar(b.transform,temp_ui)
		EventTriggerListener.Get(temp_ui.klj.gameObject).onClick = basefunc.handler(self, self:GetAward(i))
		b.gameObject:SetActive(true)
		self.temp_uis[#self.temp_uis + 1] = temp_ui
	end

	self:MyRefresh()
end


function C:all_ju_func(i,sum)
	local ju = {1,1,1,1,1,2,2,2,2,2,3,3,3,3,3}
	sum = sum or 0
	if i < 1 then
		return sum
	else
		sum = ju[i] + sum
		return M.all_ju_func(i-1,sum)
	end
end

function C:MyRefresh()
	local data = M.GetData()
	
	if data and IsEquals(self.gameObject) then
		local b = basefunc.decode_task_award_status(data.award_get_status)
		b = basefunc.decode_all_task_award_status2(b, data, 15)
		for i = 1,15 do
			self.temp_uis[i].yhd.gameObject:SetActive(b[i] == 2)
			self.temp_uis[i].klj.gameObject:SetActive(b[i] == 1)
			self.temp_uis[i].ju_txt.text = M.all_ju_func(i).."局"
			self.temp_uis[i].award_img.sprite = GetTexture("mfcdj_icon_"..(i - 1) % 5 + 1)
		end
		self:RefreshProcess()
		self.curr_txt.text = "当前累计胜利局数："..M.GetWinTimes()
	end	
end

function C:RefreshProcess()
	local t = M.GetWinTimes()
	local data = M.GetData()
	if data then

		local now_max_level = M.CanGetNowLevel()
		for i = 1,now_max_level - 1 do
			self.temp_uis[i].liang.gameObject:SetActive(true)
		end
		for i = 1,15 do
			self.temp_uis[i].qipao.gameObject:SetActive(false)
		end
		if now_max_level <= 15 then
			local level_need = M.all_ju_func(now_max_level) - M.all_ju_func(now_max_level - 1)
			local total = data.now_total_process - M.all_ju_func(now_max_level - 1)
			self.process.transform.sizeDelta = {
				x = off_set[now_max_level].min + (off_set[now_max_level].max - off_set[now_max_level].min) * (total/level_need),
				y = 41.95
			}
			dump(off_set[now_max_level].min)
			self.temp_uis[now_max_level].qipao.gameObject:SetActive(true)
			self.temp_uis[now_max_level].qipao_txt.text = "再赢"..level_need - total .."局可领取"
		else
			self.process.transform.sizeDelta = {
				x = process_W - process_offset,
				y = 41.95
			}
		end
		
	end
end

function C:GetAward(i)
	local index = i
	return function ()
		Act_018_MFCDJGetAwardPanel.Create(index)
	end
end

function C:OnAssetChange(data)
    if data.change_type and data.change_type == "task_p_freestyle_ddz" then
		self.award_data = data
    end
end

function C:AutoGoCanGetAwardItem(index)
	local go_anim = function(val)
		self.SV.horizontalNormalizedPosition = val
	end
	if index <= 5 then
		go_anim(0)
	elseif index >= 10 then
		go_anim(1)
	else
		go_anim(1/16 * (index) + 0.015)
	end
end