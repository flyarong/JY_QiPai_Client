
local basefunc = require "Game/Common/basefunc"
EliminateXYHeroManager = basefunc.class()
local M = EliminateXYHeroManager
M.name = "EliminateXYHeroManager"
--BGJ：白骨精
--SWK：唐僧
local bgj_img_index = 1
local bgj_img_round = {
	"村姑","妇人","老夫","白骨精"
}
local default_Active_Node = {"hero2_model1","hero1_model1",}
local default_UnActive_Node = {"hero2_model2","hero2_model3","hero2_model4","hero2_lottery","hero2_jc","bgj_sp_item","hero2_jc_mini","hero2_pro","hero1_lottery",
		"hero3_mf","hero3_mfjj","hero1_hyjj","hero4_lottery",
		"hero1_speak_1","hero1_speak_2","hero1_speak_3","hero1_speak_4","hero1_speak_5",
		"hero2_speak_1","hero2_speak_2","hero2_speak_3","hero2_speak_4",
		"hero1_pra1","hero1_pra2","hero1_pra3","hero1_dj","hero1_hyjj","hero1_bg",
		"hero2_hby","hero2_bs","hero2_cx","hero2_yj",
		"hero3_mfcszj","hero3_mfyxjr","hero3_mfdd","hero3_mfyxbk",
		"h4_node1","h1_node1","bg_cj","hero3_jc","tishi",
		"node5_huo1","node5_huo2","node5_huo3","node5_huo4","node5_huo5"}
local  instance
local base_anim_config = {
	pc_1 = 0.04, -- 血条动画分割线1
	pc_2 = 0.09, -- 血条动画分割线2
	mc_1 = 4, --第二种血条动画的黄色速度
	mc_2 = 3, -- 第三种方式黄色血条速度
	mc_3 = 2,  	--第二种血条动画的绿色速度
	mc_4 = 3.5, --第三种方式绿色血条速度
	de_t = 0.5, --第二种血条动画的绿色延时
}
M.swl_lv1 = 10
M.swl_lv2 = 20

function M.Create(data)
	if not instance then 
		instance =M.New(data)
	else
		return  instance
	end 
end

function M.Exit()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

function M.Refresh()
	if instance then
		instance:MyRefresh()
	end
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
	self.lister = {}
	self.lister["view_lottery_end"]=basefunc.handler(self,self.view_lottery_end)
	self.lister["view_lottery_start"]=basefunc.handler(self,self.view_lottery_start)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
	M:StopAnimTimers()
	if self.glow_timer then 
		self.glow_timer:Stop()
		self.glow_timer = nil
		self.glow.gameObject:SetActive(false)
	end
	if self.jc_CG_timer then
		self.jc_CG_timer:Stop()
		self.jc_CG_timer = nil
	end
	self:RemoveListener()

	for i=1,1 do
		self["swk_icon" .. i .. "_img"].sprite = nil
	end
	self.P_G.sprite = nil
	self.P_G2.sprite = nil

	destroy(self.gameObject)
end

function M:ctor(data)
	ExtPanel.ExtMsg(self)

	if data==nil then data={} end 
	local parent = data.parent or GameObject.Find("Canvas/LayerLv1").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)	
	for i=1,1 do
		self["swk_icon" .. i .. "_img"] = self["EliminateXYItemSWK" .. i].transform:Find("@icon_img"):GetComponent("Image")
	end
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.award_txt.gameObject.transform.sizeDelta = Vector2.New(320,42)
	--self:SetProg(1,true)
	-- self:SetProg(1 - 0.03,false,function ()
	-- 	Timer.New(function ()
	-- 		self:SetProg(1 - 0.03 - 0.08,false,function ()
	-- 			Timer.New(function ()
	-- 				self:SetProg(0)
	-- 			end,3,1):Start()
	-- 		end)
	-- 	end,3,1):Start()
	-- end)
end

function M:InitUI()
	self.P_G = self.Progress_PG.transform:GetComponent("Image")
	self.P_G2 = self.Progress_PG2.transform:GetComponent("Image")
	self.task_sett_ani = self.Hero.transform:GetComponent("Animator")
	self.jc_mini_ani = self.hero2_jc_mini.transform:GetComponent("Animator")
	self.jc_CG = self.hero2_jc.transform:GetComponent("CanvasGroup")
	self.xxl_xy_jiangchi_chuxu = self.hero2_jc_mini.transform:Find("bai/xxl_xy_jiangchi_chuxu")
	self.free_bg = GameObject.Find("Canvas/GUIRoot/EliminateXYGamePanel/free_bg")
	self.xxl_xy_swk_yj_kuang = self.hero1_lottery:Find("xxl_xy_swk_yj_kuang")
	self.bgj_yj_txt = self.hero2_yj.transform:Find("tx/@num_txt_tx"):GetComponent("Text")
	EventTriggerListener.Get(self.hongbao_btn.gameObject).onClick = basefunc.handler(self, self.HBHint)
	self:MyRefresh()
end

