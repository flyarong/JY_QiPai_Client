-- 创建时间:2020-02-28
-- Panel:Fishing3DZPCJZPPrefab
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

 Fishing3DZPCJZPPrefab = basefunc.class()
 local C = Fishing3DZPCJZPPrefab
 C.name = "Fishing3DZPCJZPPrefab"
 
 function C.Create(panelSelf, parent, data, bs, i)
	 return C.New(panelSelf, parent, data, bs, i)
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
	 if self.seq then
		 self.seq:Kill()
	 end
	 self.seq = nil
	 self:RemoveListener()
	 destroy(self.gameObject)
 end
 
 function C:ctor(panelSelf, parent, data, bs, i)
	 self.panelSelf = panelSelf
	 self.data = data
	 self.index = i
	 for k,v in ipairs(self.data) do
		 if v == bs then
			 self.selectIndex = k
			 --dump(self.selectIndex)
			 break
		 end
	 end
	 local obj = newObject("by3d_zpcj_zp_prefab", parent)
	 local tran = obj.transform
	 self.transform = tran
	 self.gameObject = obj
	 LuaHelper.GeneratingVar(self.transform, self)
	 self.by3d_zpcj_sz_prefab = GetPrefab("by3d_zpcj_sz_prefab")
	 self.zp_tran = self.zp_img.transform
 
	 if self.index == 1 then
		 self.pj = 360 / #self.data
	 else	
		 self.pj = 360 / #self.data
	 end
	 self:MakeLister()
	 self:AddMsgListener()
	 self:InitUI()
 end
 
 function C:InitUI()
	 self:MyRefresh()
 end
 
 function C:MyRefresh()
	 if self.index == 1 then
		 self.zp_img.sprite = GetTexture("3dby_icon_cj2")
		 --self.zp_tran.localRotation = Quaternion:SetEuler(0,0,22.5)
	 else
		 self.zp_img.sprite = GetTexture("3dby_icon_cj3")
	 end
	 self.sz_list = {}
	 for k,v in ipairs(self.data) do
		 local obj = GameObject.Instantiate(self.by3d_zpcj_sz_prefab, self.zp_tran)
		 obj.transform:GetComponent("Text").text = "x" .. v
		 if self.index == 1 then
			 obj.transform.localRotation = Quaternion:SetEuler(0, 0, (1-k) * self.pj )--- 22.5)
		 else	
			 obj.transform.localRotation = Quaternion:SetEuler(0, 0, (1-k) * self.pj)
		 end
		 self.sz_list[#self.sz_list + 1] = obj
	 end
 end
 function C:SetPos(pos)
	 self.transform.position = pos
 end
 function C:SetScale(s)
	 self.transform.localScale = Vector3.New(s,s,s)
 end
 
 function C:RunAnim(delay)
	 local rota = -360 * 8 + self.pj * (self.selectIndex-1)
	 if self.index == 1 then
		 rota = rota --+ 22.5
	 end
	 self.seq = DoTweenSequence.Create()
	 if delay and delay > 0 then
		 self.seq:AppendInterval(delay)
	 end
	 self.seq:AppendCallback(function ()
		 self.panelSelf:on_by3d_zpcj_zp_gd_ks(self.index)
	 end)
	 self.seq:Append(self.zp_tran:DORotate( Vector3.New(0, 0 , rota), 2, DG.Tweening.RotateMode.FastBeyond360):SetEase(DG.Tweening.Ease.InOutExpo))
	 self.seq:OnKill(function ()
		 self.panelSelf:on_by3d_zpcj_zp_gd_js(self.index)
		 if IsEquals(self.gameObject) then
			 self.zp_tran.localRotation = Quaternion:SetEuler(0, 0, rota)
		 end
		 self.seq = nil
	 end)
 end
 
 function C:RunAnimMove(endPos, delay)
	 self.seq_move = DoTweenSequence.Create()
	 if delay and delay > 0 then
		 self.seq_move:AppendInterval(delay)
	 end
	 self.seq_move:Append(self.transform:DOMoveBezier(endPos, 20, 0.5))
	 self.seq_move:OnKill(function ()
		 self.panelSelf:on_by3d_zpcj_zp_move_wc()
	 end)
 end
 