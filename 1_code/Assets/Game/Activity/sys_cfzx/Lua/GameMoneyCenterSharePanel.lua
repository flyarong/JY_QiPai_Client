-- 创建时间:2018-07-16

local basefunc = require "Game.Common.basefunc"

GameMoneyCenterSharePanel = basefunc.class()
GameMoneyCenterSharePanel.name = "GameMoneyCenterSharePanel"
local PAGE_TBL = {
	"share_1.png", "share_4.png", "share_13.png", "share_14.png"
}

function GameMoneyCenterSharePanel.Create(parent)
	return GameMoneyCenterSharePanel.New(parent)
end

function GameMoneyCenterSharePanel:MyExit()
	self:ClearAll()
	destroy(self.gameObject)
end
function GameMoneyCenterSharePanel:Close()
	self:MyExit()
end

function GameMoneyCenterSharePanel:MyClose()
	self:MyExit()
end

function GameMoneyCenterSharePanel:ctor(parent)

	ExtPanel.ExtMsg(self)

	if parent == nil then
		parent = GameObject.Find("Canvas/LayerLv5").transform
	end
	local obj = newObject(GameMoneyCenterSharePanel.name, parent)
	local tran = obj.transform
	self.gameObject = obj
	self.transform = obj.transform
	LuaHelper.GeneratingVar(self.transform, self)
	self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")

	self.page_weights = {}
	self.page_count = math.ceil(#PAGE_TBL / 4)
	if self.page_count > 1 then
		local step = 1 / (self.page_count - 1)
		for idx = 1, self.page_count, 1 do
			self.page_weights[idx] = (idx - 1) * step
		end
	else
		self.page_weights[1] = 0
	end
	self.page_index = 1
	self.dragPosition = 0
	self.select_index = -1

	self.pageList = {}

	self:InitRect()
end

function GameMoneyCenterSharePanel:InitRect()
	local transform = self.transform

	self.scrollView = transform:Find("Scroll View"):GetComponent("ScrollRect")
	EventTriggerListener.Get(self.scrollView.gameObject).onBeginDrag = basefunc.handler(self, self.OnBeginDrag)
	EventTriggerListener.Get(self.scrollView.gameObject).onEndDrag = basefunc.handler(self, self.OnEndDrag)

	self.scp_left_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		
		self.page_index = Mathf.Clamp(self.page_index - 1, 1, self.page_count);
		self:UpdatePageButtons()
		self:AnimationScroll(self.page_weights[self.page_index])
	end)
	self.scp_right_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		
		self.page_index = Mathf.Clamp(self.page_index + 1, 1, self.page_count);
		self:UpdatePageButtons()
		self:AnimationScroll(self.page_weights[self.page_index])
	end)

	self.wx_btn.onClick:AddListener(function ()
		self:WeChatShareImage(false)
	end)

	self.pyq_btn.onClick:AddListener(function ()
		self:WeChatShareImage(true)
	end)

	-- 朋友圈链接被屏蔽，暂时关闭朋友圈分享
	self.wx_btn.transform.localPosition = Vector3.New(0, -334, 0)
	self.pyq_btn.gameObject:SetActive(false)
	self:Refresh()
	HandleLoadChannelLua("GameMoneyCenterSharePanel", self)
	GameManager.GotoUI({gotoui = "sys_open_install_binding",goto_scene_parm = "share"})
end

function GameMoneyCenterSharePanel:Refresh()
	self:ClearItemList(self.pageList)
	self.pageList = {}
	self:FillItemList(PAGE_TBL)
	self:UpdatePageButtons()
end

function GameMoneyCenterSharePanel:ClearItemList(list)
	for k, v in ipairs(list) do
		GameObject.Destroy(v.gameObject)
		list[k] = nil
	end
end

function GameMoneyCenterSharePanel:ClearAll()
	self:ClearItemList(self.pageList)
	self.pageList = {}
	self.currentIndex = 0
	self.currentPage = 0
	self.select_index = -1
end

