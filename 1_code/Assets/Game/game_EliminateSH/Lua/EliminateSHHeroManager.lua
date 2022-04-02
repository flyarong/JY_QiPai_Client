
local basefunc = require "Game/Common/basefunc"
EliminateSHHeroManager = basefunc.class()
local C = EliminateSHHeroManager
C.name = "EliminateSHHeroManager"
local HeroCfg={
	[1]={
		name="武松",
		img="shxxl_icon_rw4",
		zuo="EliminateSH_men1_wushong",
		you="EliminateSH_men2_wushong",
		kuang="wusong_kuang"
	},
	[2]={
		name="鲁智深",
		img="shxxl_icon_rw3",
		zuo="EliminateSH_men1_luzhishen",
		you="EliminateSH_men2_luzhishen",
		kuang="luzhiseng_kuang"
	},
	[3]={
		name="李逵",
		img="shxxl_icon_rw1",
		zuo="EliminateSH_men1_likui",
		you="EliminateSH_men2_likui",
		kuang="likui_kuang"
	},
	[4]={
		name="宋江",
		img="shxxl_icon_rw2",
		zuo="EliminateSH_men1_songjiang",
		you="EliminateSH_men2_songjiang",
		kuang="songjiang_kuang"
	},
}

C.AnimType={
	idle = 1,
	open_fall = 2,
	open_scucc = 3,
	open = 4,
}

local  instance
function C.Create(data)
	if not instance then 
		instance =C.New(data)
	else
		return  instance
	end 
end

function C.Exit()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["view_lottery_end"]=basefunc.handler(self,self.view_lottery_end)
	self.lister["view_lottery_start"]=basefunc.handler(self,self.view_lottery_start)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	self.HeroItemContent = nil
	self.HeroBGContent = nil
	destroy(self.gameObject)
end

function C:ctor(data)
	if data==nil then data={} end 
	local parent = data.parent or GameObject.Find("Canvas/LayerLv1").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C.GetHeroItemContent()
	if instance then
		if not IsEquals(instance.HeroItemContent) then
			instance.HeroItemContent = instance.transform:Find("HeroPraticle/hero2/2/Viewport/HeroItemContent")
		end
		return instance.HeroItemContent
	else
		return GameObject.Find("HeroItemContent")
	end
end

function C.GetHeroBGContent()
	if instance then
		if not IsEquals(instance.HeroBGContent) then
			instance.HeroBGContent = instance.transform:Find("HeroPraticle/hero2/2/HeroBGContent")
		end
		return instance.HeroBGContent
	else
		return GameObject.Find("HeroBGContent")
	end
end

function C.GetHero1Part3()
	if instance then
		if not IsEquals(instance.Hero1Part3) then
			instance.Hero1Part3 = instance.transform:Find("HeroPraticle/hero1/3")
		end
		return instance.Hero1Part3
	else
		return GameObject.Find("EliminateSHHeroManager").transform:Find("HeroPraticle/hero1/3")
	end
end

function C.GetHero1TW()
	if instance then
		if not IsEquals(instance.Hero1TW) then
			instance.Hero1TW = instance.transform:Find("HeroPraticle/hero1/3/xxl_sh_wusong_tuowei")
		end
		return instance.Hero1TW
	else
		return GameObject.Find("EliminateSHHeroManager").transform:Find("HeroPraticle/hero1/3/xxl_sh_wusong_tuowei")
	end
end

function C:InitUI()
	EliminateSHObjManager.InitHeroBG(2,4)
	self.lotter = self.transform:Find("HeroPraticle/hero2/2")
	self.lotter.gameObject:SetActive(false)
	self.ttxd_num_img = self.transform:Find("HeroPraticle/hero4/3/ttxd_num_img"):GetComponent("Image")
	self.hero_map={}
	for i = 1, 4 do
		local b = self.transform:Find("Hero/hero" .. i .. "/hero")
		-- b.gameObject:SetActive(true)
		-- b.gameObject.transform.localPosition = Vector2.zero
		-- b.gameObject.transform:Find("zuo_men/zuo"):GetComponent("Image").sprite=GetTexture(HeroCfg[i].zuo)
		-- b.gameObject.transform:Find("you_men/you"):GetComponent("Image").sprite=GetTexture(HeroCfg[i].you)
		-- b.gameObject.transform:Find("yingxiong/renwu"):GetComponent("Image").sprite=GetTexture(HeroCfg[i].img)
		local animator = b:GetComponent("Animator")
		local audio_node = self.transform:Find("HeroSpeak/" .. i)
		local part = {}
		for j=-2,4 do
			part[j] = self.transform:Find("HeroPraticle/hero" .. i .. "/" .. j)
		end
		if i == 2 then
			if IsEquals(part[2]) then
				part.sg = {}
				for j=1,4 do
					part.sg[j] = part[2].transform:Find("skill/" .. j)
				end
			end
			if IsEquals(part[3]) then
				part.tsxc = {}
				for j=1,4 do
					part.tsxc[j] = part[3].transform:Find("tsxc" .. j)
				end
			end
		end
		self.hero_map[i] = {ani = animator,obj = b,part = part,audio_node = audio_node}
	end
	self:MyRefresh()
