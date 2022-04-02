-- 创建时间:2019-01-10
require "Game.CommonPrefab.Lua.CachePrefab"

CachePrefabManager = {}

local this
local cachemap = {}
local rect_width = 1920
local rect_height = 1080

-- 动态缓存对象
local dt_cache_list = {}

function CachePrefabManager.Init()
	if not this then
		local pp = GameObject.Find("GameManager").transform
		if not IsEquals(pp) then
			print("<color=red>CachePrefabManager.Init()</color>")
		end
		this = CachePrefabManager

		local obj = GameObject.New()
		local rect = obj.gameObject:AddComponent(typeof(UnityEngine.RectTransform))
		obj.transform:SetParent(pp)
		obj.name = "CacheRootNode"
		local canvasS = GameObject.Find("Canvas"):GetComponent("RectTransform")
		local width = Screen.width
    	local height = Screen.height
    	if width / height < 1 then
			width,height = height,width
    	end
    	local matchWidthOrHeight = MainModel.GetScene_MatchWidthOrHeight(width, height)
	    if matchWidthOrHeight == 0 then
		    height = 1080 * (1920 / width)
		    width = 1920
	    else
	    	width = 1080 * (width / height)
		    height = 1080
	    end
	    rect_width = width
	    rect_height = height
	 	obj.transform.localScale = Vector3.one
	 	rect.sizeDelta = {x=width, y=height}
		this.CacheRootNode = obj.transform
	else

	end
end

-- 清除标记
function CachePrefabManager.CloseCacheTag()
	if cachemap and next(cachemap) then
		for k,v in pairs(cachemap) do
			for k1,v1 in ipairs(v) do
				v1.is_in_use = false
				v1.last_in_use_time = 0
				v1.prefab:SetParent(this.CacheRootNode)
			end
		end
	end
end

