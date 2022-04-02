-- 创建时间:2020-03-20

local basefunc = require "Game.Common.basefunc"

TTLItemBase = basefunc.class()

local C = TTLItemBase

C.name = "TTLItemBase"



TTLItemBase.Type = {	

	switch="switch",--灯泡
	boundary="boundary",--边界
	normal="normal",--0角，有分
	bigAward="bigAward",--8角，16角，有分
	bomb="bomb",--20角，无分

}

function C.Create(parent, data,coordinate_node,index,award_txt)
    return C.New(parent, data,coordinate_node,index,award_txt)
end


function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["Bullet_behit_by_bullet_TTL"]=basefunc.handler(self,self.on_behit)--被碰撞
    self.lister["GamePanel_on_close_TTL"]=basefunc.handler(self,self.on_close)
    --self.lister["BombPanel_add_score_TTL"]=basefunc.handler(self,self.on_bomb)
    self.lister["model_switchRoll_TTL"]=basefunc.handler(self,self.on_switchRoll)
    self.lister["BombPanel_destoroy_TTL"]=basefunc.handler(self,self.bomb_destroy_bigaward)
    self.lister["ItemBase_still_Live_bigAward_TTL"]=basefunc.handler(self,self.still_Live_bigAward)
    self.lister["GamePanel_chang_power_TTL"]=basefunc.handler(self,self.change_power)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

--获取预制体名字
function C:get_prefab_name()
	if self.data.type == "bigAward" then
		if self.data.complete_time == 8 then
			return "bigAward8"
		elseif self.data.complete_time == 12 then
			return "bigAward12"
		elseif self.data.complete_time == 16 then
			return "bigAward16"
		else
			dump(self.data, "<color=red>未知角</color>")
		end
	elseif self.data.type == "bomb" then
		return "bomb20"
	elseif self.data.type == "switch" then
		return "switch1"
	elseif self.data.type == "normal" then
		return "normal1"
	else
		dump(self.data, "<color=red>未知数据</color>")
	end
end


--获取撞击特效名字
function C:get_Particle_onHit_name(prefab_name)
	if prefab_name=="normal1" then
		return "normal1_boom"
	elseif prefab_name=="bigAward8" then
		return "bigAward8_boom"
	elseif prefab_name=="bigAward16" then
		return "bigAward16_boom"
	elseif prefab_name=="bomb20" then
		return "bomb20_boom"
	end
end

--获取死亡特效名字
function C:get_Particle_onDie_name(prefab_name)
	if prefab_name=="bigAward8" then
		return "bigAward8_boom2"
	elseif prefab_name=="bigAward16" then
		return "bigAward16_boom2"
	elseif prefab_name=="bomb20" then
		return "bomb20_boom2"
	end
end



