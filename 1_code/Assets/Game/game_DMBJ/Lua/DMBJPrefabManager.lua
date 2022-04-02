-- 创建时间:2020-12-02
-- DMBJPrefabManager 管理器

local basefunc = require "Game/Common/basefunc"
DMBJPrefabManager = {}
local M = DMBJPrefabManager
local this
local lister

local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end

local function MakeLister()
    lister = {}    
end

function M.Init()
	M.Exit()
	this = DMBJPrefabManager
	this.m_data = {}
	MakeLister()
    AddLister()
end

function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function M.GetRoot()
    M.root = M.root or GameObject.Find("GameObject")
    if IsEquals(M.root) then 
        return M.root.transform
    else
        
    end
    return M.root
end

M.Prefabs = {
    ParmItem = newObject("DMBJItem",M.GetRoot()),
    item_1 = GetTexture("dmbj_icon_qtss"),
    item_2 = GetTexture("dmbj_icon_syyp"),
    item_3 = GetTexture("dmbj_icon_gx"),
    item_4 = GetTexture("dmbj_icon_zgbs"),
    item_5 = GetTexture("dmbj_icon_smty"),
    item_6 = GetTexture("dmbj_icon_fhd"),
    item_7 = GetTexture("dmbj_icon_klt"),
    item_8 = GetTexture("dmbj_icon_hjgd"),
    item_9 = GetTexture("dmbj_icon_ljld"),
    item_10 = GetTexture("dmbj_icon_mjf"),
    item_1_liang = GetTexture("dmbj_icon_qtss2"),
    item_2_liang = GetTexture("dmbj_icon_syyp2"),
    item_3_liang = GetTexture("dmbj_icon_gx2"),
    item_4_liang = GetTexture("dmbj_icon_zgbs2"),
    item_5_liang = GetTexture("dmbj_icon_smty2"),
    item_6_liang = GetTexture("dmbj_icon_fhd2"),
    item_7_liang = GetTexture("dmbj_icon_klt2"),
    item_8_liang = GetTexture("dmbj_icon_hjgd2"),
    item_9_liang = GetTexture("dmbj_icon_ljld2"),
    item_10_liang = GetTexture("dmbj_icon_mjf2"),
}

function M.SetPos2Map(pos,Prefab)
    M.Pos2Map = M.Pos2Map or {}
    M.Pos2Map[pos] = Prefab
end

function M.GetPrefabByPos()

end

function M.CreateItem(parm,pos)
    local b = DMBJPrefab.Create(parm,pos)
    b:SetIsLiang(true)
    return b
end