-- 创建缓冲池
function CachePrefabManager.InitCachePrefab(prefabname, count, ishide)
	CachePrefabManager.Init()
	
	-- 确保初始化被执行
	CachePrefabManager.DelCachePrefab(prefabname)
	if not cachemap[prefabname] then
		local pp = GameObject.New()
		pp.transform:SetParent(this.CacheRootNode)
		local rect = pp.gameObject:AddComponent(typeof(UnityEngine.RectTransform))
		rect.sizeDelta = {x=rect_width, y=rect_height}
		pp.transform.localScale = Vector3.one
		
		pp.name = prefabname
		if ishide then
			pp:SetActive(false)
		end
		local list = {}
		cachemap[prefabname] = {}
		cachemap[prefabname].parent = pp.transform
		cachemap[prefabname].useindex = 0
		cachemap[prefabname].list = list
		for i = 1, count do
			local data = {}
			data.is_in_use = false
			data.last_in_use_time = 0
			data.prefabname = prefabname
			data.index = i
			data.prefab = CachePrefab.Create(prefabname, pp.transform)
			data.prefab:SetObjName(i)
			list[#list + 1] = data
		end
	end
end
-- 删除缓冲池
function CachePrefabManager.DelCachePrefab(prefabname)
	if cachemap[prefabname] then
		destroy(cachemap[prefabname].parent.gameObject)
		cachemap[prefabname] = nil
	end
end

-- 是否还有缓存
function CachePrefabManager.IsBeCache(prefabname, num)
	num = num or 1
	local data = cachemap[prefabname]
	if data and next(data.list) then
		if (data.useindex+num) <= #data.list then
			return true
		else
			return false
		end
	else
		return false
	end
end

-- 取用
function CachePrefabManager.Take(prefabname, parent, step)
	if not this or not IsEquals(this.CacheRootNode) then
		CachePrefabManager.Init()
	end
	local data = cachemap[prefabname]
	if data and next(data.list) then
		if (data.useindex+1) <= #data.list then
			data.useindex = data.useindex + 1
			local pre = data.list[data.useindex]
			if pre then
				pre.is_in_use = true
			end
			return pre
		else
			if step then
				CachePrefabManager.SubstepCachePrefab(prefabname, step)
				return CachePrefabManager.Take(prefabname, parent)
			end
			local data = {}
			data.is_in_use = true
			data.last_in_use_time = 0
			data.prefabname = prefabname
			data.index = -888
			if IsEquals(parent) then
				data.prefab = CachePrefab.Create(prefabname, parent)
			else
				data.prefab = CachePrefab.Create(prefabname, this.CacheRootNode)
			end
			data.prefab:SetObjName("-888")
			return data
		end
	else
		if step then
			CachePrefabManager.SubstepCachePrefab(prefabname, step, true)
			return CachePrefabManager.Take(prefabname, parent)
		end

		local data = {}
		data.is_in_use = true
		data.last_in_use_time = 0
		data.prefabname = prefabname
		data.index = -888
		if IsEquals(parent) then
			data.prefab = CachePrefab.Create(prefabname, parent)
		else
			data.prefab = CachePrefab.Create(prefabname, this.CacheRootNode)
		end
		data.prefab:SetObjName("-888")
		return data
	end
end
-- 不强制取用，缓存没有了，返回nil
function CachePrefabManager.NoForceTake(prefabname, parent)
	if CachePrefabManager.IsBeCache(prefabname, 1) then
		return CachePrefabManager.Take(prefabname, parent)
	end
end

-- 归还
function CachePrefabManager.Back(prefab)
	if not prefab then
		return
	end
	if prefab.index < 0 then
		GameObject.Destroy(prefab.prefab:GetObj())
		return
	end
	local data = cachemap[prefab.prefabname]
	if data and not IsEquals(data.parent) then
		cachemap[prefab.prefabname] = nil
		return
	end
	if data and next(data.list) then
		if prefab.is_in_use then
			if prefab.index ~= data.useindex then
				data.list[data.useindex],data.list[prefab.index] = data.list[prefab.index],data.list[data.useindex]
			end
			if not data.list[prefab.index] then
				return
			end
			data.list[prefab.index].index = prefab.index
			prefab.index = data.useindex
			if not IsEquals(prefab.prefab.prefabObj) then
				-- prefab.prefab = CachePrefab.Create(prefab.prefabname, data.parent)
				return
			end
			prefab.prefab:SetObjName(data.useindex)
			prefab.is_in_use = false
			prefab.prefab:SetParent(data.parent)
			data.useindex = data.useindex - 1
		end
	end
end

-- 创建缓冲池
function CachePrefabManager.SubstepCachePrefab(prefabname, count, ishide)
	CachePrefabManager.Init()
	
	-- 确保初始化被执行
	if not cachemap[prefabname] then
		local pp = GameObject.New()
		pp.transform:SetParent(this.CacheRootNode)
		local rect = pp.gameObject:AddComponent(typeof(UnityEngine.RectTransform))
		rect.sizeDelta = {x=rect_width, y=rect_height}
		pp.transform.localScale = Vector3.one
		
		pp.name = prefabname
		if ishide then
			pp:SetActive(false)
		end
		cachemap[prefabname] = {}
		cachemap[prefabname].parent = pp.transform
		cachemap[prefabname].list = {}
		cachemap[prefabname].useindex = 0

		dt_cache_list[#dt_cache_list + 1] = prefabname
	end

	local ppp = cachemap[prefabname].parent
	local list = cachemap[prefabname].list
	local cur_count = #list
	for i = 1, count do
		local data = {}
		data.is_in_use = false
		data.last_in_use_time = 0
		data.prefabname = prefabname
		data.index = i + cur_count
		data.prefab = CachePrefab.Create(prefabname, ppp)
		data.prefab:SetObjName(data.index)
		list[#list + 1] = data
	end
end

-- 创建缓冲池
function CachePrefabManager.GetCacheList()
	return dt_cache_list
end
function CachePrefabManager.DelCacheList()
	dt_cache_list = {}
end