function M:MyRefresh()
	local data = EliminateXYModel.data
	self:HeroReset()
	M.RefreshTask()
	if not data.eliminate_data or not data.eliminate_data.result then return end
	if data.is_new then return end
	local last_data = data.eliminate_data.result[#data.eliminate_data.result]
	if not table_is_null(last_data.swk_map_new) then
		M.SetBigGameState(last_data)
	elseif not table_is_null(last_data.map_new) then
		M.BGJModelShow(1)
	end
	if not instance.camer then
		instance.camer = GameObject.Find("Camera")
	end
	instance.camer.transform.localPosition = Vector3.New(0,0,-406)
end

function M:view_lottery_end()
	self:MyRefresh()
end

function M:view_lottery_start()
	self:HeroReset()
	M.RefreshTask()
	M.BGJModelShow(1)
end

function M:HBHint()
	local td = EliminateXYModel.GetTaskData()
	if table_is_null(td) then 
		LittleTips.Create("击败白骨精，即可获得红包奖励！")
	end
	local offset = td.need_process - td.now_process
	offset = StringHelper.ToCash(offset)
	LittleTips.Create("普通游戏中再消除".. offset .."，即可获得红包奖励！")
end

function M.ViewFreeBG(b)
	if not instance  then return end
	instance.free_bg.gameObject:SetActive(b)
end

function M.BGJModelShow(index)
	if not instance then return end
	if not index then index = 1 end
	if index > 4 or index < 1 then index = 1 end
	instance.hero2_model1.gameObject:SetActive(index == 1)
	instance.hero2_model2.gameObject:SetActive(index == 2)
	instance.hero2_model3.gameObject:SetActive(index == 3)
	instance.hero2_model4.gameObject:SetActive(index == 4)
	if index ~= 1 then
		M.BGJSpeak(index)
	end
end

function M.BGJSpeak(index,s1_show)
	instance.hero2_speak_1.gameObject:SetActive(index == 1)
	instance.hero2_speak_2.gameObject:SetActive(index == 2)
	instance.hero2_speak_3.gameObject:SetActive(index == 3)
	instance.hero2_speak_4.gameObject:SetActive(index == 4)
	if index ~= 1 then
		local i = index - 1
		ExtendSoundManager.PlaySound(audio_config.sdbgj["bgm_sdbgj_bgj_" .. i].audio_name)
	else
		-- ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_swk_bgj_duihua.audio_name)
	end
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateXYModel.GetTime(5))
	seq:AppendCallback(function(  )
		if not instance then return end
		if index == 1 then
			instance.hero2_speak_1.gameObject:SetActive(false)
		elseif index == 2 then
			instance.hero2_speak_2.gameObject:SetActive(false)
		elseif index == 3 then
			instance.hero2_speak_3.gameObject:SetActive(false)
		elseif index == 4 then
			instance.hero2_speak_4.gameObject:SetActive(false)
		end
	end)
end

function M:ReSetNodeShowOrHideFunc() 
	for i = 1,#default_Active_Node do
		self[default_Active_Node[i]].gameObject:SetActive(true)
	end
	for i = 1,#default_UnActive_Node do
		self[default_UnActive_Node[i]].gameObject:SetActive(false)
	end		
end

--重置英雄
function M:HeroReset()
	ExtendSoundManager.PlaySceneBGM(audio_config.sdbgj.bgm_sdbgj_beijing.audio_name)
	self:ReSetNodeShowOrHideFunc()
	self.hero2_jc_mini.transform.localPosition = Vector3.New(-34,-50,0)
	self.hero2_jc_mini.transform.localScale = Vector3.one
	self.jc_CG.alpha = 1
	self.jc_mini_ani.enabled = false
	-- self.task_sett_ani.enabled = false
	self.xxl_xy_jiangchi_chuxu.gameObject:SetActive(false)
	self.h4_node.localPosition = Vector3.zero
	self.h4_node1.localPosition = Vector3.New(100,-288,0)
	M.ViewFreeBG(false)
end

--孙悟空技能触发
function M.SWKSkillTrigger(data,cur_del_map)
	if not instance then return end
	local callback = function(  )
		local img
		for i=1,1 do
			img = instance["swk_icon" .. i .. "_img"]
			img.sprite = EliminateXYObjManager.item_obj.xxl_swk_icon_9
		end
		instance.hero1_lottery.localScale = Vector3.one
		instance.hero1_lottery.gameObject:SetActive(true)
		ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_swk_ui.audio_name)
		EliminateXYAnimManager.DOShakePositionCamer(nil,EliminateXYModel.GetTime(1))
	end
	EliminateXYPartManager.XCSWK({cur_del_map = eliminate_xy_algorithm.change_map_to_list(cur_del_map)},callback)
end

function M.SWKSpeak(i)
	if i == 1 then
		instance.hero1_speak_1.gameObject:SetActive(false)
		instance.hero1_speak_1.gameObject:SetActive(true)
		ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_xhz.audio_name)
	elseif i == 2 then
		instance.hero1_speak_2.gameObject:SetActive(false)
		instance.hero1_speak_2.gameObject:SetActive(true)
		ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_jgb.audio_name)
	elseif i == 3 then
		instance.hero1_speak_3.gameObject:SetActive(false)
		instance.hero1_speak_3.gameObject:SetActive(true)
		ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_jg.audio_name)
	elseif i == 4 then
		instance.hero1_speak_4.gameObject:SetActive(false)
		instance.hero1_speak_4.gameObject:SetActive(true)
		ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_hyjj.audio_name)
	elseif i == 5 then
		instance.hero1_speak_5.gameObject:SetActive(false)
		instance.hero1_speak_5.gameObject:SetActive(true)
	end
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateXYModel.GetTime(5))
	seq:AppendCallback(function(  )
		if not instance then return end
		if i == 1 then
			instance.hero1_speak_1.gameObject:SetActive(false)
		elseif i == 2 then
			instance.hero1_speak_2.gameObject:SetActive(false)
		elseif i == 3 then
			instance.hero1_speak_3.gameObject:SetActive(false)
		elseif i == 4 then
			instance.hero1_speak_4.gameObject:SetActive(false)
		elseif i == 5 then
			instance.hero1_speak_5.gameObject:SetActive(false)
		end
	end)
end

function M.SWKYJTX()
	if not instance or not IsEquals(instance.xxl_xy_swk_yj_kuang) then return end
	instance.xxl_xy_swk_yj_kuang.gameObject:SetActive(false)
	instance.xxl_xy_swk_yj_kuang.gameObject:SetActive(true)
