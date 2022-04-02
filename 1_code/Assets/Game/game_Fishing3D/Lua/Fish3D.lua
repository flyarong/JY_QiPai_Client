-- 创建时间:2020-02-10

local basefunc = require "Game/Common/basefunc"
-- 表现模式 高级
local show_pattern = false
Fish3D = basefunc.class()
Fish = Fish3D
local C = Fish3D
C.name = "Fish3D"

function C.Create(parent, data, is_game_create)
	return C.New(parent, data, is_game_create)
end

function C:FrameUpdate()
	if self.fish_base then
		self.fish_base:FrameUpdate()
	end
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

function C:UpdateTransform(pos, r, scale)
	self.fish_base:UpdateTransform(pos, r, scale)
end

function C:IsDebug()
	if FishingModel.isDebug then
		return true
	end
end
function C:MyExit()
	if self.bianda_seq then
		self.bianda_seq:Kill()
	end
	if self:IsDebug() then
        print("<color=red>MyExit Fish</color>\n" .. self.debug_txt.text)
		destroy(self.debug_obj)
	end
	self.fish_base:MyExit()
	self:RemoveListener()
end

function C:ctor(parent, data, is_game_create)
	self.data = data
	self.use_fish_cfg = FishingModel.Config.use_fish_map[data.fish_type]
	self.fish_cfg = FishingModel.Config.fish_map[self.use_fish_cfg.fish_id]
	local parm = {}
	if data.fish_id then
		parm.obj_name = data.fish_id
	else
		parm.obj_name = data.fish_type
	end

	parm.fish_list = {"fish"}
	parm.fish_tran = "box_size"
	parm.fish_anim = "fish3d"
	self.fish_base = FishBase.Create(parent, data, parm, is_game_create)
	self.parm = parm

	if self.data.ori_life and self.data.ori_life > 0 then
		local h = self.fish_cfg.size_h * 100 * 0.6
		self.fish_base:CreateBlood()
	end

	self.transform = self.fish_base.transform
	self.gameObject = self.fish_base.gameObject

	if self:IsDebug() then
		local obj = GameObject.New()
		obj.name = "fish_debug"
		self.debug_txt = obj.gameObject:AddComponent(typeof(UnityEngine.UI.Text))
		obj.transform:SetParent(self.transform)

		self.debug_obj = obj

		self.debug_txt.text = ""
		self.debug_txt.text = self.debug_txt.text .. "fish_type=" .. data.fish_type .. "\n"
		if data.fish_id then
			self.debug_txt.text = self.debug_txt.text .. "id=" .. data.fish_id .. "\n"
		end
	end

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

-- 刷新数据改变
function C:UpdateChangeData(data)
	if self.fish_base then
		self.fish_base:UpdateBlood(data)
	end
end
-- 刷新鱼状态
function C:UpdateStatus(b)
	if self.data.status and self.data.status > 0 then
		if self:IsDebug() then
			self.debug_txt.text = self.debug_txt.text .. "status=" .. self.data.status .. "\n"
		end
		local m_scale = 1
		if self.data.status >= 3 then
			m_scale = 1
		elseif self.data.status == 2 then
			m_scale = 1.5
		elseif self.data.status == 1 then
			m_scale = 2
		end
		if self.fish_cfg.id == 8 then
			if b then
				self.fish_base.transform.localScale = Vector3.New(m_scale, m_scale, m_scale)
				return
			end

			ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_siwang8.audio_name)
			self.bianda_seq = DoTweenSequence.Create()
			self.bianda_seq:Append(self.fish_base.transform:DOScale(m_scale, 2):SetEase(DG.Tweening.Ease.InQuint))
			self.bianda_seq:OnKill(function ()
				self.bianda_seq = nil
			end)
		elseif self.fish_cfg.id == 23 then
			local m_scale = 1
			if self.data.status >= 3 then
				m_scale = 1
			elseif self.data.status == 2 then
				m_scale = 1.1
			elseif self.data.status == 1 then
				m_scale = 1.2
			end
			if b then
				self.fish_base.transform.localScale = Vector3.New(m_scale, m_scale, m_scale)
				return
			end

			self.bianda_seq = DoTweenSequence.Create()
			self.bianda_seq:AppendInterval(1.5)
			self.bianda_seq:Append(self.fish_base.transform:DOScale(m_scale, 0.2):SetEase(DG.Tweening.Ease.InQuint))
			self.bianda_seq:OnKill(function ()
				ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_siwang23.audio_name)
				self.bianda_seq = nil
			end)
		else
			if not b then
				dump(self.fish_cfg, "<color=red>可以死多次的鱼</color>")
			end
		end
	end
