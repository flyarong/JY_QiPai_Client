-- 创建时间:2019-05-16
-- 创建时间:2019-05-14
local basefunc = require "Game/Common/basefunc"
EliminateButtonPrefab=basefunc.class()
local  M=EliminateButtonPrefab
local  ins
M.name="EliminateButtonPrefab"
--图片ID
M.icon_id=1
--钱
M.money=0
function  M.Create(_id,_money)
    M.icon_id=_id
    M.money=_money
    ins=M.New()
    return  ins
end
--加钱按钮
function M:OnAddOnClick()
     self.money=self.money+50
     print("<color=yellow>-----你点击了加-------</color>")
     self:ReFresh()  
end
function M:OnReduOnClick()
    if (self.money-50)<0 then
        self.money=0
    else    
        self.money=self.money-50    
    end
    self:ReFresh()
end
--刷新单个押注
function M:eliminate_change_yazhu_one(_,data)
     self.gameObject.transform:Find("Text"):GetComponent("Text").text=data
     self.shanguang:Stop()
     self.shanguang:Play()
     Event.Brocast("eliminate_refresh_yazhu", "eliminate_refresh_yazhu", {[1]=self.icon_id,[2]=data})
end

function M:ctor()
    self.money=M.money
    self.icon_id=M.icon_id
    --self.parent = GameObject.Find("Canvas/LayerLv4/EliminateInfoPanel/Viewport/@TaskNode").transform
    self.parent = GameObject.Find("Canvas/GUIRoot/EliminateMoneyPanel/Viewport/layoutgroup").transform
    self.gameObject = newObject(M.name, self.parent)
    local tran = self.gameObject.transform
    local img=tran:Find("Image"):GetComponent("Image")
    local t=tran:Find("Text"):GetComponent("Text")
    self.shanguang=self.gameObject.transform:Find("shanguang"):GetComponent("ParticleSystem")
    img.sprite=GetTexture("xxl_icon_" .. self.icon_id)
    t.text=self.money
    self:eliminate_change_yazhu_one(_,self.money)
    Event.AddListener("eliminate_quit_game",basefunc.handler(self,self.Close))      
end

function M:Close()
    Event.RemoveListener("eliminate_quit_game",basefunc.handler(self,self.Close)) 
    GameObject.Destroy(self.gameObject)
end






