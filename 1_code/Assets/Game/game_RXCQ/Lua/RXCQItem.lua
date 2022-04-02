-- 创建时间:2021-02-05
-- Panel:RXCQItem
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

RXCQItem = basefunc.class()
local C = RXCQItem
C.name = "RXCQItem"
local prefab_map = {
	[1] = "RXCQItem_JueZhanShaCheng",
	[2] = "RXCQItem_CiShaJianShu",
	[3] = "RXCQItem_BanYueWanDao",
	[4] = "RXCQItem_GongShaJianShu",
	[5] = "RXCQItem_LieHuoJianFa",
	[6] = "RXCQItem_ShenBinTianJiang",
	[7] = "RXCQItem_TianRenHeYi",
	[8] = "RXCQItem_BanYueWanDao_Ex",
	[9] = "RXCQItem_CiShaJianShu_Ex",
	[10] = "RXCQItem_GongShaJianShu_Ex",
	[11] = "RXCQItem_LieHuoJianFa_Ex",
}

function C.Create(parent,index)
	return C.New(parent,index)
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
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent,index)
	ExtPanel.ExtMsg(self)
	local parent = parent
	local obj = GameObject.Instantiate(RXCQPrefabManager.Prefabs[prefab_map[index]],parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.transform.localPosition = Vector3.New(0,0,0)
	self.transform.localScale = Vector3.New(1,1,1)
	LuaHelper.GeneratingVar(self.transform, self)
	self.index = index
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	coroutine.start(
        function()
           	self.Animator = self.transform:GetComponent("Animator")
		   	if 	self.Animator then
				self.Animator.enabled = false
		  	end
        end
    )
end

function C:InitUI()
	self.zhongjiang = newObject("game_RXCQ_zhongjiang",self.Lottery_Node)
	self.paodong = newObject("game_RXCQ_paodong",self.Lottery_Node)
	self.zhongjiang_shan = self.zhongjiang.transform:Find("shandong")
	self.zhongjiang_idol = self.zhongjiang.transform:Find("zhongjiangdi")
	self.zhongjiang.gameObject:SetActive(false)
	self.paodong.gameObject:SetActive(false)
	self:MyRefresh()
end

function C:ShowPaoDong(speed)
	if speed <= 0.21/0.7 then
		speed = 0.6
	end
	self.paodong.transform:GetComponent("Animator").speed = speed or 1
	self.paodong.gameObject:SetActive(false)
	self.paodong.gameObject:SetActive(true)
	if speed == 0.6 then
		ExtendSoundManager.PlaySound(audio_config.rxcq.rxcq_start.audio_name)
	end	
end

function C:ChangLiang()
	self.zhongjiang.gameObject:SetActive(true)
	self.zhongjiang_shan.gameObject:SetActive(true)
	self.zhongjiang_idol.gameObject:SetActive(false)
end

function C:ShowXuanZhong()
	ExtendSoundManager.PlaySound(audio_config.rxcq.rxcq_start.audio_name)
	self.zhongjiang.gameObject:SetActive(true)
	self.zhongjiang_shan.gameObject:SetActive(true)
	self.zhongjiang_idol.gameObject:SetActive(false)
	local t1 = Timer.New(
		function()
			self.zhongjiang_shan.gameObject:SetActive(false)
			self.zhongjiang_idol.gameObject:SetActive(true)
		end
	,0.6,1,nil,true)
	t1:Start()
	RXCQModel.AddTimers(t1)
	RXCQModel.DelayCall(
		function()
			Event.Brocast("rxcq_xuanzhong_next")
		end
	,0.9)


	local call = function()
		local mini_game_index = {
			[1] = 1,[6] = 1,[7] = 1,
		}
		if not mini_game_index[self.index] then
			self:PlayNormalAnim()
		else
			--决战沙城
			if self.index == 1 then
				self:PlayJZSCAnim()
			--神兵天降
			elseif self.index == 6 then
				self:PlaySBTJAnim()
			--天人合一
			elseif self.index == 7 then
				self:PlayTRHYAnim()
			end
		end
	end

	RXCQXuanZhongOver.SaveCall(
		call
	)
end

function C:ShowChangLiang()
	self.zhongjiang.gameObject:SetActive(true)
	self.zhongjiang_shan.gameObject:SetActive(false)
	self.zhongjiang_idol.gameObject:SetActive(true)
end

function C:ReSetShow()
	self.paodong.gameObject:SetActive(false)
	self.zhongjiang.gameObject:SetActive(false)
end

function C:PlayNormalAnim()
	self.fly_item = GameObject.Instantiate(self.gameObject,self.transform.parent)
	self.zhongjiang.gameObject:SetActive(false)
	self.zhongjiang_shan.gameObject:SetActive(false)
	self.zhongjiang_idol.gameObject:SetActive(false)
	self.paodong.gameObject:SetActive(false)
	self.fly_item.transform.parent = self.transform.parent.parent
	local seq = DoTweenSequence.Create({dotweenLayerKey = "rxcq_item"})
	seq:AppendInterval(0.01)
	seq:Append(self.fly_item.transform:DOLocalMove(RXCQFightPrefab.player_zero_pos,0.2))

	seq:Join(self.fly_item.transform:DOScale(Vector3.New(0.3,0.3,0.3), 0.2))
	seq:AppendCallback(
		function()

			self.fly_item.gameObject:SetActive(false)
		end
	)
	seq:AppendInterval(0.1)
	seq:AppendCallback(
		function()
			local key_word = {
				[1] = "BanYueWanDao",
				[2] = "CiShaJianShu",
				[3] = "GongShaJianShu",
				[4] = "LieHuoJianFa",
			}
			local img = {
				[1] = "jn_img_bywd",
				[2] = "jn_img_csjs",
				[3] = "jn_img_gjjs",
				[4] = "jn_img_lhjf",
			}
			local choose_img
			for i = 1,#key_word do
				if string.match(prefab_map[self.index],key_word[i]) == key_word[i] then
					choose_img =  img[i]
					break
				end
			end
			self.show = GameObject.Instantiate(RXCQPrefabManager.Prefabs["RXCQShowSkillItem"],self.fly_item.transform.parent)
			ExtendSoundManager.PlaySound("rxcq_skillname")
			self.show.transform.localPosition = Vector3.New(RXCQFightPrefab.player_zero_pos.x + 10,RXCQFightPrefab.player_zero_pos.y + 180) 
			local temp_ui = {}
			LuaHelper.GeneratingVar(self.show.transform,temp_ui)
			temp_ui.main_img.sprite = GetTexture(choose_img)
		end
	)
	seq:AppendInterval(0.6)
	seq:AppendCallback(
		function()
			Event.Brocast("rxcq_xuanzhong_over")
			destroy(self.fly_item)
			destroy(self.show)
		end
	)
end

function C:PlaySBTJAnim()
	local obj = GameObject.Instantiate(self.gameObject,self.transform)
	obj.transform.parent = GameObject.Find("GUIRoot/RXCQGamePanel/@Fight_UI").transform
	local obj_Animator = obj.transform:GetComponent("Animator")
	self.gameObject:SetActive(false)
	local seq = DoTweenSequence.Create({dotweenLayerKey = "rxcq_item"})
	seq:Append(obj.transform:DOLocalMove(Vector3.New(788,-1.79,0),0.1))
	seq:Join(obj.transform:DOScale(Vector3.New(1.815,1.815,0),0.1))
	seq:AppendCallback(
		function()
			if obj_Animator then
				obj_Animator.enabled = true
				obj_Animator:Play("RXCQItem_tjsb")
			end
		end
	)
	seq:AppendInterval(3)
	seq:AppendCallback(
		function()
			Event.Brocast("rxcq_xuanzhong_over")
		end
	)
	RXCQModel.DelayCall(
		function()
			self.gameObject:SetActive(true)
			destroy(obj)
		end
	,3.4)
end

function C:PlayTRHYAnim()
	local obj = GameObject.Instantiate(self.gameObject,self.transform)
	obj.transform.parent = GameObject.Find("Canvas/GUIRoot/RXCQGamePanel/@temp_top").transform
	local obj_Animator = obj.transform:GetComponent("Animator")
	self.gameObject:SetActive(false)
	local seq = DoTweenSequence.Create({dotweenLayerKey = "rxcq_item"})
	seq:Append(obj.transform:DOLocalMove(Vector3.New(-780,-2.441,0),0.1))
	seq:Join(obj.transform:DOScale(Vector3.New(1.815,1.815,0),0.1))
	seq:AppendCallback(
		function()
			if obj_Animator then
				obj_Animator.enabled = true
				obj_Animator:Play("RXCQItem_TianRenHeYi")
			end
		end
	)
	seq:AppendInterval(1.45)
	seq:AppendCallback(
		function()
			Event.Brocast("rxcq_xuanzhong_over")
		end
	)
	RXCQModel.DelayCall(
		function()
			self.gameObject:SetActive(true)
			destroy(obj)
		end
	,1.75)
end

function C:PlayJZSCAnim()
	local obj = GameObject.Instantiate(self.gameObject,self.transform)
	obj.transform.parent = GameObject.Find("Canvas/GUIRoot/RXCQGamePanel/@temp_top").transform
	local obj_Animator = obj.transform:GetComponent("Animator")
	self.gameObject:SetActive(false)
	local seq = DoTweenSequence.Create({dotweenLayerKey = "rxcq_item"})
	seq:Append(obj.transform:DOLocalMove(Vector3.New(0,311,0),0.1))
	seq:Join(obj.transform:DOScale(Vector3.New(1.815,1.815,0),0.1))
	seq:AppendCallback(
		function()
			if obj_Animator then
				obj_Animator.enabled = true
				obj_Animator:Play("RXCQItem_JueZhanShaCheng")
			end
		end
	)
	seq:AppendInterval(2)
	seq:AppendCallback(
		function()
			Event.Brocast("rxcq_xuanzhong_over")
		end
	)
	RXCQModel.DelayCall(
		function()
			self.gameObject:SetActive(true)
			destroy(obj)
		end
	,2.3)
end


function C:MyRefresh()

end