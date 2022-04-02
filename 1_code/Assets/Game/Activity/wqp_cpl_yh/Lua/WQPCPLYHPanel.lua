-- 创建时间:2020-06-18
-- Panel:WQPCPLYHPanel
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

WQPCPLYHPanel = basefunc.class()
local C = WQPCPLYHPanel
C.name = "WQPCPLYHPanel"
local M = WQPCPLYHManager
local task_id = 21543

function C.Create(parm)
	return C.New(parm)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
	self.lister["AssetChange"] = basefunc.handler(self,self.OnAssetChange)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	C.gotoby_btn = nil
	if self.huxiTipGoBY then
		self.huxiTipGoBY.Stop()
	end
    self.huxiTipGoBY = nil
    
    if self.fixStuck then
		self.fixStuck:Stop()
		self.fixStuck = nil
	end
	self:RemoveListener()
	-- destroy(self.gameObject)
end

function C:ctor(parm)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	self.parm = parm
    self.data = parm.data
    if parm.ui == "DdzFreeClearing" then
        if self.data.is_game_over then
	    	self:GotoBYGameInWQP()
        else
            if not self.fixStuck then
                self.fixStuck = Timer.New(function()
	            	self:GotoBYGameInWQP()
                end, 5.05, 1, false)
                self.fixStuck:Start()
            end
        end
	end
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	-- if not IsEquals(self.gameObject) then return end
end

--玩棋牌平台：前往捕鱼，只在失败对局后才弹出
function C:GotoBYGameInWQP()

	dump(self.data, "<color=white>AAAAAAAAAAAAAAAAAAAAAAAAAA</color>")
	if not self.data or self.data.isWin ~= false then return end
    local a, b = GameButtonManager.RunFun({ gotoui = "sys_qx", _permission_key = "actp_own_task_" .. task_id, is_on_hint = true }, "CheckCondition")
	if a and not b then return end
	if IsEquals(C.gotoby_btn) then return end
	local parent = GameObject.Find("DdzFreeClearing_New")
	if not IsEquals(parent) then return end
	parent = parent.transform:Find("@anniu_node")
	if not IsEquals(parent) then return end

	local gotoby_btn = newObject("wqp_cpl_yh_gotoby_btn",parent.transform)
	local ui_table = {}
	gotoby_btn.transform:SetAsFirstSibling()
	ui_table.gotoby_btn = gotoby_btn.transform:GetComponent("Button")
	ui_table.gotoby_btn.gameObject:SetActive(true)
	ui_table.gotobyImg=ui_table.gotoby_btn.transform:Find("Image")
	ui_table.gotobyText = ui_table.gotobyImg.transform:Find("Text"):GetComponent("Text")

	self.huxiTipGoBY = CommonHuxiAnim.Go(ui_table.gotobyImg.gameObject,1)
	self.huxiTipGoBY.Stop()
	self.huxiTipGoBY.Start()
	local is_GotoBY_GetAward = false
	local task_data = GameTaskModel.GetTaskDataByID(task_id)
	if task_data and task_data.award_status == 2 then
		is_GotoBY_GetAward = true
	end

	ui_table.gotoby_btn.onClick:AddListener(function()
		self:GotoBY(is_GotoBY_GetAward)
	end)
	if not is_GotoBY_GetAward then --首次领取
		ui_table.gotobyText.text = "送1000鱼币"
	else --已经领取
		ui_table.gotobyText.text = "大额福卡"
	end
	for k,v in pairs(ui_table) do
		v = nil
	end
	ui_table = nil
	C.gotoby_btn = gotoby_btn
end

--玩棋牌平台：跳转捕鱼
function C:GotoBY(is_gotoby_getaward)
    print("<color=yellow>跳转捕鱼</color>") 
    local quit_game = function(data)
        dump(data,"???????????????????????")
        if data.result == 0 then
            MainLogic.ExitGame()
            if not is_gotoby_getaward then --首次跳转
            	--根据鲸币确定 g_id
                local  g_id = 1
                if MainModel.UserInfo.jing_bi<=199999 then
                    g_id = 1
                elseif MainModel.UserInfo.jing_bi>199999 and MainModel.UserInfo.jing_bi<2000000 then
                    g_id = 2
                else
                    g_id = 3
                end
                local get_award = function()
                    Network.SendRequest("get_task_award", { id = task_id })
                end
                GameManager.CommonGotoScence({gotoui = "game_Fishing",p_requset = {id = g_id},goto_scene_parm={game_id = g_id},enter_scene_call=get_award}, function ()
                    PlayerPrefs.SetInt("FishRapidBeginKey" .. MainModel.UserInfo.user_id, g_id)
                end)
            else
                GameManager.GotoUI({gotoui = "game_FishingHall"})
            end

        else
            HintPanel.ErrorMsg(data.result)
        end
    end
    if Network.SendRequest("fg_quit_game",nil,"退出报名",quit_game)  then
        DdzFreeClearing.Close()
    else
        DDZAnimation.Hint(2, Vector3.New(0, -350, 0), Vector3.New(0, 0, 0))
    end
      
end
