-- 创建时间:2020-06-28

local basefunc = require "Game/Common/basefunc"

BY3DKPSHBEnterPanel = basefunc.class()
local C = BY3DKPSHBEnterPanel
C.name = "BY3DKPSHBEnterPanel"
local M = BY3DKPSHBManager
local g_num

local ui_data

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
    self.lister["by3d_kpshb_refresh_gun"] = basefunc.handler(self, self.on_refresh_gun)
    self.lister["kpshb_model_task_change_msg"] = basefunc.handler(self,self.on_kpshb_model_task_change_msg)
    self.lister["crr_level_state_change_msg"] = basefunc.handler(self,self.on_crr_level_state_change_msg)
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

function C:ctor(parm)
	self.parm=parm

	local parent = parm.parent
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
	self.dajindu = self.dajindu.transform:GetComponent("Slider")
	self.xiaojindu = self.xiaojindu.transform:GetComponent("Slider")

	self.hbui_list = {}
	self.hbui_list[#self.hbui_list + 1] = {self.hb1_img}
	self.hbui_list[#self.hbui_list + 1] = {self.hb2_img, self.hb3_img}
	self.hbui_list[#self.hbui_list + 1] = {self.hb4_img, self.hb5_img, self.hb6_img}

	self.choujiang_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnCJClick()
	end)
	self.shuoming_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		KPSHBSMPrefabPanel.Create()
    end)
    self.choujiang_no_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnCJClick()
	end)

    self.goto_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		M.GuidePlayerGoGJC(true)
	end)

    self.jd_width = 456
	self.fx_obj = GameObject.Instantiate(GetPrefab("BY3DKPSHBEnterPanel_Slidernode_glow"), self.fx_node)
	self.fx_obj.transform.localPosition = Vector3.zero

	self:MyRefresh()
end

function C:MyRefresh()
	self.ui_config = M.GetConfigByGameID(FishingModel.game_id)

	for k,v in ipairs(self.ui_config.hb) do
		self["jiangli"..k.."_txt"].text = ""..StringHelper.ToCash(v / 100)
	end
	self.hint_red_txt.text = "最高" .. StringHelper.ToCash(self.ui_config.show_hb / 100)
	self:RefreshProgressUI()
	self:RefreshJD()

	self:RefreshTaskLv()
end

function C:RefreshJD()
	self.need_txt.text = string.format("差%s炮", M.GetGunRateSurNum( M.GetCurTaskLv() ))	
end

function C:on_refresh_gun()
	self:RefreshJD()
end

function C:on_kpshb_model_task_change_msg()
	self:RefreshProgressUI()
	self:RefreshJD()
end

function C:RefreshProgressUI()
	local task = GameTaskModel.GetTaskDataByID( M.GetCurrTaskID() )
	local lv = M.GetCurTaskLv()
	if task then
		local pro_value = string.format("%.2f", task.now_process/task.need_process)
		self.xiaojindu.value = pro_value
		if lv == 1 then		
			self.dajindu.value = 0.22*pro_value
		elseif lv == 2 then 
	    	self.dajindu.value = 0.26*pro_value + 0.22
	    elseif lv == 3 then
			self.dajindu.value = 0.52*pro_value + 0.48
		end
		if self.dajindu.value > 0.024 then
			self.fx_obj:SetActive(true)
			self.fx_obj.transform.localPosition = Vector3.New(self.dajindu.value * self.jd_width, 0, 0)
		else
			self.fx_obj:SetActive(false)
		end
	end

	if self.dajindu.value == 1 then
		self.Text.gameObject:SetActive(false)
		self.need_txt.gameObject:SetActive(false)
		self.Text2.gameObject:SetActive(false)
		self.Text3.gameObject:SetActive(true)
		self.Handle3_img.sprite = GetTexture("kpshb_jdtbg_jd2")
		self.guang3.gameObject:SetActive(true)
		self.guang2.gameObject:SetActive(false)
		self.hb2_img.color = Color.New(0.54, 0.54, 0.54, 1)
		self.hb3_img.color = Color.New(0.54, 0.54, 0.54, 1)
		self.fuliquan_img.transform.localPosition = Vector3.New(111, 0, 0)
	else
		self.Text.gameObject:SetActive(true)
		self.need_txt.gameObject:SetActive(true)
		self.Text2.gameObject:SetActive(true)      
		self.Text3.gameObject:SetActive(false)
		self.fuliquan_img.transform.localPosition = Vector3.New(356, 0, 0)
	end
end

function C:RefreshTaskLv()
	self.guang1.gameObject:SetActive(false)
	self.guang2.gameObject:SetActive(false)
	self.guang3.gameObject:SetActive(false)
	self.Handle1_img.sprite = GetTexture("kpshb_jdtbg_jd1")
	self.Handle2_img.sprite = GetTexture("kpshb_jdtbg_jd1")
	self.Handle3_img.sprite = GetTexture("kpshb_jdtbg_jd1")


	local lv = M.GetCurTaskLv()
	local wc_lv
	if lv == 1 then
		self.fuliquan_img.sprite = GetTexture("kpshb_imgf_ptflq")
		wc_lv = 0
	elseif lv == 2 then
		wc_lv = 1
		self.Handle1_img.sprite = GetTexture("kpshb_jdtbg_jd2")
		self.fuliquan_img.sprite = GetTexture("kpshb_imgf_gjflq")
	else
		self.Handle1_img.sprite = GetTexture("kpshb_jdtbg_jd2")
		self.Handle2_img.sprite = GetTexture("kpshb_jdtbg_jd2")
		self.fuliquan_img.sprite = GetTexture("kpshb_imgf_cjflq")

		local task = GameTaskModel.GetTaskDataByID( M.GetCurrTaskID() )
		if task.now_process >= task.need_process then
			wc_lv = 3
			self.Handle3_img.sprite = GetTexture("kpshb_jdtbg_jd2")
		else
			wc_lv = 2
			self.Handle3_img.sprite = GetTexture("kpshb_jdtbg_jd1")
		end
	end
	if wc_lv > 0 then
		self["guang"..wc_lv].gameObject:SetActive(true)

	end
	-- 
	for i = 1, 3 do
		for k,v in ipairs(self.hbui_list[i]) do
			if i < wc_lv then
				v.color = Color.New(0.54, 0.54, 0.54, 1)
			else
				v.color = Color.New(1, 1, 1, 1)
			end
		end
	end
	
	local b = M.IsCanGetAward()
	self.choujiang_btn.gameObject:SetActive(b)
	self.choujiang_no_btn.gameObject:SetActive(not b)

	if M.IsRedGetReachMax( FishingModel.game_id ) then
		self.root_yes.gameObject:SetActive(false)
		self.root_no.gameObject:SetActive(true)
	else
		self.root_yes.gameObject:SetActive(true)
		self.root_no.gameObject:SetActive(false)
	end
end

--任务阶段改变
function C:on_crr_level_state_change_msg()
	self:RefreshTaskLv()
end

function C:OnCJClick()
	KPSHBLotteryPanel.Create()
end

function C:NoCJClick()
	local task = GameTaskModel.GetTaskDataByID( M.GetCurrTaskID() )
	local name 
	local lv = M.GetCurTaskLv()
	if task then
		if lv == 1 then
			name = "普通福卡"
		elseif lv == 2 then
			name = "高级福卡"
		else
			name = "超级福卡"
		end
 	end	
	LittleTips.Create(string.format( "还差%s炮可抽%s。", M.GetGunRateSurNum( M.GetCurTaskLv() ), name))	
end