end

--孙悟空技能使用
function M.SWKSkillUse(data)
	if not instance then return end
	if not data.swk_skill then return end
	local item_list = {}
	local data_list = {}
	local callback = function()
		--滚动完成
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.swk_yj_hide))
		if instance then 
			seq:Append(instance.hero1_lottery.transform:DOScale(Vector3.zero,EliminateXYModel.GetTime(EliminateXYModel.time.swk_yjsx)))
		end
		seq:OnKill(function(  )
			if not instance then return end
			instance.hero1_lottery.gameObject:SetActive(false)
			instance.hero1_lottery.localScale = Vector3.one
		end)
		seq:OnForceKill(function(  )
			if not instance then return end
			instance.hero1_lottery.gameObject:SetActive(false)
			instance.hero1_lottery.localScale = Vector3.one
		end)
		M.SWKSpeak(data.swk_skill + 1)
	end
	for i=1,1 do
		table.insert(item_list,instance["EliminateXYItemSWK"..i])
		if data.swk_skill == 0 then
			table.insert(data_list,9)
		elseif data.swk_skill == 1 then
			table.insert(data_list,10)
		elseif data.swk_skill == 2 then
			table.insert(data_list,11)
		elseif data.swk_skill == 3 then
			table.insert(data_list,12)
		end
	end
	ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_swk_yj.audio_name)
	EliminateXYAnimManager.ScrollSWKItem(item_list,data_list,callback,instance.h1_node1)
end

--孙悟空技能3元素重摇
function M.SWKSkillUse3(data,cb)
	if not instance then return end
	if not data.swk_skill then return end
	if not data.swk_skill_change_xc then return end
	local item_map = {}
	local data_map = {}
	local rate_map = data.bgj_rate_map
	local callback = function(  )
		--滚动完成
		if not instance then return end
		if cb and type(cb) == "function" then
			cb()
		end
	end

	for x,_v in pairs(data.swk_skill_change_xc) do
		for y,v in pairs(_v) do
			item_map[x] = item_map[x] or {}
			item_map[x][y] = EliminateXYObjManager.GetEliminateItem(x,y).ui.gameObject
			data_map[x] = data_map[x] or {}
			data_map[x][y] = data.swk_skill_change_xc[x][y]
		end
	end

	local seq = DoTweenSequence.Create()
	seq:AppendCallback(function(  )
		instance.hero1_hyjj.gameObject:SetActive(true)
	end)
	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.swk_hyjj))
	seq:AppendCallback(function(  )
		EliminateXYAnimManager.ScrollSWKSkill3(item_map,data_map,rate_map,callback)
	end)
end

--白骨精技能摇奖
function M.BGJSkillUse(next_data)
	if not instance then return end
	instance.hero2_lottery.gameObject:SetActive(true)
	local item_list = {}
	local data_list = {}
	local x_c = eliminate_xy_algorithm.get_xc_count(next_data.xc_change_data)
	local i = 0
	if x_c < 10 then 
		i = 0 
	elseif x_c < 20 then
		i = 1
	else
		i = 2
	end
	table.insert(data_list,i)
	i = x_c % 10
	table.insert(data_list,i)
	for i=1,2 do
		table.insert(item_list,instance["EliminateXYItemBGJ"..i])
	end

	local callback = function()
		--滚动完成
		if not instance then return end
		local gw = data_list[2]
		local sw = data_list[1]
		instance.bgj_yj_txt.text = sw .. gw
		instance.hero2_yj.gameObject:SetActive(true)
		local seq = DoTweenSequence.Create()
		seq:AppendCallback(function(  )
			if not instance then return end
			local o_pos = instance.hero2_lottery.position
			EliminateXYPartManager.CreateBGJTW(o_pos,next_data)
		end)
		seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.bgj_sl_yj_yc))
		seq:AppendCallback(function(  )
			if not instance then return end
			instance.hero2_lottery.gameObject:SetActive(false)
			instance.hero2_yj.gameObject:SetActive(false)
		end)
	end

	ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_bgj_yj.audio_name)
	EliminateXYAnimManager.ScrollBGJSkill(item_list,data_list,callback)
end

--孙悟空进入免费游戏
function M.SWKSkillFreeJoin(data)
	if not instance then return end
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.ts_mfyxbk,1))
	seq:AppendCallback(function(  )
		instance.hero1_pra1.gameObject:SetActive(false)
		instance.hero1_pra2.gameObject:SetActive(false)
		instance.hero1_pra3.gameObject:SetActive(false)
		instance.hero1_bg.gameObject:SetActive(false)
		instance.hero1_dj.gameObject:SetActive(false)
	end)
end

--白骨精进入免费游戏
function M.BGJSkillFreeJoin(data)
	if not instance then return end
	M.BGJSpeak(1)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.bgj_mfyxjr + 1.5,1))
	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.bgj_bs,1))
	seq:AppendCallback(function(  )
		ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_yanwu.audio_name)
		instance.hero2_bs.gameObject:SetActive(false)
		instance.hero2_bs.gameObject:SetActive(true)
		M.BGJModelShow(2)
		instance.hero2_jc.gameObject:SetActive(false)
		instance.bgj_sp_item.gameObject:SetActive(false)
		instance.hero2_jc_mini.gameObject:SetActive(true)
		instance.hero2_jc_mini_txt.text = 0
		instance.hero2_pro.gameObject:SetActive(false)
	end)

	seq:AppendInterval(EliminateXYModel.GetTime(6,1))
	seq:AppendCallback(function(  )
		instance.hero2_bs.gameObject:SetActive(false)
	end)
end

