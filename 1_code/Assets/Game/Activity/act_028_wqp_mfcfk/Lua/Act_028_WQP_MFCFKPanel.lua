-- 创建时间:2020-06-18
-- Panel:Act_028_WQP_MFCFKPanel
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

Act_028_WQP_MFCFKPanel = basefunc.class()
local C = Act_028_WQP_MFCFKPanel
C.name = "Act_028_WQP_MFCFKPanel"
C.Now_Task_ID = nil
local M = Act_028_WQP_MFCFKManager
--spcae + 物体宽度的一半 * 2
local item_space = 100 + 128.9
local head_space = 140
local process_W = 14 * item_space + head_space * 2
local Content_W = process_W + 60
local process_offset = (139.3 - 129.53)/2
local off_set = {}
local task_len_data = {
}
function C.Create(choose_index)
	return C.New(choose_index)
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["close_Act_028_WQP_MFCFK"] = basefunc.handler(self,self.MyExit)
	self.lister["AssetChange"] = basefunc.handler(self,self.OnAssetChange)
	self.lister["Act_028_WQP_MFCFK_refresh"] = basefunc.handler(self,self.MyRefresh)
	self.lister["Act_028_WQP_MFCFK_close"] = basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	if self.time then
		self.time:Stop()
	end
	self.time = nil
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(choose_index)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.choose_index = choose_index or 1 
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.Camera = GameObject.Find("Canvas/Camera").transform
	self.SV = self.transform:Find("Scroll View"):GetComponent("ScrollRect")
	self:MakeLister()
	self:AddMsgListener()
	for i = 1,4 do
		self["s"..i.."_btn"].onClick:AddListener(
			function()
				self:ChangeButtonStatus(i)
			end
		)
	end
	-- if M.IsFirstGame() then
	-- 	self:IsFirstInto()
	-- else
 	self:ChangeButtonStatus(self.choose_index)
	-- end


	--Network.SendRequest("query_one_task_data",{task_id = M.task_id})
	if MainModel.myLocation ~= "game_Mj3D" then	
		self.CameraPosition = self.Camera.position
		self.Camera.position = Vector3.New(0,0,-200 * 0.84629)
	end
	self:InitUI()

end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self.time = Timer.New(function(  )
		dump(debug.traceback(),"wqp_fkcfkpanel_into_finish")

		if M.IsFirstGetAward() then
		Event.Brocast("wqp_fkcfkpanel_into_finish")	
		end
	end,0.05,1)
	self.time:Start()
end

