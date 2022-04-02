-- 创建时间:2018-06-06

local basefunc = require "Game.Common.basefunc"

MjXlHuanZhuo3D = basefunc.class()

MjXlHuanZhuo3D.name = "MjXlHuanZhuo3D"

local C = MjXlHuanZhuo3D

local instance
function C.Create(parent)
	if not instance then
		instance = C.New(parent)
	else
		instance:MyRefresh()
	end
	return instance
end


-- 关闭
function C.Close()
	if instance then
		instance:RemoveListener()
		if IsEquals(instance.transform) then
			GameObject.Destroy(instance.transform.gameObject)
		end
		instance = nil
	end
end

function C:AddMsgListener(lister)
    for proto_name,func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    --self.lister["model_fg_gameover_msg"] = basefunc.handler(self, self.on_model_fg_gameover_msg)
    self.lister["fg_huanzhuo_response_code"] = basefunc.handler(self, self.on_fg_huanzhuo_response_code)
end
function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end
function C:MyRefresh()
    
end

function C:ctor(parent)
	self.gameExitTime = os.time()

	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	self:MakeLister()
	self:AddMsgListener(self.lister)
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran

	self.ChangedeskButton = tran:Find("ChangedeskButton"):GetComponent("Button")
	self.ChangedeskButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		local a,b = GameButtonManager.RunFun({gotoui="sys_act_operator"}, "CanLeaveGameBeforeEnd")
		local is_true = a and b
		if MjXlModel.data.status ~= MjXlModel.Status.settlement and MjXlModel.data.status ~= MjXlModel.Status.gameover and not is_true then
			local a,b = GameButtonManager.RunFun({gotoui="sys_act_operator"}, "CheckCSActivity")
			local is_true = a and b
			local a1,b1 = GameButtonManager.RunFun({gotoui="sys_act_operator"}, "CheckCS")
			local is_true1 = a1 and b1
			if is_true and is_true1 then
				if is_true1 then
					local panel = HintPanel.Create(4, "财神已幸运的降临到该局游戏中！\n如果在该局离开将无法获得财神奖励，是否确定离开？", function(  )
						self:OnChangedeskClick()
					end)
					panel:SetBtnTitle("确  定", "取  消")
					return
				else
					self:OnChangedeskClick()
					return
				end
			end
			HintPanel.Create(1, "活动进行中，请等待对局结束!")
		else
			self:OnChangedeskClick()
		end
	end)

	self.ExitButton = tran:Find("ExitButton"):GetComponent("Button")
	self.ExitButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		local callback = function ()
			self:OnExitClick()
		end
		GameButtonManager.RunFun({gotoui="sys_act_operator",showHint = true,callback = callback}, "CanLeaveGameBeforeEnd")
	end)

	self.ChangedeskButton.gameObject:SetActive(false)
	self.ExitButton.gameObject:SetActive(false)

	MjAnimation.DelayTimeAction( function() 
		if IsEquals(self.ChangedeskButton) and IsEquals(self.ExitButton) then
	        self.ChangedeskButton.gameObject:SetActive(true)
	        self.ExitButton.gameObject:SetActive(true)
	    end
    end , 1 )

end

function C:on_fg_huanzhuo_response_code(result)
	if result == 0 then
		C.Close()
	end
end

-- 退出
function C:OnExitClick()
	if Network.SendRequest("fg_quit_game") then
		C.Close()
    else
		MJAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
    end
end

--- 换桌
function C:OnChangedeskClick()
	MjXlModel.HZCheck()
end