function C:ctor(parent, data,coordinate_node,index,award_txt)
	self.data = data
	local pre_name = self:get_prefab_name()
	if not pre_name then
		return
	end
	local obj = newObject(pre_name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.transform.localPosition = Vector3.New(self.data.center.x,self.data.center.y,0)

	self.fun_type_map = {}
	self.fun_type_map[TTLItemBase.Type.switch] = self.Type_switch
	self.fun_type_map[TTLItemBase.Type.boundary] = self.Type_boundary
	self.fun_type_map[TTLItemBase.Type.normal] = self.Type_normal
	self.fun_type_map[TTLItemBase.Type.bigAward] = self.Type_bigAward
	self.fun_type_map[TTLItemBase.Type.bomb] = self.Type_bomb


	self.horn_list={}
	self:addHorn()

	self.power=500

	self.index=index or 0
	if self.index~=0 then
		for i=0,self.index-2 do
			dump(self)
			--dump(i,"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT")
			self.horn_list[i]:SetActive(true)
			--self.hornBG_img.transform:GetChild(i):GetChild(0).gameObject:SetActive(true)
		end
	end


	if self.data.type=="bigAward" then
		if award_txt then
			self.award_txt.text=award_txt
		else
			self.award_txt.text=self.data.award*TTLModel.Defines.bets
		end
	end


	self.is_switchRoll=false
	self.coordinate_node_to_particle=coordinate_node

	self:MakeLister()
	self:AddMsgListener()
end


function C:addHorn()
	if  self.data.type=="bigAward" or self.data.type=="bomb" then
		--dump(TTLModel.Item_config.obs_data[self.data.obs_no].complete_time)
		for i=0,TTLModel.Item_config.obs_data[self.data.obs_no].complete_time-1 do
			self.horn_list[i]= self.hornBG_img.transform:GetChild(i):GetChild(0).gameObject
		end
	end
	--dump(self.horn_list)
	-- body
end



--被碰撞
function C:on_behit(id)
	if id == self.data.obs_no then
		self.fun_type_map[self.data.type](self)
	end
end

--被撞击变大动画
function C:DoScale()
	self.scale_seq1 = DoTweenSequence.Create()
	self.scale_seq1:Append(self.transform:DOScale(Vector3.New(1.2,1.2,1.2), 0.3))
	self.scale_seq1:Append(self.transform:DOScale(Vector3.New(1,1,1), 0.3))
end





--灯泡
function C:Type_switch()
	print("switch")
	if self.is_switchRoll then
		--触发摇奖后,灯泡不再判断亮或不亮
	else
		if self.switchOn_huo.gameObject.activeSelf then
			self.switchOn_huo.gameObject:SetActive(false)
		else
			self.switchOn_huo.gameObject:SetActive(true)			
		end
	end
end

function C:Type_bomb()
	local id=self.data.obs_no
	if not TTLModel.Item_config.obs_data[id] or not TTLModel.Item_config.obs_data[id].complete_time then
		dump(TTLModel.Item_config.obs_data[id])
	end

	--播放碰撞加分
	local complete_time = TTLModel.Item_config.obs_data[id].complete_time
	
	if self.index<complete_time then
		--dump(self.index)
		--dump(self.hornBG_img)
		self.horn_list[self.index]:SetActive(true)
		--self.hornBG_img.transform:GetChild(self.index):GetChild(0).gameObject:SetActive(true)

			if self.index<=3 then 
				ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_dazhuangji1.audio_name)
			elseif self.index<=6 and self.index>3 then
				ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_dazhuangji2.audio_name)
			elseif self.index<=9 and self.index>6 then
				ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_dazhuangji3.audio_name)
			elseif self.index<=12 and self.index>9 then
				ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_dazhuangji4.audio_name)
			elseif self.index<=15 and self.index>12 then
				ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_dazhuangji5.audio_name)
			elseif self.index>15 then
				ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_dazhuangji6.audio_name)
			end



		self:DoScale()
		self:Particle_onHit()--播放碰撞特效

		self.index = self.index + 1
	end
	if self.index==complete_time then
		Event.Brocast("ItemBase_still_Live_bigAward_TTL")--给还活着的bigAward发消息
		--TTLBombPanel.Create(self.transform.localPosition)
		Event.Brocast("ItemBase_on_bomb_TTL")
		--Event.Brocast("ItemBase_bomb_TTL")--子彈暫停
		--Event.Brocast("model_bullet_pause_msg",{type="bomb",is_pause=false})
		
		self:Particle_onDie()--播放爆炸特效
		--播放爆炸加分
		--destroy(self.gameObject)--销毁自身

		self.destroy_ = Timer.New(function ()
						self:MyExit()
				if self.destroy_ then
					self.destroy_:Stop()
					self.destroy_ = nil
				end
			end,3.5,1,false)
		self.destroy_:Start()

	end
	-- body
end


--墙壁
function C:Type_boundary()
	print("boundary")	
	-- body
end


--没有边角的物体
function C:Type_normal()
	
	self:DoScale()
	ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_xiaozhuangji.audio_name)
	self:ScoreTxt_onHit_or_Die((self.power/1000)*self.data.award)--播放碰撞加分
	self:Particle_onHit()--播放碰撞特效
	Event.Brocast("ItemBase_Award_Die_or_Hit_TTL",self.data.award)
	-- body
end