end

-- 设置层级
function C:SetLayer(order)
	self.fish_base:SetLayer(order)
end

function C:Back_attrobj()
	self.fish_base:Back_attrobj()
end

function C:Back_iceobj()
	self.fish_base:Back_iceobj()
end
function C:Back_deadattrobj()
	self.fish_base:Back_deadattrobj()
end

-- 修改鱼身上的特效层级
function C:ChangeLayer(obj, scale, isUp)
	self.fish_base:Back_deadattrobj(obj, scale, isUp)
end
function C:InitUI()
	self.fish_base:InitUI()

	self:UpdateStatus(true)
end

function C:MyRefresh()
	self.fish_base:MyRefresh()
end

function C:Print()
	self.fish_base:Print()
end

-- 是否在鱼池中
function C:CheckIsInPool()
	return self.fish_base:CheckIsInPool()
end
-- 是否完全在鱼池中
function C:CheckIsInPool_Whole()
	return self.fish_base:CheckIsInPool_Whole()
end

-- 是否完全在鱼池外
function C:CheckIsOutPool_Whole()
	return self.fish_base:CheckIsOutPool_Whole()
end

-- 设置冰冻状态
function C:SetIceState(isIce)
	if self:IsDebug() and not FishingModel.IsRecoverRet then
		self.debug_txt.text = self.debug_txt.text .. "冰冻" .. "\n"
	end

	self.fish_base:SetIceState(isIce)
end
-- 冰冻解封
function C:SetIceDeblocking()
	if self:IsDebug() and not FishingModel.IsRecoverRet then
		self.debug_txt.text = self.debug_txt.text .. "解冻" .. "\n"
	end
	self.fish_base:SetIceDeblocking()
end

function C:SetBox2D(b)
	if self:IsDebug() then
		if b then
			self.debug_txt.text = self.debug_txt.text .. "Box=true" .. "\n"
		else
			self.debug_txt.text = self.debug_txt.text .. "Box=false" .. "\n"
		end
	end

	self.fish_base:SetBox2D(b)
end

-- 标记鱼假死
function C:SetFeignDead(b)
	if not self.data.status or self.data.status <= 1 then
		if self:IsDebug() then
			if b then
				self.debug_txt.text = self.debug_txt.text .. "假死=true" .. "\n"
			else
				self.debug_txt.text = self.debug_txt.text .. "假死=false" .. "\n"
			end
		end
		self.fish_base:SetFeignDead(b)
	end
end

function C:Flee()
	if self:IsDebug() then
		self.debug_txt.text = self.debug_txt.text .. "逃离" .. "\n"
	end
	self.fish_base:Flee()
end

function C:Hit()
	self.fish_base:Hit()
end
function C:SetLayer()
	
end
function C:Dead(_dead_index, ZZ)
	if self:IsDebug() then
		self.debug_txt.text = self.debug_txt.text .. "死亡" .. "\n"
	end

	if self.fish_base then
		self.fish_base:Dead(_dead_index, function ()
			self:MyExit()
		end, ZZ)
	end
end

function C:Tag()
	self.fish_base:Tag()
end

--鱼的类型
function C:GetFishType()
	return self.fish_cfg.id
end
--鱼的特殊奖励？？？
function C:GetFishAward()
	return nil
end

-- 鱼的组别
function C:GetFishGroup()
	return self.data.group_id
end

-- 鱼的额外属性
function C:GetFishAttr()
	return self.use_fish_cfg.attr_id
end
-- 鱼是否是敢死队
function C:GetFishTeam()
	return self.data.isTeam
end

-- 鱼的倍率
function C:GetFishRate()
	-- 处理河豚前面两次的死亡效果
	if self.fish_cfg.id == 28 and self.data.status and self.data.status > 1 then
		return 20
	else
		return self.fish_cfg.rate
	end
end
-- 锁定点
function C:GetLockPos()
	return self.fish_base:GetLockPos()
end
-- 鱼的名字 图片
function C:GetFishNameToSprite()
	return self.fish_cfg.name_image
end

-- 爆炸表现 pos是爆炸鱼的坐标
function C:BoomHit(pos)
	self.fish_base:BoomHit(pos)
end
function C:GetPos()
	return self.fish_base:GetPos()
end