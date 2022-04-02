-- 创建时间:2019-05-14
local basefunc = require "Game/Common/basefunc"
EliminateSHDesPrefab=basefunc.class()
local M=EliminateSHDesPrefab
local  ins
M.name="EliminateSHDesPrefab"
M.des_id=""
M.des_num=""
M._isReCreat=""
function  M.Create(_id,_num,_isReCreat,parent,hero_del)
    M.des_id=_id
    M.des_num=_num
    M._isReCreat=_isReCreat
    ins=M.New(parent,hero_del)
    return  ins
end
function M:ctor(parent,hero_del)
    self.parent =parent
    self.gameObject =newObject(M.name,self.parent)
    local tran = self.gameObject.transform
    local t= tran:Find("GameObject/Text"):GetComponent("Text")
    local img=tran:Find("GameObject/Image"):GetComponent("Image")
    img.sprite=GetTexture("shxxl_icon_" .. self.des_id)   
    t.text=self.des_num
    if hero_del then
        if hero_del == 2 then
            t.text = "兄弟无数"
        elseif hero_del == 3 then
            t.text = "大开杀戒"
        end
        t.fontSize = 30
    end
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