function GameMoneyCenterSharePanel:FillItemList()
	local page_count = #PAGE_TBL

	for idx = 1, page_count, 1 do
		self.pageList[#self.pageList + 1] = self:CreateShareItem(idx)
	end
end

function GameMoneyCenterSharePanel:OnBeginDrag()
	local page_count = self.page_count
	if page_count <= 1 then return end

	self.dragPosition = self.scrollView.horizontalNormalizedPosition
end

function GameMoneyCenterSharePanel:OnEndDrag()
	local page_count = self.page_count
	if page_count <= 1 then return end

	local currentPosition = self.scrollView.horizontalNormalizedPosition
	if currentPosition > self.dragPosition then
		currentPosition = currentPosition + 0.1
	else
		currentPosition = currentPosition - 0.1
	end

	local page_index = 1
	local offset = math.abs(self.page_weights[page_index] - currentPosition)
	for idx = 2, page_count, 1 do
		local tmp = math.abs(currentPosition - self.page_weights[idx])
		if tmp < offset then
			page_index = idx
			offset = tmp
		end
	end
	self.page_index = page_index
	self:UpdatePageButtons()
	self:AnimationScroll(self.page_weights[self.page_index])
end

function GameMoneyCenterSharePanel:UpdatePageButtons()
	local page_count = self.page_count
	if page_count <= 1 then
		self.scp_left_btn.gameObject:SetActive(false)
		self.scp_right_btn.gameObject:SetActive(false)
	else
		self.scp_left_btn.gameObject:SetActive(true)
		self.scp_right_btn.gameObject:SetActive(true)
		if self.page_index <= 1 then
			self.scp_left_btn.gameObject:SetActive(false)
        end
		if self.page_index >= page_count then
			self.scp_right_btn.gameObject:SetActive(false)
		end
	end
end

function GameMoneyCenterSharePanel:AnimationScroll(dst)
	if not IsEquals(self.scrollView) then return end

	local callbacks = {}

	local CNT = 5
	local current = self.scrollView.horizontalNormalizedPosition
	local step = (dst - current) / CNT

	for idx = 1, CNT, 1 do
		callbacks[idx] = {}
		callbacks[idx].stamp = 0.03
		callbacks[idx].method = function()
			if IsEquals(self.scrollView) then
				self.scrollView.horizontalNormalizedPosition = current + step * idx
			end
		end
	end

	GameMoneyCenterSharePanel.TweenDelay(callbacks, function()
		if IsEquals(self.scrollView) then
			self.scrollView.horizontalNormalizedPosition = dst
		end
	end)
end

function GameMoneyCenterSharePanel:CreateShareItem(index)
	local go = self:CreateItem(self.scp_list, self.share_tmpl)
	local go_table = {}
	LuaHelper.GeneratingVar(go.transform, go_table)

	local share_cfg = basefunc.deepcopy(share_link_config.img_money_center_wdtgm)
	share_cfg.share_source = share_cfg.share_source .. index
	share_cfg.share_img = share_cfg.share_img[index]
	ShareHelper.RefreshShareImage(go_table.share_img,share_cfg)
    ShareHelper.RefreshQRCode(go_table.qr_code_img,share_cfg)
    ShareHelper.RefreshImage(go_table.head_img,go_table.icon_img,go_table.invite_txt,share_cfg.share_img)
	if gameMgr:getMarketPlatform() == "wqp" then
        go_table.icon_img.transform.localPosition = Vector3.New(-215, 448, 0)
        go_table.icon_img.transform.localScale = Vector3.New( 0.35, 0.35, 1)
    end
	PointerEventListener.Get(go_table.share_img.gameObject).onUp = function()
		self:SetFocus(index)
	end
	return go
end

function GameMoneyCenterSharePanel:CreateItem(parent, tmpl)
	local obj = GameObject.Instantiate(tmpl)
	obj.transform:SetParent(parent)
	obj.transform.localPosition = Vector3.zero
	obj.transform.localScale = Vector3.one
	obj.transform:SetAsLastSibling()
	obj.gameObject:SetActive(true)
	return obj
end

function GameMoneyCenterSharePanel:SetFocus(index)
	local selected_img = nil
	for i = 1, #PAGE_TBL do
		selected_img = self.pageList[i].transform:Find("selected_img")
		if i == index then
			selected_img.gameObject:SetActive(true)
		else
			selected_img.gameObject:SetActive(false)
		end
	end
	self.select_index = index
end

function GameMoneyCenterSharePanel:WeChatShareImage(isCircleOfFriends)
	local select_index = self.select_index
	if select_index <= 0 then
		select_index = math.random(1, #PAGE_TBL)
		self:SetFocus(select_index)
	end
	local share_cfg = basefunc.deepcopy(share_link_config.img_money_center_wdtgm)
	share_cfg.share_source = share_cfg.share_source .. select_index
	share_cfg.share_img = share_cfg.share_img[select_index]
	share_cfg.isCircleOfFriends = isCircleOfFriends
	GameManager.GotoUI({gotoui = "sys_fx",goto_scene_parm = "image",share_cfg = share_cfg})
end

function GameMoneyCenterSharePanel.TweenDelay(callbacks, finally_callback)
	local traceTbl = {}

	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:OnKill(function()
		DOTweenManager.RemoveStopTween(tweenKey)

		for k, v in ipairs(traceTbl) do
			if not v then
				if callbacks[k].method then callbacks[k].method() end
			end
		end

		if finally_callback then finally_callback() end
	end)

	for k, v in ipairs(callbacks) do
		traceTbl[k] = false
		seq:AppendInterval(v.stamp):AppendCallback(function()
			traceTbl[k] = true
			if v.method then v.method() end
		end)
	end

	return tweenKey
end