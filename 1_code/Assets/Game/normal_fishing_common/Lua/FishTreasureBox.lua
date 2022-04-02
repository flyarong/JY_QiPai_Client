-- 创建时间:2019-06-10
-- 宝箱鱼

local basefunc = require "Game/Common/basefunc"
FishTreasureBox = basefunc.class()
local C = FishTreasureBox
C.name = "FishTreasureBox"

FishTreasureBox.BoxState = 
{
	BS_Nor="正常",
	BS_Open1="微微打开",
	BS_Open2="打开",
	BS_Open3="全开",
}

function C.Create(parent, data)
	return C.New(parent, data)
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

function C:UpdateTransform(pos, r)
	self.fish_base:UpdateTransform(pos, r)
	self.transform_ui.position = FishingModel.Get2DToUIPoint(self.transform.position)
end

function C:MyExit()
	self.fish_base:MyExit()
	self.fish_base = nil

	if self.anim_time then
		self.anim_time:Stop()
		self.anim_time = nil
	end
	self:RemoveListener()

	if self.prefab_ui then
		CachePrefabManager.Back(self.prefab_ui)
		self.prefab_ui = nil
	end
end

function C:ctor(parent, data)
	self.data = data
	self.use_fish_cfg = FishingModel.Config.use_fish_map[data.fish_type]
	self.fish_cfg = FishingModel.Config.fish_map[self.use_fish_cfg.fish_id]

	self.panelSelf = FishingLogic.GetPanel()

	-- UI表现
	self.prefab_ui = CachePrefabManager.Take("FishTreasureBox_UI")
    self.prefab_ui.prefab:SetParent(self.panelSelf.FXNode)
	local tran_ui = self.prefab_ui.prefab.prefabObj.transform
	self.transform_ui = tran_ui
	self.gameObject_ui = tran_ui.gameObject
	tran_ui.localRotation = Quaternion.Euler(0, 0, 0)
	self.gameObject_ui.name = data.fish_id

	self.RectImage = tran_ui:Find("Image/RectImage"):GetComponent("RectTransform")
	self.AwardText = tran_ui:Find("AwardText"):GetComponent("Text")
	self.BloodImage = tran_ui:Find("Image/RectImage/BloodImage"):GetComponent("Image")
	self.HintText = tran_ui:Find("HintGroup/Image/HintText"):GetComponent("Text")
	self.HintGroup = tran_ui:Find("HintGroup"):GetComponent("CanvasGroup")
	self.HintGroup.alpha = 0

	self.max_rate = self.data.ori_life
	if not self.max_rate or self.max_rate == 0 then
		print("<>color=red>配置有为题data.fish_type = " .. data.fish_type .."</color>")
	end

	local parm = {}
	if data.fish_id then
		parm.obj_name = data.fish_id
	else
		parm.obj_name = data.fish_type
	end
	parm.prefab = "FishTreasureBox"
	parm.fish_list = {"node/box1", "node/box2", "node/box3", "node/box5", "node/glow", "node/jb1", "node/fish_pp"}
	parm.fish_tran = "box_size"
	parm.fish_anim = "node"
	parm.sortingOrder = 600
	self.fish_base = FishBase.Create(parent, data, parm)
	self.parm = parm
	self.transform = self.fish_base.transform
	self.gameObject = self.fish_base.gameObject

	self.hint_state = "nor"
	self.blood_state = 1
	self.blood_color_list = { Color.New(117/ 255,244/ 255,48/ 255), Color.New(255/ 255,183/ 255,20/ 255), Color.New(241/ 255,50/ 255,2/ 255) }
	self:SetColorLerp(0)

	self:RefreshAnim(FishTreasureBox.BoxState.BS_Nor)

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.max_ui_len = 416
	self:UpdateChangeData({data={0, self.max_rate}})
end

function C:SetColorLerp(lerp)
	local colorStart = self.blood_color_list[self.blood_state]
	local colorEnd = self.blood_color_list[self.blood_state + 1]
	self.BloodImage.color = Color.Lerp(colorStart, colorEnd, lerp)
end
function C:RefreshAnim(state)
	if self.box_state and self.box_state == state then
		return
	end

	self.box_state = state
	if self.box_state == FishTreasureBox.BoxState.BS_Nor then
		self.fish_base.anim_pay:Play("fx_baoxiang_guan", -1, 0)	
	elseif self.box_state == FishTreasureBox.BoxState.BS_Open1 then
		self.fish_base.anim_pay:Play("fx_baoxiang", -1, 0)	
	elseif self.box_state == FishTreasureBox.BoxState.BS_Open2 then
		self.fish_base.anim_pay:Play("fx_baoxiang_kai", -1, 0)	
	else
		self.fish_base.anim_pay:Play("fx_baoxiang_quankai", -1, 0)
	end
end

