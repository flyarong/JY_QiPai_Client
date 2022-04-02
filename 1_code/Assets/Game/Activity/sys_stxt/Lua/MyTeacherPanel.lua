local basefunc = require "Game/Common/basefunc"

MyTeacherPanel = basefunc.class()
local C = MyTeacherPanel
C.name = "MyTeacherPanel"
--控制排序
local order_data = {
	[1] = "calloff_item",
	[2] = "refuse_item",
	[3] = "broke_item",
	[4] = "repair_item",
	[5] = "teacher_item",
}
--当前各个子物体个数
local index_data = {
	repair_item = 0, 
	broke_item = 0,
	teacher_item = 0,
	refuse_item = 0,
	calloff_item = 0,
}
local curr_like_ids
function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	-- self.lister["query_master_personal_info_list_response"] = basefunc.handler(self,self.on_query_master_personal_info_list_response)
	-- self.lister["query_master_notify_info_list_response"] = basefunc.handler(self,self.on_query_master_notify_info_list_response)
	self.lister["Teacher_Notify_Finsh"] = basefunc.handler(self,self.Teacher_Notify_Finsh)
	self.lister["Teacher_Info_Finsh"] = basefunc.handler(self,self.Teacher_Info_Finsh)
	self.lister["click_like_response"] = basefunc.handler(self,self.on_click_like_response)
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

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.transform.localPosition = Vector3.zero
	curr_like_ids = {}
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	-- Network.SendRequest("query_master_personal_info_list")
	-- Network.SendRequest("query_master_notify_info_list")
	SYSSTXTManager.SendTeacherQuery()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()

end

function C:AutoSetSibling(obj)
	if not IsEquals(obj) then return end
	index_data[obj.name] = index_data[obj.name] + 1
	local index = 0
	for i = 1,#order_data do
		if obj.name == order_data[i] then 
			obj.transform:SetSiblingIndex(index + index_data[obj.name] - 1)
			return  
		else
			index = index + self:GetItemIndex(order_data[i])
		end
	end
end

function C:GetItemIndex(item)
	return index_data[item]
end
-- message_data type 
--     1 徒弟向师父申请
--     2 师父收到徒弟的申请消息
--     3 徒弟收到的师父对自己的解除关系消息
--     4 师父收到的徒弟对自己的解除关系消息
--     5 徒弟收到的师父对自己的恢复关系消息
--     6 师父收到的徒弟对自己的恢复关系消息
--     7 徒弟收到的师父对自己的拒绝关系消息

function C:Refresh_Notify_UI(data)
	local temp_ui = {}
	if data then
		local data = table.sort(data,function (a,b)
			return a.time > b.time
		end) or data
		for i = 1,#data do 
			if data[i].type == 1 then 
				local b = GameObject.Instantiate(self.calloff_item,self.Content)
				LuaHelper.GeneratingVar(b.transform, temp_ui)
				b.name = "calloff_item"
				b.gameObject:SetActive(true)
				URLImageManager.UpdateHeadImage(data[i].head_image,temp_ui.head_img)
				temp_ui.name_txt.text = data[i].player_name
				temp_ui.vip_txt.text = "VIP"..data[i].vip_level
				temp_ui.confirm_btn.onClick:AddListener(
					function ()
						ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
						HintPanel.Create(2,"撤回请求后，需要等待拜师冷却后\n才能再次拜师哦，确认删除吗？",function ()
							Network.SendRequest("change_message_from_apprentice",{master_id = data[i].player_id,message_type = 1})
							b.gameObject:SetActive(false)
						end)
					end
				)
				self:AutoSetSibling(b)
			end
			if data[i].type == 3 then 
				local b = GameObject.Instantiate(self.broke_item,self.Content)
				LuaHelper.GeneratingVar(b.transform, temp_ui)
				b.name = "broke_item"
				b.gameObject:SetActive(true)
				URLImageManager.UpdateHeadImage(data[i].head_image,temp_ui.head_img)
				temp_ui.name_txt.text = data[i].player_name
				temp_ui.vip_txt.text = "VIP"..data[i].vip_level
				temp_ui.confirm_btn.onClick:AddListener(
					function ()
						ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
						Network.SendRequest("change_message_from_apprentice",{master_id = data[i].player_id,message_type = 4})
						b.gameObject:SetActive(false)
					end
				)
				self:AutoSetSibling(b)
			end
			if data[i].type == 5 then 
				local b = GameObject.Instantiate(self.repair_item,self.Content)
				LuaHelper.GeneratingVar(b.transform, temp_ui)
				b.name = "repair_item"
				b.gameObject:SetActive(true)
				URLImageManager.UpdateHeadImage(data[i].head_image,temp_ui.head_img)
				temp_ui.name_txt.text = data[i].player_name
				temp_ui.vip_txt.text = "VIP"..data[i].vip_level
				temp_ui.confirm_btn.onClick:AddListener(
					function ()
						ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
						Network.SendRequest("change_message_from_apprentice",{master_id = data[i].player_id,message_type = 2},"",function (data)
							if data and data.result == 0 then 
								self:CreateTeacher(data[i])
								HintPanel.Create(1,"恭喜你,玩家【"..data[i].player_name.."】成为了您的师父")
							end 
						end)
						b.gameObject:SetActive(false)				
					end
				)
				self:AutoSetSibling(b)
			end
			if data[i].type == 7 then 
				local b = GameObject.Instantiate(self.refuse_item,self.Content)
				LuaHelper.GeneratingVar(b.transform, temp_ui)
				b.name = "refuse_item"
				b.gameObject:SetActive(true)
				URLImageManager.UpdateHeadImage(data[i].head_image,temp_ui.head_img)
				temp_ui.name_txt.text = data[i].player_name
				temp_ui.vip_txt.text = "VIP"..data[i].vip_level
				temp_ui.confirm_btn.onClick:AddListener(
					function ()
						ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
						Network.SendRequest("change_message_from_apprentice",{master_id = data[i].player_id,message_type = 3})
						b.gameObject:SetActive(false)
					end
				)
				self:AutoSetSibling(b)
			end
		end
	end 