--唐僧技能进入免费游戏
function M.TSSkillFreeJoin(data)
	if not instance then return end
	local seq = DoTweenSequence.Create()
	seq:AppendCallback(function(  )
		instance.hero3_mfdd.gameObject:SetActive(true)
		instance.hero3_mfdd.localScale = Vector3.zero
		instance.hero3_mfjj.gameObject:SetActive(true)
		instance.hero3_mfyx.gameObject:SetActive(false)
		instance.hero3_mfcszj.gameObject:SetActive(false)
		instance.hero3_mfcszj.gameObject:SetActive(true)
	end)
	seq:Append(instance.hero3_mfdd.transform:DOScale(Vector3.New(0,0,0),EliminateXYModel.GetTime(0.01,1)))
	seq:Append(instance.hero3_mfdd.transform:DOScale(Vector3.New(1, 1, 1),EliminateXYModel.GetTime(0.5,1)))
	seq:AppendCallback(function(  )
		ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_ts_zj.audio_name)
		EliminateXYAnimManager.DOShakePositionCamer(nil,EliminateXYModel.GetTime(EliminateXYModel.time.ts_mfyx_zd,1))
	end)
	seq:AppendCallback(function(  )
		ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_free_chufa.audio_name)
	end)
	seq:AppendInterval(EliminateXYModel.GetTime(2,1))
	seq:AppendCallback(function(  )
		instance.hero3_mfyxjr.gameObject:SetActive(false)
		instance.hero3_mfyxjr.gameObject:SetActive(true)
	end)
	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.ts_mfyxbk,1))
	seq:AppendCallback(function(  )
		instance.mf_txt.text = data.free_game_num_cur - 1
		instance.hero3_mfyxbk.gameObject:SetActive(true)
		instance.hero3_mfdd.gameObject:SetActive(false)
		instance.hero3_mfjj.gameObject:SetActive(false)
		M.ViewFreeBG(true)
		ExtendSoundManager.PlaySceneBGM(audio_config.sdbgj.bgm_sdbgj_free_beijing.audio_name)
	end)
	seq:OnKill(function (  )
		if instance and IsEquals(instance.hero3_mfdd) then
			instance.hero3_mfdd.localScale = Vector3.one
		end
	end)
	seq:OnForceKill(function(  )
		if instance and IsEquals(instance.hero3_mfdd) then
			instance.hero3_mfdd.localScale = Vector3.one
		end
	end)
end

--唐僧消除前摇
function M.TSXCQY(data,cur_del_map)
	if not instance then return end
	local callback
	EliminateXYPartManager.XCTS({cur_del_map = eliminate_xy_algorithm.change_map_to_list(cur_del_map)},callback)
end

--唐僧消除后摇
function M.TSXCHY(data,cur_del_map)
	if not data.ts_skill_trigger or not data.free_game_num_cur or not instance then return end
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.ts_mfyx_zj))
	seq:AppendCallback(function(  )
		instance.hero3_mfyx.gameObject:SetActive(true)
		instance.hero3_mf.gameObject:SetActive(true)
		instance.mf_txt.text = data.free_game_num_cur
		if data.state == "nor" then
			instance.hero3_mfjj.gameObject:SetActive(true)
		elseif data.state == "free" then
			instance.hero3_mfjj.gameObject:SetActive(false)
		end
		ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_ts_zj.audio_name)
		EliminateXYAnimManager.DOShakePositionCamer(nil,EliminateXYModel.GetTime(EliminateXYModel.time.ts_mfyx_zd))
	end)
end

--唐僧免费游戏触发
function M.TSSkillFreeUse(data)
	if not data.ts_skill_use or not data.free_game_num_cur or not instance then return end
	local seq = DoTweenSequence.Create()
	seq:AppendCallback(function(  )
		instance.hero3_mfyx.gameObject:SetActive(false)
		instance.hero3_mfcszj.gameObject:SetActive(false)
		instance.hero3_mfcszj.gameObject:SetActive(true)
	end)
	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.ts_mfyx_js))
	seq:AppendCallback(function(  )
		instance.mf_txt.text = data.free_game_num_cur - 1
	end)
end

--白骨精免费游戏变身
function M.BGJFreeChange(data)
	if not data.ts_skill_use or not data.free_game_num_del or not instance then return end
	if data.free_game_num_del == 7 or data.free_game_num_del == 13 then 
		local seq = DoTweenSequence.Create()
		seq:AppendCallback(function(  )
			ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_yanwu.audio_name)
			instance.hero2_bs.gameObject:SetActive(false)
			instance.hero2_bs.gameObject:SetActive(true)
		end)
		seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.bgj_bs))
		seq:AppendCallback(function(  )
			local i = 1
			if data.free_game_num_del <= 6 then
				i = 2
			elseif data.free_game_num_del > 6 and data.free_game_num_del <= 12 then
				i = 3
			elseif data.free_game_num_del > 12 and data.free_game_num_del <= 18 then
				i = 4
			end
			M.BGJModelShow(i)
		end)
	end
end