end

function C:MyRefresh()
	local hero_data = EliminateSHModel.GetHeroData()
	self:HeroReset(true)
	if table_is_null(hero_data) then 
		--没有英雄
		self.lotter.gameObject:SetActive(false)
		for i=1,4 do
			C.ChangeAnim(i,C.AnimType.idle)
		end
	else
		--有英雄
		for k,v in pairs(hero_data) do
			C.ChangeAnim(k,C.AnimType.open)
			if k == 1 then
				self.hero_map[k].part[2].transform.gameObject:SetActive(false)
			elseif k == 2 then
				self.hero_map[k].part[2].transform.gameObject:SetActive(false)
				self:RefreshHeroLottery()
			elseif k == 3 then
				self.hero_map[k].part[3].gameObject:SetActive(false)
			elseif k == 4 then
				self.hero_map[k].part[3].gameObject:SetActive(false)
			end
		end
	end
end

function C:RefreshHeroLottery()
	local hero_data = EliminateSHModel.GetHeroData()
	dump(hero_data, "<color=yellow>英雄数据</color>")
	if hero_data and hero_data[2] then
		local hero2 = hero_data[2]
		local hero_map = {}
		local x = 1
		for y,v in pairs(hero2.random) do
			hero_map[x] = hero_map[x] or {}
			hero_map[x][y] = v
		end
		x = 2
		for y,v in pairs(hero2.base) do
			hero_map[x] = hero_map[x] or {}
			hero_map[x][y] = v
		end
		EliminateSHObjManager.RemoveHeroItem(hero_map)
		EliminateSHObjManager.AddHeroItem(hero_map)
		if hero2.lucky then
			local gray_map = {}
			for i=1,2 do
				for y,v in pairs(hero2.lucky) do
					gray_map[i] = gray_map[i] or {}
					gray_map[i][y] = v
				end
			end
			EliminateSHObjManager.SetHeroItemGray(gray_map)
		end
	else
		self.lotter.gameObject:SetActive(false)
	end
end

function C.SetBaseLotteryBefore(hero2)
	if not instance then return end
	if hero2 then
		local hero_map = {}
		local x = 2
		for y,v in pairs(hero2.base) do
			hero_map[x] = hero_map[x] or {}
			hero_map[x][y] = v
		end
		EliminateSHObjManager.RemoveHeroItem(hero_map)
		EliminateSHObjManager.AddHeroItem(hero_map)
		-- if hero2.lucky then
		-- 	local gray_map = {}
		-- 	for y,v in pairs(hero2.lucky) do
		-- 		gray_map[x] = gray_map[x] or {}
		-- 		gray_map[x][y] = v
		-- 	end
		-- 	EliminateSHObjManager.SetHeroItemGray(gray_map)
		-- end
	end
end

function C.SetBaseLotteryLaster(hero2)
	if not instance then return end
	if hero2 then
		local hero_map = {}
		local x = 2
		for y,v in pairs(hero2.base) do
			hero_map[x] = hero_map[x] or {}
			hero_map[x][y] = v
		end
		EliminateSHObjManager.RemoveHeroItem(hero_map)
		EliminateSHObjManager.AddHeroItem(hero_map)
		if hero2.lucky then
			local gray_map = {}
			for y,v in pairs(hero2.lucky) do
				gray_map[x] = gray_map[x] or {}
				gray_map[x][y] = v
			end
			EliminateSHObjManager.SetHeroItemGray(gray_map)
		end
	end
end

function C.SetRandomLotteryBefore(hero2)
	if not instance then return end
	if hero2 then
		local hero_map = {}
		local x = 1
		for y,v in pairs(hero2.random) do
			hero_map[x] = hero_map[x] or {}
			hero_map[x][y] = y
		end
		EliminateSHObjManager.RemoveHeroItem(hero_map)
		EliminateSHObjManager.AddHeroItem(hero_map)
	end
end

function C.SetRandomLotteryLaster(hero2)
	if not instance then return end
	if hero2 then
		local hero_map = {}
		local x = 1
		for y,v in pairs(hero2.random) do
			if not EliminateSHModel.CheckHero2IndexIsLuckyed(hero2,y) then
				hero_map[x] = hero_map[x] or {}
				hero_map[x][y] = v
			end
		end
		EliminateSHObjManager.RemoveHeroItem(hero_map)
		EliminateSHObjManager.AddHeroItem(hero_map)
	end
end