end

function C:Refresh_Info_UI(data)
	local temp_ui = {}
	if data and data.result == 0 then 
		if not table_is_null(data.master_info)  then 
			for i=1,#data.master_info do
				self:CreateTeacher(data.master_info[i])
			end
		else
			LittleTips.Create("您还没有师父")
		end 
	end
end

function C:CreateTeacher(data)
	local temp_ui = {}
	if data.is_not_my_master == 1 then 
		local b = GameObject.Instantiate(self.repair_item,self.Content)
		LuaHelper.GeneratingVar(b.transform, temp_ui)
		b.name = "repair_item"
		b.gameObject:SetActive(true)
		URLImageManager.UpdateHeadImage(data.head_image,temp_ui.head_img)
		temp_ui.name_txt.text = data.player_name
		temp_ui.vip_txt.text = "VIP"..data.vip_level
		temp_ui.like_txt.text = data.total_like_num
		temp_ui.confirm_btn.onClick:AddListener(
			function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
				Network.SendRequest("change_info_from_apprentice",{master_id = data.master_id,message_type = 2})
				b.gameObject:SetActive(false)
				Event.Brocast("tp_CloseTHENOpen","MyTeacher")
			end
		)
	else
		local b = GameObject.Instantiate(self.teacher_item,self.Content)
		LuaHelper.GeneratingVar(b.transform, temp_ui)
		b.name = "teacher_item"
		b.gameObject:SetActive(true)
		URLImageManager.UpdateHeadImage(data.head_image,temp_ui.head_img)
		temp_ui.name_txt.text = data.player_name
		temp_ui.like_red.gameObject:SetActive(not self:CheakIsLikeToday(data.master_id,MainModel.UserInfo.user_id))
		temp_ui.task_red.gameObject:SetActive(false)
		temp_ui.like_txt.text = data.total_like_num
		temp_ui.vip_txt.text = "VIP"..data.vip_level
		if data.online_status == 1 then 
			temp_ui.time_txt.text = self:GetTimeLineStr(tonumber(data.last_exit_time))
			temp_ui.time_txt.color = Color.gray
		else
			temp_ui.time_txt.text = "在线"
			temp_ui.time_txt.color = Color.New(220/255,139/255,66/255,1)
		end
		temp_ui.like_btn.onClick:AddListener(
			function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
				Network.SendRequest("click_like",{master_id = data.master_id})
				temp_ui.like_red.gameObject:SetActive(false)
				curr_like_ids.teacher_id = data.master_id
				curr_like_ids.pupil_id = MainModel.UserInfo.user_id
			end
		)
		temp_ui.broke_btn.onClick:AddListener(
			function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
				BrokeTPPanel.Create(nil,data,"P")
			end
		)
		if not table_is_null(data.task_data) and data.task_data.award_status ~= 2 then 
			temp_ui.task_red.gameObject:SetActive(true)	
		else
			temp_ui.task_red.gameObject:SetActive(false)	
		end 
		temp_ui.task_btn.onClick:RemoveAllListeners()
		temp_ui.task_btn.onClick:AddListener(
			function()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
				if not table_is_null(data.task_data) then 
					ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
					TpTaskPanel.Create(nil,data.task_data,"Pupil")
				else
					ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
					HintPanel.Create(1,"您的师傅还没有发布任务哦")
				end	
			end
		)
	end 
	self:AutoSetSibling(b)
end


function C:OnDestroy()
	self:MyExit()
end

function C:Teacher_Notify_Finsh()
	dump(SYSSTXTManager.Get_Teacher_Notify(),"Get_Teacher_Notify")
	self:Refresh_Notify_UI(SYSSTXTManager.Get_Teacher_Notify())
end

function C:Teacher_Info_Finsh()
	dump(SYSSTXTManager.Get_Teacher_Info(),"Get_Teacher_Info")
	self:Refresh_Info_UI(SYSSTXTManager.Get_Teacher_Info())
end

function C:on_click_like_response(_,data)
	dump(data,"on_click_like_response")
	if data and data.result == 0 then
		HintPanel.Create(1,"点赞成功")
		self:SetLikeToday(curr_like_ids.teacher_id,curr_like_ids.pupil_id)
	elseif data and data.result == 5512 then 
		HintPanel.ErrorMsg(data.result)
		self:SetLikeToday(curr_like_ids.teacher_id,curr_like_ids.pupil_id)
	else
		HintPanel.ErrorMsg(data.result)
	end 
end

function C:CheakIsLikeToday(t_id,p_id)
	local b = PlayerPrefs.GetInt(t_id.."@"..p_id..os.date("%Y%m%d",os.time()),0)
	if b == 1 then 
		return true
	else
		return false
	end 
end

function C:SetLikeToday(t_id,p_id)
	PlayerPrefs.SetInt(t_id.."@"..p_id..os.date("%Y%m%d",os.time()),1)
end

function C:GetTimeLineStr(time)
	if not time then return "已下线" end 
	if os.time() - time >= 0 and os.time() - time <= 24 * 3600 then
		if  os.time() - time <= 3600 then
			return math.floor((os.time() - time)/60).."分钟前"
		end 
		return math.floor((os.time() - time)/3600).."小时前"
	elseif os.time() - time > 24 * 3600 then
		return math.floor((os.time() - time)/86400).."天前"
	end 
end