function M.BigGameShow(data)
	if not instance then return end
	local seq = DoTweenSequence.Create()
	seq:AppendCallback(function(  )
		instance.jc_CG.alpha = 0
		instance.hero2_jc.gameObject:SetActive(true)
		instance.bgj_sp_item.gameObject:SetActive(true)
		if instance.jc_CG_timer then
			instance.jc_CG_timer:Stop()
			instance.jc_CG_timer = nil
		end
		instance.jc_CG_timer = Timer.New(function(  )
			if IsEquals(instance.jc_CG) then
				instance.jc_CG.alpha = instance.jc_CG.alpha + 0.02
			end
		end,0.02,50)
		instance.jc_CG_timer:Start()
		instance.hero2_cx.gameObject:SetActive(true)
		ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_bg_bgj.audio_name)
	end)
	seq:AppendInterval(EliminateXYModel.GetTime(4))
	seq:AppendCallback(function(  )
		instance.hero2_jc_mini.gameObject:SetActive(true)
		instance.hero2_jc_mini.transform.localPosition = Vector3.New(-34,-50,0)
		instance.jc_mini_ani.enabled = true
		instance.jc_mini_ani:Play("@hero2_jc_mini",-1,0)
	end)
	seq:AppendInterval(EliminateXYModel.GetTime(0.4))
	seq:AppendCallback(function(  )
		ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_bg_zj.audio_name)
		EliminateXYAnimManager.DOShakePositionCamer(nil,EliminateXYModel.GetTime(EliminateXYModel.time.bgj_jc_fdzd))
	end)
	--摇奖
	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.big_game_yj_wait))
	seq:AppendCallback(function(  )
		ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_bg_swk.audio_name)
		instance.h4_node.localPosition = Vector3.zero
		instance.hero4_lottery.gameObject:SetActive(true)
	end)
	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.big_game_yj_show))
	seq:AppendCallback(function(  )
		local item_list = {}
		local data_list = {}
		local callback = function(  )
			--滚动完成
			dump(nil,"<color=red>滚动完成</color>")
		end

		local sp_callback = function(  )
			M.BigGameLottery(data)
		end
		math.randomseed(tostring(os.time()):reverse():sub(1, 7))
		if data.swk_skill_award == 1 then
			for i=1,5 do
				if i == 3 then
					table.insert(data_list,EliminateXYModel.eliminate_enum.swk)
				else
					table.insert(data_list,math.random(6,8))
				end
			end
		elseif data.swk_skill_award == 2 then
			for i=1,5 do
				if i == 3 then
					table.insert(data_list,EliminateXYModel.eliminate_enum.ts)
				else
					table.insert(data_list,math.random(6,8))
				end
			end
		else
			for i=1,5 do
				if i == 3 then
					table.insert(data_list,EliminateXYModel.eliminate_enum.bgj)
				else
					table.insert(data_list,math.random(6,8))
				end
			end
		end
		M.big_data_list = data_list
		for i=1,5 do
			table.insert(item_list,instance["EliminateXYItem" .. i])
		end
		instance.bg_cj.gameObject:SetActive(true)
		EliminateXYAnimManager.ScrollBigGame(item_list,data_list,callback,sp_callback,instance.h4_node1)
	end)
	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.swk_xc_qy))
	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.big_game_yj_time))
	seq:AppendCallback(function(  )
		if not instance then return end
		instance.bg_cj.gameObject:SetActive(false)
		if not (data.swk_skill_award == 1 or data.swk_skill_award == 2) then return end
		local _callback = function(  )
			EliminateXYAnimManager.DOShakePositionCamer(nil,EliminateXYModel.GetTime(1))
		end
		if data.swk_skill_award == 1 then
			--孙悟空
			local o_pos = eliminate_xy_algorithm.get_pos_by_index(5,3)
			o_pos = Vector3.New(o_pos.x,o_pos.y - 74,0)
			local t_pos = Vector3.New(100,560,0)
			EliminateXYPartManager.CreateTW(o_pos,t_pos,"xxl_xy_tuowei_huang")
		elseif data.swk_skill_award == 2 then
			--唐僧
			local o_pos = eliminate_xy_algorithm.get_pos_by_index(5,3)
			o_pos = Vector3.New(o_pos.x,o_pos.y - 74,0)
			local t_pos = eliminate_xy_algorithm.get_pos_by_index(2,1)
			t_pos = Vector3.New(t_pos.x + 100,t_pos.y + 20,0)
			EliminateXYPartManager.CreateTW(o_pos,t_pos,"xxl_ts_tuowei")
		end
	end)

	if data.swk_skill_award == 1 then
		seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.swk_jc_bg))
		seq:AppendCallback(function(  )
			ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_bg_skill.audio_name)
			instance.hero1_bg.gameObject:SetActive(true)
		end)
		seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.swk_jc_dj))
		seq:AppendCallback(function(  )
			instance.hero1_dj.gameObject:SetActive(true)
		end)
		seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.swk_jc_djzd))
		seq:AppendCallback(function(  )
			EliminateXYAnimManager.DOShakePositionCamer(nil,EliminateXYModel.GetTime(EliminateXYModel.time.swk_jc_djzdt))
			local bgj_sp_item = GameObject.Instantiate(instance.bgj_sp_item.gameObject,instance.hero2_jc.transform)
			instance.bgj_sp_item.gameObject:SetActive(false)
			instance.hero2_jc_mini.gameObject:SetActive(false)
			EliminateXYPartManager.CreateBGJBlom(bgj_sp_item)
			instance.bgj_sp_bg.gameObject:SetActive(true)
		end)
		seq:AppendInterval(EliminateXYModel.GetTime(0.5))
		seq:AppendCallback(function(  )
			instance.bgj_sp_bg.gameObject:SetActive(true)
		end)
	elseif data.swk_skill_award == 2 then
		seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.ts_jc_bao))
		seq:AppendCallback(function(  )
			ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_ts_zj.audio_name)
			EliminateXYAnimManager.DOShakePositionCamer(nil,EliminateXYModel.GetTime(EliminateXYModel.time.swk_jc_djzdt))
			instance.hero3_jc.gameObject:SetActive(true)
		end)
	end

	seq:OnKill(function (  )
		
	end)
end

