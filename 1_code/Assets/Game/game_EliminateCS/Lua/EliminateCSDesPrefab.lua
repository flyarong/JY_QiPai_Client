-- 创建时间:2019-05-14
local basefunc = require "Game/Common/basefunc"
EliminateCSDesPrefab=basefunc.class()
local M=EliminateCSDesPrefab
local  ins
M.name="EliminateCSDesPrefab"
M.des_id=""
M.des_num=""
M._isReCreat=""
function  M.Create(_id,_num,_isReCreat,parent)
    M.des_id=_id
    M.des_num=_num
    M._isReCreat=_isReCreat
    ins=M.New(parent)
    return  ins
end
function M:ctor(parent)
    self.parent =parent
    self.gameObject =newObject(M.name,self.parent)
    local tran = self.gameObject.transform
    local t= tran:Find("GameObject/Text"):GetComponent("Text")
    local img=tran:Find("GameObject/Image"):GetComponent("Image")
    img.sprite=GetTexture("csxxl_icon_" .. self.des_id)   
    t.text=self.des_num
    self.gameObject.transform:SetSiblingIndex(0)
    self.Gobj=self.gameObject.transform:Find("GameObject").transform
    --断线重连的时候，直接到具体位置
    if self._isReCreat==true then
        self.Gobj.localPosition =Vector3.zero
        self.gameObject.transform.parent.localPosition=Vector3.New(0, 0, 0) 
    else
        self:PlayAnimIn()     
    end
   
end
function M.Close()
    ins.des_id=nil
    ins.des_num=nil
    ins._isReCreat=nil
    GameObject.Destroy(ins.gameObject) 
end
function M:PlayAnimIn()
    self.gameObject.transform.parent.localPosition=Vector3.New(0, 0, 0)
    self.Gobj.localPosition = Vector3.New(-200, 0, 0)
    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:Append(self.Gobj:DOLocalMoveX(0, 0.3):SetEase(DG.Tweening.Ease.Linear))--OutBack
    seq:OnKill(     
        function()
            DOTweenManager.RemoveStopTween(tweenKey) 
            SafaSetTransformPeoperty( self.Gobj , "localPosition" , Vector3.zero) 
        end       
    )
end



