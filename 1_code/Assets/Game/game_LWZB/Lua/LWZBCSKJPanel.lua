-- 创建时间:2020-09-25
-- Panel:LWZBCSKJPanel
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

LWZBCSKJPanel = basefunc.class()
local C = LWZBCSKJPanel
C.name = "LWZBCSKJPanel"
local M = LWZBModel
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
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["EnterBackGround"] = basefunc.handler(self,self.on_background_msg)--切到后台
    self.lister["lwzb_force_exit_qlcf_or_settel_msg"] = basefunc.handler(self,self.on_lwzb_force_exit_qlcf_or_settel_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:StopTimer()
	self:CloseItemPrefab()
	self:CloseItemPrefabLast()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	ExtendSoundManager.PlaySound(audio_config.lwzb.bgm_lwzb_cs_bg.audio_name)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	Event.Brocast("lwzb_cskjpanel_has_create_msg")
	local data = M.GetAllInfo()
	local big_data = data.settle_data.qlcf_big_award
	self.curraward_txt.text = big_data.award_value
	self.award_txt.text = LWZBManager.PoolFormat(data.status_data.qlcf_award_pool)
	self:MyRefresh()
	self:CreateItemPrefab()
end

function C:MyRefresh()
end

function C:ScrollBigGame(item_list,data_list,parent,callback,sp_callback)
	if not IsEquals(parent) then return end
	destroyChildren(parent)
	local material_FrontBlur = GetMaterial("FrontBlur")
	local time = self:GetTime(14)
	local spacing = 170
	local obj_list = {}
	for i=1,#item_list do
		local pre = GameObject.Instantiate(item_list[i],parent).gameObject
		obj_list[#obj_list + 1] = pre
		URLImageManager.UpdateHeadImage(data_list[i].head_image, obj_list[#obj_list].transform:Find("@icon_img"):GetComponent("Image"))
		obj_list[#obj_list].transform:Find("@fh").gameObject:SetActive(self:CheckIsFH(data_list[i].player_id))  
		obj_list[#obj_list].transform:Find("@xyx").gameObject:SetActive(self:CheckIsXYX(data_list[i].player_id))
		obj_list[#obj_list].transform:Find("@lw").gameObject:SetActive(self:CheckIsLw(data_list[i].player_id))
	end
	for i=1,7 do
		local pre = GameObject.Instantiate(item_list[i],parent).gameObject
		obj_list[#obj_list + 1] = pre
		URLImageManager.UpdateHeadImage(data_list[i].head_image, obj_list[#obj_list].transform:Find("@icon_img"):GetComponent("Image"))
		obj_list[#obj_list].transform:Find("@fh").gameObject:SetActive(self:CheckIsFH(data_list[i].player_id))  
		obj_list[#obj_list].transform:Find("@xyx").gameObject:SetActive(self:CheckIsXYX(data_list[i].player_id))
		obj_list[#obj_list].transform:Find("@lw").gameObject:SetActive(self:CheckIsLw(data_list[i].player_id))
	end
	self:MoveTimer(true,obj_list)

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(6)
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.lwzb.bgm_lwzb_cs_zhuandong.audio_name)
		--[[self.obj_txt.text = #obj_list
		self.item_txt.text = #item_list
		self.big_txt.text = self:GetBigAwardIndex()--]]
	end)
	if sp_callback and type(sp_callback) == "function" then
		sp_callback()
	end	
	local xx = 0
	xx = self:GetBigAwardIndex() - 4
	local t_x = parent.localPosition.x - spacing * (9*(#obj_list - 7) + xx) + 5
	seq:Append(parent.transform:DOLocalMoveX(t_x, time))
	seq:SetEase(DG.Tweening.Ease.OutCirc)
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.lwzb.bgm_lwzb_cs_tingzhi.audio_name)
	end)
	--seq:AppendInterval(0.2)
	seq:OnComplete(function ()	
		LWZBCSDJTJPanel.Create()
		seq:Kill()		
	end)
	seq:OnForceKill(function ()
		self:MyExit()
	end)
	--[[seq:InsertCallback(12,function ()
		--ExtendSoundManager.PlaySound(audio_config.lwzb.bgm_lwzb_cs_tingzhi.audio_name)
		LWZBCSDJTJPanel.Create()
		seq:Kill()
		self:MyExit()
	end)--]]
	
end

function C:MoveTimer(b,obj_tab)
	self:StopTimer()
	if b then
		self.showtime = 0
		self.c = 0
		self.move_timer = Timer.New(function ()
			self.showtime = self.showtime + 0.02
			if self.showtime > 0.5 and not self.gameObject.activeSelf then
				self.gameObject:SetActive(true)
			end
			if self.c == 0 and self.box_rect.transform.localPosition.x <= -510-((#obj_tab-7)*170) then
				self.c = 1
				for i=1,#obj_tab do
					obj_tab[i].transform.localPosition = Vector3.New(((#obj_tab-7) + i - 1)*170,0,0)
				end
			elseif self.c == 1 and self.box_rect.transform.localPosition.x <= -510-(2*(#obj_tab-7)*170) then
				self.c = 2
				for i=1,#obj_tab do
					obj_tab[i].transform.localPosition = Vector3.New((2*(#obj_tab-7) + i - 1)*170,0,0)
				end
			elseif self.c == 2 and self.box_rect.transform.localPosition.x <= -510-(3*(#obj_tab-7)*170) then
				self.c = 3
				for i=1,#obj_tab do
					obj_tab[i].transform.localPosition = Vector3.New((3*(#obj_tab-7) + i - 1)*170,0,0)
				end
			elseif self.c == 3 and self.box_rect.transform.localPosition.x <= -510-(4*(#obj_tab-7)*170) then
				self.c = 4
				for i=1,#obj_tab do
					obj_tab[i].transform.localPosition = Vector3.New((4*(#obj_tab-7) + i - 1)*170,0,0)
				end
			elseif self.c == 4 and self.box_rect.transform.localPosition.x <= -510-(5*(#obj_tab-7)*170) then
				self.c = 5
				for i=1,#obj_tab do
					obj_tab[i].transform.localPosition = Vector3.New((5*(#obj_tab-7) + i - 1)*170,0,0)
				end
			elseif self.c == 5 and self.box_rect.transform.localPosition.x <= -510-(6*(#obj_tab-7)*170) then
				self.c = 6
				for i=1,#obj_tab do
					obj_tab[i].transform.localPosition = Vector3.New((6*(#obj_tab-7) + i - 1)*170,0,0)
				end
			elseif self.c == 6 and self.box_rect.transform.localPosition.x <= -510-(7*(#obj_tab-7)*170) then
				self.c = 7
				for i=1,#obj_tab do
					obj_tab[i].transform.localPosition = Vector3.New((7*(#obj_tab-7) + i - 1)*170,0,0)
				end
			elseif self.c == 7 and self.box_rect.transform.localPosition.x <= -510-(8*(#obj_tab-7)*170) then
				self.c = 8
				for i=1,#obj_tab do
					obj_tab[i].transform.localPosition = Vector3.New((8*(#obj_tab-7) + i - 1)*170,0,0)
				end
			elseif self.c == 8 and self.box_rect.transform.localPosition.x <= -510-(9*(#obj_tab-7)*170) then
				self.c = 9
				for i=1,#obj_tab do
					obj_tab[i].transform.localPosition = Vector3.New((9*(#obj_tab-7) + i - 1)*170,0,0)
				end
			elseif self.c == 9 and self.box_rect.transform.localPosition.x <= -510-(10*(#obj_tab-7)*170) then
				self.c = 10
				for i=1,#obj_tab do
					obj_tab[i].transform.localPosition = Vector3.New((10*(#obj_tab-7) + i - 1)*170,0,0)
				end
			end
		end,0.02,-1)
		self.move_timer:Start()
	end
end

function C:StopTimer()
	if self.move_timer then
		self.move_timer:Stop()
		self.move_timer = nil
	end
end

function C:GetTime(t,speed)
	local speed = speed or 1
    local t = t or 1
    if speed then
        return t / speed / 2
    end
    return t / speed / 2
end

function C:CreateItemPrefab()
	local data = M.GetAllInfo()
	local qlcf_img_list = data.settle_data.qlcf_image_list
	local tab1 = {}
	dump({is_i = self:CheckIisInList()},"<color=red>||||||||||||||||||||||||||</color>")
	if self:CheckIisInList() then--如果我在表里,就调整到第4个位置
		for i=1,#qlcf_img_list do
			if i ~= self.I_index then
				if #tab1 == 3 then
					tab1[#tab1 + 1] = qlcf_img_list[self.I_index]
				else
					tab1[#tab1 + 1] = qlcf_img_list[i]
				end
			else
				--
			end
		end
	else--如果我不在表里,就前端自己插入第4个位置
		for i=1,3 do
			tab1[i] = qlcf_img_list[i]
		end
		local temp = {}
		temp.head_image = MainModel.UserInfo.head_image
		temp.player_id = MainModel.UserInfo.user_id
		tab1[#tab1 + 1] = temp
		for i=4,#qlcf_img_list do
			tab1[#tab1 + 1] = qlcf_img_list[i]
		end
	end
	self.tab1 = tab1
	self:CloseItemPrefab()
	for i=1,#tab1 do
		local pre = newObject("LWZBCSDJHeadItemPanel", self.inst_node.transform)
		self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
	end
	dump(self.spawn_cell_list,"<color>999999999999---------------9999999999999999</color>")
	self:ScrollBigGame(self.spawn_cell_list,tab1,self.box_rect)
end

function C:CloseItemPrefab()
	if not table_is_null(self.spawn_cell_list) then
		for k,v in pairs(self.spawn_cell_list) do
			destroy(v.gameObject)
		end
	end
	self.spawn_cell_list = {}
end

function C:CloseItemPrefabLast()
	if not table_is_null(self.spawn_cell_list_last) then
		for k,v in pairs(self.spawn_cell_list_last) do
			destroy(v.gameObject)
		end
	end
	self.spawn_cell_list_last = {}
end

function C:CheckIisInList()
	local data = M.GetAllInfo()
	local qlcf_img_list = data.settle_data.qlcf_image_list
	for i=1,#qlcf_img_list do
		if qlcf_img_list[i].player_id == MainModel.UserInfo.user_id then
			self.I_index = i
			return true
		end
	end
	self.I_index = nil
	return false
end


function C:GetBigAwardIndex()
	local data = M.GetAllInfo()
	local big_data = data.settle_data.qlcf_big_award
	local qlcf_img_list = self.tab1--data.settle_data.qlcf_image_list
	local big_id = big_data.player_info.player_id
	for i=1,#qlcf_img_list do
		if qlcf_img_list[i].player_id == big_id then
			return i
		end
	end
end

function C:on_background_msg()
	self:MyExit()
end

function C:on_lwzb_force_exit_qlcf_or_settel_msg()
	self:MyExit()
end

--判断是不是富豪
function C:CheckIsFH(id)
	local all_info = M.GetAllInfo()
	local fuhao = all_info.fuhao_rank
	--dump(fuhao,"<color=green>+++++++fuhao+++++++++</color>")
	if fuhao[1].player_info.player_id == id then
		return true
	end
	return false
end

--判断是不是幸运星
function C:CheckIsXYX(id)
	local all_info = M.GetAllInfo()
	local xyx = all_info.lucky_star
	--dump(xyx,"<color=green>++++++xyx++++++++++</color>")
	if xyx.player_info.player_id == id then
		return true
	end
	return false
end

--判断是不是龙王
function C:CheckIsLw(id)
	local all_info = M.GetAllInfo()
	local dragon = all_info.dragon_info
	--dump(dragon,"<color=green>++++++dragon++++++++++</color>")
	if dragon.player_info.player_id == id then
		return true
	end
	return false
end