function M.XCBGJ(data)
	local cur_del_map = data.bgj_xc_map
	local cur_rate = data.bgj_rate
	EliminateXYPartManager.XCBGJ({cur_del_map = eliminate_xy_algorithm.change_map_to_list(cur_del_map)})
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.bgj_xc + EliminateXYModel.time.bgj_xc_fx))
	seq:AppendCallback(function(  )
		instance.hero2_jc_mini_txt.text = StringHelper.ToCash(EliminateXYModel.GetAwardGold(data.bgj_rate_jc_cur))
	end)
end

function M.NorBGJ(cur_del_map,bgj_rate_jc_cur)
	local seq = DoTweenSequence.Create()
	seq:AppendCallback(function(  )
		EliminateXYPartManager.XCBGJ({cur_del_map = eliminate_xy_algorithm.change_map_to_list(cur_del_map)})
	end)
	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.bgj_xc + EliminateXYModel.time.bgj_xc_fx))
	seq:AppendCallback(function(  )
		instance.hero2_jc_mini_txt.text = StringHelper.ToCash(EliminateXYModel.GetAwardGold(bgj_rate_jc_cur))
	end)
end

function M.XCBGJ1(cur_del_map,bgj_rate_jc_cur)
	local o_pos = instance.hero1_lottery.position
	local seq = DoTweenSequence.Create()
	seq:AppendCallback(function(  )
		EliminateXYPartManager.CreateSWKTW1(o_pos,cur_del_map)
	end)
	-- seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.swk_jb_sg_yd + EliminateXYModel.time.xc_bgj_jg))
	-- seq:AppendCallback(function(  )
	-- 	EliminateXYPartManager.XCBGJ({cur_del_map = eliminate_xy_algorithm.change_map_to_list(cur_del_map)})
	-- end)
	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.bgj_xc + EliminateXYModel.time.bgj_xc_fx))
	seq:AppendCallback(function(  )
		instance.hero2_jc_mini_txt.text = StringHelper.ToCash(EliminateXYModel.GetAwardGold(bgj_rate_jc_cur))
	end)
end

function M.SetBigGameState(data)
	if not instance then return end
	instance.hero2_jc_mini.gameObject:SetActive(false)
	instance.hero2_jc.gameObject:SetActive(true)
	if data.swk_skill_award and (data.swk_skill_award == 1 or data.swk_skill_award == 2) then
		instance.bgj_sp_item.gameObject:SetActive(false)
		instance.bgj_sp_bg.gameObject:SetActive(true)
	else
		instance.bgj_sp_item.gameObject:SetActive(true)
		instance.bgj_sp_bg.gameObject:SetActive(false)
	end

	M.BigGameLottery(data)
end

function M.BigGameLottery(data)
	if not instance then return end
	if data.swk_skill_award then
		local xxl_icon = "xxl" .. "_icon_"
		if data.swk_skill_award == 1 then
			xxl_icon = xxl_icon .. 8
		elseif data.swk_skill_award == 2 then
			xxl_icon = xxl_icon .. 6
		else
			xxl_icon = xxl_icon .. 7
		end
		for i=1,5 do
			local img = instance["EliminateXYItem" .. i].transform:Find("@icon_img"):GetComponent("Image")
			local bg_img = instance["EliminateXYItem" .. i].transform:Find("@bg"):GetComponent("Image")
			local money_img = instance["EliminateXYItem" .. i].transform:Find("@money_img"):GetComponent("Image")
			if i == 3 then
				img.sprite = EliminateXYObjManager.item_obj[xxl_icon]
				if data.swk_skill_award == 1 then
					money_img.sprite = GetTexture("sdbgj_imgf_qejc")
					money_img.gameObject:SetActive(true)
					bg_img.gameObject:SetActive(true)
				elseif data.swk_skill_award == 2 then
					money_img.sprite = GetTexture("sdbgj_imgf_bljc1")
					money_img.gameObject:SetActive(true)
					bg_img.gameObject:SetActive(true)
				else
					money_img.gameObject:SetActive(false)
					bg_img.gameObject:SetActive(false)
				end
			else
				local id = math.random(6,8)
				if M.big_data_list and M.big_data_list[i] then
					id = M.big_data_list[i]
				end
				img.sprite = EliminateXYObjManager.item_obj["xxl_icon_" .. id]
				if id == 8 then
					money_img.sprite = GetTexture("sdbgj_imgf_qejc")
					money_img.gameObject:SetActive(true)
					bg_img.gameObject:SetActive(true)
				elseif id== 6 then
					money_img.sprite = GetTexture("sdbgj_imgf_bljc1")
					money_img.gameObject:SetActive(true)
					bg_img.gameObject:SetActive(true)
				else
					money_img.gameObject:SetActive(false)
					bg_img.gameObject:SetActive(false)
				end
			end
		end
		instance.h4_node.localPosition = Vector3.New(0,-80,0)
		instance.hero4_lottery.gameObject:SetActive(true)
	end
end

function M.TaskAdd(data,cur_del_map)
	EliminateXYPartManager.XCNor({cur_del_map = eliminate_xy_algorithm.change_map_to_list(cur_del_map)},function (  )
		M.SetSWKTaskState(data)
	end)
end

function M.SetSWKTaskState(data)
	if not instance then return end
	local index = 0
	if not data.swk_rate_cur or data.swk_rate_cur == 0 then
		index = 0
	elseif data.swk_rate_cur > 0 and data.swk_rate_cur < M.swl_lv1 then
		index = 1
	elseif data.swk_rate_cur >= M.swl_lv1 and data.swk_rate_cur < M.swl_lv2 then
		index = 2
	elseif data.swk_rate_cur >= M.swl_lv2 then
		index = 3
	end
	if data.state == "free" then
		index = 0
	end 
	for i=1,3 do
		instance["hero1_pra" .. i].gameObject:SetActive(i == index)
	end
end