-- 服务器告知死亡
function C:DeadData(data)
	dump(data, "<color=red>服务器告知宝箱鱼死亡 >>>>>>>>>>>>>>>>>>>>> </color>")
	if not data or not data.data or #data.data ~= 5 then
		return
	end
	local award_lvl = data.data[5] or 1
	self:SetBox2D(false)
	if self.data.fish_id then
		VehicleManager.RemoveVehicle(self.data.fish_id)
	end
	if self.anim_time then
		self.anim_time:Stop()
		self.anim_time = nil
	end
	if self.prefab_ui then
		CachePrefabManager.Back(self.prefab_ui)
		self.prefab_ui = nil
	end

	self:RefreshAnim(FishTreasureBox.BoxState.BS_Open3)

	self.RectImage.sizeDelta = {x=0, y=26}
    local beginPos = FishingModel.Get2DToUIPoint(self.transform.position)
    FishingAnimManager.PlayTSFishDeadHint(self.panelSelf.FXNode, beginPos, self.gameObject, function ()
        self:Dead()
        FishingAnimManager.PlayBoxFishZJLvl(self.panelSelf.FlyGoldNode.transform, beginPos, award_lvl, 1)
        for i = 1, #data.data do
		    local userdata = FishingModel.GetSeatnoToUser(i)
		    if userdata and userdata.base and data.data[i] > 0 then
		    	local uipos = FishingModel.GetSeatnoToPos(i)
    	        local endPos = self.panelSelf.PlayerClass[uipos]:GetFlyGoldPos()
		        local playerPos = self.panelSelf.PlayerClass[uipos]:GetPlayerFXPos()
		        local mbPos = self.panelSelf.PlayerClass[uipos]:GetMBPos()

		    	userdata.wait_add_score = userdata.wait_add_score + data.data[i]
		        userdata.last_wait_add_score_time = os.time()
                local buf1 = {}
                buf1.seat_num = i
                buf1.score = data.data[i]
                buf1.grades = 0
		        if award_lvl == 4 then
		        	buf1.rate = 500
			        FishingAnimManager.PlayDeadFX(buf1, self.panelSelf.FlyGoldNode.transform, beginPos, endPos, playerPos, mbPos, self:GetFishNameToSprite(), 0.5)
		        else
		        	buf1.rate = 10
			        FishingAnimManager.PlayDeadFX(buf1, self.panelSelf.FlyGoldNode.transform, beginPos, endPos, playerPos, mbPos, self:GetFishNameToSprite(), 0.5)
		        end
		    end
		end
	end)
end
-- 刷新数据改变
function C:UpdateChangeData(data)
	if not data or not data.data or #data.data ~= 1 then
		dump(data, "<color=red>刷新数据改变</color>")
		return
	end
	if data.data[1] < 0 then
		data.data[1] = 0
	end
	local rr = data.data[1]/self.max_rate
	if rr > 1 then
		rr = 1
	end
	local ww = self.max_ui_len * rr
	local c1 = rr
	self.BloodImage.color = Color.New(1, c1, c1)
	if rr > 0.5 then
		self.blood_state = 1
		self:SetColorLerp((1 - rr) / (0.5))
	else
		self.blood_state = 2
		self:SetColorLerp((0.5 - rr) / (0.5))
	end

	local state = 3
	for i = 1, #FishingModel.Config.fish_parm_map.box_fish_anim do
		if rr >= FishingModel.Config.fish_parm_map.box_fish_anim[i] then
			state = i
			break
		end
	end
	if state == 1 then
		self:RefreshAnim(FishTreasureBox.BoxState.BS_Nor)
	elseif state == 2 then
		self:RefreshAnim(FishTreasureBox.BoxState.BS_Open1)
	else
		self:RefreshAnim(FishTreasureBox.BoxState.BS_Open2)
	end
	
	self.RectImage.sizeDelta = {x=ww, y=26}
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
	self.fish_base:SetIceState(isIce)
end
-- 冰冻解封
function C:SetIceDeblocking()
	self.fish_base:SetIceDeblocking()
end

function C:SetBox2D(b)
	self.fish_base:SetBox2D(b)
end

-- 标记鱼假死
function C:SetFeignDead(b)
	self.fish_base:SetFeignDead(b)
end

function C:Flee()
	self.fish_base:Flee()
end

function C:Hit()
	self.fish_base:Hit()

	if self.hint_state == "nor" then
		self.hint_state = "hit"
		self.cur_hint_color_a = 1
		self.anim_time = Timer.New(function ()
			self.HintGroup.alpha = self.cur_hint_color_a
			self.cur_hint_color_a = self.cur_hint_color_a - 0.05 -- 2秒消失
			if self.cur_hint_color_a <= 0 then
				self.hint_state = "nor"
				if self.anim_time then
					self.anim_time:Stop()
					self.anim_time = nil
				end
			end
		end, 0.1, -1)
		self.anim_time:Start()
	else
		self.cur_hint_color_a = 1
	end
end

function C:Dead(_dead_index)
	self.fish_base:Dead(_dead_index, function ()
		self:MyExit()
	end)
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
	return self.fish_cfg.rate
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


