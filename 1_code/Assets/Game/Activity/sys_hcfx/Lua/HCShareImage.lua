-- 创建时间:2019-10-31
-- Panel:HCC
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

HCShareImage = basefunc.class()
local C = HCShareImage
C.name = "HCShareImage"

local bg_list = {"share_17_05","share_18_05","share_19_05","share_20_05","share_21_05"}
local tu1_list = {"share_17_01","share_18_01","share_19_01","share_20_01","share_21_01"}
local tu2_list = {"share_17_02","share_18_02","share_19_02","share_20_02","share_21_02"}
local tu3_list = {"share_17_03","share_18_03","share_19_03","share_20_03","share_21_03"}
local tu4_list = {"share_17_04","share_18_04","share_19_04","share_20_04","share_21_04"}
function C.Create(shareType, parm)
	return C.New(shareType, parm)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(shareType, parm)
    self.shareType = shareType
    self.parm = parm

	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

    self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")

    self.isRunMake = false
    self.loadHeadFinish = true
    self:RunMake()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	local ss = string.reverse(tostring(os.clock()))
	math.randomseed( tonumber(string.sub(ss, 1, 7)) ) -- 设置时间种子
	
	local a = math.random(1, #bg_list)
	local b = math.random(1, #tu1_list)
	local c = math.random(1, #tu2_list)
	local d = math.random(1, #tu3_list)
	local e = math.random(1, #tu4_list)
	self.bg_img.sprite = GetTexture(bg_list[a])
	self.tu1_img.sprite = GetTexture(tu1_list[b])
	self.tu2_img.sprite = GetTexture(tu2_list[c])
	self.tu3_img.sprite = GetTexture(tu3_list[d])
	self.tu4_img.sprite = GetTexture(tu4_list[e])
    self:EWM(self.ewm_img.mainTexture, ewmTools.getEwmDataWithPixel(self.parm.url, ShareHelper.size))
end

function C:MakeImage(imageName, call)
    self.imageName = imageName
    self.call = call
    self.isRunMake = true
    self:RunMake()
end
function C:RunMake()
    if not self.isRunMake or not self.loadHeadFinish then
        return
    end
    local pos1 = self.node1.position
    local pos2 = self.node2.position
    local s1 = self.camera:WorldToScreenPoint(pos1)
    local s2 = self.camera:WorldToScreenPoint(pos2)
    local x = s1.x
    local y = s1.y
    local w = s2.x - s1.x
    local h = s2.y - s1.y
    local canvas = AddCanvasAndSetSort(self.gameObject, 100)
    panelMgr:MakeCameraImgAsync(x, y, w, h, self.imageName, function ()
        destroy(canvas)
        Event.Brocast("ui_share_end")
        self:Close()
        if self.call then
            self.call()
        end
    end, false,false)
end
function C:Close()
	destroy(self.gameObject)
end

function C:EWM(texture, data)    
    if not texture or not data then
        return
    end
    local w = data.width
    local scale = math.floor(ShareHelper.size/w)
    local py = (ShareHelper.size-w*scale)/2
    py = math.floor(py)
    print(py .. " " .. w .. " " .. scale)
    local dots = data.data
    for i = 1, w do
        for j = 1, w do
            if dots[(i-1)*w + j] == 1 then
                texture:SetPixel(i-1+py, j-1+py, Color.New(0,0,0,1))
            else
                texture:SetPixel(i-1+py, j-1+py, Color.New(1,1,1,1))
            end
        end
    end
    texture:Apply()
end