function C.SetRandomLotteryBeforeGray(hero2)
	if not instance then return end
	if hero2 then
		local x = 1
		if hero2.lucky then
			local gray_map = {}
			for y=1,4 do
				if EliminateSHModel.CheckHero2IndexIsLuckyed(hero2,y) then
					gray_map[x] = gray_map[x] or {}
					gray_map[x][y] = y
				end
			end
			EliminateSHObjManager.SetHeroItemGray(gray_map)
		end
	end
end

function C.SetRandomLotteryLasterGray(hero2)
	if not instance then return end
	if hero2 then
		local x = 1
		if hero2.cur_lucky then
			local gray_map = {}
			for y=1,4 do
				if hero2.cur_lucky[y] then
					gray_map[x] = gray_map[x] or {}
					gray_map[x][y] = y
				end
			end
			EliminateSHObjManager.SetHeroItemGray(gray_map)
		end
	end
end

function C.HideHero3FT()
	if not instance or table_is_null(instance.hero_map) or table_is_null(instance.hero_map[3]) then return end
	instance.hero_map[3].part[3].gameObject:SetActive(false)
end

function C.RefreshHero4TTXD(cur_result)
	if not instance or table_is_null(instance.hero_map) or table_is_null(instance.hero_map[4]) then 
		local obj = GameObject.Find("Canvas/LayerLv1/EliminateSHHeroManager/HeroPraticle/hero4/3")
		if IsEquals(obj) then
			obj.gameObject:SetActive(false)
		end
		return 
	end
	local hero_data = cur_result.hero
	if hero_data and hero_data[4] and hero_data[4].loop_count > 0 then
		local hero4 = hero_data[4]
		instance.ttxd_num_img.sprite = GetTexture("shxxl_imfg_" .. hero4.loop_count)
		instance.hero_map[4].part[3].gameObject:SetActive(true)
	else
		instance.hero_map[4].part[3].gameObject:SetActive(false)
	end
end

function C:view_lottery_end()
	self:MyRefresh()
end

function C:view_lottery_start()
	self:HeroReset()
end

function C.ChangeAnim(hero_id,state)
	if not instance or table_is_null(instance.hero_map) or not instance.hero_map[hero_id] then return end
	if state == C.AnimType.idle then 
		instance.hero_map[hero_id].ani:Play("xxl_sh_notopen")
	elseif state == C.AnimType.open_scucc then 
		instance.hero_map[hero_id].ani:Play("xxl_sh_open_yingxiong")
	elseif state == C.AnimType.open_fall then 
		instance.hero_map[hero_id].ani:Play("xxl_sh_dabukai")
	elseif state == C.AnimType.open then
		print("<color=white>打开门</color>")
		instance.hero_map[hero_id].ani:Play("xxl_sh_dakai")
	else
		print("暂无该动画的类型.....水浒消消乐")	
	end 
end

function C.PlayAudio(hero_id)
	if not instance or table_is_null(instance.hero_map) or not instance.hero_map[hero_id] then return end
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_km_yy_jg))
	seq:AppendCallback(function ()
		instance.hero_map[hero_id].audio_node.gameObject:SetActive(true)
		--语音
		-- local audio_name = "bgm_shxxl_yingxiong" .. hero_id
		-- ExtendSoundManager.PlaySound(audio_config.shxxl[audio_name].audio_name)
		if hero_id == 1 then
			ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_yingxiong1.audio_name)
		elseif hero_id == 2 then
			ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_yingxiong2.audio_name)
		elseif hero_id == 3 then
			ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_yingxiong3.audio_name)
		elseif hero_id == 4 then
			ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_yingxiong4.audio_name)
		end
	end)
	seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_km_yy_sj))
	seq:AppendCallback(function ()
		instance.hero_map[hero_id].audio_node.gameObject:SetActive(false)
	end)
end