function C:MyRefresh(task_id)
	local data = M.GetData(self.now_choose_index)
	dump(data,"daaaaaaaaaaatttttaaaa")
	if data and IsEquals(self.gameObject) and task_id == M.task_ids[self.now_choose_index] then
		local b = basefunc.decode_task_award_status(data.award_get_status)
		local base_data = M.GetCurBaseData(self.now_choose_index)
		task_len_data = {
			#base_data[1],#base_data[2],#base_data[3],#base_data[4]
		}
		b = basefunc.decode_all_task_award_status2(b, data, task_len_data[self.now_choose_index])
		if #base_data[self.now_choose_index] ~= #self.temp_uis then
			--第一次向第二次转变
			destroy(self.temp_uis[#self.temp_uis].gameObject)
			self.temp_uis[#self.temp_uis] = nil
		else
			for i = 1,task_len_data[self.now_choose_index] do
				self.temp_uis[i].yhd.gameObject:SetActive(b[i] == 2)
				self.temp_uis[i].klj.gameObject:SetActive(b[i] == 1)
				local view_str =""
				view_str=M.all_ju_func(i,self.now_choose_index)

				self.temp_uis[i].ju_txt.text =view_str .."局"
				--self.temp_uis[i].award_img.sprite = GetTexture("mfcdj_icon_"..(i - 1) % 5 + 1)
				
				local award = M.GetCurAwardByCCJD(self.now_choose_index,i)
				if award then
					if award.award_type == "shop_gold_sum" then
						self.temp_uis[i].fk_txt.text = award.award_list[#award.award_list] / 100 .. "福卡"
						self.temp_uis[i].award_img.sprite = GetTexture("ty_icon_flq3_activity_act_028_wqp_mfcfk")
					elseif award.award_type == "jing_bi" then
						self.temp_uis[i].award_img.sprite = GetTexture("pay_icon_gold11")
						self.temp_uis[i].fk_txt.text = award.award_list[#award.award_list] .. "鲸币"
					else
						self.temp_uis[i].award_img.sprite = GetTexture("ty_icon_flq3_activity_act_028_wqp_mfcfk")
						self.temp_uis[i].fk_txt.text = award.award_list[#award.award_list]
					end
				else
					self.temp_uis[i].award_img.sprite = GetTexture("ty_icon_flq3_activity_act_028_wqp_mfcfk")
					self.temp_uis[i].fk_txt.text = "???"
				end
			end
		end
		
		self.curr_txt.text = "当前累计胜利局数："..M.GetWinTimes(self.now_choose_index)
	end
	self:RefreshProcess()
	self:RefreshRed()
	--self:IsFirstInto()

end

function C:RefreshProcess()
	local data = M.GetData(self.now_choose_index)
	if data then
		local now_max_level = M.CanGetNowLevel(self.now_choose_index)
		for i = 1,now_max_level - 1 do
			if self.temp_uis[i] and self.temp_uis[i].liang and IsEquals(self.temp_uis[i].liang) then
				self.temp_uis[i].liang.gameObject:SetActive(true)
			end
		end
		for i = 1,task_len_data[self.now_choose_index] do
			if self.temp_uis[i] and self.temp_uis[i].qipao and IsEquals(self.temp_uis[i].qipao) then
				self.temp_uis[i].qipao.gameObject:SetActive(false)
			end
		end

		if now_max_level <= task_len_data[self.now_choose_index] then

			 dump(now_max_level,"now_max_level")
			-- dump(M.all_ju_func(now_max_level,self.now_choose_index),"111111")
			-- dump(M.all_ju_func(now_max_level - 1,self.now_choose_index),"222222")
			-- dump(M.all_ju_func(1,self.now_choose_index),"33333")
			local level_need = M.all_ju_func(now_max_level,self.now_choose_index) - M.all_ju_func(now_max_level - 1,self.now_choose_index)
			--local total = data.now_total_process - M.all_ju_func(now_max_level - 1,self.now_choose_index)
			--dump(M.all_ju_func(now_max_level - 1,self.now_choose_index))
			local total = M.GetWinTimes(self.now_choose_index) - M.all_ju_func(now_max_level - 1,self.now_choose_index)
			-- dump(off_set[now_max_level].min,"off_set[now_max_level].min")
			-- dump((off_set[now_max_level].max - off_set[now_max_level].min),"2222222222222")
			-- dump(total/level_need,"433333333")
			-- dump(off_set)
			
			self.process.transform.sizeDelta = {

				x = off_set[now_max_level].min + (off_set[now_max_level].max - off_set[now_max_level].min) * (total/level_need),
				y = 41.95
				
			}
			--dump(total,"total")
			--dump(level_need,"level_need")

			if self.temp_uis[now_max_level] and IsEquals(self.temp_uis[now_max_level].qipao) then
				self.temp_uis[now_max_level].qipao.gameObject:SetActive(true)
			end
			if self.temp_uis[now_max_level] and IsEquals(self.temp_uis[now_max_level].qipao_txt) then
				self.temp_uis[now_max_level].qipao_txt.text = level_need - total
			end
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
		Act_028_WQP_MFCFKGetAwardPanel.Create(index)
	end
end

function C:OnAssetChange(data)
	if data.change_type and data.change_type == "task_p_freestyle_ddz" then
		self.award_data = data
	end
end

function C:destroyAwardItem()
	destroyChildren(self.a_node)
	self.temp_uis = {}
end

function C:ChangeButtonStatus(index)

	for i = 1,4 do
		self["m"..i.."_mask"].gameObject:SetActive(false)
	end
	self["m"..index.."_mask"].gameObject:SetActive(true)
	
	self.now_choose_index = index
	C.Now_Task_ID = Act_028_WQP_MFCFKManager.task_ids[self.now_choose_index]
	--local base_data = M.GetBaseData()
	local base_data = M.GetCurBaseData(self.now_choose_index)

	dump(base_data,"base_data------")
	--local base_data = M.GetBaseData()
	task_len_data = {
		#base_data[1],#base_data[2],#base_data[3],#base_data[4]
	}
	--spcae + 物体宽度的一半 * 2
	item_space = 100 + 128.9
	head_space = 140
	process_W = (task_len_data[self.now_choose_index] - 1)  * item_space + head_space * 2
	Content_W = process_W + 60
	process_offset = (139.3 - 129.53)/2
	off_set = {}
	self:destroyAwardItem()
	self.Content.transform.sizeDelta = {x = Content_W,y = 368}
	self.bg_process.transform.sizeDelta = {x = process_W,y = 56}

	--dump(task_len_data,"task_len_data------")
	for i = 1,task_len_data[self.now_choose_index] do
		local temp_ui = {}
		local b = GameObject.Instantiate(self.a_item,self.a_node)
		LuaHelper.GeneratingVar(b.transform,temp_ui)
		EventTriggerListener.Get(temp_ui.klj.gameObject).onClick = basefunc.handler(self, self:GetAward(i))
		b.gameObject:SetActive(true)
		self.temp_uis[#self.temp_uis + 1] = temp_ui
	end
	self:InitProData()
	self:MyRefresh(M.task_ids[self.now_choose_index])
end

function C:InitProData()
	off_set = {}
	for i = 1,task_len_data[self.now_choose_index] do
		if i == 1 then
			local data = {}
			data.min = 0
			data.max = 129
			off_set[#off_set + 1] = data
		elseif i >= 2 and i <= task_len_data[self.now_choose_index] - 1 then
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
end

function C:RefreshRed()
	for i = 1,#M.task_ids do
		local data = M.GetData(i)
		if data and data.award_status == 1 then
			self["red"..i].gameObject:SetActive(true)
		else
			self["red"..i].gameObject:SetActive(false)
		end
	end
end

