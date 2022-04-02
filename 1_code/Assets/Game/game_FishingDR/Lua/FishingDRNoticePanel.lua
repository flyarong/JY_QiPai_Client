-- 创建时间:2019-07-25
-- Panel:New Lua
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

FishingDRNoticePanel= basefunc.class()
local C = FishingDRNoticePanel
C.name = "FishingDRNoticePanel"
C.Types={
	BH="捕获",
	JYB="金元宝",
	KSBY="开始捕鱼",
	DDKS="等待开始",
}
local spriteList={
	[1] ="bydr_game_icon_y8",
	[2] ="bydr_game_icon_y9",
	[3] ="bydr_game_icon_y10",
	[4] ="bydr_game_icon_y11",
	[5] ="bydr_game_icon_y12",
	[6] ="bydr_game_icon_y13",
	[7] ="bydr_game_icon_y14",
}

local defaultTimeout=1.6

local instance

function C.Create()
	if not instance then 
		instance = C.New()
	end  
	return  instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	-- self.lister["fishing_dr_quit_room_response"] = basefunc.handler(self, self.on_fsmg_quit_game)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:on_fsmg_quit_game()
	self:MyExit()
end 

function C.Close(  )
	if instance then
		instance:MyExit()
		instance = nil
	end
end

function C.Show(type,data,backcall,timeout,isclickclose)
	instance.isclickclose=isclickclose
	instance.backcall=backcall	
	instance:Hide()
	instance:InitTimer(timeout)
	instance.Button.gameObject:SetActive(true)
	if     type==instance.Types.BH then 
		if data ==nil then 
			return 
		end
		instance:BH(data)
	elseif  type==instance.Types.JYB then 
		if data ==nil then 
			return 
		end
		instance:JYB(data)
	elseif  type==instance.Types.KSBY then 
		instance:KSBY()
	elseif  type==instance.Types.DDKS then 
		instance:DDKS()
	end 
end


function C:InitTimer(timeout)
	self.timeout=timeout
	self.timeout=self.timeout or defaultTimeout
	if self.out_Timer then
		self.out_Timer:Stop()
		self.out_Timer=nil
	end 
	self.out_Timer=Timer.New(function ()
		self.timeout=self.timeout-0.1					
		if  self.timeout <= 0 then 			
			if self.out_Timer then
				self.out_Timer:Stop()
			end 
			self:Hide()
			if self.backcall then 
				self.backcall()
			end 
	    end 		
	end,0.1,-1)	
	self.out_Timer:Start()
end

--处理捕获
function C:BH(data)
	dump(data,"------------------------")
	self.bh.gameObject:SetActive(true)
	destroyChildren(self.bhContent)
	for i = 1, #data do
		local b =  GameObject.Instantiate(self.bhChild,self.bhContent)
		b.gameObject:SetActive(true)
		b.gameObject.transform:Find("Fish"):GetComponent("Image").sprite=GetTexture(spriteList[data[i]])
		b.gameObject.transform:Find("Fish"):GetComponent("Image"):SetNativeSize()
		b.gameObject.transform:Find("Bet/Text"):GetComponent("Image").sprite=GetTexture(self:GetMLImage(data[i]))
		b.gameObject.transform:Find("Bet/Text"):GetComponent("Image"):SetNativeSize()
		-- b.gameObject.transform:Find("Text"):GetComponent("Text").text="x"..(data[i].count or 1)
	end
end

--处理金元宝
function C:JYB(data)
	dump(data,"<color=red>金元宝------------------</color>")
	self.jyb.gameObject:SetActive(true)
	self.jybText.text=data.."鲸币"
end

--处理开始捕鱼
function C:KSBY()
	self.ksby.gameObject:SetActive(true)
end

--等待开始
function C:DDKS()
	self.ddks.gameObject:SetActive(true)
end 



function C:Hide()
	self:StopAllTimer()
	self.bh.gameObject:SetActive(false)
	self.jyb.gameObject:SetActive(false)
	self.ksby.gameObject:SetActive(false)
	self.ddks.gameObject:SetActive(false)
	self.Button.gameObject:SetActive(false)
end

function C:StopAllTimer()
	if self.out_Timer then 
		self.out_Timer:Stop()
	end 
end

function C:MyExit()
	self:RemoveListener()
	self:StopAllTimer()
	destroy(self.gameObject)
	instance=nil
end

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.isclickclose=false	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	 self.bh=self.transform:Find("BH")
	 self.jyb=self.transform:Find("JYB")
	 self.ksby=self.transform:Find("KSBY")
	 self.ddks=self.transform:Find("TZGM")
	 self.bhContent=self.transform:Find("BH/View/Content")
	 self.jybText=self.transform:Find("JYB/Text"):GetComponent("Text")
	 self.bhChild=self.transform:Find("AwardChild")
	 self.Button=self.transform:Find("Button"):GetComponent("Button")
	 self.Button.gameObject:SetActive(false)
	 self.Button.onClick:AddListener(
		 function ()
				 if self.isclickclose then 
					self:Hide()
					if self.backcall then 
						self.backcall()
					end 
					self.backcall=nil				
				end 
		 end
	 )
end

function C:MyRefresh()
end

function  C:GetMLImage(id)
	if id == 1 then
		return   "bydr_game_imgf_2b"
	end 
	if id == 2 then
		return  "bydr_game_imgf_4b"
	end 
	if id == 3 then
		return  "bydr_game_imgf_6b"
	end 
	if id == 4 then
		return  "bydr_game_imgf_8b"
	end 
	if id == 5 then
		return  "bydr_game_imgf_12b"
	end 
	if id == 6 then
		return  "bydr_game_imgf_18b"
	end 
	if id == 7 then
		return  "bydr_game_imgf_88b"
	end 
end