C.show_time_map = {EliminateSHModel.time.yx_1_show,EliminateSHModel.time.yx_2_show,0,0} --英雄出场时间表
--英雄出场顺序表
function C.GetHeroShowList(cur_result,cur_del_list,cur_del_index,is_check)
	--手动消除
	if cur_del_index then
		local hero_list
		local xc_id = eliminate_sh_algorithm.get_xc_id(cur_del_list)
		if eliminate_sh_algorithm.check_add_hero(xc_id) and not table_is_null(cur_result.hero_add_list) then
			local xc_count = eliminate_sh_algorithm.get_xc_count(cur_del_list)
			local hc = eliminate_sh_algorithm.get_hero_count(xc_count)
			local f_h_c = 0
			if not table_is_null(cur_result.del_list) then
				local f_del_list
				local f_xc_count
				for i=1,cur_del_index - 1 do
					f_del_list = cur_result.del_list[i]
					xc_id = eliminate_sh_algorithm.get_xc_id(f_del_list)
					if eliminate_sh_algorithm.check_add_hero(xc_id) then
						f_h_c = f_h_c + eliminate_sh_algorithm.get_hero_count(eliminate_sh_algorithm.get_xc_count(f_del_list))
					end
				end
			end
			if hc then
				for i=1,hc do
					if cur_result.hero_add_list[1 + f_h_c] then
						local hero_id = cur_result.hero_add_list[1 + f_h_c]
						if not is_check then
							table.remove(cur_result.hero_add_list,1 + f_h_c)
						end
						local show_time = C.show_time_map[hero_id] or 0 --英雄出场时间
						--英雄出现
						hero_list = hero_list or {}
						table.insert(hero_list,{hero_id = hero_id,show_time = show_time})
					end
				end
			end
		end
		return hero_list
	end

    local hero_list
    local xc_id = eliminate_sh_algorithm.get_xc_id(cur_del_list)
    if eliminate_sh_algorithm.check_add_hero(xc_id) and not table_is_null(cur_result.hero_add_list) then
        local xc_count = eliminate_sh_algorithm.get_xc_count(cur_del_list)
        local hc = eliminate_sh_algorithm.get_hero_count(xc_count)
        if hc then
            for i=1,hc do
                if cur_result.hero_add_list[1] then
					local hero_id = cur_result.hero_add_list[1]
					if not is_check then
						table.remove(cur_result.hero_add_list,1)
					end
                    local show_time = C.show_time_map[hero_id] or 0 --英雄出场时间
                    --英雄出现
                    hero_list = hero_list or {}
                    table.insert(hero_list,{hero_id = hero_id,show_time = show_time})
                end
            end
        end
    end
    return hero_list
end

function C.HeroShow(hero_list,hero)
	local show_hero_list = {}--开门，开门失败，不开门

	for k,v in pairs(hero) do
		show_hero_list[k] = "not_open" --不开门
	end

	for i,v in ipairs(hero_list) do
		show_hero_list[v.hero_id] = "open_scucc"--开门成功
	end

	for hero_id = 1,4 do
		if not show_hero_list[hero_id] then
			show_hero_list[hero_id] = "open_fall"--开门失败
		end
	end

	ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_kaimen.audio_name)
	for k,v in pairs(show_hero_list) do
		if v == "open_scucc" then
			C.ChangeAnim(k,C.AnimType.open_scucc)
			C.PlayAudio(k)
		elseif v == "open_fall" then
			C.ChangeAnim(k,C.AnimType.open_fall)
		end
	end
end

--持续型的技能
function C.HeroSkillContinued(hero_data,cur_result)
	local id = hero_data.hero_id
	local hero_skill = cur_result.hero_skill
	if not instance or table_is_null(instance.hero_map) or not instance.hero_map[id] then return end
	local v = instance.hero_map[id]
	if id == 1 then
		local seq = DoTweenSequence.Create()
		seq:AppendCallback(function ()
			ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_yingxionglihui.audio_name)
			v.part[-2].gameObject:SetActive(true)
		end)
		seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_1_jn_rc_r))
		seq:AppendCallback(function ()
			ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_wusong.audio_name)
			v.part[-1].gameObject:SetActive(true)
			v.part[0].gameObject:SetActive(true)
			v.part[1].gameObject:SetActive(true)
		end)
		seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_1_jn_rc))
		seq:AppendCallback(function ()
			v.part[-2].gameObject:SetActive(false)
			v.part[-1].gameObject:SetActive(false)
			v.part[0].gameObject:SetActive(false)
			v.part[1].gameObject:SetActive(false)
			v.part[2].gameObject:SetActive(true)
		end)
		seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_1_jn_rc_jb))
		seq:AppendCallback(function ()
			--震动，音效
			ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_wusong1.audio_name)
			EliminateSHAnimManager.DOShakePositionCamer(nil,EliminateSHModel.GetTime(EliminateSHModel.time.yx_1_jn_zd))
			Event.Brocast("view_add_hero",{hero_id = 1})
		end)
		seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_1_jn_rc_js))
		seq:OnForceKill(function ()
			v.part[-2].gameObject:SetActive(false)
			v.part[-1].gameObject:SetActive(false)
			v.part[0].gameObject:SetActive(false)
			v.part[1].gameObject:SetActive(false)
			v.part[2].gameObject:SetActive(false)
		end)
	elseif id == 2 then
		local seq = DoTweenSequence.Create()
		-- seq:AppendCallback(function ()
		-- 	ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_yingxionglihui.audio_name)
		-- 	v.part[-2].gameObject:SetActive(true)
		-- end)
		-- seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_2_jn_rc_r))
		ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_luzhishen.audio_name)
		seq:AppendCallback(function ()
			v.part[-1].gameObject:SetActive(true)
			v.part[0].gameObject:SetActive(true)
			v.part[1].gameObject:SetActive(true)
		end)
		seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_2_jn_rc))--鲁智深技能 1 时间
		seq:AppendCallback(function ()
			v.part[1].gameObject:SetActive(false)
			v.part[2].gameObject:SetActive(true)
			C.SetRandomLotteryBefore(cur_result.hero[id])
			C.SetBaseLotteryBefore(hero_skill[id])
		end)
		seq:Append(v.part[2].gameObject.transform:DOLocalMoveX(400,EliminateSHModel.GetTime(EliminateSHModel.time.yx_2_jn_fr)):From())--从右边飞回来的时间
		seq:SetEase(DG.Tweening.Ease.Linear)
		seq:OnForceKill(function ()
			ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_luzhishen1.audio_name)
			EliminateSHAnimManager.DOShakePositionCamer(nil,EliminateSHModel.GetTime(EliminateSHModel.time.yx_2_jn_zd))
			v.part[-2].gameObject:SetActive(false)
			v.part[-1].gameObject:SetActive(false)
			v.part[0].gameObject:SetActive(false)
			v.part[2].gameObject.transform.localPosition = Vector3.zero
		end)
	elseif id == 3 then
		
	elseif id == 4 then
		local seq = DoTweenSequence.Create()
		seq:AppendCallback(function ()
			v.part[4].gameObject:SetActive(true)
			C.RefreshHero4TTXD(cur_result)
		end)
		seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_4_jn_sg))
		seq:OnForceKill(function (  )
			v.part[4].gameObject:SetActive(false)
			C.RefreshHero4TTXD(cur_result)
		end)
	end
