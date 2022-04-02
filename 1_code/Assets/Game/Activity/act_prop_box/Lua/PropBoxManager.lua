-- 创建时间:2018-11-06
PropBoxManager = {}
local M = PropBoxManager
package.loaded["Game.CommonPrefab.Lua.OpenBoxrPanel"] = nil
require "Game.CommonPrefab.Lua.OpenBoxrPanel"
local lister
local this
local function MakeLister()
	lister = {}
	lister["OpenBox_panel"] = this.OpenBox_panel
end

local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end
local function RemoveLister()
    if lister == nil then return end
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end
local function InitData()
	
end
function M.Init()
    M.Exit()
    this=M
    InitData()
    MakeLister()
	AddLister()
    return this
end

function M.Exit()
    if this then
        RemoveLister()
        m_data=nil
        this=nil
    end
end

function M.OpenBox_panel(data)
    OpenBoxrPanel.Create(data)
end