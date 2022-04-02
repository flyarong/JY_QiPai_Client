-- 创建时间:2020-09-12
-- Panel:Act_029_DJGFPanel
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

Act_029_DJGFPanel = basefunc.class()
local C = Act_029_DJGFPanel
C.name = "Act_029_DJGFPanel"

function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["query_common_divide_base_info_response"] = basefunc.handler(self,self.on_query_common_divide_base_info_response)
	self.lister["query_common_divide_sys_info_response"] = basefunc.handler(self,self.on_query_common_divide_sys_info_response)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.UpDate_Timer then
		self.UpDate_Timer:Stop()
	end
	if self.Out_Timer then
		self.Out_Timer:Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:UpDateData()
end

function C:InitUI()
	self.go_btn.onClick:AddListener(
		function()
			GameManager.CommonGotoScence({gotoui="game_Free"},function()
				self:MyExit()
			end)
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
end


function C:UpDateData()
	Network.SendRequest("query_common_divide_base_info",{divide_type = "znq_2year_divide"})
	Network.SendRequest("query_common_divide_sys_info",{divide_type = "znq_2year_divide"})
	if self.UpDate_Timer then
		self.UpDate_Timer:Stop()
	end
	self.UpDate_Timer = Timer.New(
	function()
		Network.SendRequest("query_common_divide_base_info",{divide_type = "znq_2year_divide"})
		Network.SendRequest("query_common_divide_sys_info",{divide_type = "znq_2year_divide"})
	end,5,-1)
	self.UpDate_Timer:Start()
end

function C:OnDestroy()
	self:MyExit()
end

function C:on_query_common_divide_base_info_response(_,data)
	dump(data,"<color=red>所有的数据</color>")
	if data and data.result == 0 then
		self.my_num_txt.text = data.divide_num
	end
end

function C:on_query_common_divide_sys_info_response(_,data)
	dump(data,"<color=red>自己的数据</color>")
	if data and data.result == 0 then
		self.num_txt.text = "当前已有"..data.total_divide_player.."人满足瓜分条件"
		self:UpdateTimer(data.divide_time - os.time())
	end
end

--更新时间
function C:UpdateTimer(time)
	if self.Out_Timer then
		self.Out_Timer:Stop()
	end
	self:Time2Str(time)
	self.Out_Timer = Timer.New(
		function()
			time = time - 1
			self:Time2Str(time)
		end
	,1,-1)
	self.Out_Timer:Start()
end

function C:Time2Str(second)
	local timeDay = math.floor(second/86400)
    local timeHour = math.fmod(math.floor(second/3600), 24)
    local timeMinute = math.fmod(math.floor(second/60), 60)
	local timeSecond = math.fmod(second, 60)
	self.day_txt.text = timeDay
	self.hour_txt.text = timeHour
	self.minute_txt.text = timeMinute
	self.second_txt.text = timeSecond
end