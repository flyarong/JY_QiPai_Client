-- 创建时间:2020-03-19

local basefunc = require "Game.Common.basefunc"

TTLBullet = basefunc.class()

local C = TTLBullet

C.name = "TTLBullet"

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
    self.lister["GamePanel_on_close_TTL"]=basefunc.handler(self,self.on_close)
    --self.lister["model_switchRoll_TTL"]=basefunc.handler(self,self.on_Roll_or_Bomb)
    self.lister["ItemBase_on_bomb_TTL"]=basefunc.handler(self,self.on_Roll_or_Bomb)
    --self.lister["model_changeQuicken_TTL"]=basefunc.handler(self,self.changeQuicken)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:ctor(parent)
	self.bullet_speed = TTLModel.Defines.BulletSpeed_max
	self.bullet_radius = TTLModel.Defines.BulletRadius
	self.quicken=1
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.bullet_origin_pos=self.bullet.transform.localPosition--子弹的初始位置
	self.bullet_origin_rot=self.bullet.transform.localRotation--子弹的初始角度
	--self.arrow_origin_pos=self.arrow.transform.localPosition--瞄准器的初始位置
	--dump(self.arrow_origin_pos)
	
	self.is_move=false

	--self:RunWait()


	self:MakeLister()
	self:AddMsgListener()
end

function C:changeQuicken(quicken)
	if self.quicken==quicken then
		self.quicken=1
	else
		self.quicken=quicken
	end
end

function C:FrameUpdate(time_elapsed)
	if not self.is_move then
		return
	end

	local run_t = time_elapsed *self.quicken
	while (true) do
        if run_t >= time_elapsed then
            self:Moving(time_elapsed)
            run_t = run_t - time_elapsed
        else
            self:Moving(run_t)
            break
        end
    end
end


function C:Moving(time_elapsed)
	-- 调整速度
	if self.bullet_speed > (TTLModel.Defines.BulletSpeed_min - 0.00001) and self.bullet_speed < (TTLModel.Defines.BulletSpeed_min + 0.00001) then
		-- 匀速
	else
		self.bullet_speed = self.bullet_speed + TTLModel.Defines.BulletAcceleration *time_elapsed
		if self.bullet_speed < TTLModel.Defines.BulletSpeed_min then
			self.bullet_speed = TTLModel.Defines.BulletSpeed_min
		end
	end


    local nextframe_pos = self.bullet.transform.localPosition + self.bullet.transform.up * time_elapsed * self.bullet_speed--下一帧应该走到的点
    local cha1 = {x=nextframe_pos.x-self.bullet.transform.localPosition.x , y=nextframe_pos.y-self.bullet.transform.localPosition.y}--当前点到下一帧点的向量
    local cha2 = {x=self.end_posX-self.bullet.transform.localPosition.x , y=self.end_posY-self.bullet.transform.localPosition.y}--当前点到下一个目标点的向量
    local len1 = math.sqrt(cha1.x*cha1.x + cha1.y*cha1.y)--当前点到下一帧点的距离
    local len2 = math.sqrt(cha2.x*cha2.x + cha2.y*cha2.y)--当前点到下一个目标点的距离
    if len1 <= len2 then
    	self.bullet.transform.localPosition = nextframe_pos
--广播花费的时间与slider同步
    	Event.Brocast("Bullet_timeRunning_TTL", time_elapsed)
    else
    	if self.cur_index then
    		-- self.bullet_speed = TTLModel.Defines.BulletSpeed_max
    	end
--广播花费的时间与slider同步
    	Event.Brocast("Bullet_timeRunning_TTL", time_elapsed * len2 / len1)
    	-- todo 时间有误差 time_elapsed 大于实际移动时间

    	self.bullet.transform.localPosition = Vector3.New(self.end_posX,self.end_posY,0) 
		Event.Brocast("Bullet_behit_by_bullet_msg",self.end_id)
		--Event.Brocast("Bullet_behit_by_bullet_TTL",self.end_id)
		self:RefreshSpeed(self.end_id)

    	

		--ExtendSoundManager.PlaySound(audio_config.ttl.com_but_confirm.audio_name)

    	self.cur_index = self.cur_index + 3
    	if self.cur_index <= #self.point_data then
			self.end_posX = self.point_data[self.cur_index]
			self.end_posY = self.point_data[self.cur_index+1]
			self.end_id = self.point_data[self.cur_index+2]

			self:ImproveRotation()
    	else
    		-- 移动完成
    		Event.Brocast("model_bullet_pause_msg", {type="ydwc", is_pause=false})

    	end 
    end
end

--碰撞后加速
function C:RefreshSpeed(id)
	if not TTLModel.Item_config.obs_data[id] then
		dump(id,"<color=red>Error TTL RefreshSpeed id </color>")
		return
	end
	if TTLModel.Item_config.obs_data[id].type =="boundary" then
		--墙面不刷新子弹速度
	else
		self.bullet_speed = TTLModel.Defines.BulletSpeed_max
	end
end

-- 第一次运行发射（初始化数据）
function C:RunMove(unzip_data)	
	dump(unzip_data,"<color=red>/////////////////////////////</color>")
	dump(self.is_move)
	if true then
		--self.arrow.transform:GetComponent("Animator").enabled=false
		self.cur_index = 4
		--self.pos_data = data
		--self.id_data =id
		--self.type_data=type_
		self.point_data=unzip_data
		self.end_posX = self.point_data[self.cur_index]
		self.end_posY = self.point_data[self.cur_index+1]
		self.end_id = self.point_data[self.cur_index+2]
		self.bullet.transform.localPosition=Vector3.New(self.point_data[1], self.point_data[2], 0)
		--self.end_type=self.type_data[self.cur_index]
		self:ImproveRotation()
		--self.arrow.transform.localPosition=self.arrow_origin_pos
		self.is_move = true
	end
end

--调整子弹方向
function C:ImproveRotation()
	local MoveNormalized = Vector3.New(self.end_posX,self.end_posY,0) -self.bullet.transform.localPosition 
	self.direction = MoveNormalized:SetNormalize()
	local z
	if (self.direction.x > 0) then
		z = -Vector3.Angle (Vector3.New(0,1,0), self.direction)
	else 
		z = Vector3.Angle (Vector3.New(0,1,0), self.direction)
	end
	self.bullet.transform.localRotation = Quaternion:SetEuler(0,0,z)
end

function C:GetCurArrowRotation()
	local zz = self.arrow.transform.localEulerAngles.z
	dump(zz,"<color=red>zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz</color>")
	local xs = 1
	if zz < 0 then
		xs = -1
	end
	while(zz > 90 or zz < -90) do
		zz = zz - xs * 360
	end
	dump(zz,"<color=blue>zzzzzzzzzzzzzzzzzzzzzzzzzzzzz</color>")

	zz = zz + 90
	zz = math.ceil(zz / 2) * 2
	if zz<30 then
		zz=30
	end
	if zz>150 then
		zz=150
	end
	dump(zz,"<color=blue>zzzzzzzzzzzzzzzzzzzzzzzzzzzzz</color>")
	return zz
end

function C:on_close()
	self:RemoveListener()
end

function C:MyRefresh()
	self.bullet.transform.localPosition=self.bullet_origin_pos
	self.bullet.transform.localRotation=self.bullet_origin_rot
end
function C:MyExit()
	self:RemoveListener()
end

function C:is_pause(bool)
	self.is_move = bool
end

function C:on_Roll_or_Bomb()
	self.on_Roll_or_Bomb = true
end