--有边角的物体
function C:Type_bigAward()
	local id=self.data.obs_no
	if not TTLModel.Item_config.obs_data[id] or not TTLModel.Item_config.obs_data[id].complete_time then
		dump(TTLModel.Item_config.obs_data[id])
	end
	--播放碰撞加分
	local complete_time = TTLModel.Item_config.obs_data[id].complete_time

	if self.index<complete_time then
		--dump(self.index)
		--dump(self.horn_list)
		--dump(self.hornBG_img)
		self.horn_list[self.index]:SetActive(true)
		--self.hornBG_img.transform:GetChild(self.index):GetChild(0).gameObject:SetActive(true)
		if complete_time==8 then
			if self.index<=1 then 
				ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_dazhuangji1.audio_name)
			elseif self.index<=2 and self.index>1 then
				ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_dazhuangji2.audio_name)
			elseif self.index<=3 and self.index>2 then
				ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_dazhuangji3.audio_name)
			elseif self.index<=4 and self.index>3 then
				ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_dazhuangji4.audio_name)
			elseif self.index<=5 and self.index>4 then
				ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_dazhuangji5.audio_name)
			elseif self.index>5 then
				ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_dazhuangji6.audio_name)
			end
		elseif complete_time==16 then
			if self.index<=2 then 
				ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_dazhuangji1.audio_name)
			elseif self.index<=4 and self.index>2 then
				ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_dazhuangji2.audio_name)
			elseif self.index<=6 and self.index>4 then
				ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_dazhuangji3.audio_name)
			elseif self.index<=8 and self.index>6 then
				ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_dazhuangji4.audio_name)
			elseif self.index<=10 and self.index>8 then
				ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_dazhuangji5.audio_name)
			elseif self.index<=12 and self.index>10 then
				ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_dazhuangji6.audio_name)
			elseif self.index<=14 and self.index>12 then
				ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_dazhuangji6.audio_name)
			elseif self.index>14 then
				ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_dazhuangji6.audio_name)
			end
		end

		self:DoScale()
		self:Particle_onHit()--播放碰撞特效

		self.index = self.index + 1
	end
	if self.index==complete_time then
		self:Particle_onDie()--播放爆炸特效
		self:ScoreTxt_onHit_or_Die((self.power/1000)*self.data.award)--播放爆炸加分
		Event.Brocast("ItemBase_Award_Die_or_Hit_TTL",self.data.award)
        --destroy(self.gameObject)--销毁自身
        self:MyExit()
		
		
		
	end
end

function C:on_bomb(bombPanel_pre)
	if self.data.type=="bigAward" then
		Event.Brocast("ItemBase_Award_Die_or_Hit_TTL",self.data.award)
		--destroy(self.gameObject)
		-- body
	end
end

--播放撞击加分
function C:ScoreTxt_onHit_or_Die(award_)
	TTLParticleManager.Create("score_prefab",self.coordinate_node_to_particle,self.transform.localPosition+self.transform.up,award_,nil,self.data.type)
	-- body
end



--播放碰撞特效
function C:Particle_onHit()
	TTLParticleManager.Create(self:get_Particle_onHit_name(self:get_prefab_name()),self.coordinate_node_to_particle,self.transform.localPosition)
	-- body
end


--播放死亡特效
function C:Particle_onDie()
	ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_dabaopo.audio_name)
	TTLParticleManager.Create(self:get_Particle_onDie_name(self:get_prefab_name()),self.coordinate_node_to_particle,self.transform.localPosition)
	-- body
end



function C:on_close()
	self:RemoveListener()
	-- body
end


function C:MyExit()
	self:RemoveListener()
	GameObject.Destroy(self.gameObject)
	-- body
end


--已经触发摇奖,所以将灯泡设为常亮
function C:on_switchRoll()
	self.is_switchRoll=true
	-- body
end

--销毁原bigAward
function C:bomb_destroy_bigaward()
	if self.data.type=="bigAward" then
		self:MyExit()
	end
	-- body
end

--活着的bigAward将自己的信息传给TTLModel
function C:still_Live_bigAward()
	if self.data.type=="bigAward" then
		TTLModel.Still_live_bigAward(self.data,self.index,self.award_txt.text)
	end
	-- body
end


function C:change_power(power)
	self.power=power
	if self.data.type=="bigAward" then		
		self.award_txt.text=(power/1000)*self.data.award
	end
	-- body
end