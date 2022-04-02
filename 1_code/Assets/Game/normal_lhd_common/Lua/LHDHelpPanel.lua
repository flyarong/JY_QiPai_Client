-- 创建时间:2020-01-03
-- Panel:LHDHelpPanel
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

LHDHelpPanel = basefunc.class()
local C = LHDHelpPanel
C.name = "LHDHelpPanel"

function C.Create()
	return C.New()
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
	if self.UpdateTime then
		self.UpdateTime:Stop()
		self.UpdateTime = nil
	end
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	self.TopScroll = self.TopScroll:GetComponent("MyButton")
    EventTriggerListener.Get(self.TopScroll.gameObject).onDown = basefunc.handler(self, self.OnScrollDown)
    EventTriggerListener.Get(self.TopScroll.gameObject).onUp = basefunc.handler(self, self.OnScrollUp)

	self.dotCell = GetPrefab("lhd_dot_prefab")

	self.speed = 2400
	self.CellSize = {x = 1320, y = 632}
	self.isScroll = false
	self.isScrollLock = false
	self.isOpenScroll = true

	self.UpdateTime = Timer.New(basefunc.handler(self, self.Update), 0.1, -1, nil, true)
	self.UpdateTime:Start()

	self:InitUI()
end

local pai_map = {
	[2] = {
		[1] = {id=9, list={25,21,17,13,9}},
		[2] = {id=8, list={25,26,27,28,9}},
		[3] = {id=7, list={25,26,27,21,22}},
		[4] = {id=6, list={26,18,14,10,6}},
	},
	[3] = {
		[1] = {id=5, list={25,22,19,15,10}},
		[2] = {id=4, list={25,26,27,22,14}},
		[3] = {id=3, list={25,26,17,18,10}},
		[4] = {id=2, list={25,26,22,16,10}},
	}
}
function C:InitUI()
	self.back_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:MyExit()
    end)
	self.total_num = {1,4,2,3}

	self:CloseItem()
	for k,v in ipairs(self.total_num) do
		local obj = GameObject.Instantiate(GetPrefab("lhd_help_prefab"..v), self.item_node)
		obj.transform.localPosition = Vector3.New((k - 1) * self.CellSize.x, 0, 0)
		self.CellList[#self.CellList + 1] = obj
		local tran = obj.transform
		if v == 2 or v == 3 then
			local card_node = {}
			card_node[#card_node + 1] = tran:Find("Node1")
			card_node[#card_node + 1] = tran:Find("Node2")
			card_node[#card_node + 1] = tran:Find("Node3")
			card_node[#card_node + 1] = tran:Find("Node4")
			for i = 1, 4 do
				self:CreateCardItem(card_node[i], pai_map[v][i])
			end
			local desc = tran:Find("DescText"):GetComponent("Text")
			if LHDManager.is_use_aq_style then
				desc.text = "大小相同时,金>银>铜>铁"
			else
				desc.text = "大小相同时,黑桃>红心>梅花>方块"
			end
		elseif v == 1 then
			local desc = tran:Find("Image3"):GetComponent("Image")
			if LHDManager.is_use_aq_style then
				desc.sprite = GetTexture("dld_imgf_bz6_old")
			else
				desc.sprite = GetTexture("dld_imgf_bz6")
			end
		elseif v == 4 then
			local desc = tran:Find("Image3"):GetComponent("Image")
			if LHDManager.is_use_aq_style then
				desc.sprite = GetTexture("dld_imgf_tmd4")
			else
				desc.sprite = GetTexture("dld_imgf_tmd3")
			end
		end

		local dotObj = GameObject.Instantiate(self.dotCell, self.dot_node)
		self.DotCellList[#self.DotCellList + 1] = dotObj
		dotObj.name = "" .. k
		EventTriggerListener.Get(dotObj.gameObject).onClick = basefunc.handler(self, self.OnDotClick)
	end
	self:UpdateSelect(1)
	self:MyRefresh()
end
function C:CreateCardItem(tran, data)
	tran:Find("Text"):GetComponent("Text").text = LHDManager.PAI_STYLE[data.id].name
	local obj = GameObject.Instantiate(GetPrefab("lhd_help_card_prefab"), tran)
	obj.transform.localPosition = Vector3.zero
	local pp = {}
	for i = 1, 5 do
		pp[#pp + 1] = obj.transform:Find("card" .. i)
	end
	for k,v in ipairs(data.list) do
		LHDCardPrefab.Create(pp[k], v)
	end
end
function C:CloseItem()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			destroy(v)
		end
	end
	self.CellList = {}

	if self.DotCellList then
		for k,v in ipairs(self.DotCellList) do
			destroy(v.gameObject)
		end
	end
	self.DotCellList = {}
end
function C:MyRefresh()

end

function C:OnDotClick(obj)
	local id = tonumber(obj.name)
	local x = self.CellList[id].gameObject.transform.localPosition.x
	self:PlayAnim(x, id)
end

function C:KillAnim()
	if self.forSeq then
		self.forSeq:Kill()
		self.forSeq = nil
	end
end
function C:Update()
	if self.isScrollLock then
		return
	end
	if self.isScroll then
		local pos = UnityEngine.Input.mousePosition
		local px = pos.x - self.latelyPos.x
		self.item_node.transform:Translate (px, 0, 0)
		self.latelyPos = pos
		dump(px)
		local x = -1 * self.item_node.transform.localPosition.x
	end
end

function C:OnScrollDown()
	if not self.isOpenScroll then
		return
	end
	if self.isScrollLock then
		return
	end
	print("<color=red>OnScrollDown</color>")
	self:KillAnim()
	self.begPos = UnityEngine.Input.mousePosition
	self.latelyPos = UnityEngine.Input.mousePosition
	self.isScroll = true
end
function C:OnScrollUp()
	if not self.isOpenScroll then
		return
	end
	if self.isScrollLock then
		return
	end
	print("<color=red>OnScrollUp</color>")
	self.isScroll = false
	self.isScrollLock = true
	self.minPY = self.latelyPos.x - self.begPos.x
	self:Springback()
end
function C:Springback()
	local x = -1 * self.item_node.transform.localPosition.x
	local jindian
	local i
	for k,v in ipairs(self.CellList) do
		local bx = v.transform.localPosition.x
		if math.abs(self.minPY) > 20 then
			if self.minPY < 0 then
				if bx > x then
					if jindian then
						if math.abs(jindian - x) > math.abs(bx - x) then
							jindian = bx
							i = k
						end
					else
						jindian = bx
						i = k
					end
				end
			else
				if bx < x then
					if jindian then
						if math.abs(jindian - x) > math.abs(bx - x) then
							jindian = bx
							i = k
						end
					else
						jindian = bx
						i = k
					end
				end
			end
		else
			if jindian then
				if math.abs(jindian - x) > math.abs(bx - x) then
					jindian = bx
					i = k
				end
			else
				jindian = bx
				i = k
			end
		end
	end
	if jindian then
		self:PlayAnim(jindian, i)
	else
		jindian = self.CellList[self.selectIndex].transform.localPosition.x
		self:PlayAnim(jindian, self.selectIndex)
	end
end

function C:UpdateSelect(id)
	self.selectIndex = id
	for k,v in ipairs(self.DotCellList) do
		if k == self.selectIndex then
			v.transform:Find("Image").gameObject:SetActive(true)
		else
			v.transform:Find("Image").gameObject:SetActive(false)
		end
	end
end

function C:PlayAnim(jindian, i)
	local x = -1 * self.item_node.transform.localPosition.x
	local t = math.abs(jindian - x) / self.speed
	self.forSeq = DoTweenSequence.Create()
	self.forSeq:Append(self.item_node.transform:DOLocalMoveX(-1 * jindian, t))
	self.forSeq:OnKill(function ()
		self.isScrollLock = false
		if IsEquals(self.item_node) then
			self:UpdateSelect(i)
			self.item_node.transform.localPosition = Vector3.New(-1 * jindian, 0, 0)
		end
	end)
end


