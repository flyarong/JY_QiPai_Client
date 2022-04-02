-- 创建时间:2020-06-18
-- Panel:Act_018_MFCDJGetAwardPanel
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

Act_018_MFCDJGetAwardPanel = basefunc.class()
local C = Act_018_MFCDJGetAwardPanel
C.name = "Act_018_MFCDJGetAwardPanel"
local had_use = {}
local M = Act_018_MFCDJManager
function C.Create(index)
	return C.New(index)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["act_018_mfcdj_can_quit"] = basefunc.handler(self,self.act_018_mfcdj_can_quit)
	self.lister["AssetChange"] = basefunc.handler(self,self.OnAssetChange)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	for i = 1,5 do
		self.prefabs[i]:MyExit()
	end
	if not M.CanGetAwardIndex() then
		Event.Brocast("close_act_018_mfcdj")
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(index)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.index = index
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.prefabs = {}
	for i = 1,5 do
		self.prefabs[#self.prefabs + 1] = Act_018_MFCDJCardPrefab.Create(self["node"..i],self.index)
		self["node"..i].transform.localPosition = Vector3.New(self["node"..i].transform.localPosition.x,self["node"..i].transform.localPosition.y,0)
	end
	self:GuideAnim(self.prefabs,function ()
		Event.Brocast("act_018_mfcdj_can_click",{can_click = true})
		self.choose.gameObject:SetActive(true)
	end)
	self.exit_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self:MyRefresh()
end

function C:GuideAnim(objs,backcall)
	local finsh_times = 0
	for i=1,#objs do
		local obj_t = objs[i].transform
		self.seq = DoTweenSequence.Create()
		local old_p  = obj_t.parent
		obj_t.parent = self.transform
		local v  = obj_t.transform.localPosition
		obj_t.transform.localPosition = Vector2.New(self.mid_pos.transform.localPosition.x,self.mid_pos.transform.localPosition.y)
		--self.seq:Append(obj_t:DOLocalMove(self.mid_pos.transform.localPosition, 0.001))
		self.seq:AppendInterval(0.5)
		self.seq:Append(obj_t:DOLocalMove(v, 0.7))
		self.seq:OnKill(function ()
			finsh_times = finsh_times + 1
			if finsh_times == #objs then 
				if backcall then 
					backcall()
				end 
			end 
			obj_t.parent = old_p
			self.seq = nil
		end)
	end
end

function C:MyRefresh()

end


function C:OnAssetChange(data)
	dump(data,"<color=red>任务奖励数据</color>")
    if data.change_type and data.change_type == "task_p_freestyle_ddz" then
		self.award_data = data
		had_use = {}
		local dd = {data.data[1].asset_type,data.data[1].value}
		had_use[#had_use + 1]= dd
		Event.Brocast("act_018_mfcdj_info_get",{award_data = data})
    end
end

function C.GetAllAwardData(index)
	return M.base_data[index]
end

local fake_index = 1
function C.GetFakeAward()
	local data = M.GetFakeAwardData()
	local r =  data[fake_index]
	fake_index = fake_index + 1
	if fake_index == 5 then
		fake_index = 1
	end
	return r
end

function C.GetMapping(max)
	local temp_list = {}
	local List = {}
	for i = 1, max do
		List[i] = i
	end
	math.randomseed(MainModel.UserInfo.user_id)
	while #temp_list < max do
		local R = math.random(1, max)
		if List[R] ~= nil then
			temp_list[#temp_list + 1] = List[R]
			table.remove(List, R)
		end
	end
	return temp_list
end

function C:act_018_mfcdj_can_quit()
	if not IsEquals(self.gameObject) then return end
	self.choose.gameObject:SetActive(false)
	self.exit_btn.gameObject:SetActive(true)
end

