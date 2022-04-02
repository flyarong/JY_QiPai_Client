-- 创建时间:2020-02-12
-- Panel:DTTJ_BYPrefab
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

DTTJ_BYPrefab = basefunc.class()
local C = DTTJ_BYPrefab
C.name = "DTTJ_BYPrefab"

function C.Create(parent, cfg)
	return C.New(parent, cfg)
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

function C:ctor(parent, cfg)
	local obj = newObject(cfg.prefab, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.FISHINGBox = self.FISHINGBox:GetComponent("PolygonClick")
	self.transform.localPosition = Vector3.zero

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end
 -- -73 -298
function C:InitUI()
	self.FISHINGBox.PointerClick:AddListener(function (obj)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnFishingClick()
	end)

	self:MyRefresh()
end

function C:MyRefresh()
	-- 捕鱼新人福卡提示
	local old_obj = GameObject.Find("Canvas/LayerLv1/byxrhb_hall_hintobj")
	if IsEquals(old_obj) then
		destroy(old_obj)
	end
    local b,c = GameButtonManager.RunFun({gotoui = "by_xrhb"}, "GetJYFLShowId")
    if b and c then
		local parent = GameObject.Find("Canvas/LayerLv1/HallPanel/@RectRight/@TJGameNode").transform
		
		local obj = newObject("byxrhb_hall_hintobj", parent)
		local temp_ui = {}
		LuaHelper.GeneratingVar(obj.transform,temp_ui)
		local ca = CommonCellAnim.Create()
		ca:Go(temp_ui.move_node,temp_ui.hongbao,2,4,-1)
	end
	
	self:RefreshFishingMatch()
end
-- 刷新捕鱼比赛提示
function C:RefreshFishingMatch()
	if IsEquals(self.fish_nor_node) then
		self.fish_nor_node.gameObject:SetActive(true)
	end
	local b = FishingManager.IsTodayHaveMatch()
	if b then
		if IsEquals(self.fish_match_hint) then
			self.fish_match_hint.gameObject:SetActive(true)
		end
		-- if IsEquals(self.fish_nor_node) then
		-- 	self.fish_nor_node.gameObject:SetActive(false)
		-- end
	else
		if IsEquals(self.fish_match_hint) then
			self.fish_match_hint.gameObject:SetActive(false)
		end
	end
end

function C:OnFishingClick()
	if GameGlobalOnOff.Fishing then
		GameManager.GotoUI({gotoui = "game_FishingHall",goto_scene_parm ={down_style={panel=self.transform}}})
	else
		HintPanel.Create(1, "即将开放，敬请期待")
	end
end