end

function C.GetHero2NotLucky(cur_result)
	if table_is_null(cur_result) or 
	table_is_null(cur_result.hero_skill) or 
	table_is_null(cur_result.hero_skill[2]) then 
		return 
	end
	if table_is_null(cur_result.hero_skill[2].cur_lucky) then
		return true
	end
end

C.skill_time_map = {0.02,EliminateSHModel.time.yx_2_skill,EliminateSHModel.time.yx_3_skill,EliminateSHModel.time.yx_4_skill} --英雄使用技能时间表
--当前英雄使用的消除技能
function C.GetHeroSkillTrigger(cur_result,i,cur_rate)
	if table_is_null(cur_result) or table_is_null(cur_result.hero_skill) or table_is_null(cur_result.hero_skill[i]) then return end
	local hero_skill = cur_result.hero_skill[i]
    local hero_id = i
	local skill_time = C.skill_time_map[hero_id] or 0 --英雄使用技能时间
	local del_list
	local del_rate_list
	if i == 1 then
		if cur_rate and cur_rate == 0 then return end
		local is_hero1 = eliminate_sh_algorithm.check_cur_result_is_hero1(cur_result)
		if not is_hero1 then return end
		return {hero_id = hero_id,skill_time = skill_time, del_list = del_list, del_rate_list = del_rate_list}
	elseif i == 2 then
		local lucky_count = EliminateSHModel.GetHeroLuckyedCount(cur_result,i)
		if lucky_count == 4 and table_is_null(cur_result.hero_skill[i].cur_lucky) then
			--已经摇完英雄
			return
		end

		local change_lucky = EliminateSHModel.GetHeroCurChangeLuckyCount(cur_result,i)
		EliminateSHModel.time.yx_2_jn_z_d = EliminateSHModel.time.yx_2_gdyc_sj * change_lucky + EliminateSHModel.time.yx_2_jsgdjg * (change_lucky - 1)
		skill_time = EliminateSHModel.time.yx_2_jn_z_d + EliminateSHModel.time.yx_2_jn_rc_r
		if not table_is_null(hero_skill.cur_lucky) then
			skill_time = skill_time + EliminateSHModel.time.yx_2_jn_sgdtsxcjg + EliminateSHModel.time.yx_2_jn_tsxctime
			local v = {}
			for j=1,4 do
				if hero_skill.cur_lucky[j] then
					if not table_is_null(cur_result.hero_del_list) and not table_is_null(cur_result.hero_del_list[1]) then
						local cur_hero_del_list = basefunc.deepcopy(cur_result.hero_del_list[1])
						table.remove(cur_result.hero_del_list,1)
						del_list = del_list or {}
						table.insert(del_list,cur_hero_del_list)
					end
					if not table_is_null(cur_result.hero_del_rate_list) then
						local cur_rate = cur_result.hero_del_rate_list[1]
						table.remove(cur_result.hero_del_rate_list,1)
						del_rate_list = del_rate_list or {}
						table.insert(del_rate_list,cur_rate)
					end
					skill_time = skill_time + EliminateSHModel.time.yx_2_jn_tsxcjg
				end
			end
		end
		return {hero_id = hero_id,skill_time = skill_time, del_list = del_list, del_rate_list = del_rate_list}
	elseif i == 3 then
		local cur_hero_del_list = basefunc.deepcopy(cur_result.hero_del_list[1])
		table.remove(cur_result.hero_del_list,1)
		del_list = del_list or {}
		table.insert(del_list,cur_hero_del_list)

		local cur_rate = cur_result.hero_del_rate_list[1]
		table.remove(cur_result.hero_del_rate_list,1)
		del_rate_list = del_rate_list or {}
		table.insert(del_rate_list,cur_rate)
		return {hero_id = hero_id,skill_time = skill_time, del_list = del_list, del_rate_list = del_rate_list}
	elseif i == 4 then
		return {hero_id = hero_id,skill_time = skill_time, del_list = del_list, del_rate_list = del_rate_list}
	end
