-- 创建时间:2021-02-04
-- RXCQPrefabManager 管理器

local basefunc = require "Game/Common/basefunc"
RXCQPrefabManager = {}
local M = RXCQPrefabManager
local this
local lister
local preload_index = 0
M.Prefabs = {}
M.Texture2Ds = {}
M.Max_Texture2Ds = {}

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
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
end

function M.Init(PrefabNode)
	M.Exit()
    this = RXCQPrefabManager
    this.PrefabNode = PrefabNode
    M.Max_Texture2Ds = {}
	MakeLister()
    AddLister()
end

function M.Exit()
	if this then
        preload_index = 0
		RemoveLister()
		this = nil
	end
end

function M.OnReConnecteServerSucceed()

end

--加载预制体
function M.PreLoadPrefabs()
    if gameRuntimePlatform == "Ios"   then
        local t = M.Prefabs
        local m_table = {__index = function(t,key)
            return newObject(key,this.PrefabNode)
        end
        }
        setmetatable(M.Prefabs,m_table)    
    else
        M.Prefabs[rxcq_prefab_list[preload_index]] = newObject(rxcq_prefab_list[preload_index],this.PrefabNode)
    end
end

--图片加载
function M.PreLoadTexture()
    local keys = {"hit","death","stand","attack","run","skill"}
    local i = preload_index - #rxcq_prefab_list
    for j = 1,#keys do
        if gameRuntimePlatform == "Ios"   then
            M.LoadTextureIos(rxcq_textrue2d_list[i],keys[j])
        else
            M.LoadTexture(rxcq_textrue2d_list[i],keys[j])
        end
    end
end

function M.PreLoad()
    preload_index = preload_index + 1
    if preload_index <= #rxcq_prefab_list then
        M.PreLoadPrefabs()
        return preload_index / (#rxcq_prefab_list + #rxcq_textrue2d_list)
    elseif preload_index <= #rxcq_prefab_list + #rxcq_textrue2d_list then
        M.PreLoadTexture()
        return preload_index / (#rxcq_prefab_list + #rxcq_textrue2d_list)
    end
end

function M.LoadTexture(str,key)
    for i = 1,100 do
        --图片是从0开始
        local texture = GetTexture(str.."_"..key.."_"..(i - 1))
        if texture then
            M.Texture2Ds[str] = M.Texture2Ds[str] or {}
            M.Max_Texture2Ds[str] = M.Max_Texture2Ds[str] or {}
            M.Texture2Ds[str][key] = M.Texture2Ds[str][key] or {}
            M.Max_Texture2Ds[str][key] = M.Max_Texture2Ds[str][key] or {}
            M.Max_Texture2Ds[str][key][#M.Max_Texture2Ds[str][key] + 1] = 1
            M.Texture2Ds[str][key][#M.Texture2Ds[str][key] + 1] = texture
        else
            return
        end
    end
end

function M.LoadTextureIos(str,key)
    for i = 1,100 do
        --图片是从0开始
        local max_le = M.GetTextureLength(str,key)
        if max_le and i <= max_le then
            M.Texture2Ds[str] = M.Texture2Ds[str] or {}
            M.Max_Texture2Ds[str] = M.Max_Texture2Ds[str] or {}
            M.Texture2Ds[str][key] = M.Texture2Ds[str][key] or {}
            M.Max_Texture2Ds[str][key] = M.Max_Texture2Ds[str][key] or {}
            M.Max_Texture2Ds[str][key][#M.Max_Texture2Ds[str][key] + 1] = 1
            if true then
                local t = M.Texture2Ds[str][key]
                local m_table = {__index = function(t,index)
                    return GetTexture(str.."_"..key.."_"..(index - 1))
                end
                }
                setmetatable(M.Texture2Ds[str][key],m_table)
            end
        else
            if M.Max_Texture2Ds[str] and M.Max_Texture2Ds[str][key] then
                dump(str,"<color=red>str</color>")
                dump(key,"<color=red>key</color>")
                dump(#M.Max_Texture2Ds[str][key],"<color=red>长度</color>")
            end
            return
        end
    end
end

function M.GetTextureLength(str,key)
    local config = {
        cxem5 = {
            hit = 3,
            death = 12,
            stand = 4,
        },
        djs5 = {
            hit = 2,
            death = 10,
            stand = 4,
        },
        js5 = {
            hit = 2,
            death = 8,
            stand = 4,
        },
        jxrc5 = {
            hit = 5,
            death = 10,
            stand = 4,
        },
        kljl5 = {
            hit = 3,
            death = 9,
            stand = 4,
        },
        klzj5 = {
            hit = 3,
            death = 9,
            stand = 4,
        },
        klzs5 = {
            hit = 3,
            death = 12,
            stand = 4,
        },
        stjg5 = {
            hit = 3,
            death = 8,
            stand = 4,
        },
        stxm5 = {
            hit = 4,
            death = 10,
            stand = 4,
        },
        sw5 = {
            hit = 3,
            death = 6,
            stand = 4,
        },
        ttf5 = {
            hit = 3,
            death = 10,
            stand = 4,
        },
        wmjz5 = {
            hit = 3,
            death = 9,
            stand = 4,
        },
        wmws5 = {
            hit = 3,
            death = 9,
            stand = 4,
        },
        wmys5 = {
            hit = 3,
            death = 8,
            stand = 4,
        },
        xeqc5 = {
            hit = 3,
            death = 10,
            stand = 4,
        },
        yzbai5 = {
            hit = 3,
            death = 10,
            stand = 4,
        },
        yzhei5 = {
            hit = 3,
            death = 10,
            stand = 4,
        },
        yzhong5 = {
            hit = 3,
            death = 10,
            stand = 4,
        },
        zmdx5 = {
            hit = 2,
            death = 7,
            stand = 4,
        },
        zmjz5 = {
            hit = 3,
            death = 8,
            stand = 4,
        },
        zmws5 = {
            hit = 2,
            death = 7,
            stand = 4,
        },
        fs1 = {
            death = 4,
            stand = 4,
            run = 8,
            skill = 7,
        },
        fs2 = {
            death = 4,
            stand = 4,
            run = 8,
            skill = 7,
        },
        ds1 = {
            death = 4,
            stand = 4,
            run = 8,
            skill = 7,
        },
        ds2 = {
            death = 4,
            stand = 4,
            run = 8,
            skill = 7,
        },
        zs1 = {
            death = 4,
            stand = 4,
            run = 8,
            attack = 7,
        },
        zs2 = {
            death = 4,
            stand = 4,
            run = 8,
            attack = 7,
        },
    }
    return config[str][key]
end

function M.GetPrefab(name)
    return M.Prefabs[name]
end