function M.TaskSettlement(data)
	if not instance then return end
	local td = EliminateXYModel.GetTaskData()
	local ta = EliminateXYModel.GetTaskAward()
	if table_is_null(td) then return end
	local get_award_t = M.GetUseTime(td)
	-- dump(get_award_t,"<color=red>所用耗时：+++++++++++++++++++++++++++++</color>")
	local cur_lv = 0
	if not data.swk_rate_cur or data.swk_rate_cur == 0 then
		cur_lv = 0
	elseif data.swk_rate_cur > 0 and data.swk_rate_cur < M.swl_lv1 then
		cur_lv = 1
	elseif data.swk_rate_cur >= M.swl_lv1 and data.swk_rate_cur < M.swl_lv2 then
		cur_lv = 2
	elseif data.swk_rate_cur >= M.swl_lv2 then
		cur_lv = 3
	end

	local seq = DoTweenSequence.Create()
	if cur_lv == 3 then
		seq:AppendCallback(function(  )
			ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_swk_gongji.audio_name)
		end)
		seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.task_sett_swkgj))
	end
	seq:AppendCallback(function(  )
		-- instance.task_sett_ani.enabled = true
		instance.task_sett_ani:Play("EliminateXYHeroManager",-1,0)
	end)
	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.task_sett_bgj_xt))
	seq:AppendCallback(function(  )
		ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_zj.audio_name)
		if cur_lv == 3 then
			EliminateXYAnimManager.DOShakePositionCamer(nil,EliminateXYModel.GetTime(1))
		end
		--白骨精血条减少
		M.SetProAni(td)
	end)
	seq:AppendInterval(EliminateXYModel.GetTime(get_award_t * 2))

	if not table_is_null(ta) then
		seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.task_sett_bgj_bs))
		seq:AppendCallback(function(  )
			--冒烟给奖励
			instance.hero2_bs.gameObject:SetActive(false)
			instance.hero2_bs.gameObject:SetActive(true)
		end)
		seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.task_sett_bgj_hby))
		seq:AppendCallback(function(  )
			-- instance.hero2_hby.gameObject:SetActive(true)
			instance.tishi.gameObject:SetActive(true)
		end)
		seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.task_sett_bgj_get_award))
		seq:AppendCallback(function(  )
			EliminateXYPartManager.CreateNumGoldInPos(instance.award_txt.transform.position,ta[1].value / 100)
		end)
		seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.task_sett_bgj_hby_hide))
		seq:AppendCallback(function(  )
			-- instance.hero2_hby.gameObject:SetActive(false)
			instance.tishi.gameObject:SetActive(false)
		end)
	end
	seq:OnKill(function(  )
		EliminateXYModel.InitTaskAward()
		M.RefreshTask()
	end)
	seq:OnForceKill(function (  )
		EliminateXYModel.InitTaskAward()
		M.RefreshTask()
	end)
end

--任务相关
local AnimTimers = {}
local PG_width = 372
local now_process = 0
local now_lv = 0
function M.RefreshTask()
	if not instance then return end
	if instance and IsEquals(instance.hero2_hby) then
		instance.hero2_hby.gameObject:SetActive(false)
	end
	local td = EliminateXYModel.GetTaskData()
	local cfg = EliminateXYModel.xiaoxiaole_xy_defen_cfg.task
	dump({td,cfg},"<color=white>西游任务刷新</color>")
	if table_is_null(td) or not cfg then
		instance.hero2_pro.gameObject:SetActive(false)
		return 
	end
	M.SetProInstant(td)
	local award = 0
	if cfg[td.need_process] then
		award = cfg[td.need_process].asset_count / 100
	end
	award = StringHelper.ToCash(award)
	instance.award_txt.text = award
	instance.pro_txt.text = (td.need_process - td.now_process) .. "/" .. td.need_process
	instance.hero2_pro.gameObject:SetActive(true)
end

--瞬间进度变化
function M.SetProInstant(td)
	if not instance or table_is_null(td) then return end 
	now_process = 1 - td.now_process / td.need_process
	now_lv = td.now_lv
	instance:SetProg(now_process,true)
end
--动画变化
function M.SetProAni(td)
	if not instance or table_is_null(td) then return 0 end
	local all_usetime = 0
	if now_lv == td.now_lv then
		now_process = 1 - td.now_process / td.need_process
		now_lv = td.now_lv
		all_usetime = instance:SetProg(now_process)
	else
		--多段血条减少 
		--满血
		--减少
		local now_process = 1 - td.now_process / td.need_process
		local times = math.abs(td.now_lv - now_lv)
		local func = function(backcall,now_times)
			now_times = now_times or 0
			if now_times < times then
				now_lv = now_lv + 1
				now_times = now_times + 1
				--设定为0会直接触发红包动画
				all_usetime = all_usetime +	instance:SetProg(0,false,function ()
					instance:SetProg(1,true,function ()
						backcall(backcall,now_times)
					end)
				end)
			else
				all_usetime = all_usetime + instance:SetProg(now_process,false)
				now_lv = td.now_lv
			end
		end
		func(func)
	end
	return all_usetime
end

