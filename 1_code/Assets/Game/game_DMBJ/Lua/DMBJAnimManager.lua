-- 创建时间:2020-11-20
-- DMBJAnimManager 管理器

local basefunc = require "Game/Common/basefunc"
DMBJAnimManager = {}
local M = DMBJAnimManager
M.name = DMBJAnimManager
M.IsInAnim = false
local GamePanel = nil

function M.Init(gamepanel)
    GamePanel = gamepanel
end

function M.GetRandomVector3()
	local left_top = {x = -270,y = 375}
	local right_top = {x = 270,y = 375}
	local left_bottom = {x = -270,y = 160}
	local right_bottom = {x = 270,y = 160}
	return Vector3.New(math.random(left_top.x,right_top.x),math.random(left_bottom.y,left_top.y))
end

function M.MoveByPath(data,items,backcall)
	if not IsEquals(GamePanel) then return end
	local paths = {
		[1] = { [0] = GamePanel.award_pos1.transform.localPosition,
				[1] = M.GetRandomVector3(),
				[2] = GamePanel.show_pos1.transform.localPosition},
		[2] = { [0] = GamePanel.award_pos2.transform.localPosition,
				[1] = M.GetRandomVector3(),
				[2] = GamePanel.show_pos2.transform.localPosition},
		[3] = { [0] = GamePanel.award_pos3.transform.localPosition,
				[1] = M.GetRandomVector3(),
				[2] = GamePanel.show_pos3.transform.localPosition},
		[4] = { [0] = GamePanel.award_pos4.transform.localPosition,
				[1] = M.GetRandomVector3(),
				[2] = GamePanel.show_pos4.transform.localPosition},
		[5] = { [0] = GamePanel.award_pos5.transform.localPosition,
				[1] = M.GetRandomVector3(),
				[2] = GamePanel.show_pos5.transform.localPosition},
	}
	local Finsh_Times = 0
	for i = 1,#items do
		items[i].transform.parent = GamePanel.ShowAwardPanel
		items[i]:SetIsLiang(false)
		GamePanel.Spawn.gameObject:SetActive(false)
		local seq = DoTweenSequence.Create({dotweenLayerKey = M.name})
		seq:Append(items[i].transform:DOLocalPath(paths[items[i].pos],1,DG.Tweening.PathType.CatmullRom))
		seq:AppendCallback(
		function ()
			Finsh_Times = Finsh_Times + 1
			items[i].transform.parent = GamePanel["show_pos"..items[i].pos]
			if Finsh_Times == #items then
				ExtendSoundManager.PlaySound(audio_config.dmbj.dmbj_genghuan.audio_name)
				M.ExchangePos(GamePanel.ui_items,backcall)
			end
		end
		)
	end

end

function M.DoFirstLottery(data,ui_items,backcall)
	M.IsInAnim = true
	local seq = DoTweenSequence.Create({dotweenLayerKey = M.name})
	GamePanel.Spawn.gameObject:SetActive(true)
	seq:AppendInterval(2)
	seq:AppendCallback(
		function ()
			M.MoveByPath(data,ui_items,backcall)
		end
	) 
end

function M.DoSecondLottery(data,ui_items,backcall)
	M.IsInAnim = true
	local diffdata = DMBJModel.GetDifferentAtMap()
	GamePanel.Spawn.gameObject:SetActive(true)
	dump(diffdata,"<color=red>差异数据</color>")
	dump(DMBJModel.GetFirstLotteryMap())
	dump(DMBJModel.GetSecondLotteryMap())
	local ui_items = {}
	GamePanel:HideSpawnTX()
	for i = 1,#GamePanel.send_exchange do
		local glow = GamePanel["award_pos"..i].transform:Find("glow_0"..i).gameObject
		glow:SetActive(true)
		local b = GamePanel.ui_items[GamePanel.send_exchange[i]]
		b.gameObject:SetActive(true)
		b.transform.parent = GamePanel["award_pos"..i]
		b.transform.localPosition = Vector3.New(0,0,0)
		b:ReSetParm(diffdata[i])
		b:SetIsLiang(true)
		ui_items[#ui_items + 1] = b
	end
	local seq = DoTweenSequence.Create({dotweenLayerKey = M.name})
	seq:AppendInterval(2)
	seq:AppendCallback(
		function ()
			M.MoveByPath(DMBJModel.GetSecondLotteryMap(),ui_items,backcall)
		end
	) 
end

local sort_function = function(a,b)
	if a.rate == b.rate then
		return a.parm > b.parm
	end
	return a.rate > b.rate
end

function M.ExchangePos(items,backcall)
	local RE = {}
	for i = 1,#items do
		RE[items[i].parm] = RE[items[i].parm] or {}
		RE[items[i].parm][#RE[items[i].parm] + 1] = items[i]
	end
	local Final_Data = {}
	for k,v in pairs(RE) do
		local data = {parm = k,length = #v,rate = DMBJModel.CountRate(k,#v),prefabs = v}
		Final_Data[#Final_Data + 1] = data
	end
	table.sort(Final_Data, sort_function)
	local items = {}
	for i = 1,#Final_Data do
		for j = 1,#Final_Data[i].prefabs do
			items[#items + 1] = Final_Data[i].prefabs[j]
		end
	end 
	dump(Final_Data,"<color=red>Final_Data</color>")
	dump(items,"<color=red>items</color>")
	local exchange_item = {}

	local get_prefab_by_pos = function(pos,tabel)
		for i = 1,#tabel do
			if pos == tabel[i].pos then
				return tabel[i]
			end
		end
	end
	local need_exchange_pos = {}
	for i = 1,#items do
		items[i].used1 = false
		items[i].used2 = false
		if items[i].parm ~= DMBJPrefabManager.Pos2Map[i].parm then
			need_exchange_pos[#need_exchange_pos + 1] = i
		end
	end
	dump(need_exchange_pos,"<color=red>need_exchange_pos</color>")
	for i = 1,#need_exchange_pos do
		local current = DMBJPrefabManager.Pos2Map[need_exchange_pos[i]]
		for j = 1,#need_exchange_pos do
			local item = items[need_exchange_pos[j]]
			if not item.used1 and not current.used2 and current.parm == item.parm then
				item.used1 = true
				current.used2  = true
				local data = {prefab = current,target = need_exchange_pos[j]}
				exchange_item[#exchange_item + 1] = data
			end
		end
	end
	local Finsh_Times = 0
	local OverCall = function()
		Finsh_Times = Finsh_Times + 1
		if Finsh_Times == #exchange_item then
			if backcall then
				backcall()
			end
			M.IsInAnim = false
			Event.Brocast("anim_dmbj_exchangepos_finsh")
		end
	end
	for i = 1,#exchange_item do
		local pos = exchange_item[i].target
		local path = {}
		exchange_item[i].prefab.transform.transform.parent = GamePanel.ShowAwardPanel
		path[0] = exchange_item[i].prefab.transform.localPosition
		path[1] = GamePanel["show_pos"..pos].transform.localPosition
		local seq = DoTweenSequence.Create({dotweenLayerKey = M.name})
		seq:AppendInterval(0.5)
		seq:Append(exchange_item[i].prefab.transform:DOLocalPath(path,0.26))
		seq:AppendCallback(function ()
			exchange_item[i].prefab:SetPos(pos)
			exchange_item[i].prefab.transform.transform.parent = GamePanel["show_pos"..pos].transform
			OverCall()
		end)
	end
	if #exchange_item == 0 then
		if backcall then
			backcall()
		end
		M.IsInAnim = false
		Event.Brocast("anim_dmbj_exchangepos_finsh")
	end
end
