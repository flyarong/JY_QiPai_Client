local basefunc = require "Game.Common.basefunc"
VIPPayPrefab = basefunc.class()
local C = VIPPayPrefab
C.name = "VIPPayPrefab"
local instance
local ExtM = VIPExtManager
local HGImagelist={
	"vip_tq_icon_hz1",
	"vip_tq_icon_hz2",
	"vip_tq_icon_hz3",
	"vip_tq_icon_hz4",
	"vip_tq_icon_hz5",
	"vip_tq_icon_hz6",
	"vip_tq_icon_hz7",
	"vip_tq_icon_hz8",
	"vip_tq_icon_hz9",
    "vip_tq_icon_hz10",
    "vip_tq_icon_hz11",
    "vip_tq_icon_hz12",
}

function C.Create(parent)
    if instance then
        C.Close()
    end
    instance = C.New(parent)
	return instance
end

function C.Close(  )
    if instance then
        instance:Exit()
    end
end

function C.Refresh(  )
    if instance then
        instance:MyRefresh()
    end
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_vip_upgrade_change_msg"] = basefunc.handler(self, self.model_vip_upgrade_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:Exit()
    self:RemoveListener()
    destroy(self.gameObject)    
    self.data = nil
    self.cfg = nil
    instance = nil
end

function C:ctor(parent)
    self:MakeLister()
    self:AddMsgListener()
	local obj = newObject(C.name, parent.transform)
	self.gameObject = obj
	self.transform = obj.transform
    self.transform.localPosition = Vector3.zero
    LuaHelper.GeneratingVar(obj.transform, self)
    self.vip_tq_btn.onClick:AddListener(
        function()
            -- PayPanel.Close()
            GameManager.GotoUI({gotoui="vip", goto_scene_parm="VIP2"})
        end
    )
    self:MyRefresh()
end

function C:MyRefresh(  )
    self.data = VIPManager.get_vip_data()
    dump(self.data, "<color=yellow>vip 数据</color>")
    if not self.data or not IsEquals(self.gameObject) then return end
    self.cfg = VIPManager.GetVIPCfgByType(VIP_CONFIG_TYPE.dangci)

    self.slider = self.transform:Find("Slider"):GetComponent("Slider")
    if  self.data.vip_level==0 then 
        self.transform:Find("Image (1)"):GetComponent("Image").sprite=GetTexture(HGImagelist[1])
    else
        self.transform:Find("Image (1)"):GetComponent("Image").sprite=GetTexture(HGImagelist[self.data.vip_level])    
    end
    self.cur_vip_txt.text = "VIP" .. self.data.vip_level
    if self.data.vip_level < ExtM.GetUserMaxVipLevel() then 
        
        local now_process
        local need_process

        if self.cfg[self.data.vip_level + 1].total then
            now_process = self.data.now_charge_sum / 100
            need_process = self.cfg[self.data.vip_level + 1].total
            self.Rect.gameObject:SetActive(true)
            self.Rect2.gameObject:SetActive(true)
            self.tips_txt.gameObject:SetActive(false)
        else
            now_process = self.data.treasure_value
            need_process = self.cfg[self.data.vip_level + 1].cfz
            self.Rect.gameObject:SetActive(false)
            self.Rect2.gameObject:SetActive(false)
            self.tips_txt.gameObject:SetActive(true)
        end

        local process = now_process / need_process
        if process > 1 then
            process = 1
        end
        self.progress_txt.text = now_process .. "/" .. need_process
        self.slider.value = process == 0 and 0 or 0.95 * process + 0.05
        self.money_txt.text = need_process - now_process
        self.vip_txt.text = "VIP" .. (self.data.vip_level + 1)
    else
        self.slider.value = 1
        self.progress_txt.text = "MAX"
        self.Rect.gameObject:SetActive(false)
        self.Rect2.gameObject:SetActive(false)
        self.tips_txt.gameObject:SetActive(false)
    end
end

function C:model_vip_upgrade_change_msg(data)
    dump(data, "<color=yellow>model_vip_upgrade_change_msg</color>")
    self:MyRefresh()
end