end

--触发型的技能
function C.HeroSkillTrigger(data,cur_result,next_result)
	local id = data.hero_id
	if not instance or table_is_null(instance.hero_map) or not instance.hero_map[id] then return end
	local v = instance.hero_map[id]
	if id == 1 then
		local seq = DoTweenSequence.Create()
		seq:AppendCallback(function ()
			v.part[3].gameObject:SetActive(true)
			local del_data = eliminate_sh_algorithm.change_map_to_list(data.cur_del_list)
			--拖尾滚动
			EliminateSHPartManager.CreateHero1TW(v.part[3].transform.position,del_data)
		end)
		seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_1_jn_jb_sg_js))
		seq:OnForceKill(function ()
			v.part[3].gameObject:SetActive(false)
		end)
	elseif id == 2 then
		--摇奖
		local seq = DoTweenSequence.Create()
		seq:AppendCallback(function ()
			ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_yingxionglihui.audio_name)
			v.part[-2].gameObject:SetActive(true)
		end)
		seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_2_jn_rc_r))

		local hero_map = EliminateSHObjManager.GetHeroMap()
		local hero_item_map = {}
		local x = 1
		local hero2 = cur_result.hero[2]
		for y=1,4 do
			if not EliminateSHModel.CheckHero2IndexIsLuckyed(hero2,y) then
				hero_item_map[x] = hero_item_map[x] or {}
				if hero_map[x] and hero_map[x][y] then
				hero_item_map[x][y] = hero_map[x][y]
				end
			end
		end

		seq:AppendCallback(function ()
			v.part[-1].gameObject:SetActive(true)
			v.part[0].gameObject:SetActive(true)
			if not table_is_null(hero_item_map) then
				--英雄转到动 1 秒
				EliminateSHAnimManager.ScrollDefaultChangeToRandom(hero_item_map,cur_result)
			end
		end)
		if not table_is_null(hero_item_map) then
			local change_lucky = EliminateSHModel.GetHeroCurChangeLuckyCount(cur_result,id)
			EliminateSHModel.time.yx_2_jn_z_d = EliminateSHModel.time.yx_2_gdyc_sj * change_lucky + EliminateSHModel.time.yx_2_jsgdjg * (change_lucky - 1)
			seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_2_jn_z_d))
		end
		if not table_is_null(cur_result.hero_skill[2].cur_lucky) then
			seq:AppendCallback(function ()
				--亮起中奖特效
				v.part[2].gameObject:SetActive(true)
				for k,_v in pairs(cur_result.hero_skill[2].cur_lucky) do
					v.part.sg[k].gameObject:SetActive(true)
					ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_luzhishen5.audio_name)
				end
			end)
			seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_2_jn_sgdtsxcjg))

			seq:AppendCallback(function ()
				v.part[3].gameObject:SetActive(true)
			end)
			for k=4,1,-1 do
				if cur_result.hero_skill[2].cur_lucky[k] then
					seq:AppendCallback(function ()
						v.part.tsxc[k].gameObject:SetActive(true)
						ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_luzhishen4.audio_name)
						local del_map = {}
						if not table_is_null(data.del_list) and not table_is_null(data.del_list[1]) then
							del_map = basefunc.deepcopy(data.del_list[1])
							table.remove(data.del_list,1)
						end
						local del_rate = 0
						if not table_is_null(data.del_rate_list) then
							del_rate =  basefunc.deepcopy(data.del_rate_list[1])
							table.remove(data.del_rate_list,1)
						end
						if not table_is_null(del_map) then
							EliminateSHObjManager.PlayParticleEliminate({is_hero1 = false},del_map,del_rate)
							EliminateSHObjManager.RemoveEliminateItem(del_map)
						else
							EliminateSHObjManager.PlayParticleEliminateNull(del_rate,k)
						end
						
						--消除元素加入消除框
						-- Event.Brocast("view_lottery_award",{cur_del_list = del_map,cur_rate = del_rate,hero_id = 2})
						--技能触发中奖英雄加入消除框
						local cur_del_hero_list = {}
						cur_del_hero_list.hero_del = 2
						cur_del_hero_list[1] = {}
						table.insert( cur_del_hero_list[1],"hero_" .. cur_result.hero_skill[2].cur_lucky[k])
						Event.Brocast("view_lottery_award",{cur_del_list = cur_del_hero_list,cur_rate = del_rate,hero_id = 2})
					end)
					seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_2_jn_tsxcjg))
				end
			end
			seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_2_jn_tsxctime))
			seq:OnForceKill(function ()
				v.part[-2].gameObject:SetActive(false)
				v.part[-1].gameObject:SetActive(false)
				v.part[0].gameObject:SetActive(false)
				v.part[3].gameObject:SetActive(false)
				EliminateSHHeroManager.SetRandomLotteryLaster(cur_result.hero[2])
				EliminateSHHeroManager.SetBaseLotteryLaster(cur_result.hero[2])
				EliminateSHHeroManager.SetRandomLotteryLasterGray(cur_result.hero_skill[2])
				-- v.part[2].gameObject:SetActive(false)
				for k,_v in pairs(cur_result.hero_skill[2].cur_lucky) do
					v.part.sg[k].gameObject:SetActive(false)
					v.part.tsxc[k].gameObject:SetActive(false)
				end
			end)
		else
			seq:OnForceKill(function ()
				v.part[-2].gameObject:SetActive(false)
				v.part[-1].gameObject:SetActive(false)
				v.part[0].gameObject:SetActive(false)
				v.part[3].gameObject:SetActive(false)
				EliminateSHHeroManager.SetRandomLotteryLaster(cur_result.hero[2])
				EliminateSHHeroManager.SetBaseLotteryLaster(cur_result.hero[2])
				EliminateSHHeroManager.SetRandomLotteryLasterGray(cur_result.hero_skill[2])
			end)
		end
	elseif id == 3 then
		local seq = DoTweenSequence.Create()
		seq:AppendCallback(function ()
			ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_yingxionglihui.audio_name)
			v.part[-2].gameObject:SetActive(true)
		end)
		seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_3_jn_rc_r))
		seq:AppendCallback(function ()
			ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_likui.audio_name)
			v.part[-1].gameObject:SetActive(true)
			v.part[0].gameObject:SetActive(true)
			v.part[1].gameObject:SetActive(true)
		end)

		-- seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_3_jn_zd))
		-- seq:AppendCallback(function ()
		-- 	ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_likui1.audio_name)
		-- 	EliminateSHAnimManager.DOShakePositionCamer(nil,EliminateSHModel.GetTime(EliminateSHModel.time.yx_3_jn_cf))
		-- end)
		-- seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_3_jn_gb))
		-- seq:AppendCallback(function ()
		-- 	--扩散效果
		-- 	EliminateSHPartManager.ChangeAllItem(cur_result)
		-- end)

		-- seq:AppendCallback(function ()
		-- 	--摇奖效果
		-- 	local item_map = EliminateSHObjManager.GetAllEliminateItem()
		-- 	local times = {
		-- 		ys_jsgdsj = EliminateSHModel.time.yx_3_jn_ys_jsgdsj,
		-- 		ys_ysgdjg = EliminateSHModel.time.yx_3_jn_ys_ysgdjg,
		-- 		ys_j_sgdsj = EliminateSHModel.time.yx_3_jn_ys_j_sgdsj,
		-- 		ys_jsgdjg = EliminateSHModel.time.yx_3_jn_ys_jsgdjg
		-- 	}
		-- 	EliminateSHAnimManager.ScrollLottery(item_map,times)
		-- end)
		-- seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_3_jb_yj_sj))
		-- seq:AppendCallback(function ()
		-- 	--停止摇奖
		-- 	local new_map = {}
		-- 	for x=1,8 do
		-- 		for y=1,8 do
		-- 			new_map[x] = new_map[x] or {}
		-- 			new_map[x][y] = cur_result.hero_skill[3].id
		-- 		end
		-- 	end
		-- 	local times = {
		-- 		ys_j_sgdjg = EliminateSHModel.time.yx_3_jn_ys_j_sgdjg,
		-- 		ys_ysgdsj = EliminateSHModel.time.yx_3_jn_ys_ysgdsj,
		-- 	}
		-- 	EliminateSHAnimManager.StopScrollLottery(new_map,nil,times)
		-- end)

		--整体变化效果
		seq:AppendCallback(function ()
			EliminateSHPartManager.ChangeAllItemOverall(cur_result)
			ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_likui1.audio_name)
			EliminateSHAnimManager.DOShakePositionCamer(nil,EliminateSHModel.GetTime(EliminateSHModel.time.yx_3_jn_cf))
		end)
		seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_3_jn_cf))
		seq:AppendCallback(function ()
			--吹飞效果
			ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_likui2.audio_name)
			v.part[2].gameObject:SetActive(true)
		end)
		seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_3_jn_cf_jg))
		seq:AppendCallback(function ()
			--吹飞效果
			EliminateSHPartManager.CreateAllBlom(EliminateSHObjManager.GetAllEliminateItem())
			--清屏
			if not table_is_null(data.del_list) then
                for i,del_map in ipairs(data.del_list) do
                    EliminateSHObjManager.PlayParticleEliminate({is_hero1 = false},del_map,data.del_rate_list[i])
					EliminateSHObjManager.RemoveEliminateItem(del_map)
					for x,_v in pairs(del_map) do
						for y,v in pairs(_v) do
							del_map[x][y] = cur_result.hero_skill[3].id
						end
					end
					del_map.hero_del = 3
					--消除元素加入消除框
					Event.Brocast("view_lottery_award",{cur_del_list = del_map,cur_rate = data.del_rate_list[i],hero_id = 3})
					--技能触发中奖英雄加入消除框
					-- local cur_del_hero_list = {}
					-- cur_del_hero_list[1] = {}
					-- if cur_result.hero[3].id then
					-- 	table.insert( cur_del_hero_list[1],cur_result.hero[3].id)
					-- end
                    -- Event.Brocast("view_lottery_award",{cur_del_list = cur_del_hero_list,cur_rate = data.del_rate_list[i],hero_id = 3})
                end
            end
		end)
		seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_3_jn_cc))
		seq:OnForceKill(function ()
			v.part[-2].gameObject:SetActive(false)
			v.part[-1].gameObject:SetActive(false)
			v.part[0].gameObject:SetActive(false)
			v.part[1].gameObject:SetActive(false)
			v.part[2].gameObject:SetActive(false)
			v.part[3].gameObject:SetActive(false)
		end)
	elseif id == 4 then
		local seq = DoTweenSequence.Create()
		seq:AppendCallback(function ()
			ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_yingxionglihui.audio_name)
			v.part[-2].gameObject:SetActive(true)
		end)
		seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_4_jn_rc_r))
		seq:AppendCallback(function ()
			--英雄3的斧头隐藏
			C.HideHero3FT()
			ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_songjiang.audio_name)
			v.part[-1].gameObject:SetActive(true)
			v.part[0].gameObject:SetActive(true)
			v.part[1].gameObject:SetActive(true)
			v.part[2].gameObject:SetActive(true)
		end)
		seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_4_jn_rc))
		seq:AppendCallback(function ()
			v.part[4].gameObject:SetActive(true)
			C.RefreshHero4TTXD(cur_result)
			--转动
			ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_songjiang1.audio_name)
			local item_map = EliminateSHObjManager.GetAllEliminateItem()
			local times = {
				ys_jsgdsj = EliminateSHModel.time.yx_4_jn_ys_jsgdsj,
				ys_ysgdjg = EliminateSHModel.time.yx_4_jn_ys_ysgdjg,
				ys_j_sgdsj = EliminateSHModel.time.yx_4_jn_ys_j_sgdsj,
				ys_jsgdjg = EliminateSHModel.time.yx_4_jn_ys_jsgdjg
			}
			EliminateSHAnimManager.ScrollLottery(item_map,times)
		end)
		seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_4_jn_zd))
		seq:AppendCallback(function ()
			local new_map = next_result.map_base
			local times = {
				ys_j_sgdjg = EliminateSHModel.time.yx_4_jn_ys_j_sgdjg,
				ys_ysgdsj = EliminateSHModel.time.yx_4_jn_ys_ysgdsj,
			}
			EliminateSHAnimManager.StopScrollLottery(new_map,function(  )
				EliminateSHObjManager.ClearEliminateItem()
        		EliminateSHObjManager.CreateEliminateItem(new_map)
			end,times)
		end)
		seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_4_jn_sg))
		seq:OnForceKill(function ()
			C.RefreshHero4TTXD(cur_result)
			v.part[-2].gameObject:SetActive(false)
			v.part[-1].gameObject:SetActive(false)
			v.part[0].gameObject:SetActive(false)
			v.part[1].gameObject:SetActive(false)
			v.part[2].gameObject:SetActive(false)
			v.part[4].gameObject:SetActive(false)
			if not table_is_null(next_result) and 
				not table_is_null(next_result.hero) and
				not table_is_null(next_result.hero[2]) then
				EliminateSHHeroManager.SetRandomLotteryBefore(next_result.hero[2])
				EliminateSHHeroManager.SetBaseLotteryBefore(next_result.hero[2])
			end
		end)
	end
end

--重置英雄
function C:HeroReset(not_change_ani)
	if not instance or table_is_null(instance.hero_map) then return end
	for k,v in pairs(instance.hero_map) do
		if not not_change_ani then
			C.ChangeAnim(k,C.AnimType.idle)
		end
		for j=-2,4 do
			if IsEquals(v.part[j]) then
				v.part[j].gameObject:SetActive(false)
			end
		end
		if k == 2 then
			for j=1,4 do
				if IsEquals(v.part.tsxc[j]) then
					v.part.tsxc[j].gameObject:SetActive(false)
				end
				if IsEquals(v.part.sg[j]) then
					v.part.tsxc[j].gameObject:SetActive(false)
				end
			end
		end
	end
end