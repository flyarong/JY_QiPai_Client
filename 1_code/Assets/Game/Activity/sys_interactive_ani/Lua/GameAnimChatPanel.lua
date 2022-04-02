-- 创建时间:2018-09-11

local basefunc = require "Game.Common.basefunc"

local animChatMap = 
{
	HDcuizi = {time = 1.3, movet=0.6},
	HDzhuan = {time = 1.28, movet=0.6},
	HDdiuzhadan = {time = 1.76, movet=0.667},
	HDqingwen = {time = 1.42, movet=0.5},
	HDrenjidan = {time = 0.87, movet=0.6},
	HDsonghua = {time = 2, movet=1},
	HDzan = {time = 1.5, movet=0.6},
	
	HDzhutou = {time = 2.04, movet=1},
	HD666 = {time = 2.9, movet=0.9},
	HDdiuxueqiu = {time = 1.8, movet = 0.9},

	HDposhui = {time = 1.83, movet=0.7},
	HDpingdiguo = {time = 2, movet=0.7},

	HDmojing_dizhu = {time = 1.5},
	HDmojing_nongming = {time = 1.5},
	
	BQshangxin = {time = 1.4},
	BQshengqi = {time = 1.4},
	BQweixiao = {time = 0.7},

	BQ_bianpao_01 = {time = 2, movet=1},
}

GameAnimChatPanel = basefunc.class()

GameAnimChatPanel.instance = nil
function GameAnimChatPanel.Create()
	if not GameAnimChatPanel.instance then
		GameAnimChatPanel.instance = GameAnimChatPanel.New()
	end
	return GameAnimChatPanel.instance
end
function GameAnimChatPanel.Exit()
	if GameAnimChatPanel.instance then
		GameAnimChatPanel.instance:ExitUI()
	end
	GameAnimChatPanel.instance = nil
end
-- 发送表情聊天
function GameAnimChatPanel.SendAnimChat(pid1, pid2, key)
	if GameAnimChatPanel.instance then
		GameAnimChatPanel.instance:onSendVoice(pid1, pid2, key)
		return true
	else
		print("<color=red>表情动画没有初始化 Logic</color>")
	end
end

function GameAnimChatPanel:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv4").transform
    self.gameObject = newObject("GameAnimChatPanel", parent)
    self.transform = self.gameObject.transform
    local tran = self.transform

    self.Node = tran:Find("Node")
    self.AnimChatPrefab = {}
    for k,v in pairs(animChatMap) do
    	self.AnimChatPrefab[k] = GetPrefab(k)
    end
	
	if MainModel.GetLocalType() == "mj" then
		self.gameType = "MJ3D"
	else
		self.gameType = "DDZ"
	end

end
function GameAnimChatPanel:onSendVoice(pid1, pid2, key)
    Network.SendRequest("send_player_easy_chat", {act_apt_player_id=pid2, parm=key})
end

function GameAnimChatPanel:ShowUI()
	self.gameObject:SetActive(true)
end
function GameAnimChatPanel:HideUI()
	self.gameObject:SetActive(false)
end

function GameAnimChatPanel:MyExit()
	self.AnimChatPrefab = {}
	destroy(self.gameObject)
end
function GameAnimChatPanel:ExitUI()
	self:MyExit()
end

local MJ3DAnimChatShowPos =
{
    [1] = {pos = {x=-820, y=-200, z=0}, rota= {x=0, y=0, z=0}},
    [2] = {pos = {x=820, y=240, z=0}, rota= {x=0, y=180, z=0}},
    [3] = {pos = {x=346, y=456, z=0}, rota= {x=0, y=180, z=0}},
    [4] = {pos = {x=-820, y=240, z=0}, rota= {x=0, y=0, z=0}},
}
local MJ3DAnimChatShowPosBQ =
{
    [1] = {pos = {x=-650, y=-180, z=0}, rota= {x=0, y=0, z=0}},
    [2] = {pos = {x=650, y=280, z=0}, rota= {x=0, y=180, z=0}},
    [3] = {pos = {x=178, y=450, z=0}, rota= {x=0, y=180, z=0}},
    [4] = {pos = {x=-650, y=280, z=0}, rota= {x=0, y=0, z=0}},
}

