-- 创建时间:2020-03-09
-- Panel:Act_020HBFXHistoryPanel
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

Act_020HBFXHistoryPanel = basefunc.class()
local C = Act_020HBFXHistoryPanel
C.name = "Act_020HBFXHistoryPanel"

local button_mask = {"ZDJL_MASK","TZSB_MASK"}
local node = {"zd_node","sb_node"}

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
	self.lister["query_npca_slave_data_list_response"] = basefunc.handler(self,self.on_query_npca_slave_data_list_response)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

-- succeed 1 : *npca_challenge_info # 组队挑战的玩家信息
-- challenge_defeated 2 : *npca_challenge_info # 组队挑战的玩家信息
-- defeated 3 : *npca_challenge_info # 组队挑战的玩家信息

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	Network.SendRequest("query_npca_slave_data_list")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:OnSwitchButtonClick(1)
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self.confirm_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			-- local share_cfg = basefunc.deepcopy(share_link_config.img_yql48)
			-- GameManager.GotoUI({gotoui = "sys_fx",goto_scene_parm = "panel",share_cfg = share_cfg})
			Act_020HBFXManager.Share()
		end
	)
	self.ZDJL_btn.onClick:AddListener(function ()
		self:OnSwitchButtonClick(1)
	end)
	self.TZSB_btn.onClick:AddListener(function ()
		self:OnSwitchButtonClick(2)
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	
end

function C:OnSwitchButtonClick(index)
	for i = 1,#button_mask do 
		self[button_mask[i]].gameObject:SetActive(false)
		self[node[i]].gameObject:SetActive(false)
	end
	self[button_mask[index]].gameObject:SetActive(true)
	self[node[index]].gameObject:SetActive(true)
end

function C:on_query_npca_slave_data_list_response(_,data)
	dump(data,"<color=red>组队历史记录</color>")
	if data and data.result == 0 then
		local temp_ui = {}	
		if #data.succeed == 1 then	
			
		elseif #data.succeed >= 2 and #data.succeed <= 3 then
			local b = GameObject.Instantiate(self.zd_item,self.zd_parent)
			b.gameObject:SetActive(true)
			LuaHelper.GeneratingVar(b.transform, temp_ui)
			temp_ui.tzcg_txt.gameObject:SetActive(true)
			temp_ui.tzsb_txt.gameObject:SetActive(false)
			URLImageManager.UpdateHeadImage(data.succeed[1].head_image, temp_ui.head1_img)
			URLImageManager.UpdateHeadImage(data.succeed[2].head_image, temp_ui.head2_img)
			temp_ui.time_txt.text =  os.date("%m月%d日",data.succeed[1].challenge_time) 
		elseif #data.succeed == 4 then 
			for i = 1,2 do 
				local b = GameObject.Instantiate(self.zd_item,self.zd_parent)
				b.gameObject:SetActive(true)
				LuaHelper.GeneratingVar(b.transform, temp_ui)
				temp_ui.tzcg_txt.gameObject:SetActive(true)
				temp_ui.tzsb_txt.gameObject:SetActive(false)
				URLImageManager.UpdateHeadImage(data.succeed[i].head_image, temp_ui.head1_img)
				URLImageManager.UpdateHeadImage(data.succeed[i + 1].head_image, temp_ui.head2_img)
				temp_ui.time_txt.text =  os.date("%m月%d日",data.succeed[i].challenge_time) 
			end
		end
		
		if #data.succeed <= 1 and #data.challenge_defeated == 0 then
			LittleTips.Create("暂无组队挑战记录，快去邀请好友挑战吧~")
		end
		for i = 1,#data.challenge_defeated  do 
			local b = GameObject.Instantiate(self.zd_item,self.zd_parent)
			b.gameObject:SetActive(true)
			LuaHelper.GeneratingVar(b.transform, temp_ui)
			temp_ui.tzcg_txt.gameObject:SetActive(false)
			temp_ui.tzsb_txt.gameObject:SetActive(true)
			URLImageManager.UpdateHeadImage(data.challenge_defeated[i].head_image, temp_ui.head1_img)
			temp_ui.time_txt.text =  os.date("%m月%d",data.challenge_defeated[i].challenge_time) 
		end

		for i = 1,#data.defeated  do 
			local b = GameObject.Instantiate(self.sb_item,self.sb_parent)
			b.gameObject:SetActive(true)
			LuaHelper.GeneratingVar(b.transform, temp_ui)
			temp_ui.tzcg_txt.gameObject:SetActive(false)
			temp_ui.tzsb_txt.gameObject:SetActive(true)
			URLImageManager.UpdateHeadImage(data.defeated[i].head_image, temp_ui.head1_img)
			temp_ui.time_txt.text =  os.date("%m月%d日",data.defeated[i].challenge_time) 
		end
	end
end