function M:SetProg(val,IsInstant,OverCall)
	M:StopAnimTimers()
	if self.glow_timer then 
		self.glow_timer:Stop()
		self.glow.gameObject:SetActive(false)
	end
	if val > 1 then 
		val = 1 
	end 
	if val < 0 then 
		val = 0 
	end 
	if IsInstant then 
		self.P_G.fillAmount = val
		self.P_G2.fillAmount = val
		self:SetTxPos(val)
		if OverCall then
			OverCall()
		end
		return 
	end
	self.glow_timer = Timer.New(function(  )
		self.glow.gameObject:SetActive(false)
	end,0.5,1)
	self.glow.gameObject:SetActive(true)
	self.glow_timer:Start()

	local func = function(val)
		self:SetTxPos(val)
	end
	local new_val = val
	local dis = math.abs(self.P_G.fillAmount - val)
	--第一次执行得时黄色条动画，第二次时绿色
	local use_time = 0
	if  dis<= base_anim_config.pc_1 then
		self.P_G.fillAmount = val
		self.P_G2.fillAmount = val
		if OverCall then
			OverCall()
		end
		self:SetTxPos(val)
	elseif dis >= base_anim_config.pc_1 and dis <= base_anim_config.pc_2 then
		self:DoProAnim(val,self.P_G,dis * base_anim_config.mc_1,nil,function ()			
		end)
		local t
		t = Timer.New(function ()
			self:DoProAnim(new_val,self.P_G2,dis * base_anim_config.mc_2,func,OverCall)
		end,0.5,1)
		t:Start()
		AnimTimers[#AnimTimers + 1] = t
		use_time = dis * base_anim_config.mc_1 > (dis * base_anim_config.mc_2 + base_anim_config.de_t) and dis * base_anim_config.mc_1 or dis * base_anim_config.mc_2 + base_anim_config.de_t
	else
		self:DoProAnim(val,self.P_G,dis * base_anim_config.mc_3,nil,function ()
			self:DoProAnim(new_val,self.P_G2,dis * base_anim_config.mc_4,func,OverCall)
		end)
		use_time = dis * base_anim_config.mc_4 + dis * base_anim_config.mc_3
	end
	-- dump(use_time,"<color>用时</color>")
	return use_time
end

--设置特效位置
function M:SetTxPos(val)
	self.tx_pos.transform.localPosition  = Vector2.New(PG_width * val,self.tx_pos.transform.localPosition.y)
	self.val = val
	local b = val <= 0
	self.tx_pos.gameObject:SetActive(not b)
	-- now_lv
	if b then
		local cfg = EliminateXYModel.xiaoxiaole_xy_defen_cfg.task
		local award = 0
		for k,v in pairs(cfg) do
			if now_lv == v.lv then
				award = v.asset_count / 100
				award = StringHelper.ToCash(award)
				instance.award_txt.text = award
				return
			end
		end
		local lv = 0
		local max_cfg
		for k,v in pairs(cfg) do
			if v.lv > lv then
				lv = v.lv
				max_cfg = v
			end			
		end
		if now_lv > lv then
			award = max_cfg.asset_count / 100
			award = StringHelper.ToCash(award)
			instance.award_txt.text = award
			return
		end
		award = StringHelper.ToCash(award)
		instance.award_txt.text = award

		local td = EliminateXYModel.GetTaskData()
		instance.pro_txt.text = (td.need_process - td.now_process) .. "/" .. td.need_process
	end
end

function M:DoProAnim(val,P_G,DurTime,CallUpdateCall,OverCall)
	local c_v = P_G.fillAmount
	local dur_time = DurTime -- 总持续时间
	local performs = 1.8 --顺滑度
	local each_time = 0.016 * performs -- 单帧时间(可以根据性能减少帧数，性能越差，performs越大)
	local run_times = dur_time / each_time --执行次数
	local s = val - c_v -- 总路程
	local each_s = s / run_times -- 单帧路程
	local get_check_func = function (a1,a2) --返回一个检查是否到终点得函数，不用math.abs是因为不平滑
		if a1 > a2 then
			return function (a1,a2)
				if a2 >= a1 then
					return true
				end
			end
		else
			return function (a1,a2)
				if a2 <= a1 then
					return true
				end
			end
		end
	end
	local is_over = get_check_func(val,c_v)
	local change_timer
	change_timer = Timer.New(function()
		if is_over(val,P_G.fillAmount) then 
			P_G.fillAmount = val
			if OverCall then
				OverCall()
				OverCall = nil
			end
			if change_timer then
				change_timer:Stop()
			end
		else
			P_G.fillAmount = P_G.fillAmount + each_s
			if CallUpdateCall then
				CallUpdateCall(P_G.fillAmount)
			end
		end
	end ,each_time,run_times)
	change_timer:Start()
	AnimTimers[#AnimTimers + 1] = change_timer
end

function M:StopAnimTimers()
	for i = 1,#AnimTimers do
		AnimTimers[i]:Stop()
		AnimTimers[i] = nil
	end
	AnimTimers = {}
end

function M.GetUseTime(task_data)
	if table_is_null(task_data) then return 0 end
	local val = 1 - task_data.now_process / task_data.need_process
	local times = math.abs(task_data.now_lv - now_lv) + 1
	local one_func = function (val,fillAmount)
		local dis = math.abs(fillAmount - val)
		if  dis<= base_anim_config.pc_1 then
			return 0
		elseif dis >= base_anim_config.pc_1 and dis <= base_anim_config.pc_2 then
			return dis * base_anim_config.mc_1 > (dis * base_anim_config.mc_2 + base_anim_config.de_t) and dis * base_anim_config.mc_1 or dis * base_anim_config.mc_2 + base_anim_config.de_t
		else
			return dis * base_anim_config.mc_4 + dis * base_anim_config.mc_3
		end
	end
	local all_func = function ()
		local t = 0
		--一次性打多个血条
		if times > 1 then
			for i = 1,times do
				if i == 1 then
					t = t + one_func(0,instance.P_G.fillAmount)
				elseif i == times then
					t = t + one_func(1,val)
				else					
					t = t + one_func(0,1)
				end
			end
		else
			t = one_func(val,instance.P_G.fillAmount)
		end
		return t
	end
	return all_func()
end

function M.ShowNodeHuo(i,b)
	if not instance then return end
	instance["node5_huo" .. i].gameObject:SetActive(b)
end