-- 头的位置
local DDZHeroAnimChatShowPos =
{
    [1] = {pos = {x=-756, y=-182, z=0}, rota= {x=0, y=0, z=0}},
    [2] = {pos = {x=735, y=355, z=0}, rota= {x=0, y=0, z=0}},
    [3] = {pos = {x=-736, y=346, z=0}, rota= {x=0, y=0, z=0}},
}

local DDZHeroAnimChatShowPosBQ =
{
    [1] = {pos = {x=-550, y=-150, z=0}, rota= {x=0, y=0, z=0}},
    [2] = {pos = {x=500, y=330, z=0}, rota= {x=0, y=180, z=0}},
    [3] = {pos = {x=-530, y=330, z=0}, rota= {x=0, y=0, z=0}},
}

-- 头的位置
local DDZHeroAnimChatShowPosTou =
{
    [1] = {pos = {x=-688, y=-218, z=0}, rota= {x=0, y=0, z=0}},
    [2] = {pos = {x=728, y=338, z=0}, rota= {x=0, y=180, z=0}},
    [3] = {pos = {x=-680, y=338, z=0}, rota= {x=0, y=0, z=0}},
}

function GameAnimChatPanel:GetShowPos (uipos, isdz, isTZ, animName)
	if self.gameType == "MJ3D" then
		if animName == "HDmojing" then
			return MJ3DAnimChatShowPos[uipos]
		else
			if isTZ then
				return MJ3DAnimChatShowPos[uipos]
			else
				return MJ3DAnimChatShowPosBQ[uipos]
			end
		end
	else
		if animName == "HDmojing" then
			return DDZHeroAnimChatShowPosTou[uipos]
		else
			if isTZ then
				return DDZHeroAnimChatShowPos[uipos]
			else
				return DDZHeroAnimChatShowPosBQ[uipos]
			end
		end
	end
end

function GameAnimChatPanel:PlayAnimChat(data)
	local model = GameAnimChatLogic.gameModel
	if model then
		local speedyData
	    local kk = ""
	    local key = tonumber(data.parm)
	    for k,v in ipairs(GameAnimChatModel.SpeedyConfig.config) do
	        if v.item_id == key then
	            kk = v.effect
	            speedyData = v
	            break
	        end
	    end
		local animName = kk
		if kk == "HDmojing" then
			if myDZ then
				animName = "HDmojing_dizhu"
			else
				animName = "HDmojing_nongming"
			end
		end

    	local isTZ
    	if data.act_apt_player_id ~= data.player_id and animChatMap[animName].movet then
    		isTZ = true
		else
			isTZ = false
		end
		if speedyData and speedyData.voice then
			ExtendSoundManager.PlaySound(speedyData.voice, 1, function ()
			end)
		end
		local a,b,myDZ = model.GetAnimChatShowPos(data.player_id)
		local uiPos1 = self:GetShowPos(a, b, isTZ, kk)
		local a2,b2,myDZ = model.GetAnimChatShowPos(data.act_apt_player_id)
		local uiPos2 = self:GetShowPos(a2, b2, isTZ, kk)

		print("<color=red>animName " .. animName .. "</color>")
		local obj = GameObject.Instantiate(self.AnimChatPrefab[animName], self.Node)
		obj.transform.localPosition = uiPos1.pos
		self.playSeq = DG.Tweening.DOTween.Sequence()
		local tweenKey = DOTweenManager.AddTweenToStop(self.playSeq)
		self.playSeq:AppendInterval(animChatMap[animName].time)
		if isTZ then
			self.playSeq:Join(obj.transform:DOLocalMove(uiPos2.pos, animChatMap[animName].movet))
		end
		if not isTZ then
			if kk ~= "HDmojing" then
				obj.transform.localRotation = Quaternion:SetEuler(uiPos1.rota.x, uiPos1.rota.y, uiPos1.rota.z)
			end
		end
		self.playSeq:OnComplete(function ()
			GameAnimChatModel.PlayFinish()
		end)
		self.playSeq:OnKill(function ()
			GameObject.Destroy(obj.gameObject)
			DOTweenManager.RemoveStopTween(tweenKey)
		end)		
	end
end