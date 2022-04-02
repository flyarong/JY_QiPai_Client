-- 创建时间:2021-02-26
-- Panel:RXCQGuaiWuPrefab
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

RXCQGuaiWuPrefab = basefunc.class()
local C = RXCQGuaiWuPrefab
C.name = "RXCQGuaiWuPrefab"

function C.Create(parent,name,guaiwu_id)
	return C.New(parent,name,guaiwu_id)
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

function C:ctor(parent,name,guaiwu_id)
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
	self.guaiwu_id = guaiwu_id
end

function C:Hit(backcall)
	self:CreateYY()
	self.gameObject:SetActive(false)
	self.gameObject:SetActive(true)
	self:StopAnim()
	local index = 0
	local func = function()
		index = index + 1
		if index <= #RXCQPrefabManager.Max_Texture2Ds[self.texture_name]["hit"] then
			self.main_img.sprite = RXCQPrefabManager.Texture2Ds[self.texture_name]["hit"][index]
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
		local texture = RXCQPrefabManager.Texture2Ds[self.texture_name]["hit"][1].texture
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
	,0.1,#RXCQPrefabManager.Max_Texture2Ds[self.texture_name]["hit"],nil,true)
	self.MainTimer:Start()
	GameObject.Destroy(shouji,1)
end

function C:Stand()
	self.status = "活"
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
	self.status = "死"
	self:DestroyYY()
	self:StopAnim()
	local index = 0
	local func = function()
		index = index + 1
		--dump(index,"index")
		--dump(self.guaiwu_id,"<color=red>guaiwu_id +++</color>")
		if index <= #RXCQPrefabManager.Max_Texture2Ds[self.texture_name]["death"] then
			self.main_img.sprite = RXCQPrefabManager.Texture2Ds[self.texture_name]["death"][index]
			self.main_img:SetNativeSize()
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
	local config = rxcq_main_config.guaiwu
	local re 
	for i = 1,#config do
		if config[i].texture == self.texture_name then
			re = config[i]
			break
		end
	end
	if re then
		local pos = StringHelper.Split(re.foot_pos,"#")
		return Vector3.New(pos[1],pos[2],0)
	end
end

function C:ShowChuanSong(backcall)
	if self.chuansong then
		destroy(self.chuansong)
		self.chuansong = nil
	end
	self.gameObject:SetActive(false)
	self.chuansong = GameObject.Instantiate(RXCQPrefabManager.Prefabs["RXCQ_ChuanSong_Guaiwu"],self.transform)
	local v = self:GetYYPos()
	self.chuansong.transform.localPosition = Vector3.New(v.x,v.y + 33)
	self.chuansong.transform.parent = self.transform.parent
	RXCQModel.DelayCall(function()
		if self.chuansong then
			self.chuansong:SetActive(false)
		end
	end,0.6)
	RXCQModel.DelayCall(function()
		if self.gameObject then
			self.gameObject:SetActive(true)
		end
		if backcall then
			backcall()
		end
	end,0.4)
end

function C:PlayHitSound()
	local skill_name = RXCQModel.GetSkillNameByCid(RXCQModel.game_data.cid)
	local config = {
		BanYueWanDao = "rxcq_byhit",
		CiShaJianShu = "rxcq_cshit",
		GongShaJianShu = "rxcq_gshit",
		LieHuoJianFa = "rxcq_lhhit",
	}
	if skill_name then
		ExtendSoundManager.PlaySound(audio_config.rxcq[config[skill_name]].audio_name)
	end
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