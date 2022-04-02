-- 创建时间:2020-06-02
-- Panel:Act_020_JBBXPanel
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

Act_020_JBBXPanel = basefunc.class()
local C = Act_020_JBBXPanel
C.name = "Act_020_JBBXPanel"
local M = Act_020_JBBXManager

local State = {
	ST_None = "ST_None",--无特殊状态
	ST_Switching = "ST_Switching",--切换宝箱
}

function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["CJLB_on_background_msg"] = basefunc.handler(self,self.MyExit)
    self.lister["model_cjlb_bx_change_msg"] = basefunc.handler(self,self.on_model_cjlb_bx_change_msg)
    self.lister["CJLB_All_BX_Data_is_Init_msg"] = basefunc.handler(self,self.on_CJLB_All_BX_Data_is_Init_msg)
    self.lister["model_cjlb_unrealy_change_msg"] = basefunc.handler(self,self.on_model_cjlb_unrealy_change_msg)
    self.lister["CJLB_on_AssetChange_msg"] = basefunc.handler(self,self.on_CJLB_on_AssetChange_msg)
    
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	M.Query_BXData_Timer(false)
	self:CloseItemPrefab()
	self:KillTween()
	if self.seq1 then
		self.seq1:Kill()
		self.seq1 = nil
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self.cur_state = State.ST_None
	self.config = M.GetConfig()
	dump(self.config,"<color>+++++++++++self.config+++++++++++++</color>")
	self.BX_list = {}
	self.BX_list[#self.BX_list + 1] = self.BX_by_img
	self.BX_list[#self.BX_list + 1] = self.BX_hj_img
	self.BX_list[#self.BX_list + 1] = self.BX_zs_img
	self.index = 2--预制体默认选中黄金宝箱
	self.pos1 = self.BX_hj_img.transform.localPosition
	self.pos2 = self.BX_zs_img.transform.localPosition
	self.pos3 = self.BX_by_img.transform.localPosition


	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.transform.anchorMin = Vector2.New(0,0)
	self.transform.anchorMax = Vector2.New(1,1)
	self.transform.offsetMax = Vector2.New(0,0)
	self.transform.offsetMin = Vector2.New(0,0)
end

function C:InitUI()
	EventTriggerListener.Get(self.exit_btn.gameObject).onClick = basefunc.handler(self, self.on_ExitClick)
	EventTriggerListener.Get(self.left_btn.gameObject).onClick = basefunc.handler(self, self.on_LeftClick)
	EventTriggerListener.Get(self.right_btn.gameObject).onClick = basefunc.handler(self, self.on_RightClick)
	EventTriggerListener.Get(self.buy_btn.gameObject).onClick = basefunc.handler(self, self.on_BuyClick)
	M.Query_AllBXData()--请求3种宝箱的数据,以判断打开panel时默认显示哪个宝箱
	self:isFingerShow()
end

function C:on_CJLB_All_BX_Data_is_Init_msg()
	self:GetDefine()
end

function C:GetDefine()
	local index = M.GetDefineBX()--获取默认选中宝箱的index
	dump(index,"<color>++++++++++++++GetDefineBX+++++++++++</color>")
	if index == self.index then
		self:MyRefresh()
	elseif index > self.index then
		self:on_RightClick()
	elseif index < self.index then
		self:on_LeftClick()
	end
end


function C:MyRefresh()
	M.OpenPanelToQueryData(self.config[self.index].ID)
	M.Query_BXData_Timer(true,self.config[self.index].ID)
	self:CreateItemPrefab()
end

function C:on_ExitClick()
	self:MyExit()
end

function C:on_LeftClick()
	self:isFingerShow()
	if self.cur_state ~= State.ST_Switching then 
		dump(self.index,"<color>++++++++++on_LeftClick+++++++++++++</color>")
		self.cur_state = State.ST_Switching
		self.index = self.index - 1
		self:CheakIndex()
		self:DoTween()
		self:CreateItemPrefab()
		M.OpenPanelToQueryData(self.config[self.index].ID)
		M.Query_BXData_Timer(true,self.config[self.index].ID)
	else
		dump("<color>++++当前状态为"..self.cur_state.."+++++</color>")
	end
end

function C:on_RightClick()
	self:isFingerShow()
	if self.cur_state ~= State.ST_Switching then
		dump(self.index,"<color>++++++++++on_RightClick+++++++++++++</color>")
		self.cur_state = State.ST_Switching
		self.index = self.index + 1
		self:CheakIndex()
		self:DoTween()
		self:CreateItemPrefab()
		M.OpenPanelToQueryData(self.config[self.index].ID)
		M.Query_BXData_Timer(true,self.config[self.index].ID)
	else
		dump("<color>++++当前状态为"..self.cur_state.."+++++</color>")
	end
end

function C:CheakIndex()
	if self.index == 0 then 
		self.index = #self.BX_list
	end
	if self.index > #self.BX_list then 
		self.index = 1
	end
end

function C:on_BuyClick()
	dump(self.config[self.index],"<color>++++++++++++buy+++++++++++++</color>")
	self:BuyShop(self.config[self.index].gift_id)
end

function C:BuyShop(shopid)
	dump(shopid)
    local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
    dump(MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid))
    if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        ServiceGzhPrefab.Create({desc="请前往公众号获取"})
    else
        PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
    end
end

--虚假数据跑马灯
function C:on_model_cjlb_unrealy_change_msg()
	local str = ""
	if M.GetUnrealyAwardName() == 1 then
		str = "<color=#002DFF>白银宝箱</color>"
	elseif M.GetUnrealyAwardName() == 2 then
		str = "<color=#E900FF>黄金宝箱</color>"
	elseif M.GetUnrealyAwardName() == 3 then
		str = "<color=#FF0018>钻石宝箱</color>"
	end
	local award = self.config[M.GetUnrealyAwardName()].award_descs[M.GetUnrealyAwardID()] .. "鲸币"

	self.Lantern2_txt.text = "恭喜玩家<color=#50c326>"..(M.GetUnrealyPlayerName() or "").."</color>在<color=#fafafa>"..str.."</color>中抽出<color=#20e6d6>"..award.."</color>"
	self.seq1 = DoTweenSequence.Create()
	self.seq1:Append(self.Lantern.transform:DOLocalMoveY(57.7,1.5))
	self.seq1:OnKill(function ()
			self.Lantern1_txt.text = self.Lantern2_txt.text
			self.Lantern.transform.localPosition = Vector3.New(0,0,0)
	end)
end


function C:DoTween()
	self:KillTween()
	dump(self.index,"<color>++++++++++++++DoTween+++++++++++++</color>")
	self.seq = DoTweenSequence.Create()
	if self.BX_list[self.index] == self.BX_by_img then
		self.seq:Append(self.BX_list[1].transform:DOLocalMove(self.pos1,0.5):SetEase(DG.Tweening.Ease.OutQuart))
		self.seq:Join(self.BX_list[1].transform:DOScale(Vector3.New(1.5,1.5,1.5), 0.5))
		self.seq:Join(self.BX_list[1].transform:GetComponent("CanvasGroup"):DOFade(1, 0.5))
		self.seq:Join(self.BX_list[2].transform:DOLocalMove(self.pos2,0.5):SetEase(DG.Tweening.Ease.OutQuart))
		self.seq:Join(self.BX_list[2].transform:DOScale(Vector3.New(0.5,0.5,1),0.25))
		self.seq:Join(self.BX_list[2].transform:DOScale(Vector3.New(0.7,0.7,1),0.25))
		self.seq:Join(self.BX_list[2].transform:GetComponent("CanvasGroup"):DOFade(130/255, 0.5))
		self.seq:Join(self.BX_list[3].transform:DOLocalMove(self.pos3,0.5):SetEase(DG.Tweening.Ease.OutQuart))
		self.seq:Join(self.BX_list[3].transform:DOScale(Vector3.New(0.7,0.7,1),0.5))
		self.seq:Join(self.BX_list[3].transform:GetComponent("CanvasGroup"):DOFade(130/255, 0.5))
	elseif self.BX_list[self.index] == self.BX_hj_img then
		self.seq:Append(self.BX_list[1].transform:DOLocalMove(self.pos3,0.5):SetEase(DG.Tweening.Ease.OutQuart))
		self.seq:Join(self.BX_list[1].transform:DOScale(Vector3.New(0.7,0.7,1), 0.5))
		self.seq:Join(self.BX_list[1].transform:GetComponent("CanvasGroup"):DOFade(130/255, 0.5))
		self.seq:Join(self.BX_list[2].transform:DOLocalMove(self.pos1,0.5):SetEase(DG.Tweening.Ease.OutQuart))
		self.seq:Join(self.BX_list[2].transform:DOScale(Vector3.New(1.5,1.5,1.5), 0.5))
		self.seq:Join(self.BX_list[2].transform:GetComponent("CanvasGroup"):DOFade(1, 0.5))
		self.seq:Join(self.BX_list[3].transform:DOLocalMove(self.pos2,0.5):SetEase(DG.Tweening.Ease.OutQuart))
		self.seq:Join(self.BX_list[3].transform:DOScale(Vector3.New(0.5,0.5,1),0.25))
		self.seq:Join(self.BX_list[3].transform:DOScale(Vector3.New(0.7,0.7,1),0.25))
		self.seq:Join(self.BX_list[3].transform:GetComponent("CanvasGroup"):DOFade(130/255, 0.5))
	elseif self.BX_list[self.index] == self.BX_zs_img then
		self.seq:Append(self.BX_list[1].transform:DOLocalMove(self.pos2,0.5):SetEase(DG.Tweening.Ease.OutQuart))
		self.seq:Join(self.BX_list[1].transform:DOScale(Vector3.New(0.5,0.5,1),0.25))
		self.seq:Join(self.BX_list[1].transform:DOScale(Vector3.New(0.7,0.7,1),0.25))
		self.seq:Join(self.BX_list[1].transform:GetComponent("CanvasGroup"):DOFade(130/255, 0.5))
		self.seq:Join(self.BX_list[2].transform:DOLocalMove(self.pos3,0.5):SetEase(DG.Tweening.Ease.OutQuart))
		self.seq:Join(self.BX_list[2].transform:DOScale(Vector3.New(0.7,0.7,1), 0.5))
		self.seq:Join(self.BX_list[2].transform:GetComponent("CanvasGroup"):DOFade(130/255, 0.5))
		self.seq:Join(self.BX_list[3].transform:DOLocalMove(self.pos1,0.5):SetEase(DG.Tweening.Ease.OutQuart))
		self.seq:Join(self.BX_list[3].transform:DOScale(Vector3.New(1.5,1.5,1.5), 0.5))
		self.seq:Join(self.BX_list[3].transform:GetComponent("CanvasGroup"):DOFade(1, 0.5))
	end
	self.seq:AppendCallback(function ()
		self.cur_state = State.ST_None
	end)
end

function C:KillTween()
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
end

--[[--达到随机显示效果
function C:Shuffle(t)
    if type(t) ~= "table" then
        return
    end
    local tab = {}
    local temp = {}
    for i=1,#t do
    	table.insert(temp,t[i])
    end
    local index = 1
    while #temp ~= 0 do
        local n = math.random(0,#temp)
        if temp[n] ~= nil then
            tab[index] = temp[n]
            table.remove(temp,n)
            index = index + 1
        end
    end
    return tab
end--]]

function C:CreateItemPrefab()
	self:CloseItemPrefab()
	--[[local tab = self:Shuffle(self.config[self.index].award_ids)
	for i=1,#tab do
		local pre = Act_020_JBBXItemBase.Create(self.Content.transform,self.index,tab[i])
		self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
	end--]]
	local tab = self.config[self.index].award_ids
	for i=#tab,1,-1 do
		local pre = Act_020_JBBXItemBase.Create(self.Content.transform,self.index,tab[i])
		self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
	end
end

function C:CloseItemPrefab()
	if self.spawn_cell_list then
		for k,v in ipairs(self.spawn_cell_list) do
			v:MyExit()
		end
	end
	self.spawn_cell_list = {}
end

function C:on_model_cjlb_bx_change_msg(id)
	local data = M.GetCurBXData()
	dump(data,"<color>+++++++++++++++++++++++++++++</color>")
	dump(id,"<color>+++++++++++++++++++++++++++++</color>")
	local remain = 3 - data[id].exchange_count
	self.remain_time_txt.text = "剩余购买"..remain.."次"
	self.buy_txt.text = self.config[self.index].cost_text.."抽取"
	self.bx_type_img.sprite = GetTexture(self.config[self.index].type_img)
	self.bx_type_img:SetNativeSize()
	if remain == 0 then
		self.buy_btn.gameObject:SetActive(false)
		self.no_time_img.gameObject:SetActive(true)
	else	
		self.buy_btn.gameObject:SetActive(true)
		self.no_time_img.gameObject:SetActive(false)
	end
	Timer.New(function()
		Event.Brocast("CJLB_itembase_change_msg",data,self.config[self.index].ID)
	end, 0.2, 1, false,false):Start()
end

function C:isFingerShow()
	if PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."cjlb") == 0 then
	else
		self.finger.gameObject:SetActive(false)
	end
	PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."cjlb",os.time())
end

function C:on_CJLB_on_AssetChange_msg()
	M.query_data(self.config[self.index].ID)
end