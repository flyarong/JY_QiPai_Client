-- 创建时间:2019-05-14
local basefunc = require "Game/Common/basefunc"
EliminateDesPrefab=basefunc.class()
local  M=EliminateDesPrefab
local  ins
M.name="EliminateDesPrefab"
M.des_id=""
M.des_num=""
M._isReCreat=""
function  M.Create(_id,_num,_isReCreat)
    M.des_id=_id
    M.des_num=_num
    M._isReCreat=_isReCreat
     ins=M.New()
     return  ins
end
function M:ctor()
    self.parent = GameObject.Find("Canvas/GUIRoot/EliminateInfoPanel/bgs/bg/Viewport/@TaskNode").transform
    -- print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>DESDESDES")
    self.gameObject = newObject(M.name, self.parent)
    local tran = self.gameObject.transform
    local t= tran:Find("GameObject/Text"):GetComponent("Text")
    local img=tran:Find("GameObject/Image"):GetComponent("Image")
    img.sprite=GetTexture("xxl_icon_" .. self.des_id)
    
    t.text=self.des_num
    if self.des_num=="同类暴击" or self.des_num=="全屏暴击" then
    t.transform.localScale=Vector3.New(0.6,0.6,1)
    end
    self.gameObject.transform:SetSiblingIndex(0)
    self.Gobj=self.gameObject.transform:Find("GameObject").transform
    if self._isReCreat==1 then
        self.gameObject.transform.parent = GameObject.Find("Canvas/GUIRoot/EliminateInfoPanel/bgs/bg/Viewport/@TaskNode").transform       
        self.Gobj.localPosition =Vector3.zero
        self.gameObject.transform.parent.localPosition=Vector3.New(0, 0, 0) 
    else
        self:PlayAnimIn()     
    end
   

end
function M.Close()
    --print("关闭》》》》》》》》》》》》》》》》》》》》")
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
    seq:Append(self.Gobj:DOLocalMoveX(0, EliminateModel.GetTime(EliminateModel.cfg.time.eliminate_despfb_into_time)):SetEase(DG.Tweening.Ease.Linear))--OutBack
    seq:OnKill(     
        function()--这里报过异常
            DOTweenManager.RemoveStopTween(tweenKey) 
            SafaSetTransformPeoperty( self.Gobj , "localPosition" , Vector3.zero) 
        end
        
    )
end



