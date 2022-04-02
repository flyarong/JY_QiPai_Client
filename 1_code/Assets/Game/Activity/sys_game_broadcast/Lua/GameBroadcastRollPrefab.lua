-- 创建时间:2018-11-28

local basefunc = require "Game.Common.basefunc"

GameBroadcastRollPrefab = basefunc.class()

local instance = nil
function GameBroadcastRollPrefab.Create(data, parent, tmpl)
	instance = GameBroadcastRollPrefab.New(data, parent, tmpl)
	return instance
end
function GameBroadcastRollPrefab:ctor(data, parent, tmpl)
	ExtPanel.ExtMsg(self)
	dump(data,"<color=red>广播数据 +++++++++++++++++++++++++</color>")
	self.data = data
    --self.gameObject = newObject("GameBroadcastRollPrefab", parent)
	self.gameObject = GameObject.Instantiate(tmpl, parent)
    self.transform = self.gameObject.transform
    local tran = self.transform
    tran.localPosition = Vector3.New(1000, 0, 0)
	local text = tran:Find("Text"):GetComponent("Text")
	self:InitGotoButton()
	text.text = data.msg.content
	local ww = text.preferredWidth

	self.seqMove = DG.Tweening.DOTween.Sequence()

	local is_complete = false
	-- 移动速度固定 计算移动时间
	local tt1 = (1100 + ww)/1100 * 6
	-- 400是两条滚动广播的距离
	local tt2 = (400 + ww)/1100 * 6
	local pos1 = Vector3.New(-550-ww, 0, 0)
	self.seqMove:AppendInterval(tt2)
	self.seqMove:AppendCallback(function ()
		GameBroadcastManager.PlayFinish(data.key)
	end)
	self.seqMove:AppendInterval(-1 * tt2)
	self.seqMove:Append(tran:DOLocalMoveX(pos1.x, tt1):SetEase(DG.Tweening.Ease.Linear))
	self.seqMove:OnComplete(function ()
		is_complete = true
		GameBroadcastRollPanel.PlayEnd(data.key)
	end)
	self.seqMove:OnKill(function ()
		self.seqMove = nil
		if not is_complete then
			is_complete = true
			GameBroadcastRollPanel.PlayEnd(data.key)
		end
	end)
end
function GameBroadcastRollPrefab:Destroy()
	self:MyExit()
end
function GameBroadcastRollPrefab:MyExit()
	if IsEquals(self.gameObject) then
		if self.seqMove then
			self.seqMove:Kill()
		end
		destroy(self.gameObject)
	end
end

function GameBroadcastRollPrefab:InitGotoButton()
	local Button = self.transform:Find("Button"):GetComponent("Button")
	local config = {
		{key = "街机捕鱼",value = "game_FishingHall"}, --201.12.21修改为街机打鱼
		{key = "街机打鱼",value = "game_FishingHall"},
		{key = "敲敲乐财神模式",value = "game_Zjd"},
		{key = "敲敲乐",value = "game_Zjd"},
		{key = "萌宠消消乐",value = "game_Eliminate"},

		{key = "水浒消消乐",value = "game_EliminateSH"},
		{key = "财神消消乐",value = "game_EliminateCS"},
		{key = "西游消消乐",value = "game_EliminateXY"},
		{key = "疯狂捕鱼",value = "game_FishingDR"},

		{key = "苹果大战",value = "game_ZPG"},
		{key = "热血传奇",value = "game_RXCQ"},
		{key = "超级消消乐",value = "game_EliminateCJ"},
		{key = "龙王争霸",value = "game_LWZBHall"},

		{key = "盗墓笔记",value = "game_DMBJ"}, --201.12.21修改为寻龙摸金
		{key = "寻龙摸金",value = "game_DMBJ"},
		{key = "弹弹乐",value = "game_TTL"},
		{key = "锦标赛",value = "game_MatchHall"},
		{key = "三国消消乐",value = "game_EliminateSG"},
		{key = "福星高照",value = "game_EliminateFX"},
	}
	local content = self.data.msg.content
	local goto_ui = nil
	local game_name = ""
	for i = 1,#config do
		local key = config[i].key
		if string.find(content,key) then
			goto_ui = config[i].value
			game_name = config[i].key
			break
		end
	end
	if goto_ui then
		Button.onClick:AddListener(
			function()
				HintPanel.Create(2,"是否前往【"..game_name.."】".."游戏?",function()
					if MainModel.myLocation == "game_Fishing" and goto_ui == "game_FishingHall" then
						HintPanel.Create(1,"您当前正在捕鱼哦！")
						return
					end
					GameManager.CommonGotoScence({gotoui = goto_ui})
				end)
			end
		)
	else
		Button.gameObject:SetActive(false)
	end
end