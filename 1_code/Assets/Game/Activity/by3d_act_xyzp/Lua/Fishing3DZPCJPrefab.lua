-- 创建时间:2020-02-28
-- Panel:Fishing3DZPCJPrefab
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

 Fishing3DZPCJPrefab = basefunc.class()
 local C = Fishing3DZPCJPrefab
 C.name = "Fishing3DZPCJPrefab"
 
 -- data  anim_type:1是自己 2是别人  beginPos开始点 玩家点位playerPos jn_data技能数据
 -- jn_data bs_list倍数列表(5*8*3) fish_id type=24  seat_num玩家座位号
 
 function C.Create(data,parent)
	 return C.New(data,parent)
 end
 
 function C:AddMsgListener()
	 for proto_name,func in pairs(self.lister) do
		 Event.AddListener(proto_name, func)
	 end
 end
 
 function C:MakeLister()
	 self.lister = {}
	 self.lister["EnterBackGround"] = basefunc.handler(self, self.on_background_msg)
 end
 
 function C:RemoveListener()
	 for proto_name,func in pairs(self.lister) do
		 Event.RemoveListener(proto_name, func)
	 end
	 self.lister = {}
 end
 
 function C:MyExit()
	 if self.seq1 then 
		 self.seq1:Kill()
		 self.seq1 = nil
	 end
	 if self.update_time_list then
		 for k,v in pairs(self.update_time_list) do
			 v:Stop()
		 end
	 end
	 self:RemoveListener()
	 destroy(self.gameObject)
 end
 function C:on_background_msg()
	 self:MyExit()
 end
 function C:ctor(data,parent)
	self.data = data

	 local _parent 
	 if self.data.anim_type == 1 then
		_parent = GameObject.Find("Canvas/LayerLv3").transform
	 else
		_parent = parent
	 end 

	 local obj = newObject("by3d_zpcj_prefab", _parent)
	 local tran = obj.transform
	 self.transform = tran
	 self.gameObject = obj
	 LuaHelper.GeneratingVar(self.transform, self)
	 self.zp_group = self.zp_rect.transform:GetComponent("CanvasGroup")
	 
	 self:MakeLister()
	 self:AddMsgListener()
	 self:InitUI()
 end
 
 function C:InitUI()
	 self.sztxt_list = {}
	 self.sztxt_list[#self.sztxt_list + 1] = self["sz1_txt"]
	 self.sztxt_list[#self.sztxt_list + 1] = self["sz2_txt"]
	 self.sztxt_list[#self.sztxt_list + 1] = self["sz3_txt"]
 
	 self.zp_cfg = {}
	 for k,v in ipairs(self.data.jn_data.bs_list) do
		 local tab = {}
		 local tab1 = {}
		 local num
		 local r
		 if k == 1 then
			 num = 8
			 r = 9
		 else
			 num = 5
			 r = 20
		 end
		 local tt = MathExtend.RandomGroup(r)
		 local i = 1
		 tab[#tab + 1] = v
		 while(#tab < num) do
			 if tt[i] ~= v then
				 tab[#tab + 1] = tt[i]
			 end
			 i = i + 1
		 end
		 tt = MathExtend.RandomGroup(num)
		 for kk,vv in ipairs(tt) do
			 tab1[#tab1 + 1] = tab[vv]
		 end
 
		 self.zp_cfg[#self.zp_cfg + 1] = tab
	 end
 
	 self.zpobj_list = {}
	 for i = 1, #self.zp_cfg do
		 local pre = Fishing3DZPCJZPPrefab.Create(self, self.zp_rect, self.zp_cfg[i], self.data.jn_data.bs_list[i], i)
		 self.zpobj_list[#self.zpobj_list + 1] = pre
	 end
	 self:MyRefresh()
 end
 
 function C:MyRefresh()
	 self.update_time_list = {}
	 self.sztxt_index = {}
	 self.zp_move_num = 0
	 self.zp_gd_num = 0
 
	 if self.data.anim_type == 1 then
		 self:RunAnim1()
	 else
		 self:RunAnim2()
	 end
 end
 
 function C:RunAnim1()
	 for i = 1, #self.zpobj_list do
		 local endPos = Vector3.New((i-2) * 556, -110, 0)
		 self.zpobj_list[i]:SetPos(endPos)
	 end
	 for i = 1, #self.sztxt_list do
		 self.sztxt_list[i].gameObject:SetActive(false)
	 end
	 self.zp_sz_rect.gameObject:SetActive(false)
	 self.zp_rect.transform.localScale = Vector3.New(0.2, 0.2, 0.2)
	 self.seq = DoTweenSequence.Create()
	 self.seq:Append(self.zp_rect.transform:DOScale(Vector3.New(1, 1, 1), 0.2))
	 self.seq:AppendInterval(1)
	 self.seq:OnKill(function ()
		 self:RunAnim3()
	 end)
 end
 function C:RunAnim3()
	 for i = 1, #self.zpobj_list do
		 self.zpobj_list[i]:RunAnim( 0.2 + (i-1)*2 )-- 转盘之间的开始转动间隔
	 end
 
	 self.zp_sz_rect.gameObject:SetActive(true)
	 for i = 1, #self.sztxt_list do
		 self.sztxt_list[i].gameObject:SetActive(false)
	 end
	 self.sz_cj_txt.gameObject:SetActive(false)
	 self.zp_sz_rect.localScale = Vector3.New(0, 1, 1)
	 self.seq = DoTweenSequence.Create()
	 self.seq:Append(self.zp_sz_rect:DOScaleX(1, 0.2))
	 self.seq:OnKill(function ()
	 end)
 end
 function C:on_by3d_zpcj_zp_move_wc()
	 self.zp_move_num = self.zp_move_num + 1
	 if self.data.anim_type ~= 1 then
		 self.zpobj_list[self.zp_move_num].gameObject:SetActive(false)
	 end
 
	 if self.zp_move_num == #self.zpobj_list then
		 for i = 1, #self.zpobj_list do
			 self.zpobj_list[i]:RunAnim( 0.2 + (i-1)*2 )-- 转盘之间的开始转动间隔
		 end
 
		 self.zp_sz_rect.gameObject:SetActive(true)
		 for i = 1, #self.sztxt_list do
			 self.sztxt_list[i].gameObject:SetActive(false)
		 end
		 self.sz_cj_txt.gameObject:SetActive(false)
		 self.zp_sz_rect.localScale = Vector3.New(0, 1, 1)
		 self.seq = DoTweenSequence.Create()
		 self.seq:Append(self.zp_sz_rect:DOScaleX(1, 0.2))
		 self.seq:OnKill(function ()
		 end)
	 end
 end
 function C:on_by3d_zpcj_zp_gd_ks(i)
	 self.sztxt_index[i] = 1
	 self.sztxt_list[i].gameObject:SetActive(true)
	 local ts = Timer.New(function ()
		 self.sztxt_list[i].text = self.zp_cfg[i][ self.sztxt_index[i] ]
		 self.sztxt_index[i] = self.sztxt_index[i] + 1
		 if self.sztxt_index[i] > #self.zp_cfg[i] then
			 self.sztxt_index[i] = 1
		 end
	 end, 0.033, -1)
	 ts:Start()
	 self.update_time_list[i] = ts
 end
 function C:on_by3d_zpcj_zp_gd_js(i)
	 self.zp_gd_num = self.zp_gd_num + 1
	 if self.update_time_list[i] then
		 self.update_time_list[i]:Stop()
	 end
	 self.update_time_list[i] = nil
	 self.sztxt_list[i].text = self.data.jn_data.bs_list[i]
	 -- 此处有一个闪光特效
	 FishingAnimManager.PlayGoldFX(self.transform, self.sztxt_list[i].transform.position)
 
	 if self.zp_gd_num == #self.zpobj_list then
		 self.seq = DoTweenSequence.Create()
		 self.seq:AppendInterval(0.5)
		 self.seq:AppendCallback(function ()			
			 self.sz_cj_txt.gameObject:SetActive(true)
			 local cj = 1
			 for k,v in ipairs(self.data.jn_data.bs_list) do
				 cj = cj * v
			 end
			 self.sz_cj_txt.text = cj
			 self.sz1_cj_txt.text = cj.."倍"
			 FishingAnimManager.PlayGoldFX(self.transform, self.sz_cj_txt.transform.position)
		 end)
		 self.seq:AppendInterval(2.5)
		 --self.seq:Append(self.zp_group:DOFade(0, 0.2):SetEase(DG.Tweening.Ease.OutCubic))
 
		 --self.seq:AppendInterval(0.5)
		 if self.data.anim_type == 1 then
			 self.seq:AppendCallback(function ()
				 --self.zp_sz_rect.gameObject:SetActive(false)
				 self.zp_rect1.gameObject:SetActive(true)
				 self.seq1 = DoTweenSequence.Create()
				 self.seq1:Append(self.zp_rect1.transform:DOScale(1,0.5))
				 self.seq1:OnKill(function ()
				 end)
			 end)
			 self.seq:AppendInterval(2)
		 end
		 --self.seq:Append(self.zp_group:DOFade(0, 0.2):SetEase(DG.Tweening.Ease.OutCubic))
 
		 self.seq:OnKill(function ()
			 if self.data.anim_type == 1 then
				--FishingAnimManager.PlayBY3D_HDY_FX_MY(self.data.jn_data.add_score, 35)
				self:ShowGetAnim(self.data.jn_data.add_score)
			 else
				--Event.Brocast("ui_gold_fly_finish_msg", {seat_num = 1, score = 1000})
				Event.Brocast("ui_gold_fly_finish_msg", {seat_num = self.data.jn_data.seat_num, score = self.data.jn_data.add_score})
			 end
			 self:MyExit()
		 end)
	 end
 end
 
 function C:RunAnim2()
	 self.BG.gameObject:SetActive(false)
	 self.zp_sz_node.position = Vector3.New(self.data.playerPos.x, self.data.playerPos.y, 0)
	 self.zp_sz_node.localScale = Vector3.New(0.5, 0.5, 1)
	 for i = 1, #self.zpobj_list do
		 -- local pos = Vector3.New(beginPos.x+20*(i-1), beginPos.y-10*(i-1), 0)
		 self.zpobj_list[i]:SetPos(self.data.beginPos)
		 self.zpobj_list[i]:SetScale(0.3)
		 self.zpobj_list[i]:RunAnimMove(self.data.playerPos, (i-1)*0.15)
	 end
 end

 function C:ShowGetAnim(_score)
	local parent = FishingLogic.GetPanel().LayerLv3
	local data = { seat_num = 1,score = _score}
	--FishingAnimManager.PlayBY3D_HDY_FX_MY(self.score, 34)
	ExtendSoundManager.PlaySound(audio_config.by.bgm_by_jiangli6.audio_name)
    	FishingAnimManager.PlayMultiplyingPower200(parent, Vector2.zero, Vector2.zero, _score, function ()
    		Event.Brocast("ui_gold_fly_finish_msg", data)
		end,1,nil)
end
 
 