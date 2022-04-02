-- 创建时间:2019-05-14
local basefunc = require "Game/Common/basefunc"
EliminateBSDesPrefab=basefunc.class()
local M=EliminateBSDesPrefab
local  ins
M.name="EliminateBSDesPrefab"
M.des_id=""
M.des_num=""
M._isReCreat=""
function  M.Create(_id,_num,isBshj,_isReCreat,parent)
    M.des_id=_id
    M.des_num=_num
    M._isReCreat=_isReCreat
    M.isBshj = isBshj
    ins=M.New(parent)
    return  ins
end
function M:ctor(parent)
	ExtPanel.ExtMsg(self)

    self.parent =parent
    self.gameObject =newObject(M.name,self.parent)
    local tran = self.gameObject.transform
    local t= tran:Find("GameObject/Text"):GetComponent("Text")
    local img=tran:Find("GameObject/Image"):GetComponent("Image")
    self.tx_1 = tran:Find("GameObject/@tx_1").gameObject
    self.tx_2 = tran:Find("GameObject/@tx_2").gameObject
    self.tx_3 = tran:Find("GameObject/@tx_3").gameObject
    if M.isBshj then
        img.sprite= EliminateBSObjManager.bshj_item_obj["bshj_icon_desc"]
        t.text = "宝石幻境"
    else
        img.sprite= EliminateBSObjManager.item_obj["sdbgj_icon_dj" .. self.des_id]
        t.text=self.des_num
    end
    self.gameObject.transform:SetSiblingIndex(0)
    self.Gobj=self.gameObject.transform:Find("GameObject").transform
    if self.des_id < 200 then
        self.tx_1.gameObject:SetActive(false) 
        self.tx_2.gameObject:SetActive(false) 
        self.tx_3.gameObject:SetActive(false) 
    else
        if (self.des_id >= 200) and (self.des_id < 210) then
            self.tx_1.gameObject:SetActive(true) 
            self.tx_2.gameObject:SetActive(false) 
            self.tx_3.gameObject:SetActive(false) 
        elseif (self.des_id >= 210) and (self.des_id < 220) then
            self.tx_1.gameObject:SetActive(false) 
            self.tx_2.gameObject:SetActive(true) 
            self.tx_3.gameObject:SetActive(false) 
        elseif self.des_id >= 220 then
            self.tx_1.gameObject:SetActive(false) 
            self.tx_2.gameObject:SetActive(false) 
            self.tx_3.gameObject:SetActive(true) 
        end
    end
    
    --断线重连的时候，直接到具体位置
    if self._isReCreat==true then
        self.Gobj.localPosition =Vector3.zero
        self.gameObject.transform.parent.localPosition=Vector3.New(0, 0, 0) 
    else
        self:PlayAnimIn()     
    end
   
end
function M.Close()
    ins:MyExit()
end
function M:MyExit()
	self.des_id=nil
    self.des_num=nil
    self._isReCreat=nil

	local img=self.transform:Find("GameObject/Image"):GetComponent("Image")
	img.sprite = nil

    destroy(self.gameObject) 
end

function M:PlayAnimIn()
    self.gameObject.transform.parent.localPosition=Vector3.New(0, 0, 0)
    self.Gobj.localPosition = Vector3.New(-200, 0, 0)
    local seq = DoTweenSequence.Create()
    seq:Append(self.Gobj:DOLocalMoveX(0, 0.3):SetEase(DG.Tweening.Ease.Linear))--OutBack
    seq:OnForceKill(     
        function()
            SafaSetTransformPeoperty( self.Gobj , "localPosition" , Vector3.zero) 
        end       
    )
end



