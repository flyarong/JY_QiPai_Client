-- 创建时间:2020-03-27
-- Panel:TTLBombPanel
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

TTLBombPanel = basefunc.class()
local C = TTLBombPanel
C.name = "TTLBombPanel"

function C.Create(pos)
	return C.New(pos)
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
	if self.timer1 then
		self.timer1:Stop()
		self.timer1 = nil
	end
	if self.timer2 then
		self.timer2:Stop()
		self.timer2 = nil
	end
	if self.count_timer then
		self.count_timer:Stop()
		self.count_timer = nil
	end


	self.spawn_cell_list={}
	self.spawn_cell_list=nil
	self.line_list={}
	self.line_list=nil	
	TTLModel.still_live={data={},index={},award_txt={}}
	Event.Brocast("Bullet_behit_by_bullet_msg_fx_finish","bomb")
	self:RemoveListener()
	destroy(self.gameObject)
	
end

function C:ctor(pos)
	self.data = data
	self.lightning_pos=pos
	local parent = GameObject.Find("Canvas/LayerLv2").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	

	Event.Brocast("BombPanel_destoroy_TTL")

	

	self:CreatePrefab()
	

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
end

--生成bigAward类型预制体
function C:CreatePrefab()
	self:CloseSpawnPrefab()
	for i=1,#TTLModel.still_live.data  do
			local pre = TTLItemBase.Create(self.coordinate_node.transform, TTLModel.still_live.data[i],self.coordinate_node.transform,TTLModel.still_live.index[i],TTLModel.still_live.award_txt[i])
			if pre then
				self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
			end
		
	end
	self:Play_bomb20_sd_juneng()
	-- body
end

function C:CloseSpawnPrefab()
	if self.spawn_cell_list then
		for k,v in ipairs(self.spawn_cell_list) do
			v:MyExit()
		end
	end
	self.spawn_cell_list = {}
end


--播放聚能效果
function C:Play_bomb20_sd_juneng()
	self.line_list={}
	local juneng_pre = TTLParticleManager.Create("bomb20_sd_juneng",self.coordinate_node,self.lightning_pos)
	ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_shandianqiujuneng.audio_name)
	self.timer1 = Timer.New(function ()
				ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_shandianqiushifang.audio_name)
				for i=1,#self.spawn_cell_list do
					--print("<color=blue>++++++++++++++++++++++++</color>")
		            self.line_list[#self.line_list+1] = TTLParticleManager.Create("bomb20_sd_line01",self.coordinate_node,self.lightning_pos,nil,self.spawn_cell_list[i].transform.localPosition)
		            --self.line2 = TTLParticleManager.Create("bomb20_sd_line02",self.coordinate_node,self.lightning_pos,nil,self.spawn_cell_list[i].transform.localPosition)
		            --self.line3 = TTLParticleManager.Create("bomb20_sd_line03",self.coordinate_node,self.lightning_pos,nil,self.spawn_cell_list[i].transform.localPosition)
					TTLParticleManager.Create("bomb20_sd_sj",self.spawn_cell_list[i].transform,Vector3.New(0,0,0))
		        end		   
		        self.camera = GameObject.Find("Camera"):GetComponent("Camera")
				self.seq = DoTweenSequence.Create()
				self.seq:Append(self.camera.transform:DOShakePosition(2,Vector3.New(60,0,0),10))
				self.seq:OnKill(function ()
					-- body
				end)         
		            self.timer2 = Timer.New(function ()
		            		for i=1,#self.line_list do
		            			Event.Brocast("BombPanel_add_score_TTL",self.spawn_cell_list[i].data.award)
		            			GameObject.Destroy(self.line_list[i].gameObject)
		            			self.spawn_cell_list[i]:Particle_onDie()
		            			self.spawn_cell_list[i]:ScoreTxt_onHit_or_Die(TTLModel.still_live.award_txt[i])
		            			self.spawn_cell_list[i]:MyExit()
		            		end		   
		            		self:Exit()
						end,1.5,1,false)
					self.timer2:Start()
					end,2,1,false)
	self.timer1:Start()



end

function C:Exit()
	self.count_timer = Timer.New(function ()
		Event.Brocast("model_bullet_pause_msg",{type="bomb",is_pause=true})

		--Event.Brocast("BombPanel_on_bomb_end")--恢复子弹运动	
		self:MyExit()
	end,1.2,1,false)
	self.count_timer:Start()

	-- body
end