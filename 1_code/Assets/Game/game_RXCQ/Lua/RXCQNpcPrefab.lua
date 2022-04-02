local basefunc = require "Game/Common/basefunc"

RXCQNpcPrefab = basefunc.class()
local C = RXCQNpcPrefab
C.name = "RXCQNpcPrefab"

function C.Create(parent,name)
	return C.New(parent,name)
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister={}                                                                                                                                                             
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	self:DestroyYY()
	destroy(self.chuansong)
	self:StopAnim()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent,name)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.texture_name = name
	self:MakeLister()
	self:AddMsgListener()
end

function C:Hit(backcall)
	
	self:CreateYY()
	self.gameObject:SetActive(true)
	self:StopAnim()
	local index = 0
	local func = function()
		index = index + 1
		if index <= #RXCQPrefabManager.Max_Texture2Ds[self.texture_name]["stand"] then
			self.main_img.sprite = RXCQPrefabManager.Texture2Ds[self.texture_name]["stand"][index]
			self.main_img:SetNativeSize()
		else
			if backcall then
				backcall()
			end
		end
	end
	func()
	--获取去掉空白区域的中心位置（模糊）
	local get_near_pos = function()
		local texture = RXCQPrefabManager.Texture2Ds[self.texture_name]["stand"][1].texture
		local w = texture.width
		local h = texture.height
		local config = {
			{w/2,h/2},{w/4,h/2},{w/2,3*h/4},{3*w/4,h/2},{w/2,h/4}
		}
		local z_p = {
			w/2,h/2,
		}
		local re_index = 1
		for i = 1,#config do
			if texture:GetPixel(config[i][1], config[i][2]).a ~= 0 then
				return Vector3.New(config[i][1] - z_p[1],config[i][2] - z_p[2],0)
			end
		end
		return Vector3.New(0,0,0)
	end
	local v = Vector3.New(0,0,0) or get_near_pos()
	local shouji = GameObject.Instantiate(RXCQPrefabManager.Prefabs["RXCQ_TongYong_ShouJi"],self.transform)
	shouji.transform.localPosition = v
	self.MainTimer = Timer.New(
		function()
			func()
		end
	,0.1,#RXCQPrefabManager.Max_Texture2Ds[self.texture_name]["stand"],nil,true)
	self.MainTimer:Start()
	GameObject.Destroy(shouji,1)
end

function C:Stand()
	
	self:CreateYY()
	self.gameObject:SetActive(true)
	self:StopAnim()
	self.lock = false
	local index = 1
	local func = function()
		if index > #RXCQPrefabManager.Max_Texture2Ds[self.texture_name]["stand"] then
			index = 1
		end
		self.main_img.sprite = RXCQPrefabManager.Texture2Ds[self.texture_name]["stand"][index]
		self.main_img:SetNativeSize()
		index = index + 1
	end
	func()
	self.MainTimer = Timer.New(
		function()
			func()
		end
	,0.2,-1,nil,true)
	self.MainTimer:Start()
end

function C:Death(backcall,speed)
	
	print("<color=yellow>进入死亡</color>")
	--dump(self,"当前示例")
	self:DestroyYY()
	self:StopAnim()
	local config = {
		fs1 = "rxcq_womandeath",
		fs2 = "rxcq_mandeath",
		zs1 = "rxcq_womandeath",
		zs2 = "rxcq_mandeath",
		ds1 = "rxcq_womandeath",
		ds2 = "rxcq_mandeath",
	}
	RXCQModel.PlayAudioLimit(config[self.texture_name])
	speed = speed or 1
	local index = 1
	local func = function()
		if index <= #RXCQPrefabManager.Max_Texture2Ds[self.texture_name]["death"] then
			self.main_img.sprite = RXCQPrefabManager.Texture2Ds[self.texture_name]["death"][index]
			self.main_img:SetNativeSize()
			index = index + 1
		else
			--dump(backcall,"backcall")
			if backcall then
				backcall()
			end
			self.delay_timer = Timer.New(
				function()
					self.gameObject:SetActive(false)
					self:MyExit()
				end
			,0.2/speed,1,nil,true)
			self.delay_timer:Start()
		end
	end
	func()
	self.MainTimer = Timer.New(
		function()
			func()
		end
	,0.1/speed,#RXCQPrefabManager.Max_Texture2Ds[self.texture_name]["death"],nil,true)
	self.MainTimer:Start()
end
--构建阴影
function C:CreateYY()
	self:DestroyYY()
	self.YY = GameObject.Instantiate(RXCQPrefabManager.Prefabs["RXCQ_YY"],self.transform)
	self.YY.transform.localPosition = self:GetYYPos()
	self.YY.transform.parent = self.transform.parent
	self.YY.transform:SetSiblingIndex(0)
end

function C:DestroyYY()
	if self.YY then
		destroy(self.YY)
	end
end

function C:GetYYPos()
	local config = {
		fs1 = Vector3.New(-26.3,-178,0),
		fs2 = Vector3.New(-21,-200),
		zs1 = Vector3.New(0,-153,0),
		zs2 = Vector3.New(-15,-137,0),
		ds1 = Vector3.New(2,-142,0),
		ds2 = Vector3.New(-8,-131),
	}
	return config[self.texture_name]
end

function C:ShowChuanSong(backcall)
	if self.chuansong then
		destroy(self.chuansong)
		self.chuansong = nil
	end
	self.gameObject:SetActive(false)
	self.chuansong = GameObject.Instantiate(RXCQPrefabManager.Prefabs["RXCQ_ChuanSong_Player"],self.transform)
	local v = self:GetYYPos()
	self.chuansong.transform.localPosition = Vector3.New(v.x,v.y + 33)
	self.chuansong.transform.parent = self.transform.parent
	RXCQModel.DelayCall(function()
		self.chuansong:SetActive(false)
	end,0.6)
	RXCQModel.DelayCall(function()
		self.gameObject:SetActive(true)
		if backcall then
			backcall()
		end
	end,0.4)
end

function C:PlayDeathSound()
	ExtendSoundManager.PlaySound(audio_config.rxcq.rxcq_monsterdeath.audio_name)
end

function C:StopAnim()
	--dump(self.guaiwu_id,"<color=red>guaiwu_id +++</color>")
	if self.MainTimer then
		self.MainTimer:Stop()
	end
end

function C:CreateNearPos()
	local x = self:GetYYPos().x
	local y = self:GetYYPos().y
	return Vector3.New(x + math.random(-50,50),y + math.random(-50,50))
end

function C:Run(target_pos,backcall,time)
	
	self:CreateYY()
	self.gameObject:SetActive(true)
	self:StopAnim()
	self.lock = false
	local jingzhan = {"zs1","zs2"}
	local time_space = 0.1
	for i = 1,#jingzhan do
		if self.texture_name == jingzhan[i] then
			time_space = 0.06
			break
		end
	end
	local index = 1
	local func = function()
		if index > #RXCQPrefabManager.Max_Texture2Ds[self.texture_name]["run"] then
			index = 1
		end
		self.main_img.sprite = RXCQPrefabManager.Texture2Ds[self.texture_name]["run"][index]
		self.main_img:SetNativeSize()
		index = index + 1
	end
	func()
	self.MainTimer = Timer.New(
		function()
			func()
		end
	,time_space,-1,nil,true)
	self.MainTimer:Start()
	if target_pos then
        local seq = DoTweenSequence.Create({dotweenLayerKey = "rxcq"})
        seq:Append(self.gameObject.transform.parent.transform:DOLocalMove(target_pos, time or 0.8):SetEase(DG.Tweening.Ease.Linear))
        seq:AppendCallback(function()
            if backcall then
                backcall()
            end
        end)
    end
end

function C:Attack(target)
	
	local jingzhan = {"zs1","zs2"}
	local attack = "skill"
	local time_space = 0.2
	for i = 1,#jingzhan do
		if self.texture_name == jingzhan[i] then
			attack = "attack"
			time_space = 0.12
			break
		end
	end
	self:CreateYY()
	self.gameObject:SetActive(true)
	self:StopAnim()
	self.lock = false

	local skill_config = {
		"bingdong","huofu","shandian",
	}

	local use_skill = skill_config[1]
	if attack == "skill" then
		use_skill = skill_config[math.random(1,#skill_config)]
		if use_skill == "bingdong" then
			local b = GameObject.Instantiate(RXCQPrefabManager.Prefabs["RXCQ_BPX_Item1"],self.gameObject.transform)
			b.transform.localPosition = Vector3.New(-11,-149)
			b.transform.localScale = Vector3.New(1.3,1.3,1.3)
			GameObject.Destroy(b,3)
		end
	end

	local index = 1
	local func = function()
		self.main_img.sprite = RXCQPrefabManager.Texture2Ds[self.texture_name][attack][index]
		self.main_img:SetNativeSize()
		index = index + 1
		if index == 4 then
			if attack == "skill" then
				self:UseSkill(use_skill,target)
			end
		end
		if index >= #RXCQPrefabManager.Max_Texture2Ds[self.texture_name][attack] then
			index = 1
		end
	end
	func()
	self.MainTimer = Timer.New(
		function()
			func()
		end
	,time_space,#RXCQPrefabManager.Max_Texture2Ds[self.texture_name][attack],nil,true)
	self.MainTimer:Start()
end

-- 向量减法
local function Vec2DSub(vec1, vec2)
	return {x=vec1.x-vec2.x, y=vec1.y-vec2.y}
end


function C:UseSkill(skill_name,target)
	
	local target_pos = Vector3.New(target.transform.localPosition.x + math.random(-200,200),
	target.transform.localPosition.y + math.random(-200,200),0
	)
	if skill_name == "bingdong" then
		local b = GameObject.Instantiate(RXCQPrefabManager.Prefabs["RXCQ_BPX_Item2"],self.gameObject.transform)
		b.transform.parent = target.transform.parent
		b.transform.localPosition = target_pos
		b.transform.localScale = Vector3.New(4,4,4)
		RXCQModel.PlayAudioLimit("rxcq_bphit",0.2)
		GameObject.Destroy(b,1.15)
	elseif skill_name == "huofu" then
		local b = GameObject.Instantiate(RXCQPrefabManager.Prefabs["RXCQ_Huo_Item"],self.gameObject.transform)
		b.transform.parent = target.transform.parent
		local dirVec = Vec2DSub(b.transform.localPosition,target.transform.localPosition)
		local r = math.atan2(dirVec.y, dirVec.x) * 180 / math.pi
		b.transform.rotation = Quaternion.Euler(0, 0, r)
		b.transform.localScale = Vector3.New(2,2,2)
		local seq = DoTweenSequence.Create({dotweenLayerKey = "rxcq_item"})
		seq:Append(b.transform:DOLocalMove(target.transform.localPosition,0.3):SetEase(DG.Tweening.Ease.Linear))
		seq:AppendCallback(
			function()
				GameObject.Destroy(b,0.1)
			end
		)
	elseif skill_name == "shandian" then
		local b = GameObject.Instantiate(RXCQPrefabManager.Prefabs["RXCQ_FenWei_ShanDian"],self.gameObject.transform)
		b.transform.parent = target.transform.parent
		b.transform.localPosition = Vector3.New(target_pos.x,target_pos.y + 300,0)
		RXCQModel.PlayAudioLimit("rxcq_ldhit",0.2)
		b.transform.localScale = Vector3.New(2,2,2)
		GameObject.Destroy(b,0.75)
	end
end